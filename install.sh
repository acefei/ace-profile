#!/usr/bin/env sh
# install.sh — Bootstrap a fresh machine, or update an existing checkout.
# Installs mise (rootless), then runs: mise run bootstrap
# Usage:
#   sh install.sh                 # full bootstrap
#   sh install.sh --update        # git pull && mise run bootstrap
#   sh install.sh --help
#   curl -fsSL <raw-install-url> | sh
set -eu

MISE_BIN="$HOME/.local/bin/mise"
DEFAULT_REPO_URL="https://github.com/acefei/dotfiles-mise.git"
DEFAULT_DOTFILES_DIR="$HOME/dotfiles-mise"

DOTFILES_DIR=""
MODE="bootstrap"

# ── CLI ─────────────────────────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: sh install.sh [OPTIONS]

Options:
  -u, --update    Pull latest repo changes and re-run mise bootstrap.
  -h, --help      Show this help.

Environment:
  DOTFILES_DIR    Override target repo location (default: $DEFAULT_DOTFILES_DIR).
  DOTFILES_REPO   Override clone URL (default: $DEFAULT_REPO_URL).
  GH_TOKEN / GITHUB_TOKEN   Avoid GitHub API rate limits during mise install.
EOF
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -u|--update) MODE="update" ;;
            -h|--help)   usage; exit 0 ;;
            *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
        esac
        shift
    done
}

# ── Steps ───────────────────────────────────────────────────────────────────
require_build_tools() {
    missing=""
    for cmd in make cc; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            if [ "$cmd" = "cc" ] && (command -v gcc >/dev/null 2>&1 || command -v clang >/dev/null 2>&1); then
                continue
            fi
            missing="$missing $cmd"
        fi
    done
    [ -z "$missing" ] && return 0

    echo "Missing required build tools:$missing"
    case "$(uname -s)" in
        Darwin) echo "Install them with: xcode-select --install" ;;
        Linux)
            if   command -v apt-get >/dev/null 2>&1; then echo "Install them with: sudo apt-get update && sudo apt-get install -y build-essential"
            elif command -v dnf     >/dev/null 2>&1; then echo "Install them with: sudo dnf groupinstall -y 'Development Tools'"
            elif command -v yum     >/dev/null 2>&1; then echo "Install them with: sudo yum groupinstall -y 'Development Tools'"
            elif command -v apk     >/dev/null 2>&1; then echo "Install them with: sudo apk add --no-cache build-base"
            elif command -v pacman  >/dev/null 2>&1; then echo "Install them with: sudo pacman -Sy --noconfirm base-devel"
            fi
            ;;
    esac
    echo "Please install the missing tools and re-run this script."
    exit 1
}

install_mise() {
    if ! command -v mise >/dev/null 2>&1 && [ ! -x "$MISE_BIN" ]; then
        echo "Installing mise..."
        curl -sSL https://mise.run | sh >/dev/null 2>&1
    fi
    export PATH="$HOME/.local/bin:$PATH"
}

resolve_dotfiles_dir() {
    # When piped from stdin (curl | sh), $0 is usually "sh"; fall back to cloning.
    script_dir=""
    case "$0" in
        */*)
            if [ -f "$0" ]; then
                script_dir="$(cd "$(dirname "$0")" && pwd)"
            fi
            ;;
    esac

    if [ -n "$script_dir" ] && [ -f "$script_dir/mise.toml" ]; then
        DOTFILES_DIR="$script_dir"
        return
    fi

    DOTFILES_DIR="${DOTFILES_DIR:-$DEFAULT_DOTFILES_DIR}"
    repo_url="${DOTFILES_REPO:-$DEFAULT_REPO_URL}"

    if [ ! -f "$DOTFILES_DIR/mise.toml" ]; then
        echo "Cloning dotfiles repo to $DOTFILES_DIR..."
        git clone -q --depth=1 --single-branch "$repo_url" "$DOTFILES_DIR"
    fi
}

pull_latest() {
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        echo "Skipping git pull: $DOTFILES_DIR is not a git checkout."
        return 0
    fi
    echo "Updating dotfiles repo..."
    git -C "$DOTFILES_DIR" pull --ff-only
}

link_global_mise_config() {
    # Tools only — never mise.toml, which holds this repo's tasks. mise sets
    # MISE_PROJECT_ROOT to $HOME for whichever config it loads globally.
    mkdir -p "$HOME/.config/mise"
    ln -sf "$DOTFILES_DIR/config/mise/tools.toml" "$HOME/.config/mise/config.toml"
}

trust_repo() {
    cd "$DOTFILES_DIR"
    mise trust -y -a
}

normalize_task_perms() {
    [ -d "$DOTFILES_DIR/.mise/tasks" ] || return 0
    chmod 755 "$DOTFILES_DIR/.mise/tasks"
    find "$DOTFILES_DIR/.mise/tasks" -type f -exec chmod 755 {} +
}

ensure_github_token() {
    # mise hits the GitHub API to list/download many tools; without auth it can
    # hit rate limits and fail with 403.
    if [ -n "${GH_TOKEN:-}" ]; then
        export GITHUB_TOKEN="$GH_TOKEN"
    fi
    [ -n "${GITHUB_TOKEN:-}" ] && return 0

    printf "No GH_TOKEN/GITHUB_TOKEN found. Log in with gh CLI to avoid GitHub rate limits? [y/N] "
    if [ -r /dev/tty ]; then
        read -r REPLY </dev/tty || REPLY=""
    else
        read -r REPLY || REPLY=""
    fi
    case "$REPLY" in
        [yY]|[yY][eE][sS])
            if ! command -v gh >/dev/null 2>&1; then
                echo "Installing gh CLI via mise..."
                mise install gh
            fi
            gh_bin="$(mise which gh 2>/dev/null || command -v gh || true)"
            if [ -n "$gh_bin" ]; then
                if ! "$gh_bin" auth status >/dev/null 2>&1; then
                    "$gh_bin" auth login -h github.com -p https -w
                fi
                GITHUB_TOKEN="$("$gh_bin" auth token 2>/dev/null || true)"
                [ -n "$GITHUB_TOKEN" ] && export GITHUB_TOKEN
            fi
            ;;
        *)
            echo "Skipping gh login. Installation may hit GitHub API rate limits"
            echo "and fail; if so, set GH_TOKEN/GITHUB_TOKEN or re-run this installer later."
            ;;
    esac
}

install_tools() {
    echo "Installing tools..."
    mise install
}

run_bootstrap() {
    echo "Running bootstrap..."
    mise run bootstrap
}

# ── Flow ────────────────────────────────────────────────────────────────────
# One pipeline. --update pulls first and skips the fresh-machine-only steps.
run_install() {
    if [ "$MODE" = bootstrap ]; then
        require_build_tools
    fi
    install_mise
    resolve_dotfiles_dir
    if [ "$MODE" = update ]; then
        pull_latest
    fi
    link_global_mise_config
    trust_repo
    normalize_task_perms
    if [ "$MODE" = bootstrap ]; then
        ensure_github_token
        install_tools
    fi
    run_bootstrap
}

main() {
    parse_args "$@"
    run_install
}

main "$@"
