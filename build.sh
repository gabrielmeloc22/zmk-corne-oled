#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "================================"
echo "ZMK Firmware Local Build"
echo "Eyelash Corne with OLED"
echo "================================"
echo ""

# Initialize west workspace if needed
if [ ! -d "$SCRIPT_DIR/.west" ]; then
    echo "→ Initializing west workspace..."
    cd "$SCRIPT_DIR"
    docker run --rm -v "$SCRIPT_DIR:/workspace" -w /workspace zmkfirmware/zmk-build-arm:stable bash -c "west init -l config"
fi

echo "→ Updating west modules..."
docker run --rm -v "$SCRIPT_DIR:/workspace" -w /workspace zmkfirmware/zmk-build-arm:stable bash -c "west update"

echo "→ Creating firmware output directory..."
mkdir -p "$SCRIPT_DIR/firmware"

echo ""
echo "→ Building RIGHT side..."
docker run --rm -v "$SCRIPT_DIR:/workspace" -w /workspace zmkfirmware/zmk-build-arm:stable bash -c "export Zephyr_DIR=/workspace/zephyr/share/zephyr-package/cmake && export ZEPHYR_BASE=/workspace/zephyr && west build -s zmk/app -b eyelash_nano -p -- -DSHIELD='eyelash_corne_right nice_oled' -DZMK_CONFIG=/workspace/config -DBOARD_ROOT=/workspace"

cp "$SCRIPT_DIR/build/zephyr/zmk.uf2" "$SCRIPT_DIR/firmware/eyelash_corne_right.uf2"
echo "✓ Right side firmware saved"

echo ""
echo "→ Building LEFT side (with ZMK Studio)..."
docker run --rm -v "$SCRIPT_DIR:/workspace" -w /workspace zmkfirmware/zmk-build-arm:stable bash -c "export Zephyr_DIR=/workspace/zephyr/share/zephyr-package/cmake && export ZEPHYR_BASE=/workspace/zephyr && west build -s zmk/app -b eyelash_nano -p -- -DSHIELD='eyelash_corne_left nice_oled' -DZMK_CONFIG=/workspace/config -DBOARD_ROOT=/workspace -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n -DSNIPPET='studio-rpc-usb-uart'"

cp "$SCRIPT_DIR/build/zephyr/zmk.uf2" "$SCRIPT_DIR/firmware/eyelash_corne_left.uf2"
echo "✓ Left side firmware saved"

echo ""
echo "✓ Build complete!"
echo ""
echo "Firmware files:"
ls -lh "$SCRIPT_DIR/firmware"/*.uf2

echo ""
echo "Ready to flash!"
