#!/usr/bin/env python3
import sys
import glob
import yaml
import urllib.parse
import urllib.request
import urllib.error
import concurrent.futures

# Leap 15.3's *-Current.* names need two hops: to *-3-*-Media, then to the build.
MAX_REDIRECTS = 2

class NoRedirectHandler(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None

def extract_urls(data):
    urls = []
    if isinstance(data, dict):
        for k, v in data.items():
            if k in ('primary_link', 'url') and isinstance(v, str) and v.startswith('/'):
                urls.append(v)
            else:
                urls.extend(extract_urls(v))
    elif isinstance(data, list):
        for item in data:
            urls.extend(extract_urls(item))
    return urls

def test_url(url, opener):
    full_url = url if url.startswith('http') else 'https://download.opensuse.org' + url
    host = urllib.parse.urlsplit(full_url).hostname

    is_sha = any(ext in full_url.lower() for ext in ['.sha256', '.sha512'])
    expected_status = '200' if is_sha else '200 or a redirect to a mirror'

    # A redirect to the same host resolves an alias such as Tumbleweed's
    # *-Current.* names, so check where it leads. A redirect to another host
    # hands the download to a mirror and is accepted as before.
    target = full_url
    to_mirror = False
    for _ in range(MAX_REDIRECTS + 1):
        req = urllib.request.Request(target, method='HEAD')
        location = None
        try:
            with opener.open(req, timeout=10) as res:
                status = res.status
        except urllib.error.HTTPError as e:
            status = e.code
            location = e.headers.get('Location')
            e.close()
        except urllib.error.URLError as e:
            return url, False, f"Network Error: {e.reason}", expected_status
        except Exception as e:
            return url, False, f"Error: {str(e)}", expected_status

        if status != 302 or not location:
            break
        next_url = urllib.parse.urljoin(target, location)
        if urllib.parse.urlsplit(next_url).hostname != host:
            to_mirror = True
            break
        target = next_url
    else:
        return url, False, f"Too many redirects (next: {target})", expected_status

    success = status == 200 or (to_mirror and not is_sha)
    msg = f"Got {status} (Expected {expected_status})"
    if target != full_url:
        msg += f" from {target}"

    return url, success, msg, expected_status

def main():
    # If file patterns are specified as arguments, use them
    args = sys.argv[1:]
    if not args:
        print("Usage: python3 test_urls.py [file_patterns...]")
        sys.exit(1)
        
    files = []
    for pattern in args:
        files.extend(glob.glob(pattern))
        
    if not files:
        print(f"No files matched patterns: {args}")
        sys.exit(1)
        
    print(f"Reading URLs from {len(files)} file(s)...")
    all_urls = set()
    for f in files:
        try:
            content = yaml.safe_load(open(f))
            for url in extract_urls(content):
                all_urls.add(url)
        except Exception as e:
            print(f"Error reading {f}: {e}")
            
    if not all_urls:
        print("No URLs found in the files.")
        sys.exit(0)
        
    print(f"Testing {len(all_urls)} unique URLs concurrently...")
    
    opener = urllib.request.build_opener(NoRedirectHandler)
    results = []
    
    # Use ThreadPoolExecutor to run requests in parallel
    with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
        future_to_url = {executor.submit(test_url, url, opener): url for url in all_urls}
        for future in concurrent.futures.as_completed(future_to_url):
            url = future_to_url[future]
            try:
                url, success, msg, expected = future.result()
                results.append((url, success, msg, expected))
                status_char = "✓" if success else "✗"
                print(f"[{status_char}] {url} -> {msg}")
            except Exception as e:
                results.append((url, False, f"Execution error: {e}", "unknown"))
                print(f"[✗] {url} -> Execution error: {e}")
                
    # Summary of results
    successes = [r for r in results if r[1]]
    failures = [r for r in results if not r[1]]
    
    print("\n" + "="*50)
    print("TEST SUMMARY")
    print("="*50)
    print(f"Total Unique URLs Tested: {len(results)}")
    print(f"Passed: {len(successes)}")
    print(f"Failed: {len(failures)}")
    print("="*50)
    
    if failures:
        print("\nFailed URLs:")
        for url, success, msg, expected in sorted(failures):
            print(f" - {url} ({msg})")
        sys.exit(1)
    else:
        print("\nAll URL status codes match expectations!")
        sys.exit(0)

if __name__ == '__main__':
    main()
