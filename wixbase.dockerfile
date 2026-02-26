FROM debian:12

ARG DEBIAN_FRONTEND=noninteractive
# Si hay una version mayor reemplazar la version de wine_mono mas actual
ARG WINE_MONO_VERSION=11.0.0
ARG DOTNET_VERSION=8.0.201
# Note: DOTNET_DOWNLOAD_URL is expected to be passed as build-arg, but a default is provided here
ARG DOTNET_DOWNLOAD_URL=https://download.visualstudio.microsoft.com/download/pr/2d6bbfa7-0929-45c4-9844-315ec92c2357/62f026a27ce5f81219b101689255c428/dotnet-sdk-8.0.201-win-x86.exe

ENV WINEPATH="C:\\users\\wix\\.dotnet\\tools" \
    WINEPREFIX="/home/wix/.wine" \
    WINEARCH=win32 \
    WINEDEBUG=-all \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_GENERATE_ASPNET_CERTIFICATE=false \
    PATH="/home/wix/.dotnet/tools:$PATH"

RUN set -ex \
    && dpkg --add-architecture i386 \
    && apt-get update -qq \
    && apt-get install -qqy --no-install-recommends \
        ca-certificates \
        curl \
        python3 \
        python3-pip \
        uvicorn \
        xauth \
        xvfb \
        xz-utils \
    && curl -sSfLo /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && curl -sSfLo /etc/apt/sources.list.d/winehq-bookworm.sources https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources \
    && apt-get update -qq \
    && apt-get install -qqy --no-install-recommends winehq-staging \
    && useradd -m wix \
    && mkdir -p /opt/wine/mono/ \
    && chown -R wix:wix /opt/wine/mono/ \
    && printf '#!/bin/sh\nexec script --return --quiet -c "wine dotnet $*" /dev/null' > /usr/local/bin/dotnet \
    && printf '#!/bin/sh\nexec wine wix.exe $@' > /usr/local/bin/wix.exe \
    && chmod +x /usr/local/bin/dotnet /usr/local/bin/wix.exe \
    && ln -sf /usr/local/bin/wix.exe /usr/local/bin/wix \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY ./requirements.txt /home/wix/requirements.txt

USER wix

RUN set -ex \
    && curl -sSfLo /tmp/wine-mono-${WINE_MONO_VERSION}-x86.tar.xz https://dl.winehq.org/wine/wine-mono/${WINE_MONO_VERSION}/wine-mono-${WINE_MONO_VERSION}-x86.tar.xz \
    && tar -xf /tmp/wine-mono-${WINE_MONO_VERSION}-x86.tar.xz -C /opt/wine/mono/ \
    && rm -f /tmp/wine-mono-${WINE_MONO_VERSION}-x86.tar.xz \
    && curl -sSfLo /tmp/dotnet-sdk-${DOTNET_VERSION}-win-x86.exe ${DOTNET_DOWNLOAD_URL} \
    && xvfb-run sh -c "wineboot --init && wine /tmp/dotnet-sdk-${DOTNET_VERSION}-win-x86.exe /q /norestart" \
    && rm -f /tmp/dotnet-sdk-${DOTNET_VERSION}-win-x86.exe \
    && dotnet tool install --global wix \
    && wine wix.exe --version

RUN set -ex \
    && wix extension add -g WixToolset.UI.wixext \
    && wix extension add -g WixToolset.Util.wixext

RUN pip3 install --no-cache-dir -r /home/wix/requirements.txt --break-system-packages

WORKDIR /home/wix
