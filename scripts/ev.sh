#!/usr/bin/env bash
# Run a command and append its REAL output and exit code to docs/evidence/<milestone>.md
#
# Usage:  bash scripts/ev.sh M1 "make check" -- make check
#         bash scripts/ev.sh M1 "dump" -- bash -c './app --dump | head -20'
#
# Never use it on a command that prints secrets.
set -u
if [ $# -lt 4 ] || [ "$3" != "--" ]; then
  echo 'usage: bash scripts/ev.sh <M#> "<label>" -- <command...>' >&2
  exit 2
fi
ms="$1"; label="$2"; shift 3
dir="docs/evidence"; file="$dir/$ms.md"; max=20000
mkdir -p "$dir"
if [ ! -f "$file" ]; then
  if [ -f "$dir/_TEMPLATE.md" ]; then
    sed "s/M<n>/$ms/g" "$dir/_TEMPLATE.md" > "$file"
  else
    printf '# Evidence %s\n\n## Command log\n' "$ms" > "$file"
  fi
fi
tmp=$(mktemp)
"$@" >"$tmp" 2>&1
code=$?
bytes=$(wc -c <"$tmp" | tr -d ' ')
{
  printf '\n### %s\n' "$label"
  printf 'date: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf '```text\n$'
  for a in "$@"; do
    case "$a" in
      *[!A-Za-z0-9_./=:@%+,-]*|"") printf " '%s'" "$(printf '%s' "$a" | sed "s/'/'\\\\''/g")" ;;
      *) printf ' %s' "$a" ;;
    esac
  done
  printf '\n'
  head -c "$max" "$tmp"
  if [ "$bytes" -gt "$max" ]; then printf '\n...[truncated, %s bytes total]' "$bytes"; fi
  printf '\n[exit code: %s]\n```\n' "$code"
} >> "$file"
tail -n 25 "$tmp"
echo "[ev.sh] exit code $code -> appended to $file"
rm -f "$tmp"
exit "$code"
