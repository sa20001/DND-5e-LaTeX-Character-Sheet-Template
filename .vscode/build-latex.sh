#!/bin/bash

# cd to root dir
cd "$3" || exit 1

set -e  # exit if any command fails

# ensure lib folder exists
mkdir -p lib

# clone if not exists, otherwise pull
UPDATE_FILE="lib/.last-update"
UPDATE_INTERVAL=86400  # 24 hours in seconds
NEEDS_UPDATE=true

if [ -d lib/dnd ]; then
    if [ -f "$UPDATE_FILE" ]; then
        LAST_UPDATE=$(stat -c %Y "$UPDATE_FILE")
        NOW=$(date +%s)
        AGE=$((NOW - LAST_UPDATE))

        if [ $AGE -lt $UPDATE_INTERVAL ]; then
            NEEDS_UPDATE=false
        fi
    fi
fi

if [ ! -d lib/dnd ]; then
    git clone https://github.com/rpgtex/DND-5e-LaTeX-Template.git lib/dnd
else
    if $NEEDS_UPDATE; then
        cd lib/dnd
        git pull origin dev || true  # avoid failing build if offline
        cd ../..
        date +%s > "$UPDATE_FILE"
    fi
fi

# cd to root dir again
cd "$3" || exit 1

# $1 = output directory, $2 = tex file
latexmk -synctex=1 -interaction=nonstopmode -file-line-error -lualatex -outdir="$1" "$2"
