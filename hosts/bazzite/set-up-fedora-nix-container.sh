#!/bin/bash
set -Eeuxo pipefail

# Set up a development environment with single user Nix, Home Manager, and VS Code.

# Helper function to check if a command exists.
command_exists () {
  command -v "$1" &> /dev/null
}

# --- Install and Configure Nix ---
echo "Checking Nix..."
if ! command_exists nix; then
    echo "Nix not found. Installing..."
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon --yes
    source ~/.nix-profile/etc/profile.d/nix.sh
else
    echo "Nix is already installed, skipping..."
    echo "Try running /nix/nix-installer uninstall if you have problems"
fi

# --- Enable Nix Flakes ---
echo "Checking Nix flakes..."

mkdir -p ~/.config/nix

# Append the necessary configuration to enable flakes.
if ! grep -q "extra-experimental-features = nix-command flakes" ~/.config/nix/nix.conf 2>/dev/null; then
    echo "extra-experimental-features = nix-command flakes" | tee -a ~/.config/nix/nix.conf
    echo "Nix flakes enabled successfully."
else
    echo "Nix flakes are already enabled, skipping."
fi

# --- Install and Configure Home Manager ---
# Check if Home Manager is installed and apply the user's configuration.
echo "Checking for Home Manager..."

if ! nix run home-manager -- switch --flake github:kauhat/nixos-configs#jack-toolbox; then
    echo "Warning: Home Manager setup failed. Continuing with remaining steps..." >&2
fi

# --- Install VSCode ---
# Check if VSCode is installed. If not, add the repository and install it.
echo "Checking for VSCode..."
if ! command_exists code; then
    echo "VSCode not found. Installing..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    sudo dnf update -y
    sudo dnf install -y code
else
    echo "VSCode is already installed, skipping..."
fi

# --- Export VSCode to the Host System ---
# Export the VSCode application to the host so it can be launched directly.
echo "Exporting VSCode to host system..."
if command_exists distrobox-export; then
    distrobox-export --app code
else
    echo "Warning: distrobox-export not found. VSCode may not be exported to the host." >&2
fi

echo "Setup complete!"
