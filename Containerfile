FROM fedora-toolbox:latest

# Install systemd dependencies, base utilities, and Fedora-specific packages
RUN dnf install -y \
    systemd \
    dbus \
    pipewire \
    libsecret \
    kf6-kwallet \
    kwalletmanager \
    nix-daemon \
    nix \
    sudo \
    curl \
    git \
    fish \
    zsh \
    && dnf clean all

RUN sudo systemctl enable nix-daemon.service nix-daemon.socket

# Globally enable flakes and the nix-command CLI interface
RUN mkdir -p /etc/nix \
    && echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf \
    && echo "trusted-users = root @wheel" >> /etc/nix/nix.conf

# Pre-create system groups required for Nix daemon and host GPU access
RUN groupadd -f wheel \
    && mkdir -p /nix/var/nix/daemon-socket \
    && chmod 777 /nix/var/nix/daemon-socket

# Pre-configure dynamic linker to discover Distrobox-mounted host Nvidia GL drivers
RUN echo "/usr/lib64" > /etc/ld.so.conf.d/nvidia-distrobox.conf \
    && ldconfig
