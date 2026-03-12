#!/usr/bin/env bash
#
# Syncs a feature branch with its base branch across multiple repos.
# Uses fzf to select branch, then repos. Stops immediately on any conflict.
#
# Usage:
#   ./sync-feature-branch.sh          # fzf: pick branch, then repos
#   ./sync-feature-branch.sh --all    # fzf: pick branch, sync all repos (no repo picker)
#
# Schedule: Run 2x/week via cron or Task Scheduler (use --all for unattended)

set -euo pipefail

# Format: name|path|base_branch (scripts uses master, others use release2)
declare -a DATA_MASKING_REPOS=(
  "icm-ui|~/code/icm-ui|origin/release2"
  "Varicent|~/code/Varicent|origin/release2"
  "scripts|~/code/scripts|origin/master"
  "icm-cloud|~/code/icm-cloud|origin/release2"
)

declare -a PORTAL_ACCESS_REPOS=(
  "icm-ui|~/code/icm-ui|origin/release2"
)

# Format: branch_name|description (for fzf display)
BRANCHES=(
  "feature-data-masking|Sync feature-data-masking with base"
  "feature-portal-access-ui|Sync feature-portal-access-ui with base"
)

resolve_path() {
  echo "${1/#\~/$HOME}"
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log_error() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2
}

get_repos_for_branch() {
  local branch="$1"
  case "$branch" in
    feature-data-masking)
      printf '%s\n' "${DATA_MASKING_REPOS[@]}"
      ;;
    feature-portal-access-ui)
      printf '%s\n' "${PORTAL_ACCESS_REPOS[@]}"
      ;;
    *)
      log_error "Unknown branch: $branch"
      return 1
      ;;
  esac
}

handle_uncommitted() {
  local name="$1"
  local path="$2"
  local interactive="${3:-0}"
  local script_name="${4:-sync-feature-branch}"

  log_error "Uncommitted changes in $name."
  echo ""
  echo "--- git status ---"
  git status
  echo ""
  echo "--- git diff (staged + unstaged) ---"
  git diff
  git diff --cached
  echo ""

  if [[ "$interactive" -eq 0 ]]; then
    log_error "Run without --all to get interactive options."
    return 1
  fi

  echo "Options:"
  echo "  1) Stash changes (git stash push -u) and continue"
  echo "  2) Discard all changes (git checkout -- . && git reset HEAD) and continue"
  echo "  3) Abort"
  echo ""
  read -r -p "Choice [1-3]: " choice

  case "$choice" in
    1)
      git stash push -u -m "$script_name $(date '+%Y-%m-%d')"
      log "Stashed. Will sync, then you can run 'git stash pop' to restore."
      return 0
      ;;
    2)
      git checkout -- .
      git reset HEAD
      log "Discarded all changes."
      return 0
      ;;
    *)
      log_error "Aborted."
      return 1
      ;;
  esac
}

sync_repo() {
  local name="$1"
  local path
  path="$(resolve_path "$2")"
  local base_branch="$3"
  local feature_branch="$4"
  local interactive="${5:-1}"

  if [[ ! -d "$path" ]]; then
    log_error "Repo not found: $path"
    return 1
  fi

  echo ""
  echo "=========================================="
  echo "  REPO: $name"
  echo "  Path: $path"
  echo "  Base: $base_branch"
  echo "=========================================="
  echo ""
  log "--- Syncing: $name ($path) <- $base_branch ---"
  cd "$path" || return 1

  if [[ -n "$(git status --porcelain)" ]]; then
    if ! handle_uncommitted "$name" "$path" "$interactive" "sync-feature-branch"; then
      return 1
    fi
  fi

  if ! git checkout "$feature_branch" 2>/dev/null; then
    log_error "Branch $feature_branch does not exist in $name"
    return 1
  fi

  if ! git pull -fp origin "$feature_branch"; then
    log_error "Pull failed in $name"
    return 1
  fi

  if ! git fetch -fp; then
    log_error "Fetch failed in $name"
    return 1
  fi

  if ! git rev-parse "$base_branch" &>/dev/null; then
    log_error "Remote branch $base_branch not found in $name"
    return 1
  fi

  if ! git merge "$base_branch"; then
    log_error "Merge conflict in $name. Resolve manually, then commit and push."
    return 1
  fi

  if git push origin "$feature_branch"; then
    log "Pushed $feature_branch to origin"
  else
    log_error "Push failed in $name"
    return 1
  fi

  log "Done: $name"
  return 0
}

select_branch() {
  if ! command -v fzf &>/dev/null; then
    log_error "fzf not found. Install it to use this script."
    exit 1
  fi

  local selected
  selected="$(printf '%s\n' "${BRANCHES[@]}" | fzf --prompt="Select branch to sync: " --height=6)"
  [[ -z "$selected" ]] && return 1
  echo "${selected%%|*}"
}

select_repos() {
  local repos="$1"
  local use_all="${2:-0}"

  if [[ "$use_all" -eq 1 ]]; then
    echo "$repos"
    return
  fi

  if ! command -v fzf &>/dev/null; then
    log_error "fzf not found. Install it or use --all to sync all repos."
    exit 1
  fi

  echo "$repos" | fzf --multi --prompt="Select repos to sync (Tab=select, Enter=run): " --height=10
}

# --- Main ---
if ! command -v fzf &>/dev/null; then
  log_error "fzf not found. Install it to use this script."
  exit 1
fi

INTERACTIVE=1
USE_ALL=0
[[ "${1:-}" == "--all" ]] && USE_ALL=1

log "Select branch to sync"
FEATURE_BRANCH="$(select_branch)"
if [[ -z "$FEATURE_BRANCH" ]]; then
  log "Nothing selected. Exiting."
  exit 0
fi

REPOS="$(get_repos_for_branch "$FEATURE_BRANCH")"
if [[ -z "$REPOS" ]]; then
  exit 1
fi

log "Syncing $FEATURE_BRANCH with base branch (per-repo)"

selected="$(select_repos "$REPOS" "$USE_ALL")"
if [[ -z "$selected" ]]; then
  log "Nothing selected. Exiting."
  exit 0
fi

while IFS='|' read -r name path base_branch; do
  [[ -z "$name" ]] && continue
  if ! sync_repo "$name" "$path" "$base_branch" "$FEATURE_BRANCH" "$INTERACTIVE"; then
    log_error "Stopping due to error. Fix the issue and re-run."
    exit 1
  fi
done <<< "$selected"

log "All selected repos synced successfully."
