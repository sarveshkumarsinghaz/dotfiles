#!/bin/bash

# List of options
options="Shutdown\nReboot\nLogout"

# Show menu using Rofi and capture the selected option
# -dmenu: Enables dmenu mode for Rofi, which is suitable for this type of menu.
# -p "Power Menu:": Sets the prompt text displayed by Rofi.
selected=$(echo -e "$options" | rofi -dmenu -p "Power Menu: " -theme ~/.config/rofi/power_menu.rasi)

# Run selected command based on user's choice
case "$selected" in
    "Shutdown")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Logout")
        # This command is specific to Qtile.
        # Ensure 'qtile' is in your PATH or provide the full path to the executable.
        qtile cmd-obj -o cmd -f shutdown
        ;;
    *)
        # Handle cases where the user presses Esc or clicks outside the menu
        # This prevents an empty command from being executed.
        echo "No option selected or invalid option: $selected"
        ;;
esac
