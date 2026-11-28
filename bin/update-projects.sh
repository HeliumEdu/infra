#!/usr/bin/env bash
#
# Clone or update each Helium subproject under projects/, then run
# `make install` in it.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECTS="${PROJECTS:-platform frontend www connector}"
PROJECTS_DIR="$REPO/projects"

mkdir -p "$PROJECTS_DIR"

for project in $PROJECTS; do
    echo "Updating $project ..."
    project_path="$PROJECTS_DIR/$project"

    if [ ! -d "$project_path/.git" ]; then
        echo "Cloning $project ..."
        git clone "git@github.com:inertlabs/$project.git" "$project_path"
    else
        (cd "$project_path" && git fetch --tags --prune --force && git pull)
    fi

    make install -C "$project_path"
    echo ""
done
