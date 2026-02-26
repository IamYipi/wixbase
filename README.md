# wixbase

**wixbase** is a lightweight and robust Docker image designed as a Windows build environment for Linux systems. It combines Wine, the .NET SDK, and the WiX Toolset, enabling seamless compilation of .NET projects and the creation of Windows installers (MSI) from within containers.

This image is optimized for CI/CD pipelines, allowing developers to build and package Windows applications directly on Linux-based servers without requiring a native Windows environment.

## Docker Hub

This image is published on Docker Hub at [iamyipi/wixbase](https://hub.docker.com/r/iamyipi/wixbase).

```bash
docker pull iamyipi/wixbase
```

## 🛠️ Key Components

### Base System
- Based on **debian:12 (Bookworm)** for stability and minimal footprint.

### Wine
- Includes **Wine Staging** (latest), configured for 32-bit architecture (`WINEARCH=win32`).
- Bundled with **Wine Mono** to enable .NET applications to run inside Wine.

### .NET SDK
- Installed **.NET SDK** (win-x86) inside the Wine environment.
- `dotnet` CLI is exposed as a wrapper to execute .NET commands seamlessly from the container.

### WiX Toolset
- Global installation of **WiX Toolset** for authoring Windows Installer packages (MSI).
- Includes `WixToolset.UI.wixext` and `WixToolset.Util.wixext` extensions for advanced packaging scenarios.
- Commands `wix` and `wix.exe` are exposed for direct use.

### Python 3 and Utilities
- **Python 3** and `pip` preinstalled for auxiliary scripting.
- Dependencies specified in `requirements.txt` are installed automatically.

### Xvfb Support
- Includes a virtual framebuffer (`xvfb`) to handle graphical setup operations in Wine.

## 📂 Container Configuration

### Non-Privileged User
- Runs as the user `wix` to avoid running processes as root.

### Environment Variables
- `WINEARCH=win32`: Wine runs in 32-bit mode for compatibility.
- `WINEPREFIX=/home/wix/.wine`: User-specific Wine prefix.
- `DOTNET_CLI_TELEMETRY_OPTOUT=1`: Disables .NET CLI telemetry.
- `PATH=/home/wix/.dotnet/tools:` Adds .NET tools to the path.

### Working Directory
- `/home/wix` is set as the default working directory for your projects.

## 🚀 Main Use Cases

- ✅ **Build .NET Projects on Linux**: Run `dotnet build` to compile .NET applications as if on a Windows system.
- ✅ **Create MSI Installers with WiX Toolset**: Package applications for Windows distribution using `wix build` or `wix.exe`.
- ✅ **Integrate in CI/CD Pipelines**: Ideal for GitHub Actions, GitLab CI, Jenkins, and other CI platforms where Windows build artifacts are needed from Linux runners.

## Credits

- This project is inspired by [jkroepke/docker-wixtoolset](https://github.com/jkroepke/docker-wixtoolset).
- All credits for the original idea and groundwork go to [@jkroepke](https://github.com/jkroepke).
- Special credit to [WineHQ](https://www.winehq.org/) and the Wine project, without which this setup would not be viable.
- Special credit to [WiX Toolset](https://github.com/wixtoolset) for MSI tooling and packaging capabilities.


