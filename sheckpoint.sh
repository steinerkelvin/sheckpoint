#!/usr/bin/env bash

show_usage() {
  echo >&2 "Usage: sheckpoint [OPTIONS]"
  echo >&2 "Options:"
  echo >&2 "  -h, --help      Show this help message and exit."

  echo >&2 "  save          Create a snapshot."
  echo >&2 "  diff           Show diff from the last checkpoint."
}

# Refs
#
# https://stackoverflow.com/a/60557208/1967121
# stash changes while keeping the changes in the working directory
#
# https://stackoverflow.com/a/11024039/1967121
# git detect if there are untracked files quickly
#
# https://stackoverflow.com/a/3882880/1967121
#

args=()

while [ "$#" -gt 0 ]; do
  case "$1" in
  -h | --help)
    show_usage
    exit 0
    ;;
  *)
    args+=("$1")
    ;;
  esac
  shift 1
done

git_root() {
  git rev-parse --show-toplevel
}

checkpoint_file() {
  echo "$(git_root)/.checkpoint.local.txt"
}

any_char() {
  head -c1 | wc -c
}

non_zero_txt() {
  [[ "$1" -ne 0 ]]
}

any_untracked() {
  # git ls-files --others --directory --exclude-standard --no-empty-directory --error-unmatch &>/dev/null
  non_zero_txt "$(git ls-files --others --directory --exclude-standard --no-empty-directory | any_char)"
}

any_modified() {
  # git ls-files --modified --error-unmatch &>/dev/null
  non_zero_txt "$(git ls-files --modified | any_char)"
}

function run_save() {
  echo >&2 "Creating checkpoint..."

  while [ "$#" -gt 0 ]; do
    case "$1" in
    -u | --allow-untracked)
      allow_untracked=true
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    esac
    shift 1
  done

  # Checks if there are untracked files in the working tree
  if any_untracked && ! [ "$allow_untracked" = "true" ]; then
    echo "Untracked files are not snapshotted. Aborting." >&2
    echo "Use [-u|--allow-untracked] to bypass this check." >&2
    exit 1
  fi

  # if ! git stash push --keep-index --message "_checkpoint"; then # --include-untracked
  #   echo "Failed to create stash." >&2
  #   exit 1
  # fi

  stash_ref=$(git stash create)
  if [ -z "$stash_ref" ]; then
    echo "Failed to create stash entry." >&2
    exit 1
  fi
  # git stash store "$stash_ref" -m "_checkpoint"

  echo "$stash_ref" >"$(checkpoint_file)"
}

function run_diff() {
  if [ ! -f "$(checkpoint_file)" ]; then
    echo "No checkpoint found. Aborting." >&2
    exit 1
  fi

  stash_ref=$(cat "$(checkpoint_file)")

  echo '<diff "changes since last checkpoint">'
  git diff "$stash_ref"
  echo '</diff>'
}

if [ "${#args[@]}" -lt 1 ]; then
  show_usage
  exit 1
fi
cmd="${args[0]}"
args=("${args[@]:1}")

if [ "$cmd" = "save" ]; then
  run_save "${args[@]}"
elif [ "$cmd" = "diff" ]; then
  run_diff "${args[@]}"
else
  echo "Unknown command: $cmd" >&2
  exit 1
fi
