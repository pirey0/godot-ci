#!/bin/sh
set -e

_NAME=example
_PRESET=linux
_DEBUGMODE=true
_EDITOR_PATH=test/engine/editor.x86_64
_PROJECT_DIR=test/project/
_SUB_DIR_LOC=$_PRESET/

_MODE="export-release"
if [ "$_DEBUGMODE" = "true" ]; then
    echo "Exporting in debug mode!"
    _MODE="export-debug"
fi

# Export for project
echo "Building $_NAME for $_PRESET"
mkdir -p "$GITHUB_WORKSPACE/build/$_SUB_DIR_LOC"
cd "$GITHUB_WORKSPACE/$_PROJECT_DIR"
chmod +x $GITHUB_WORKSPACE/$_EDITOR_PATH
$GITHUB_WORKSPACE/$_EDITOR_PATH --headless --$_MODE "$_PRESET" $GITHUB_WORKSPACE/build/${_SUB_DIR_LOC}${_NAME}

echo "Build Done"
echo build=build/${_SUB_DIR_LOC} >> $GITHUB_OUTPUT