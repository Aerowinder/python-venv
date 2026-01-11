#!/usr/bin/env bash

usage() {
    echo
    echo "USAGE:   $0 -g GIT_REPO"
    echo "EXAMPLE: $0 -g \"/path/to/git/repo\""
    echo
    echo "OPTIONS:"
    echo "     -g: Path to Git repo (required)"
    echo
    exit 1
}

while getopts ":g:" opt; do
    case $opt in
        g) GIT_REPO="$OPTARG" ;;
        :) echo "[ERROR] Switch requires an argument: -$OPTARG"; usage ;; # When argument from required switch is missing.
        ?) echo "[ERROR] Illegal switch: -$OPTARG"; usage ;; # Illegal option.
    esac
done
if [[ -z "$GIT_REPO" ]]; then echo "[ERROR] Missing required switch: -g"; usage; fi # getopts can't guarantee a switch exists.
if [[ ! -d "$GIT_REPO" ]]; then echo "[ERROR] Git directory not found"; usage; fi
if [[ ! -d "$GIT_REPO/.git" ]]; then echo "[ERROR] Provided directory does not appear to be a Git repo"; usage; fi

DIR_NAME="$(basename "$GIT_REPO")"
VENV_PATH="$HOME/.venv/$DIR_NAME"
FILE_REQ="$GIT_REPO/requirements.txt"

if [[ -d "$VENV_PATH" && ! -f "$VENV_PATH/pyvenv.cfg" ]]; then
    echo "[ERROR] VENV path does not appear to be a VENV: $VENV_PATH"
    exit 1
fi

if [[ -f "$VENV_PATH/pyvenv.cfg" ]]; then
    echo "Deleting existing virtual environment at $VENV_PATH..."
    rm -rf "$VENV_PATH"
fi

echo "Creating virtual environment at $VENV_PATH..."
python3 -m venv "$VENV_PATH"

if [ -f "$FILE_REQ" ]; then
    echo "Installing dependencies from $FILE_REQ..."
    echo
    "$VENV_PATH/bin/python" -m pip install --upgrade pip
    "$VENV_PATH/bin/python" -m pip install -r "$FILE_REQ"
else
    echo "No requirements.txt found in $GIT_REPO, continuing without..."
fi

# Changelog
#2026-01-11 - AS - v1, Initial release.
