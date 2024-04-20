#!/usr/bin/env bash

set -eE

fail() {
	printf "%s\n" "$*" >&2
	exit 1
}

readlink /proc/$$/exe | grep -q bash || fail "Please run with bash"

check_deps() {
	for dep in "$@"; do
		command -v "$dep" &>/dev/null || echo "$dep"
	done
}

missing_deps=$(check_deps sfdisk futility)
[ "$missing_deps" ] && fail "The following required commands weren't found in PATH:\n${missing_deps}"

cleanup() {
	[ -z "$LOOPDEV" ] || losetup -d "$LOOPDEV" || :
	trap - EXIT INT
}

check_kern() {
	local verify_result sum flags
	echo "$1"
	verify_result=$(futility vbutil_kernel --verify "$1")
	sum=$(echo "$verify_result" | grep "^\s*Data key sha1sum:\s" | awk '{print $4}')
	flags=$(echo "$verify_result" | grep "^\s*Flags:\s")
	#echo "$verify_result"
	echo "  Data key sha1sum: $sum"
	echo "$flags"
	case "$sum" in
		e78ce746a037837155388a1096212ded04fb86eb) echo "Developer key detected. CTRL+U boot only." ;;
		*) echo "Unknown key. May boot in recovery." ;;
	esac
	echo ""
}

trap 'echo $BASH_COMMAND failed with exit code $?.' ERR
trap 'cleanup; exit' EXIT
trap 'echo Abort.; cleanup; exit' INT

[ -z "$1" ] && fail "Usage: $0 <image|kern>"
[ -b "$1" -o -f "$1" ] || fail "$1 doesn't exist or is not a file or block device"
[ -r "$1" ] || fail "Cannot read $1, try running as root?"
IMAGE="$1"

if sfdisk -l "$IMAGE" 2>/dev/null | grep -q "Disklabel type: gpt"; then
	[ "$EUID" -ne 0 ] && fail "Please run as root for whole shim images"
	LOOPDEV=$(losetup -f)
	losetup -r -P "$LOOPDEV" "$IMAGE"
	table=$(sfdisk -d "$LOOPDEV" 2>/dev/null | grep "^$LOOPDEV")
	for part in $(echo "$table" | awk '{print $1}'); do
		entry=$(echo "$table" | grep "^${part}\s")
		sectors=$(echo "$entry" | grep -o "size=[^,]*" | awk -F '[ =]' '{print $NF}')
		type=$(echo "$entry" | grep -o "type=[^,]*" | awk -F '[ =]' '{print $NF}' | tr '[:lower:]' '[:upper:]')
		if [ "$type" = "FE3A2A5D-4F32-41A7-B725-ACCC3285A309" ] && [ "$sectors" -gt 1 ]; then
			check_kern "$part" || :
		fi
	done
else
	check_kern "$IMAGE" || :
fi
