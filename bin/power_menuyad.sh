#!/bin/bash

# This script creates a beautiful power menu using Rofi.
# It provides options to Shutdown, Reboot, Logout, Suspend, and Lock the system.
#
# Prerequisites:
# - Rofi: Install it via your package manager (e.g., `sudo apt install rofi` for Debian/Ubuntu,
#         `sudo pacman -S rofi` for Arch Linux).
# - systemctl: For power management commands (shutdown, reboot, suspend).
# - betterlockscreen: For locking the screen. Ensure it's installed and configured.
#   If you don't use betterlockscreen, replace `betterlockscreen -l dim` with your preferred
#   screen locking command (e.g., `i3lock`, `gnome-screensaver-command -l`).
# - Qtile (or your Desktop Environment's logout command): The logout command is specific to Qtile.
#   If you use a different Window Manager or Desktop Environment, replace
#   `qtile cmd-obj -o cmd -f shutdown` with the appropriate logout command
#   (e.g., `loginctl terminate-session $XDG_SESSION_ID` for systemd-based DEs,
#   or `pkill X` for a general X session kill).
# - A Nerd Font or Font Awesome: For the icons to display correctly in the menu.
#   (e.g., JetBrainsMono Nerd Font, FiraCode Nerd Font).

# --- Configuration ---
# Define icons and labels for the power menu options.
# These icons require a Nerd Font or Font Awesome to display correctly.
SHUTDOWN_ICON=""  # Font Awesome: power-off
REBOOT_ICON=""   # Font Awesome: sync-alt / recycle
LOGOUT_ICON=""    # Font Awesome: sign-out-alt
SUSPEND_ICON=""   # Font Awesome: moon / sleep
LOCK_ICON=""     # Font Awesome: lock

# Define the menu options, each formatted as "ICON Label".
# These will be piped to Rofi.
OPTIONS="
$SHUTDOWN_ICON Shutdown
$REBOOT_ICON Reboot
$LOGOUT_ICON Logout
$SUSPEND_ICON Suspend
$LOCK_ICON Lock
"

# Rofi command to display the menu.
#
# -dmenu: Enables dmenu mode, where Rofi acts as a simple input/selection tool.
# -p "Power Menu": Sets the prompt text displayed by Rofi.
# -theme-str: Allows inline CSS-like styling for Rofi. This is a basic example
#             to get a dark background and light text. For advanced styling
#             (glassy blur, rounded corners, shadows), you should configure
#             Rofi via its theme file (e.g., ~/.config/rofi/config.rasi).
# -width 25: Sets the width of the Rofi window as a percentage of the screen width.
# -location 0: Places the Rofi window at the center of the screen.
#              (0 = center, 1 = top-left, 2 = top-right, etc.)
# -hide-scrollbar: Hides the scrollbar for a cleaner look.
# -line-padding 12: Adds vertical padding around each menu item.
# -padding 20: Adds internal padding around the entire menu content.
# -font "JetBrainsMono Nerd Font 14": Sets the font and size for menu items.
# -color-window "#181825": Sets the background color of the Rofi window (matches Qtile bar_bg).
# -color-normal "#181825,#CDD6F4,#181825,#89B4FA,#CDD6F4":
#   This is a comma-separated list of colors for normal items:
#   - background (normal)
#   - foreground (normal)
#   - background (alternate row)
#   - foreground (selected)
#   - background (selected)
#   So, it sets normal text to light, selected background to accent blue, and selected text to light.

ROFI_CMD="rofi -dmenu \
               -p \"Power Menu\" \
               -width 25 \
               -location 0 \
               -hide-scrollbar \
               -line-padding 12 \
               -padding 20 \
               -font \"JetBrainsMono Nerd Font 14\" \
               -color-window \"#181825\" \
               -color-normal \"#181825,#CDD6F4,#181825,#89B4FA,#CDD6F4\" \
               -color-active \"#282A36,#89B4FA,#CDD6F4,#89B4FA,#CDD6F4\" \
               -color-urgent \"#F38BA8,#CDD6F4,#F38BA8,#CDD6F4,#F38BA8\""

# Pipe the options to Rofi and capture the selected choice.
# `echo -e "$OPTIONS"` is used to interpret newline characters in the OPTIONS string.
selected_option=$(echo -e "$OPTIONS" | $ROFI_CMD)

# --- Action Handling ---
# Use a case statement to perform actions based on the selected option.
# We trim whitespace and match the full string.
case $(echo "$selected_option" | xargs) in # `xargs` trims whitespace from the selection
    "$SHUTDOWN_ICON Shutdown")
        systemctl poweroff
        ;;
    "$REBOOT_ICON Reboot")
        systemctl reboot
        ;;
    "$LOGOUT_ICON Logout")
        qtile cmd-obj -o cmd -f shutdown # Qtile specific logout
        ;;
    "$SUSPEND_ICON Suspend")
        systemctl suspend
        ;;
    "$LOCK_ICON Lock")
        betterlockscreen -l dim
        ;;
    *) # Handles cases where nothing is selected or Rofi is closed without selection
        echo "Power menu cancelled or no option selected."
        ;;
esac

