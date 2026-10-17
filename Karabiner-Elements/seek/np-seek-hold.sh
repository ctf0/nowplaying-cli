#!/bin/sh
PATH="/opt/homebrew/bin:$PATH"
NP=$(command -v nowplaying-cli) || exit 0
dir="${1:-fwd}"
step="${2:-5}"
interval="${3:-0.3}"
lock="/tmp/np-seek-$dir.lock"
[ -f "$lock" ] || exit 0
self_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

cur=$("$NP" get elapsedTime)
[ -z "$cur" ] && exit 0
dur=$("$NP" get duration)

t=$(awk -v c="$cur" -v d="$dur" -v s="$step" -v dir="$dir" 'BEGIN{
  t = (dir=="back") ? c - s : c + s
  if (d+0 > 0 && t > d - 1) t = d - 1
  if (t < 0) t = 0
  printf "%.1f", t }')

while [ -f "$lock" ]; do
  ("$NP" seek "$t" >/dev/null 2>&1) &
  sleep "$interval"
  t=$(awk -v c="$t" -v d="$dur" -v s="$step" -v dir="$dir" 'BEGIN{
    t = (dir=="back") ? c - s : c + s
    if (d+0 > 0 && t > d - 1) t = d - 1
    if (t < 0) t = 0
    printf "%.1f", t }')
done
