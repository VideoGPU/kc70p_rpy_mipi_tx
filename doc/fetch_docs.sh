#!/usr/bin/env bash
# Download the third-party reference documents listed in sources.txt into vendor/.
#
# Usage: doc/fetch_docs.sh [-f] [-c] [subdir ...]
#   -f       re-download files that already exist
#   -c       only verify vendor/ against vendor.sha256
#   subdir   limit the download to these vendor/ sub-directories
#
# sources.txt format (whitespace separated, lines starting with '#' are comments):
#   <subdir> <file name> <url> <description...>
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
manifest="$here/sources.txt"
dest="$here/vendor"
sums="$here/vendor.sha256"
ua="Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0"

force=0
check=0
while getopts "fch" opt; do
  case "$opt" in
    f) force=1 ;;
    c) check=1 ;;
    *) sed -n '2,11p' "$0"; exit 0 ;;
  esac
done
shift $((OPTIND - 1))
only=("$@")

if (( check )); then
  cd "$dest" && sha256sum -c "$sums"
  exit $?
fi

selected() {
  (( ${#only[@]} == 0 )) && return 0
  local d
  for d in "${only[@]}"; do [[ "$1" == "$d" ]] && return 0; done
  return 1
}

# Reject HTML error / login pages saved in place of the real document.
looks_valid() {
  local f="$1" magic
  magic="$(head -c 8 "$f" | tr -d '\0')"
  case "$f" in
    *.pdf) [[ "$magic" == %PDF* ]] ;;
    *.zip) [[ "$magic" == PK* ]] ;;
    *.png) [[ "$magic" == ?PNG* ]] ;;
    *.html|*.htm) [[ -s "$f" ]] ;;
    *) [[ -s "$f" ]] && ! head -c 1024 "$f" | grep -qi '<!doctype html\|<html' ;;
  esac
}

ok=0
skipped=0
failed=()
while read -r dir file url _desc; do
  [[ -z "${dir:-}" || "$dir" == \#* ]] && continue
  selected "$dir" || continue
  out="$dest/$dir/$file"
  if [[ -s "$out" ]] && (( ! force )); then
    skipped=$((skipped + 1))
    continue
  fi
  mkdir -p "$dest/$dir"
  if curl -fsSL --retry 3 --retry-delay 2 --max-time 600 -A "$ua" -o "$out.part" "$url" </dev/null \
      && looks_valid "$out.part"; then
    mv -f "$out.part" "$out"
    ok=$((ok + 1))
    echo "OK    $dir/$file"
  else
    rm -f "$out.part"
    failed+=("$dir/$file  <-  $url")
    echo "FAIL  $dir/$file" >&2
  fi
done < "$manifest"

# Record checksums of everything in vendor/ so later downloads can be compared.
if [[ -d "$dest" ]]; then
  (cd "$dest" && find . -type f ! -name '*.part' | sed 's#^\./##' | LC_ALL=C sort \
      | xargs -r -d '\n' sha256sum) > "$sums"
fi

echo "downloaded: $ok, already present: $skipped, failed: ${#failed[@]}"
if (( ${#failed[@]} )); then
  printf '  %s\n' "${failed[@]}" >&2
  exit 1
fi
