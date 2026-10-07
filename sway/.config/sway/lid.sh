#!/usr/bin/env bash
set -euo pipefail

LAPTOP="eDP-1"

external_outputs() {
    swaymsg -t get_outputs | jq -r --arg laptop "$LAPTOP" \
        '.[] | select(.name != $laptop and .active == true) | .name'
}

case "${1:-}" in
    close)
        mapfile -t externals < <(external_outputs)
        if [ "${#externals[@]}" -eq 0 ]; then
            exit 0
        fi
        primary="${externals[0]}"
        swaymsg "output $primary scale 1.5"
        swaymsg "output $primary position 0 0"
        swaymsg "output $LAPTOP disable"
        ;;
    open)
        mapfile -t externals < <(external_outputs)
        if [ "${#externals[@]}" -eq 0 ]; then
            swaymsg "output $LAPTOP enable"
            swaymsg "output $LAPTOP scale 1.0"
            swaymsg "output $LAPTOP resolution 1920x1200@60Hz position 0 0"
            exit 0
        fi
        primary="${externals[0]}"
        swaymsg "output $primary scale 1.5"
        swaymsg "output $primary position 0 0"
        height=$(swaymsg -t get_outputs | jq -r --arg name "$primary" \
            '.[] | select(.name == $name) | .rect.height')
        swaymsg "output $LAPTOP enable"
        swaymsg "output $LAPTOP scale 1.0"
        swaymsg "output $LAPTOP resolution 1920x1200@60Hz position 0 $height"
        ;;
    *)
        echo "usage: $0 {close|open}" >&2
        exit 1
        ;;
esac
