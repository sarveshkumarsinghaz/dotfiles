import os
import subprocess
from libqtile import hook
from libqtile import bar, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

# --- Color Palette (Sophisticated Dark Theme) ---
# Inspired by a professional dark theme with subtle accents
colors = {
    "background": "#0e1419",  # Darkest background (similar to Dracula/Catppuccin Midnight)
    "foreground": "#CDD6F4",  # Light text for contrast
    "primary_accent": "#89B4FA", # Blue accent for active elements
    "secondary_accent": "#A6E3A1", # Green accent for positive indicators
    "tertiary_accent": "#F9E2AF", # Yellow/Orange accent for warnings/attention
    "red": "#F38BA8",         # Error/Critical
    "white": "#FFFFFF",         
    "black": "#000000",         
    "gray_dark": "#45475A",   # Darker gray for inactive elements/separators
    "gray_light": "#6C7086",  # Lighter gray for less prominent text
    "bar_bg": "#0e1419",      # Slightly lighter than background for the bar itself
}


mod = "mod4"
terminal = "kitty"

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack"),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "a", lazy.spawn("dolphin"), desc="Open dolphin window"),
    Key([mod], "w", lazy.spawn("brave --password-store=basic %U"), desc="Launch Chromium"),
    Key([mod], "e", lazy.spawn(f"{terminal} -e yazi"), desc="File Launcher"),
    Key([mod, "shift"], "e", lazy.spawn(f"{terminal} --hold sudo yazi"), desc="File Launcher"),
    Key([mod, "control"], "l", lazy.spawn("betterlockscreen -l dim"), desc="Lock screen"),
    Key([mod], "x", lazy.spawn(os.path.expanduser("~/.config/rofi/scripts/powermenu_t2")), desc="Show power menu"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen on the focused window"),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "d", lazy.spawn("/home/sk/.local/bin/dmenu-launcher"), desc="Launch dmenu with custom settings"),

    # Custom Keybindings
    Key([mod], "s", lazy.spawn(os.path.expanduser("~/dotfiles/.config/rofi/scripts/launcher_t3")), desc="Launch Rofi (application launcher)"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%"), desc="Increase volume"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%"), desc="Decrease volume"),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"), desc="Toggle mute"),
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl s +5%"), desc="Increase brightness"),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl s 5%-"), desc="Decrease brightness"),

    # Scratchpad Keybindings
    Key(["control"], "f1", lazy.group["scratchpad"].dropdown_toggle("kitty"), desc="Toggle kitty scratchpad"),
    Key(["control"], "f2", lazy.group["scratchpad"].dropdown_toggle("wiremix"), desc="Toggle wiremix scratchpad"),
    Key(["control"], "f3", lazy.group["scratchpad"].dropdown_toggle("bluetui"), desc="Toggle bluetui scratchpad"),
    Key(["control"], "f4", lazy.group["scratchpad"].dropdown_toggle("calcurse"), desc="Toggle calcurse scratchpad"),
    Key(["control"], "f5", lazy.group["scratchpad"].dropdown_toggle("nmtui"), desc="Toggle nmtui scratchpad"),

    # Resize Active Window (Grow/Shrink)
    Key([mod], "i", lazy.layout.grow(), desc="Grow focused window"),
    Key([mod], "o", lazy.layout.shrink(), desc="Shrink focused window"),
]

# Add key bindings to switch VTs in Wayland.
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )

groups = [Group(i) for i in "123456789"]

# Add ScratchPad group
groups.append(
    ScratchPad(
        "scratchpad",
        [
            DropDown(
                "kitty",
                terminal,
                x=0.2, y=0.2, width=0.6, height=0.6,
                opacity=0.9, # Added opacity for scratchpads
                on_hide_callback=lazy.window.cmd_disable_floating(),
            ),
            DropDown(
                "wiremix",
                f"{terminal} -e wiremix -v output", # aSSUMING WIREMIX RUNS IN TERMINAL
                x=0.2, y=0.2, width=0.6, height=0.6,
                opacity=0.9, # Added opacity for scratchpads
                on_hide_callback=lazy.window.cmd_disable_floating(),
            ),
            DropDown(
                "bluetui",
                f"{terminal} -e bluetui", # Assuming bluetui runs in terminal
                x=0.2, y=0.2, width=0.6, height=0.6,
                opacity=0.9, # Added opacity for scratchpads
                on_hide_callback=lazy.window.cmd_disable_floating(),
            ),
            DropDown(
                "calcurse",
                f"{terminal} -e calcurse", # Assuming calcurse runs in terminal
                x=0.2, y=0.2, width=0.6, height=0.6,
                opacity=0.9, # Added opacity for scratchpads
                on_hide_callback=lazy.window.cmd_disable_floating(),
            ),
            DropDown(
                "nmtui",
                f"{terminal} -e tui-network", # Assuming nmtui runs in terminal
                x=0.2, y=0.2, width=0.6, height=0.6,
                opacity=0.9, # Added opacity for scratchpads
                on_hide_callback=lazy.window.cmd_disable_floating(),
            ),
        ],
    )
)

for i in groups:
    if i.name != "scratchpad": # Exclude scratchpad from regular group keybindings
        keys.extend(
            [
                # mod + group number = switch to group
                Key(
                    [mod],
                    i.name,
                    lazy.group[i.name].toscreen(),
                    desc=f"Switch to group {i.name}",
                ),
                # mod + shift + group number = switch to & move focused window to group
                Key(
                    [mod, "shift"],
                    i.name,
                    lazy.window.togroup(i.name, switch_group=True),
                    desc=f"Switch to & move focused window to group {i.name}",
                ),
            ]
        )

layouts = [
    # layout.Columns(
    #     border_focus=colors["primary_accent"],
    #     border_normal=colors["gray_dark"],
    #     border_width=2,
    #     margin=6,
    # ),
    # layout.Max(),
    layout.MonadTall(
        border_focus=colors["primary_accent"],
        border_normal=colors["gray_dark"],
        border_width=2,
        margin=6,
    ),
    layout.Floating(
        border_focus=colors["primary_accent"],
        border_normal=colors["gray_dark"],
        border_width=2,
    ),
]

widget_defaults = dict(
    font="JetBrainsMono Nerd Font Bold", # Requires Nerd Font for icons
    fontsize=16,
    padding=3,
    background=colors["bar_bg"],
    foreground=colors["foreground"],
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.TextBox(
                    text="", # Arch Linux icon, large and distinct
                    fontsize=20,
                    foreground=colors["primary_accent"],
                    background=colors["bar_bg"],
                    padding=10,
                    mouse_callbacks={"Button1": lazy.spawn(os.path.expanduser("~/.config/rofi/scripts/launcher_t3"))},
                ),
                widget.GroupBox(
                    margin_y=3,
                    margin_x=0,
                    padding_y=5,
                    padding_x=8,
                    borderwidth=4, # No border for a cleaner look
                    active=colors["white"],
                    inactive=colors["gray_light"],
                    rounded=True,
                    highlight_color=colors["bar_bg"],
                    block_highlight_text_color=colors["white"],
                    highlight_method="line", # Highlight text only
                    this_current_screen_border=colors["white"],
                    this_screen_border=colors["red"],
                    other_current_screen_border=colors["gray_dark"],
                    other_screen_border=colors["gray_dark"],
                    foreground=colors["foreground"],
                    background=colors["bar_bg"],
                ),
                widget.CurrentLayoutIcon(
                    custom_icon_paths=[os.path.expanduser("~/.config/qtile/icons")],
                    foreground=colors["secondary_accent"],
                    background=colors["bar_bg"],
                    padding=5,
                    scale=0.7,
                ),
                #widget.Spacer(length=bar.STRETCH), # Pushes widgets to the right
                widget.WindowName(
                    foreground=colors["foreground"],
                    background=colors["bar_bg"],
                    format=' {name}', # Added a generic window icon
                    empty_group_string="Welcome to your desktop", # Friendly message
                    max_chars=80, #
                    padding=10, #
                ),
                widget.Spacer(length=bar.STRETCH), # Pushes widgets to the left

                widget.Prompt(
                    prompt='  Run: ', # Icon for prompt
                    foreground=colors["tertiary_accent"], #
                    background=colors["bar_bg"], #
                    padding=10, #
                ),
                widget.Chord(
                    chords_colors={
                        "launch": (colors["red"], colors["background"]),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                # widget.CPU(
                #    format=' {load_percent}%', # CPU icon
                #    foreground=colors["foreground"], #
                #    background=colors["bar_bg"], #
                #    padding=5, #
                #    update_interval=3, #
                # ),
                # widget.TextBox(
                #     text="|", #
                #     foreground=colors["gray_dark"], #
                #     background=colors["bar_bg"], #
                #     padding=2, #
                #    fontsize=16, #
                # ),
                # widget.Memory(
                #     format='󰍛 {MemUsed:.0f}{mm}/{MemTotal:.0f}{mm}', # Memory icon
                #     measure_mem='G', #
                #     foreground=colors["foreground"], #
                #     background=colors["bar_bg"], #
                #     padding=5, #
                #     update_interval=3,
                #     mouse_callbacks={
                #         "Button1": lazy.spawn(f"{terminal} -e btop")
                #     } #
                # ),
                # widget.TextBox(
                #     text="|", #
                #     foreground=colors["gray_dark"], #
                #    background=colors["bar_bg"], #
                #     padding=2, #
                #     fontsize=16, #
                # ),
                # Custom Network Speed (no decimals)
                # widget.GenPollText(
                #     func=lambda: subprocess.check_output(
                #         os.path.expanduser("~/.config/qtile/network_speed.py")
                #     ).decode("utf-8").strip(),
                #     update_interval=3, # How often to run the script (in seconds)
                #     foreground=colors["foreground"], #
                #     background=colors["bar_bg"], #
                #     padding=5, #
                #     name="network_speed",
                #     mouse_callbacks={
                #         "Button1": lazy.spawn(f"{terminal} -e tui-network")
                #     }
                # ),
                #widget.Systray(
                #    background=colors["bar_bg"], #
                #    padding=5, #
                #),
                # widget.TextBox(
                #      text="|", #
                #      foreground=colors["gray_dark"], #
                #      background=colors["bar_bg"], #
                #      padding=2, #
                #      fontsize=16, #
                # ),
                # widget.TextBox(
                #     text="| ", #
                #     foreground=colors["gray_dark"], #
                #     background=colors["bar_bg"], #
                #     padding=2, #
                #     fontsize=16, #
                # ),
                widget.Systray(
                    background=colors["bar_bg"], #
                    padding=5, #
                ),
                widget.Bluetooth(
                    default_text=' {connected_devices}',
                    default_show_battery=True,
                    device_battery_format=' 󰥉 {battery}%',
                    mouse_callbacks={
                         "Button1": lazy.spawn(f"{terminal} -e bluetui"),
                    },
                    foreground=colors["white"], #
                    background=colors["bar_bg"], #
                    padding=5, 

                ),
                widget.TextBox(
                    text="|", 
                    foreground=colors["gray_dark"], #
                    background=colors["bar_bg"], #
                    padding=2, 
                    fontsize=16, 
                ),
                widget.Volume(
                     fmt='󰕾 {}', # Volume icon
                     foreground=colors["foreground"], #
                     background=colors["bar_bg"], #
                     padding=5, #
                     mouse_callbacks={
                         "Button1": lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"),
                         "Button3": lazy.spawn(f"{terminal} -e wiremix -v output"),
                     },
                 ),
                widget.TextBox(
                     text="|", #
                     foreground=colors["gray_dark"], #
                     background=colors["bar_bg"], #
                     padding=2, #
                     fontsize=16, #
                ),
                widget.Clock(
                    format="󰃰 %I:%M %p |  %a %d %b", # Clock and Calendar icons
                    foreground=colors["foreground"], #
                    background=colors["bar_bg"], #
                    padding=5, #
                    mouse_callbacks={
                        "Button1": lazy.spawn(f"{terminal} -e calcurse")
                    }
                ),
                widget.TextBox(
                    text=" |", #
                    foreground=colors["gray_dark"], #
                    background=colors["bar_bg"], #
                    padding=2, #
                    fontsize=16, #
                ),
                widget.Image(
                    filename='/home/sk/dotfiles/.config/qtile/power-on.png', #
                    foreground=colors["red"], #
                    background=colors["bar_bg"], #
                    padding=10, #
                    mouse_callbacks={
                        "Button1": lazy.spawn( os.path.expanduser("~/.config/rofi/scripts/powermenu_t2"))
                    } #
                ),
            ],
            30, # Slightly increased bar height for presence
            background=colors["bar_bg"], #
            opacity=0.85, # Changed to 0.85 for more transparency
            margin=[5, 5, 2, 5] # Consistent margin around the bar
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    border_focus=colors["primary_accent"],
    border_normal=colors["gray_dark"],
    border_width=2,
    margin=6,

    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(wm_class="confirm"),
        Match(wm_class="dialog"),
        Match(wm_class="download"),
        Match(wm_class="error"),
        Match(wm_class="file_progress"),
        Match(wm_class="notification"),
        Match(wm_class="splash"),
        Match(wm_class="toolbar"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(title="branchdialog"),
        Match(title="Confirm File Replace"),
        Match(title="About Qtile"),
        Match(title="feh"),
        Match(wm_class="feh"),
        Match(wm_class="pavucontrol"),
        Match(wm_class="blueman-manager"),
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = None
wl_xcursor_size = 24

wmname = "LG3D"
@hook.subscribe.startup_once
def autostart():
    subprocess.Popen([os.path.expanduser("/home/sk/.config/qtile/autostart.sh")])
