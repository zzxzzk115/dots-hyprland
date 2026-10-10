#!/usr/bin/env bash
# Default: print a plan. --apply installs only explicitly selected groups.
set -euo pipefail
base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
apply=false
if [[ ${1:-} == --apply ]]; then apply=true; shift; fi
if (($# == 0)); then
    echo 'Usage: install-packages.sh [--apply] desktop development input apps research-graphics virtualization nvidia-development'
    exit 0
fi
packages=()
for group in "$@"; do
    case "$group" in desktop|development|input|apps|research-graphics|virtualization|nvidia-development) ;;
        *) echo "Unknown group: $group" >&2; exit 2;;
    esac
    while IFS= read -r pkg; do [[ -z $pkg || $pkg == \#* ]] || packages+=("$pkg"); done < "$base/packages/$group.txt"
done
mapfile -t packages < <(printf '%s\n' "${packages[@]}" | sort -u)
printf 'Selected: %s\n' "${packages[*]}"
if ! $apply; then echo 'Plan only. Repeat with --apply after updating repositories with sudo pacman -Syu.'; exit; fi
missing=()
for pkg in "${packages[@]}"; do pacman -Si "$pkg" >/dev/null 2>&1 || missing+=("$pkg"); done
if ((${#missing[@]})); then
    printf 'Unavailable in configured repositories: %s\n' "${missing[*]}" >&2
    echo 'Review current package names/sources before retrying; no packages installed.' >&2
    exit 1
fi
sudo pacman -S --needed "${packages[@]}"
