FROM debian:stable

ENV DEBIAN_FRONTEND=noninteractive

# Install systemd dependencies, base utilities, and Debian's native Nix setup
RUN apt-get update && apt-get install -y \
    systemd \
    libpam-systemd \
    nix-setup-systemd \
    pipewire-audio-client-libraries \
    sudo \
    curl \
    git \
    fish \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Globally enable flakes and the nix-command CLI interface
RUN mkdir -p /etc/nix \
    && echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf \
    && echo "trusted-users = root @nix-users @sudo" >> /etc/nix/nix.conf

# Ensure group nix-users exists and fix daemon-socket directory permissions
RUN groupadd -f nix-users \
    && mkdir -p /nix/var/nix/daemon-socket \
    && chown root:nix-users /nix/var/nix/daemon-socket \
    && chmod 775 /nix/var/nix/daemon-socket

# Pre-configure dynamic linker to discover Distrobox-mounted host Nvidia GL drivers
RUN echo "/usr/lib/x86_64-linux-gnu" > /etc/ld.so.conf.d/nvidia-distrobox.conf \
    && echo "/usr/lib64" >> /etc/ld.so.conf.d/nvidia-distrobox.conf \
    && ldconfig

# Bake user bootstrap script into /usr/local/bin
RUN printf '#!/usr/bin/env bash\n\
set -euo pipefail\n\
if ! command -v home-manager &> /dev/null; then\n\
    echo "Bootstrapping user profile for jack..."\n\
    nix profile install github:nix-community/nixGL --impure\n\
    nix profile install nixpkgs#home-manager\n\
fi\n' > /usr/local/bin/container-bootstrap \
    && chmod +x /usr/local/bin/container-bootstrap
