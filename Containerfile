FROM quay.io/fedora/fedora-toolbox:latest

RUN true \
    # Install systemd dependencies, base utilities, and Fedora-specific packages
    && dnf install -y \
    systemd \
    dbus \
    pipewire \
    libsecret \
    nix-daemon \
    nix \
    sudo \
    curl \
    git \
    fish \
    zsh \
    \
    && dnf clean all

RUN true \
    # Pre-configure dynamic linker to discover Distrobox-mounted host Nvidia GL drivers
    && echo "/usr/lib64" > /etc/ld.so.conf.d/nvidia-distrobox.conf \
    && ldconfig \
    \
    # Pre-create system groups required for Nix daemon and host GPU access
    && groupadd -f wheel \
    && mkdir -p /nix/var/nix/daemon-socket \
    && chmod 777 /nix/var/nix/daemon-socket \
    \
    # Globally enable flakes and the nix-command CLI interface
    && mkdir -p /etc/nix \
    && echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf \
    && echo "trusted-users = root @wheel" >> /etc/nix/nix.conf \
    \
    # Enable nix-daemon systemd services
    && systemctl enable nix-daemon.service nix-daemon.socket

CMD ["/usr/lib/systemd/systemd"]
