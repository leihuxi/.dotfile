#!/usr/bin/env bash
set -eu

[[ -z "$(pgrep i3lock)" ]] || exit
i3lock -n -u -t -i ~/.config/i3/wallpaper/lock_heihei.png
