#!/bin/bash

print_help() {
  echo "Usage: topsize [--help] [-h] [-N <count>] [-s <minsize>] [--] [dir...]"
  echo "\nOptions:"
  echo "  --help       Show this help message and exit"
  echo "  -N <count>   Number of top files to display (default: all)"
  echo "  -s <minsize> Minimum file size in bytes (default: 1 byte)"
  echo "  -h           Display file sizes in human-readable format"
  echo "  dir...       Directory(ies) to search (default: current directory)"
  exit 0
}

N=""
minsize=1
human_readable=false
dirs=(".")

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      print_help
      ;;
    -N)
      shift
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        N="$1"
      else
        echo "Error: -N option requires a numeric argument." >&2
        exit 1
      fi
      ;;
    -s)
      shift
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        minsize="$1"
      else
        echo "Error: -s option requires a numeric argument." >&2
        exit 1
      fi
      ;;
    -h)
      human_readable=true
      ;;
    --)
      shift
      dirs=("$@")
      break
      ;;
    *)
      if [[ "$1" == -* ]]; then
        echo "Error: Unknown option $1" >&2
        exit 1
      else
        dirs+=("$1")
      fi
      ;;
  esac
  shift
done

for dir in "${dirs[@]}"; do
  if [[ ! -d "$dir" ]]; then
    echo "Error: Directory $dir does not exist or is not accessible." >&2
    exit 1
  fi
done

find_cmd=("find" "${dirs[@]}" "-type" "f" "-size" "+${minsize}c" "-printf" "%s %p\\n")

if $human_readable; then
  sort_cmd=("sort" "-rh")
else
  sort_cmd=("sort" "-rn")
fi

if [[ -n "$N" ]]; then
  head_cmd=("head" "-n" "$N")
else
  head_cmd=("cat")
fi

export LC_ALL=C

{
  "${find_cmd[@]}" |
  "${sort_cmd[@]}" |
  "${head_cmd[@]}"
} |
while read -r size path; do
  if $human_readable; then
    size=$(numfmt --to=si --suffix=B --padding=7 "$size" 2>/dev/null || echo "$size")
  fi
  echo "$size $path"
done

