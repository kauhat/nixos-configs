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

RUN nix profile install github:guibou/nixGL --impure
RUN nix profile install home-manager
