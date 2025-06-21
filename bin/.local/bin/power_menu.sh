#!/bin/bash

# Define the power options
options="Shutdown\nReboot\nSuspend\nHibernate\nLogout"

# Get the chosen option from Rofi
# -dmenu: Run Rofi in dmenu mode
# -i: Case-insensitive matching
# -p "Power Menu:": Set the prompt text
# -theme-str: Optional - provides basic styling, you can customize more in a dedicated Rofi theme file
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu:" \
    -theme-str 'listview { lines: 5; }' \
    -theme-str 'element { padding: 8px; }' \
    -theme-str 'element-text { foreground: #cdd6f4; }' \
    -theme-str 'inputbar { background: #313244; border: 0px; padding: 8px; border-radius: 5px; }' \
    -theme-str 'entry { placeholder: "Select action..."; }' \
    -theme-str 'prompt { enabled: false; }' \
    -theme-str 'window { border: 2px; border-radius: 8px; border-color: #89b4fa; background-color: #1e1e2e; }' \
    -theme-str 'mainbox { children: [ "inputbar", "listview" ]; }' \
    -theme-str 'element selected { background-color: #585b70; }' \
    -theme-str 'scrollbar { handle-color: #89b4fa; }'
)

# Execute action based on the chosen option
case "$chosen" in
    "Shutdown")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Suspend")
        systemctl suspend
        ;;
    "Hibernate")
        systemctl hibernate
        ;;
    "Logout")
        # This is the command to safely shut down your Qtile session
        qtile cmd-obj -o cmd -f shutdown
        ;;
    *)
        # Do nothing if nothing was selected or Esc was pressed
        exit 0
        ;;
esac
