#!/usr/bin/env python3
import sys
import glob
import yaml
import urllib.request
import urllib.error
import concurrent.futures

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
    req = urllib.request.Request(full_url, method='HEAD')
    
    is_sha = any(ext in full_url.lower() for ext in ['.sha256', '.sha512'])
    expected_status = '200' if is_sha else '200/301/302'

    try:
        res = opener.open(req, timeout=10)
        status = res.status
    except urllib.error.HTTPError as e:
        status = e.code
    except urllib.error.URLError as e:
        return url, False, f"Network Error: {e.reason}", expected_status
    except Exception as e:
        return url, False, f"Error: {str(e)}", expected_status

    if is_sha:
        success = (status == 200)
        msg = f"Got {status} (Expected 200)"
    else:
        success = (status in (200, 301, 302))
        msg = f"Got {status} (Expected 200/301/302)"
        
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
