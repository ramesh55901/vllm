#!/usr/bin/env bash
set -euo pipefail

# Usage: install_gdrcopy_rhel.sh <GDRCOPY_CUDA_VERSION> <uuarch>
# uuarch must be "x64" or "aarch64"
# Optional: set GDRCOPY_VERSION to override the libgdrapi package version (default: 2.5.1-1)
# Requires: curl, rpm/dnf, root privileges
# For RHEL9/UBI9 targets only.
if [[ $(id -u) -ne 0 ]]; then
  echo "Must be run as root" >&2
  exit 1
fi
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <GDRCOPY_CUDA_VERSION> <uuarch(x64|aarch64)>" >&2
  exit 1
fi
CUDA_VER="$1"
UUARCH_RAW="$2"

case "${UUARCH_RAW,,}" in
  aarch64|arm64)
    URL_ARCH="aarch64"
    RPM_ARCH="aarch64"
    ;;
  x64|x86_64|amd64)
    URL_ARCH="x64"
    RPM_ARCH="x86_64"
    ;;
  *)
    echo "Unsupported uuarch: ${UUARCH_RAW}. Use 'x64' or 'aarch64'." >&2
    exit 1
    ;;
esac

GDRCOPY_PKG_VER="${GDRCOPY_VERSION:-2.5.1-1}"
RPM_NAME="libgdrapi_${GDRCOPY_PKG_VER}.${RPM_ARCH}.rhel9.rpm"
BASE_URL="https://developer.download.nvidia.com/compute/redist/gdrcopy"
URL="${BASE_URL}/CUDA%20${CUDA_VER}/rhel9/${URL_ARCH}/${RPM_NAME}"

echo "Downloading: ${URL}"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "${TMPDIR}"' EXIT

curl -fSL "${URL}" -o "${TMPDIR}/${RPM_NAME}"
dnf install -y "${TMPDIR}/${RPM_NAME}"
dnf clean all
rm -rf /var/cache/dnf

echo "Installed ${RPM_NAME}"
