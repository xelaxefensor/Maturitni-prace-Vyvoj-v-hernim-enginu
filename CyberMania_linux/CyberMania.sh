#!/bin/sh
echo -ne '\033c\033]0;CyberMania\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/CyberMania.x86_64" "$@"
