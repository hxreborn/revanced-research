#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <package>/<version>" >&2
  exit 1
fi

target_dir="apps/$1"
if [[ ! -d "$target_dir" ]]; then
  echo "Target workspace not found: $target_dir" >&2
  exit 1
fi

for dir in decode artifacts tmp; do
  if [[ -d "$target_dir/$dir" ]]; then
    rm -rf "$target_dir/$dir"
  fi
  mkdir -p "$target_dir/$dir"
  if [[ "$dir" == decode ]]; then
    mkdir -p "$target_dir/$dir/apktool" "$target_dir/$dir/jadx"
  fi
  echo "Reset $target_dir/$dir"
done

echo "Cleanup complete. Re-run apktool/jadx before continuing."
