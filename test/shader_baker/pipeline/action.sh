#!/bin/sh
set -e

# Targeted test for whether Godot's Shader Baker export feature can actually
# activate inside this container. Shader Baker only bakes shaders when a real
# RD-backed renderer (RendererSceneRenderRD) came up during the headless
# export, which requires a working Vulkan device -- this proves that end to
# end rather than just checking that a Vulkan ICD is installed.

_EDITOR_PATH="$GITHUB_WORKSPACE/test/shader_baker/engine/editor.x86_64"
_PROJECT_DIR="$GITHUB_WORKSPACE/test/shader_baker/project"
_PRESET=linux

chmod +x "$_EDITOR_PATH"
mkdir -p "$GITHUB_WORKSPACE/build/shader_baker_test"

echo "=== Checking which renderer/device actually came up ==="
cd "$_PROJECT_DIR"
"$_EDITOR_PATH" --headless --script res://check_renderer.gd

echo "=== Importing project ==="
cd "$_PROJECT_DIR"
"$_EDITOR_PATH" --headless --editor --import --quit || true
"$_EDITOR_PATH" --headless --editor --import --quit

echo "=== Exporting (this is what triggers Shader Baker) ==="
"$_EDITOR_PATH" --headless --export-release "$_PRESET" "$GITHUB_WORKSPACE/build/shader_baker_test/shader_baker_test"

echo "=== Verifying Shader Baker output ==="
CACHE_DIR=$(find "$_PROJECT_DIR/.godot/exported" -type d -name shader_baker 2>/dev/null | head -n 1)

if [ -z "$CACHE_DIR" ]; then
    echo "FAIL: no shader_baker cache directory was produced at all."
    echo "Shader Baker did not activate -- no RD-backed renderer (RendererSceneRenderRD) came up headless, so the Vulkan fix did not take effect."
    exit 1
fi

FILE_COUNT=$(find "$CACHE_DIR" -type f | wc -l)
TOTAL_BYTES=$(find "$CACHE_DIR" -type f -exec cat {} + 2>/dev/null | wc -c)

echo "Cache dir: $CACHE_DIR"
echo "Shader cache files: $FILE_COUNT"
echo "Shader cache total bytes: $TOTAL_BYTES"

if [ "$FILE_COUNT" -eq 0 ] || [ "$TOTAL_BYTES" -eq 0 ]; then
    echo "FAIL: shader_baker directory exists but contains no data -- baking produced no real output."
    exit 1
fi

echo "PASS: Shader Baker produced $FILE_COUNT cache file(s) totaling $TOTAL_BYTES bytes."
echo build=build/shader_baker_test >> "$GITHUB_OUTPUT"
