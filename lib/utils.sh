#!/usr/bin/env bash

is_mac() {
    [[ "$OSTYPE" == "darwin"* ]]
}

run_quiet() {
    local log_file
    log_file=$(mktemp)
    if "$@" >"$log_file" 2>&1; then
        rm -f "$log_file"
        return 0
    fi

    local status=$?
    cat "$log_file" >&2
    rm -f "$log_file"
    return "$status"
}

download() {
    local url=$1
    local dest=${2:-}
    if [[ -n "$dest" ]]; then
        curl -sSL -o "$dest" "$url"
    else
        curl -sSLO "$url"
    fi
}

work_in_temp_dir() {
    # DON'T set tempdir to local variable!
    tempdir=$(mktemp -d)
    cd "$tempdir"
    trap 'rm -rf "$tempdir"' EXIT
}

# Move an existing path aside before this repo replaces it.
#
# Never overwrite an existing backup. A file is original only once: a second run
# would otherwise "back up" the file this repo generated on the first run, and
# the real original would be gone.
backup_once() {
    local path=$1 backup
    [[ -e "$path" || -L "$path" ]] || return 0

    backup="${path}.backup"
    if [[ -e "$backup" || -L "$backup" ]]; then
        backup="${path}.backup.$(date +%Y%m%d%H%M%S)"
    fi

    mv "$path" "$backup"
    echo "Moved existing $path to $backup"
}

# Point $2 at the repo file $1.
#
# Config this repo owns is linked, not copied. An edit then takes effect the
# moment it is saved, on every machine that links it, and `git status` in this
# repo is the only drift report needed. Copying gives none of that: the edit
# lives in $HOME until the next setup run silently overwrites it.
#
# Only for files no tool writes. Anything a tool rewrites needs a copy or an
# include instead -- see setup-git for the include pattern.
link_config() {
    local src=$1 dest=$2
    [[ "$dest" == */* ]] && mkdir -p "${dest%/*}"
    # Re-pointing a symlink we already own is not worth a backup.
    [[ -L "$dest" ]] || backup_once "$dest"
    ln -sfn "$src" "$dest"
}

# Seed $2 from $1 once, then never touch it again.
#
# For files a tool rewrites: VSCode and Claude Code both save their own settings,
# so the repo copy is a starting point, not the truth. Copying on every run threw
# away whatever the tool -- or you, through its UI -- had changed since.
copy_once() {
    local src=$1 dest=$2 mode=${3:-644}
    if [[ -e "$dest" ]]; then
        echo "$dest already exists, keeping it"
        return 0
    fi
    install -m "$mode" "$src" "$dest"
}

# Append a line to a file unless it is already there. Creates the file if
# missing and never rewrites what is already in it, so your own edits survive
# every re-run. This is the include strategy: one line pointing at the repo,
# rather than replacing a file its owner also writes.
ensure_line() {
    local line=$1 file=$2
    mkdir -p "$(dirname "$file")"
    [[ -f "$file" ]] && grep -qxF "$line" "$file" && return 0
    printf '%s\n' "$line" >> "$file"
}
