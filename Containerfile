FROM quay.io/fedora/fedora-toolbox:latest

RUN true \
    # Install systemd dependencies, base utilities, Podman nesting tools, and Fedora packages
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
    podman \
    fuse-overlayfs \
    slirp4netns \
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

RUN true \
    # Configure nested single-UID rootless Podman
    && mkdir -p /etc/containers \
    && printf '[engine]\ncgroup_manager = "cgroupfs"\nevents_logger = "file"\n' > /etc/containers/containers.conf \
    && printf '[storage]\ndriver = "overlay"\n[storage.options]\nignore_chown_errors = "true"\n' > /etc/containers/storage.conf

CMD ["/usr/lib/systemd/systemd"]
