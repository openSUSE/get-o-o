#!/usr/bin/env python3
import sys
import glob
import urllib.request
import urllib.error
import concurrent.futures

class NoRedirectHandler(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None

def check_url_status(url, opener):
    full_url = 'https://download.opensuse.org' + url
    req = urllib.request.Request(full_url, method='HEAD')
    try:
        res = opener.open(req, timeout=10)
        return url, res.status
    except urllib.error.HTTPError as e:
        return url, e.code
    except Exception as e:
        return url, -1

def main():
    files = ['_data/160.yml', '_data/161.yml']
    
    # 1. Read files and extract all unique .sha512 and .sha512.asc URLs
    sha512_urls = set()
    for f_path in files:
        with open(f_path, 'r') as f:
            for line in f:
                if 'url:' in line and ('.sha512' in line or '.sha512.asc' in line):
                    # extract the URL string between quotes
                    start = line.find('"')
                    end = line.rfind('"')
                    if start != -1 and end != -1:
                        url = line[start+1:end]
                        sha512_urls.add(url)
                        
    if not sha512_urls:
        print("No .sha512 URLs found.")
        sys.exit(0)
        
    print(f"Checking status for {len(sha512_urls)} unique SHA512 URLs...")
    opener = urllib.request.build_opener(NoRedirectHandler)
    
    # 2. Concurrently check status of all .sha512 URLs
    url_statuses = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
        future_to_url = {executor.submit(check_url_status, url, opener): url for url in sha512_urls}
        for future in concurrent.futures.as_completed(future_to_url):
            url = future_to_url[future]
            try:
                _, status = future.result()
                url_statuses[url] = status
            except Exception:
                url_statuses[url] = -1
                
    # 3. For any URL that is 404, check if the .sha256 alternative exists (returns 200)
    failed_sha512 = [url for url, status in url_statuses.items() if status == 404]
    print(f"Found {len(failed_sha512)} failing SHA512 URLs. Checking for SHA256 alternatives...")
    
    sha256_checks = {}
    for url in failed_sha512:
        sha256_url = url.replace('.sha512', '.sha256')
        sha256_checks[sha256_url] = url
        
    sha256_statuses = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
        future_to_url = {executor.submit(check_url_status, url, opener): url for url in sha256_checks}
        for future in concurrent.futures.as_completed(future_to_url):
            sha256_url = future_to_url[future]
            try:
                _, status = future.result()
                sha256_statuses[sha256_url] = status
            except Exception:
                sha256_statuses[sha256_url] = -1
                
    # 4. Identify which URLs can be reverted to .sha256
    reversions = {}  # sha512_url -> sha256_url
    for sha256_url, status in sha256_statuses.items():
        if status == 200:
            original_sha512 = sha256_checks[sha256_url]
            reversions[original_sha512] = sha256_url
            
    print(f"\nFound {len(reversions)} URLs to revert back to SHA256 (since they exist as SHA256 but not SHA512):")
    for orig, rev in reversions.items():
        print(f"  - {orig} -> {rev}")
        
    if not reversions:
        print("\nNo URLs require reversion (no valid SHA256 alternatives exist).")
        sys.exit(0)
        
    # 5. Surgical replacement in files to preserve formatting and comments
    for f_path in files:
        with open(f_path, 'r') as f:
            content = f.read()
            
        modified = False
        for orig, rev in reversions.items():
            if orig in content:
                content = content.replace(orig, rev)
                modified = True
                
        if modified:
            with open(f_path, 'w') as f:
                f.write(content)
            print(f"Updated {f_path}")
            
    print("\nModification complete!")

if __name__ == '__main__':
    main()
