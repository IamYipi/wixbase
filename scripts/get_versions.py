import json
import re
import os
import urllib.request
from html.parser import HTMLParser

def get_dotnet_info():
    url = "https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/8.0/releases.json"
    print(f"Fetching .NET info from {url}")
    with urllib.request.urlopen(url) as response:
        data = json.load(response)

    latest_release = data["releases"][0]
    sdk_version = latest_release["sdk"]["version"]
    
    # Find win-x86sdk
    download_url = None
    for file in latest_release["sdk"]["files"]:
        if file["rid"] == "win-x86":
            download_url = file["url"]
            break
            
    if not download_url:
        raise Exception(f"Could not find win-x86 SDK download URL for version {sdk_version}")
        
    return sdk_version, download_url

class WineMonoParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.versions = []

    def handle_starttag(self, tag, attrs):
        if tag == "a":
            for name, value in attrs:
                if name == "href":
                    # Look for version directories like "8.0.0/"
                    match = re.match(r"^(\d+\.\d+\.\d+)/$", value)
                    if match:
                        self.versions.append(match.group(1))

def get_wine_mono_version():
    url = "https://dl.winehq.org/wine/wine-mono/"
    print(f"Fetching Wine Mono info from {url}")
    with urllib.request.urlopen(url) as response:
        content = response.read().decode('utf-8')
        
    parser = WineMonoParser()
    parser.feed(content)
    
    if not parser.versions:
        raise Exception("Could not find any Wine Mono versions")
        
    # Sort versions
    parser.versions.sort(key=lambda s: list(map(int, s.split('.'))))
    latest_version = parser.versions[-1]
    return latest_version

def main():
    try:
        dotnet_version, dotnet_url = get_dotnet_info()
        wine_mono_version = get_wine_mono_version()
        
        print(f"Detected DOTNET_VERSION: {dotnet_version}")
        print(f"Detected DOTNET_DOWNLOAD_URL: {dotnet_url}")
        print(f"Detected WINE_MONO_VERSION: {wine_mono_version}")
        
        # Write to GITHUB_ENV if available
        env_file = os.getenv('GITHUB_ENV')
        if env_file:
            with open(env_file, 'a') as f:
                f.write(f"DOTNET_VERSION={dotnet_version}\n")
                f.write(f"DOTNET_DOWNLOAD_URL={dotnet_url}\n")
                f.write(f"WINE_MONO_VERSION={wine_mono_version}\n")
        else:
            print("GITHUB_ENV not found, skipping environment variable export")
            
    except Exception as e:
        print(f"Error: {e}")
        exit(1)

if __name__ == "__main__":
    main()
