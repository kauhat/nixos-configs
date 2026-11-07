#!/bin/bash
set -Eeuo pipefail

# Set up the nix-toolbox distrobox on Bazzite.
#
# Pulls the image, creates the container from distrobox.ini and installs the
# podman-host helper.
#
# Usage:
#   setup-distrobox.sh [options] [container]
#
# Options:
#   -n, --name NAME   Container to create (default: nix-toolbox-next)
#   -N, --no-pull    Do not pull the image, use whatever is local
#   -r, --root        Create a rootful container
#   -h, --help        Show this help

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INI="${SCRIPT_DIR}/distrobox.ini"

CONTAINER="nix-toolbox-next"
PULL=true
ROOTFUL=false

# Helper function to check if a command exists.
command_exists() {
	command -v "$1" &>/dev/null
}

usage() {
	awk '
		NR == 1 { next }
		/^#/ { sub(/^# ?/, ""); print; inblock = 1; next }
		inblock && /^$/ { next }
		inblock { exit }
	' "${BASH_SOURCE[0]}"
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	-n | --name)
		CONTAINER="$2"
		shift 2
		;;
	-f | --force)
		PULL=true
		shift
		;;
	-N | --no-pull)
		PULL=false
		shift
		;;
	-r | --root)
		ROOTFUL=true
		shift
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		CONTAINER="$1"
		shift
		;;
	esac
done

# Read a key from a section of the ini file, so that the container name,
# image and home directory only have to be changed in one place.
ini_value() {
	local section="$1" key="$2"
	awk -v section="[$section]" -v key="$key" '
		$0 == section { in_section = 1; next }
		/^\[/ { in_section = 0 }
		in_section && index($0, key "=") == 1 {
			sub("^" key "=", "")
			gsub(/^"|"$/, "")
			print
			exit
		}
	' "${INI}"
}

if [[ ! -f "${INI}" ]]; then
	echo "Could not find ${INI}" >&2
	exit 1
fi

IMAGE="$(ini_value "${CONTAINER}" image)"
TOOLBOX="$(ini_value "${CONTAINER}" home)"

if [[ -z "${IMAGE}" ]]; then
	echo "No container named '${CONTAINER}' in ${INI}" >&2
	exit 1
fi

if ! command_exists podman; then
	echo "podman is required, but was not found." >&2
	exit 1
fi

if ! command_exists distrobox; then
	echo "distrobox is required, but was not found." >&2
	exit 1
fi

echo "Setting up ${CONTAINER} from ${IMAGE}"

# --- Pull the image ---
# Always pull by default: the image is published from CI, and reusing a
# stale copy locally is how you end up debugging an image that was fixed
# days ago.
if [[ "${PULL}" == true ]]; then
	echo "Pulling ${IMAGE}..."
	podman pull "${IMAGE}"
else
	echo "Skipping pull of ${IMAGE}, using the local copy."
fi

digest=$(podman image inspect "${IMAGE}" --format '{{.Digest}}' 2>/dev/null || true)
if [[ -n "${digest}" ]]; then
	echo "Image digest: ${digest}"
fi

# --- Remove the symlinks left by the older container ---
# The volumes of nix-toolbox-next mount real directories, so the symlinks
# have to go, otherwise the mount lands on a symlink instead.
echo "Cleaning up symlinks in ${TOOLBOX}"
for link in .ssh Dev Downloads Notes; do
	if [[ -L "${TOOLBOX}/${link}" ]]; then
		rm -f "${TOOLBOX:?}/${link}"
		echo "Removed symlink ${TOOLBOX}/${link}"
	fi
done

# --- Create the container ---
echo "Creating ${CONTAINER}"
distrobox_args=(assemble create --replace --file "${INI}" --name "${CONTAINER}")
if [[ "${ROOTFUL}" == true ]]; then
	distrobox_args+=(--root)
fi
distrobox "${distrobox_args[@]}"

# --- Install the podman-host helper ---
echo "Installing podman-host"
mkdir -p "${TOOLBOX}/.local/bin"
curl -fsSL https://raw.githubusercontent.com/89luca89/distrobox/main/extras/podman-host \
	-o "${TOOLBOX}/.local/bin/podman-host"
chmod +x "${TOOLBOX}/.local/bin/podman-host"

cat <<EOF

${CONTAINER} is ready.

  distrobox enter ${CONTAINER}
  nix run home-manager -- switch --flake \$(realpath ~/Dev/jack/nixos-configs-private) -b backup
  sudo \$(which non-nixos-gpu-setup)
EOF
