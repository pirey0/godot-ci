#!/bin/sh
set -e

# Targeted test for whether Godot's Shader Baker export feature can actually
# activate inside this container. Shader Baker only bakes shaders when a real
# RD-backed renderer (RendererSceneRenderRD) came up during export.
#
# Import doesn't need that, so it stays plain --headless (Dummy renderer,
# fast). Export does need it: DisplayServerHeadless ignores --rendering-driver
# and always forces the Dummy rasterizer (servers/display/display_server_headless.h),
# so --headless can never trigger baking no matter what Vulkan drivers are
# installed. Export instead runs under Xvfb with a real DisplayServer (X11)
# and --rendering-driver vulkan explicit, which does honor that choice.

_EDITOR_PATH="$GITHUB_WORKSPACE/test/shader_baker/engine/editor.x86_64"
_PROJECT_DIR="$GITHUB_WORKSPACE/test/shader_baker/project"
_PRESET=linux

chmod +x "$_EDITOR_PATH"
mkdir -p "$GITHUB_WORKSPACE/build/shader_baker_test"
cd "$_PROJECT_DIR"

echo "=== Checking which renderer/device actually comes up under Xvfb ==="
xvfb-run --auto-servernum -- "$_EDITOR_PATH" --rendering-driver vulkan --audio-driver Dummy --script res://check_renderer.gd

echo "=== Importing project ==="
"$_EDITOR_PATH" --headless --editor --import --quit || true
"$_EDITOR_PATH" --headless --editor --import --quit

echo "=== Exporting (this is what triggers Shader Baker) ==="
xvfb-run --auto-servernum -- "$_EDITOR_PATH" --verbose --rendering-driver vulkan --audio-driver Dummy --export-release "$_PRESET" "$GITHUB_WORKSPACE/build/shader_baker_test/shader_baker_test"

echo "=== Full contents of .godot/exported (ground truth, not filtered) ==="
find "$_PROJECT_DIR/.godot/exported" 2>/dev/null | sort || echo "(.godot/exported does not exist at all)"

echo "=== Verifying Shader Baker output ==="
CACHE_DIR=$(find "$_PROJECT_DIR/.godot/exported" -type d -name shader_baker 2>/dev/null | head -n 1)

if [ -z "$CACHE_DIR" ]; then
    echo "FAIL: no shader_baker cache directory was produced at all."
    echo "Shader Baker did not activate -- no RD-backed renderer (RendererSceneRenderRD) came up, so the fix did not take effect."
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
