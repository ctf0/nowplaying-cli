#!/bin/sh
PATH="/opt/homebrew/bin:$PATH"

dir="${1:-fwd}"
step="${2:-10}"

cur=$(nowplaying-cli get elapsedTime)
[ -z "$cur" ] && exit 0
dur=$(nowplaying-cli get duration)

target=$(awk -v c="$cur" -v d="$dur" -v s="$step" -v dir="$dir" 'BEGIN {
  t = (dir == "back") ? c - s : c + s
  if (d != "" && d + 0 > 0 && t > d - 1) t = d - 1
  if (t < 0) t = 0
  printf "%.0f", t
}')

nowplaying-cli seek "$target"
