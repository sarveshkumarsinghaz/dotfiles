#!/usr/bin/env python3

import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, Gio, GLib, Gdk
import os
import datetime
import subprocess

class QuickNoteTaker(Gtk.Window):
    def __init__(self):
        super().__init__(title="Quick Note")
        self.set_default_size(500, 40) 
        self.set_decorated(False)
        self.set_resizable(False)
        self.set_modal(True)
        
        self.set_css_classes(["popup"])

        key_controller = Gtk.EventControllerKey()
        key_controller.connect("key-pressed", self.on_key_press)
        self.add_controller(key_controller)

        self.entry = Gtk.Entry()
        self.entry.set_placeholder_text("Please Enter Title")
        self.entry.connect("activate", self.on_activate)

        # Set the notes directory to ~/NOTES
        self.notes_dir = os.path.join(os.path.expanduser("~"), "NOTES")
        os.makedirs(self.notes_dir, exist_ok=True) # Ensure the directory exists

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        vbox.append(self.entry)
        self.set_child(vbox)

        self.entry.grab_focus()

    def on_activate(self, entry):
        raw_input_text = entry.get_text().strip()
        if not raw_input_text:
            print("Note: Title/Note cannot be empty. Please type something.")
            return

        # As requested, use the raw input text directly as the filename.
        # WARNING: This might lead to errors if the input contains characters
        # that are invalid for filenames on your operating system (e.g., /, \, ?, *, :, <, >, |).
        file_name = f"{raw_input_text}.md"
        file_path = os.path.join(self.notes_dir, file_name)

        # Prepare file content with # title
        file_content = f""

        # Add the timestamp and creator info at the end
        current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        footer = f"\n\n---\nCreated by Sarvesh at {current_time} IST"
        file_content += footer

        try:
            with open(file_path, "w") as f:
                f.write(file_content)
            
            print(f"Note file created: {file_path}")
            self.entry.set_text("") 

            # --- Configure your terminal emulator here ---
            # Uncomment and adjust the line for your preferred terminal.
            # For Alacritty:
            terminal_command = ["kitty", "-e", "nvim", file_path]
            # For Gnome Terminal:
            # terminal_command = ["gnome-terminal", "--", "nvim", file_path]
            # For Kitty:
            # terminal_command = ["kitty", "--hold", "nvim", file_path]
            # For Konsole:
            # terminal_command = ["konsole", "-e", "nvim", file_path]
            # For Xterm:
            # terminal_command = ["xterm", "-e", "nvim", file_path]
            
            subprocess.Popen(terminal_command)
            
            self.close()
            
        except FileNotFoundError:
            # Catches errors if 'alacritty' or 'nvim' commands are not found in PATH
            print(f"Error: Command '{terminal_command[0]}' or 'nvim' not found in your system's PATH. Please ensure they are installed and accessible.")
        except OSError as e:
            # Catches errors related to invalid filenames (e.g., forbidden characters)
            print(f"Error: Cannot create file with name '{file_name}'. It might contain characters that are invalid for a filename on your operating system. Details: {e}")
        except Exception as e:
            # Catches any other unexpected errors
            print(f"An unexpected error occurred: {e}")
            
    def on_key_press(self, controller, keyval, keycode, state):
        if keyval == Gdk.KEY_Escape:
            self.close()
            return True
        return False

def main():
    app = Gtk.Application(application_id="org.example.QuickNoteTaker")

    def on_activate(gtk_app):
        win = QuickNoteTaker()
        win.set_application(gtk_app)
        win.present()

    app.connect("activate", on_activate)
    app.run(None)

if __name__ == "__main__":
    main()
