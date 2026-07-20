#!/usr/bin/env bash
# Remove symlinks/generated files created by install.sh.
# Does not delete local overrides or the submodule.
#
# Usage:
#   .ai-agent-skills/uninstall.sh
#   .ai-agent-skills/uninstall.sh --target cursor,claude
#   .ai-agent-skills/uninstall.sh --target all
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_REPO="$SCRIPT_DIR"
TARGETS="all"
CONSUMER_ROOT=""

usage() {
  sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage 0 ;;
    --target)
      TARGETS="${2:?--target requires a value}"
      shift 2
      ;;
    --target=*)
      TARGETS="${1#*=}"
      shift
      ;;
    --consumer-root)
      CONSUMER_ROOT="${2:?--consumer-root requires a path}"
      shift 2
      ;;
    --skills-repo)
      SKILLS_REPO="$(cd "${2:?}" && pwd)"
      shift 2
      ;;
    *)
      if [[ -z "${POSITIONAL_USED:-}" && -d "$1" ]]; then
        SKILLS_REPO="$(cd "$1" && pwd)"
        POSITIONAL_USED=1
        shift
      else
        echo "error: unknown argument: $1" >&2
        usage 1
      fi
      ;;
  esac
done

SKILLS_REPO="$(cd "$SKILLS_REPO" && pwd)"

if [[ -z "$CONSUMER_ROOT" ]]; then
  BASE_NAME="$(basename "$SKILLS_REPO")"
  if [[ "$BASE_NAME" == ".ai-agent-skills" ]]; then
    CONSUMER_ROOT="$(cd "$SKILLS_REPO/.." && pwd)"
  elif [[ "$(pwd)" != "$SKILLS_REPO" ]]; then
    CONSUMER_ROOT="$(pwd)"
  else
    CONSUMER_ROOT="$SKILLS_REPO"
  fi
else
  CONSUMER_ROOT="$(cd "$CONSUMER_ROOT" && pwd)"
fi

remove_managed_links() {
  local dest_dir="$1"
  local src_prefix="$2"
  local kind="$3"
  local count=0
  if [[ ! -d "$dest_dir" ]]; then
    return
  fi
  shopt -s nullglob
  for item in "$dest_dir"/*; do
    if [[ -L "$item" ]]; then
      local resolved
      resolved="$(readlink "$item")"
      case "$resolved" in
        "$src_prefix"*)
          rm -f "$item"
          echo "removed $kind link: $(basename "$item")"
          count=$((count + 1))
          ;;
      esac
    fi
  done
  shopt -u nullglob
  echo "  → $count $kind link(s) removed from $dest_dir"
}

remove_symlink_if_managed() {
  local dest="$1"
  local expected_src="$2"
  local label="$3"
  if [[ -L "$dest" ]]; then
    local resolved
    resolved="$(readlink "$dest")"
    if [[ "$resolved" == "$expected_src" ]]; then
      rm -f "$dest"
      echo "removed $label"
    fi
  fi
}

remove_generated_file() {
  local path="$1"
  local label="$2"
  if [[ -f "$path" ]] && grep -q 'generated-by: ai-agent-skills' "$path" 2>/dev/null; then
    rm -f "$path"
    echo "removed generated $label"
  fi
}

uninstall_cursor() {
  echo "==> uninstall: cursor"
  remove_managed_links "$CONSUMER_ROOT/.cursor/skills" "$SKILLS_REPO/skills" "skill"
  remove_managed_links "$CONSUMER_ROOT/.cursor/rules" "$SKILLS_REPO/rules" "rule"
}

uninstall_claude() {
  echo "==> uninstall: claude"
  remove_managed_links "$CONSUMER_ROOT/.claude/skills" "$SKILLS_REPO/skills" "skill"
  remove_generated_file "$CONSUMER_ROOT/CLAUDE.md" "CLAUDE.md"
  remove_symlink_if_managed "$CONSUMER_ROOT/CLAUDE.md" "$SKILLS_REPO/AGENTS.md" "CLAUDE.md"
}

uninstall_copilot() {
  echo "==> uninstall: copilot"
  remove_managed_links "$CONSUMER_ROOT/.github/skills" "$SKILLS_REPO/skills" "skill"
  remove_symlink_if_managed "$CONSUMER_ROOT/.github/copilot-instructions.md" "$SKILLS_REPO/AGENTS.md" "copilot-instructions.md"
  remove_managed_links "$CONSUMER_ROOT/.github/prompts" "$SKILLS_REPO/prompts" "prompt"
  if [[ -d "$CONSUMER_ROOT/.github/instructions" ]]; then
    shopt -s nullglob
    for f in "$CONSUMER_ROOT/.github/instructions"/*.instructions.md; do
      remove_generated_file "$f" "$(basename "$f")"
    done
    shopt -u nullglob
  fi
}

uninstall_codex() {
  echo "==> uninstall: codex"
  remove_managed_links "$CONSUMER_ROOT/.agents/skills" "$SKILLS_REPO/skills" "skill"
}

uninstall_windsurf() {
  echo "==> uninstall: windsurf"
  remove_symlink_if_managed "$CONSUMER_ROOT/.windsurfrules" "$SKILLS_REPO/AGENTS.md" ".windsurfrules"
  remove_symlink_if_managed "$CONSUMER_ROOT/.windsurf/rules/agents.md" "$SKILLS_REPO/AGENTS.md" "windsurf agents.md"
}

uninstall_gemini() {
  echo "==> uninstall: gemini"
  remove_symlink_if_managed "$CONSUMER_ROOT/GEMINI.md" "$SKILLS_REPO/AGENTS.md" "GEMINI.md"
}

uninstall_aider() {
  echo "==> uninstall: aider"
  remove_symlink_if_managed "$CONSUMER_ROOT/CONVENTIONS.md" "$SKILLS_REPO/AGENTS.md" "CONVENTIONS.md"
}

uninstall_shared_agents() {
  remove_symlink_if_managed "$CONSUMER_ROOT/AGENTS.md" "$SKILLS_REPO/AGENTS.md" "AGENTS.md"
}

normalize_targets() {
  local raw
  raw="$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr ',' ' ')"
  local t
  local result=""
  for t in $raw; do
    case "$t" in
      all)
        echo "cursor claude copilot codex windsurf gemini aider"
        return
        ;;
      vscode|github|github-copilot|gh-copilot) t=copilot ;;
      claude-code|anthropic) t=claude ;;
      openai|openai-codex) t=codex ;;
      cursor|claude|copilot|codex|windsurf|gemini|aider) ;;
      *)
        echo "error: unknown target '$t'" >&2
        exit 1
        ;;
    esac
    case " $result " in
      *" $t "*) ;;
      *) result="$result $t" ;;
    esac
  done
  echo "$result"
}

echo "Consumer root: $CONSUMER_ROOT"
echo "Skills repo:   $SKILLS_REPO"
echo "Targets:       $TARGETS"
echo

TARGET_LIST="$(normalize_targets "$TARGETS")"

for t in $TARGET_LIST; do
  case "$t" in
    cursor) uninstall_cursor ;;
    claude) uninstall_claude ;;
    copilot) uninstall_copilot ;;
    codex) uninstall_codex ;;
    windsurf) uninstall_windsurf ;;
    gemini) uninstall_gemini ;;
    aider) uninstall_aider ;;
  esac
  echo
done

uninstall_shared_agents

echo "Uninstall complete for:$TARGET_LIST"
echo "Submodule at $SKILLS_REPO was not removed."
