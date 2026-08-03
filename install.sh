#!/usr/bin/env bash
# Wire ai-agent-skills into a consumer repository for one or more AI IDEs/agents.
#
# Usage (from consumer repo root):
#   git submodule add https://github.com/kumpeapps/ai-agent-skills.git .ai-agent-skills
#   .ai-agent-skills/install.sh
#   .ai-agent-skills/install.sh --target all
#   .ai-agent-skills/install.sh --target cursor,claude,copilot
#   .ai-agent-skills/install.sh --list-targets
#
# Targets: all, cursor, claude, copilot, vscode, codex, windsurf, gemini, aider
# vscode is an alias of copilot (GitHub Copilot in VS Code / github.com).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_REPO="$SCRIPT_DIR"
TARGETS="all"
CONSUMER_ROOT=""

usage() {
  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

list_targets() {
  cat <<'EOF'
Available targets (comma-separated for --target):

  all       Install for every supported agent (default)
  cursor    Cursor — .cursor/skills, .cursor/rules, AGENTS.md
  claude    Claude Code — .claude/skills, CLAUDE.md → AGENTS.md
  copilot   GitHub Copilot / VS Code — .github/skills, copilot-instructions,
            .github/instructions, .github/prompts, AGENTS.md
  vscode    Alias for copilot
  codex     OpenAI Codex / AGENTS.md standard — AGENTS.md (+ skills under .agents/skills when used)
  windsurf  Windsurf — .windsurfrules → AGENTS.md, AGENTS.md
  gemini    Gemini CLI — GEMINI.md → AGENTS.md, AGENTS.md
  aider     Aider — CONVENTIONS.md → AGENTS.md, AGENTS.md

Shared across targets: AGENTS.md (open standard) and prompts under the skills repo.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage 0 ;;
    --list-targets) list_targets; exit 0 ;;
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
      SKILLS_REPO="$(cd "${2:?--skills-repo requires a path}" && pwd)"
      shift 2
      ;;
    *)
      # Backward compatible: first positional arg = skills repo path
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

if [[ ! -d "$SKILLS_REPO/skills" || ! -d "$SKILLS_REPO/rules" ]]; then
  echo "error: expected skills/ and rules/ under: $SKILLS_REPO" >&2
  exit 1
fi

if [[ -z "$CONSUMER_ROOT" ]]; then
  BASE_NAME="$(basename "$SKILLS_REPO")"
  if [[ "$BASE_NAME" == ".ai-agent-skills" ]]; then
    CONSUMER_ROOT="$(cd "$SKILLS_REPO/.." && pwd)"
  elif [[ "$(pwd)" != "$SKILLS_REPO" ]]; then
    CONSUMER_ROOT="$(pwd)"
  else
    CONSUMER_ROOT="$SKILLS_REPO"
    echo "note: installing into the skills repo itself (local preview)"
  fi
else
  CONSUMER_ROOT="$(cd "$CONSUMER_ROOT" && pwd)"
fi

SKILLS_SRC="$SKILLS_REPO/skills"
RULES_SRC="$SKILLS_REPO/rules"
PROMPTS_SRC="$SKILLS_REPO/prompts"
AGENTS_SRC="$SKILLS_REPO/AGENTS.md"

# --- helpers ---

# Absolute path of a file/dir (last component may not exist yet for dest links).
abspath() {
  local path="$1"
  local dir base
  dir="$(cd "$(dirname "$path")" && pwd)"
  base="$(basename "$path")"
  echo "$dir/$base"
}

# Path of $1 relative to directory $2 (portable; prefers python3).
relpath_to() {
  local target="$1"
  local start_dir="$2"
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' \
      "$(abspath "$target")" "$(cd "$start_dir" && pwd)"
    return
  fi
  # Fallback: GNU realpath
  if realpath --relative-to="$start_dir" "$target" >/dev/null 2>&1; then
    realpath --relative-to="$start_dir" "$target"
    return
  fi
  echo "error: need python3 or GNU realpath to create relative symlinks" >&2
  exit 1
}

# True if symlink target string is absolute (starts with /).
is_absolute_link_target() {
  local t="$1"
  [[ "$t" == /* ]]
}

# Resolve a symlink's target to an absolute path (relative targets resolved from link's dir).
resolve_link_abs() {
  local link="$1"
  local t
  t="$(readlink "$link")"
  if [[ "$t" == /* ]]; then
    abspath "$t"
  else
    abspath "$(dirname "$link")/$t"
  fi
}

link_path() {
  # link_path <source> <dest> <label>
  # Always uses a relative symlink. Re-running replaces absolute or stale links.
  local src="$1"
  local dest="$2"
  local label="${3:-link}"
  local dest_dir desired_rel existing existing_abs desired_abs
  dest_dir="$(dirname "$dest")"
  mkdir -p "$dest_dir"
  desired_rel="$(relpath_to "$src" "$dest_dir")"
  desired_abs="$(abspath "$src")"

  if [[ -L "$dest" ]]; then
    existing="$(readlink "$dest")"
    existing_abs="$(resolve_link_abs "$dest" 2>/dev/null || true)"
    if [[ "$existing" == "$desired_rel" ]] || [[ "$existing_abs" == "$desired_abs" ]]; then
      if is_absolute_link_target "$existing"; then
        echo "refresh: $label was absolute → relative ($desired_rel)"
        rm -f "$dest"
      else
        echo "ok: $label already linked"
        return 0
      fi
    else
      echo "refresh: $label target changed"
      rm -f "$dest"
    fi
  elif [[ -e "$dest" ]]; then
    echo "skip: $dest exists and is not a symlink (local override preserved)"
    return 1
  fi
  ln -s "$desired_rel" "$dest"
  echo "linked $label: $dest → $desired_rel"
  return 0
}

link_children() {
  local src_dir="$1"
  local dest_dir="$2"
  local kind="$3"
  local count=0
  local refreshed=0
  local skipped=0
  mkdir -p "$dest_dir"
  shopt -s nullglob
  for item in "$src_dir"/*; do
    local name target desired_rel desired_abs existing existing_abs
    name="$(basename "$item")"
    target="$dest_dir/$name"
    desired_rel="$(relpath_to "$item" "$dest_dir")"
    desired_abs="$(abspath "$item")"

    if [[ -L "$target" ]]; then
      existing="$(readlink "$target")"
      existing_abs="$(resolve_link_abs "$target" 2>/dev/null || true)"
      if [[ "$existing" == "$desired_rel" ]] || [[ "$existing_abs" == "$desired_abs" ]]; then
        if is_absolute_link_target "$existing"; then
          rm -f "$target"
          ln -s "$desired_rel" "$target"
          echo "refresh $kind: $name (absolute → relative)"
          refreshed=$((refreshed + 1))
        else
          echo "ok: $kind $name already linked"
        fi
        count=$((count + 1))
        continue
      fi
      rm -f "$target"
      echo "refresh $kind: $name (stale target)"
      refreshed=$((refreshed + 1))
    elif [[ -e "$target" ]]; then
      echo "skip: $target exists and is not a symlink (local override preserved)"
      skipped=$((skipped + 1))
      continue
    fi
    ln -s "$desired_rel" "$target"
    echo "linked $kind: $name → $desired_rel"
    count=$((count + 1))
  done
  shopt -u nullglob
  echo "  → $count $kind(s) in $dest_dir ($refreshed refreshed, $skipped override(s) kept)"
}

ensure_agents_md() {
  if [[ ! -f "$AGENTS_SRC" ]]; then
    return
  fi
  link_path "$AGENTS_SRC" "$CONSUMER_ROOT/AGENTS.md" "AGENTS.md" || true
}

# Convert Cursor .mdc rule → Copilot .instructions.md (generated file, not symlink)
write_copilot_instruction_from_mdc() {
  local mdc="$1"
  local out_dir="$2"
  local base
  base="$(basename "$mdc" .mdc)"
  local out="$out_dir/${base}.instructions.md"

  if [[ -e "$out" || -L "$out" ]]; then
    if [[ -L "$out" ]]; then
      rm -f "$out"
    elif [[ -f "$out" ]] && grep -q 'generated-by: ai-agent-skills' "$out" 2>/dev/null; then
      rm -f "$out"
    else
      echo "skip: $out exists (local override preserved)"
      return
    fi
  fi

  local apply_to=""
  local always=""
  local in_fm=0
  local body_started=0
  local body=""
  local line

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$body_started" -eq 0 ]]; then
      if [[ "$line" == "---" ]]; then
        if [[ "$in_fm" -eq 0 ]]; then
          in_fm=1
          continue
        else
          in_fm=0
          body_started=1
          continue
        fi
      fi
      if [[ "$in_fm" -eq 1 ]]; then
        if [[ "$line" == alwaysApply:* ]]; then
          always="$(echo "$line" | sed 's/^alwaysApply:[[:space:]]*//')"
        elif [[ "$line" == globs:* ]]; then
          apply_to="$(echo "$line" | sed 's/^globs:[[:space:]]*//' | tr -d '"')"
        fi
        continue
      fi
    fi
    body+="$line"$'\n'
  done < "$mdc"

  mkdir -p "$out_dir"
  {
    echo "---"
    echo "generated-by: ai-agent-skills"
    if [[ "$always" == "true" ]]; then
      echo "applyTo: \"**\""
    elif [[ -n "$apply_to" ]]; then
      echo "applyTo: \"$apply_to\""
    else
      echo "applyTo: \"**\""
    fi
    echo "---"
    printf "%s" "$body"
  } > "$out"
  echo "wrote Copilot instruction: $out"
}

install_cursor() {
  echo "==> target: cursor"
  link_children "$SKILLS_SRC" "$CONSUMER_ROOT/.cursor/skills" "skill"
  link_children "$RULES_SRC" "$CONSUMER_ROOT/.cursor/rules" "rule"
  ensure_agents_md
}

install_claude() {
  echo "==> target: claude (Claude Code)"
  link_children "$SKILLS_SRC" "$CONSUMER_ROOT/.claude/skills" "skill"
  ensure_agents_md
  # Prefer @-import wrapper so Claude loads AGENTS.md as the contract.
  local claude_md="$CONSUMER_ROOT/CLAUDE.md"
  if [[ -e "$claude_md" || -L "$claude_md" ]]; then
    if [[ -L "$claude_md" ]]; then
      rm -f "$claude_md"
    elif grep -q 'generated-by: ai-agent-skills' "$claude_md" 2>/dev/null; then
      rm -f "$claude_md"
    else
      echo "skip: CLAUDE.md exists (local override preserved)"
      return
    fi
  fi
  cat > "$claude_md" <<'EOF'
<!-- generated-by: ai-agent-skills -->
# Claude Code

Project agent contract is shared via AGENTS.md (ai-agent-skills).

@AGENTS.md
EOF
  echo "wrote CLAUDE.md (imports AGENTS.md)"
}

install_copilot() {
  echo "==> target: copilot (GitHub Copilot / VS Code)"
  link_children "$SKILLS_SRC" "$CONSUMER_ROOT/.github/skills" "skill"
  ensure_agents_md

  mkdir -p "$CONSUMER_ROOT/.github"
  link_path "$AGENTS_SRC" "$CONSUMER_ROOT/.github/copilot-instructions.md" "copilot-instructions.md" || true

  local instr_dir="$CONSUMER_ROOT/.github/instructions"
  mkdir -p "$instr_dir"
  shopt -s nullglob
  for mdc in "$RULES_SRC"/*.mdc; do
    write_copilot_instruction_from_mdc "$mdc" "$instr_dir"
  done
  shopt -u nullglob

  if [[ -d "$PROMPTS_SRC" ]]; then
    local prompts_dest="$CONSUMER_ROOT/.github/prompts"
    mkdir -p "$prompts_dest"
    local count=0
    local skipped=0
    shopt -s nullglob
    for p in "$PROMPTS_SRC"/*.md; do
      local base
      base="$(basename "$p" .md)"
      local target="$prompts_dest/${base}.prompt.md"
      if [[ -e "$target" || -L "$target" ]]; then
        if [[ -L "$target" ]]; then
          rm -f "$target"
        else
          echo "skip: $target exists (local override preserved)"
          skipped=$((skipped + 1))
          continue
        fi
      fi
      ln -s "$(relpath_to "$p" "$prompts_dest")" "$target"
      echo "linked prompt: ${base}.prompt.md"
      count=$((count + 1))
    done
    shopt -u nullglob
    echo "  → $count prompt(s) linked into $prompts_dest ($skipped override(s) kept)"
  fi
}

install_codex() {
  echo "==> target: codex (AGENTS.md / OpenAI Codex)"
  ensure_agents_md
  # Emerging agents skills path used by some Codex-compatible tools
  link_children "$SKILLS_SRC" "$CONSUMER_ROOT/.agents/skills" "skill"
}

install_windsurf() {
  echo "==> target: windsurf"
  ensure_agents_md
  link_path "$AGENTS_SRC" "$CONSUMER_ROOT/.windsurfrules" ".windsurfrules" || true
  mkdir -p "$CONSUMER_ROOT/.windsurf/rules"
  # Windsurf can use markdown rules; link AGENTS as a catch-all rule file
  link_path "$AGENTS_SRC" "$CONSUMER_ROOT/.windsurf/rules/agents.md" "windsurf rule" || true
}

install_gemini() {
  echo "==> target: gemini"
  ensure_agents_md
  link_path "$AGENTS_SRC" "$CONSUMER_ROOT/GEMINI.md" "GEMINI.md" || true
}

install_aider() {
  echo "==> target: aider"
  ensure_agents_md
  link_path "$AGENTS_SRC" "$CONSUMER_ROOT/CONVENTIONS.md" "CONVENTIONS.md" || true
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
        echo "error: unknown target '$t' (use --list-targets)" >&2
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

# --- main ---

echo "Consumer root: $CONSUMER_ROOT"
echo "Skills repo:   $SKILLS_REPO"
echo "Targets:       $TARGETS"
echo

TARGET_LIST="$(normalize_targets "$TARGETS")"

for t in $TARGET_LIST; do
  case "$t" in
    cursor) install_cursor ;;
    claude) install_claude ;;
    copilot) install_copilot ;;
    codex) install_codex ;;
    windsurf) install_windsurf ;;
    gemini) install_gemini ;;
    aider) install_aider ;;
  esac
  echo
done

echo "Install complete for:$TARGET_LIST"
echo "Reload / restart your IDE or agent so configuration is picked up."
echo "Shared prompts also live at: $PROMPTS_SRC"
echo
echo "Re-run anytime to add new skills/rules or convert absolute links to relative:"
echo "  git submodule update --init --recursive"
echo "  .ai-agent-skills/install.sh"
echo "Tip: .ai-agent-skills/install.sh --list-targets"
echo "Note: keep .cursor/ (and other IDE link dirs) out of git for Action/CI repos —"
echo "      symlinks are for local IDE use; committing them can break GitHub Actions."
