#!/usr/bin/env bash
#
# Clone or update each Helium subproject under projects/, then run
# `make install` in it.

set -euo pipefail

GIT_PROJECT="${GIT_PROJECT:-git@github.com:HeliumEdu}"
PROJECTS="${PROJECTS:-platform frontend www}"
PROJECTS_DIR="projects"

mkdir -p "$PROJECTS_DIR"

for proj in $PROJECTS; do
    echo "$proj"
    project_path="$PROJECTS_DIR/$proj"

    if [ ! -d "$project_path/.git" ]; then
        echo "Cloning repo to ./$project_path"
        git clone "$GIT_PROJECT/$proj.git" "$project_path"
    else
        (cd "$project_path" && git fetch --tags --prune --force && git pull)
    fi

    make install -C "$project_path"
    echo ""
done
