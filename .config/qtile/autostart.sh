#!/bin/sh
dbus-update-activation-environment --systemd XDG_CURRENT_DESKTOP XDG_SESSION_TYPE &

# Remap Caps Lock to Control
setxkbmap -option caps:ctrl_modifier &

# Set wallpaper using swaybg
feh --no-fehbg --bg-fill '/home/sk/dotfiles/wallapapers/wallhaven9.png'

# Start polkit-gnome authentication agent
/usr/lib/polkit-kde-authentication-agent-1 &

#Appleits and numlock on 
numlockx on &
nm-applet &
#pasystray &


# Explicitly set GTK theme for applications
export GTK_THEME="Catppuccin-Mocha-Standard-Dark"
export QT_QPA_PLATFORMTHEME="qt5ct"

# Start Dunst notification daemon
if ! pgrep -x "dunst" > /dev/null; then
    dunst &
fi

# Start Picom compositor
if ! pgrep -x "picom" > /dev/null; then
    picom --config ~/.config/picom/picom.conf &
fi

# Start xautolock for automatic screen locking (e.g., after 10 minutes)
if ! pgrep -x "xautolock" > /dev/null; then
    xautolock -time 10 -locker "betterlockscreen -l dim" &
fi
