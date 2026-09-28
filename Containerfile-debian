FROM debian:stable

ENV DEBIAN_FRONTEND=noninteractive

# Install systemd dependencies, base utilities, and Debian's native Nix setup
RUN apt-get update && apt-get install -y \
    systemd \
    libpam-systemd \
    nix-setup-systemd \
    pipewire-audio-client-libraries \
    dbus \
    dbus-user-session \
    libsecret-1-0 \
    libqt5keychain1 \
    libqt6keychain1 \
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

# Pre-create system groups required for Nix daemon and host GPU access
RUN groupadd -f nix-users \
    && groupadd -f render \
    && groupadd -f video \
    && mkdir -p /nix/var/nix/daemon-socket \
    && chown root:nix-users /nix/var/nix/daemon-socket \
    && chmod 775 /nix/var/nix/daemon-socket

# Pre-configure dynamic linker to discover Distrobox-mounted host Nvidia GL drivers
RUN echo "/usr/lib/x86_64-linux-gnu" > /etc/ld.so.conf.d/nvidia-distrobox.conf \
    && echo "/usr/lib64" >> /etc/ld.so.conf.d/nvidia-distrobox.conf \
    && ldconfig
