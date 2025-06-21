#!/usr/bin/env python3

import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, Gio, GLib, Gdk
import os

class DmenuLikeLauncher(Gtk.Window):
    def __init__(self):
        super().__init__(title="Launcher")
        self.set_default_size(400, 50)
        self.set_decorated(False)
        self.set_resizable(False)
        self.set_modal(True)

        key_controller = Gtk.EventControllerKey()
        key_controller.connect("key-pressed", self.on_key_press)
        self.add_controller(key_controller)

        self.entry = Gtk.Entry()
        self.entry.set_placeholder_text("Type to search...")
        self.entry.connect("changed", self.on_entry_changed)
        self.entry.connect("activate", self.on_activate)

        self.listbox = Gtk.ListBox()
        self.listbox.set_selection_mode(Gtk.SelectionMode.SINGLE)
        self.listbox.set_vexpand(True)

        self.scrolled = Gtk.ScrolledWindow()
        self.scrolled.set_min_content_height(200)
        self.scrolled.set_child(self.listbox)

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        vbox.append(self.entry)
        vbox.append(self.scrolled)
        self.set_child(vbox)

        self.apps = []
        self.load_apps()
        self.update_list()

        self.entry.grab_focus()

    def load_apps(self):
        print("--- Starting application loading ---")
        paths = [
            os.path.join(GLib.get_user_data_dir(), "applications"),
            "/usr/share/applications",
            "/home/sk/.var/app",
            "/usr/local/share/applications",
        ]
        seen = set()
        self.apps = []

        for path in paths:
            print(f"Checking path: {path}")
            if not os.path.isdir(path):
                print(f"  Path does not exist or is not a directory: {path}")
                continue
            
            try:
                for file_name in os.listdir(path):
                    if not file_name.endswith(".desktop"):
                        continue
                    
                    desktop_id = file_name[:-8]
                    if desktop_id in seen:
                        print(f"  Skipping duplicate: {desktop_id} from {path}")
                        continue
                    
                    file_path = os.path.join(path, file_name)
                    print(f"  Attempting to load: {file_path}")
                    
                    try:
                        app_info = Gio.DesktopAppInfo.new_from_filename(file_path)
                        if app_info:
                            app_name = app_info.get_name()
                            app_executable = app_info.get_executable()
                            
                            if app_name and app_executable:
                                self.apps.append((app_name, desktop_id, app_info))
                                seen.add(desktop_id)
                                print(f"  Successfully loaded: '{app_name}' (ID: {desktop_id})")
                            else:
                                print(f"  Skipping '{file_name}' - Missing Name or Executable. Name: '{app_name}', Exec: '{app_executable}'")
                        else:
                            print(f"  Failed to create AppInfo for: {file_path} (File might be invalid or malformed)")
                    except Exception as e:
                        print(f"  Error processing desktop file '{file_name}': {e}")
            except Exception as e:
                print(f"Error listing directory {path}: {e}")
                continue
        
        self.apps.sort(key=lambda x: x[0].lower())
        print(f"--- Finished application loading. Total applications found: {len(self.apps)} ---")

    def update_list(self, filter_text=""):
        # Remove all existing children
        child = self.listbox.get_first_child()
        while child:
            next_child = child.get_next_sibling()
            self.listbox.remove(child)
            child = next_child

        # Add filtered applications
        for name, desktop_id, app_info in self.apps:
            if filter_text.lower() in name.lower():
                hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
                
                icon_image = Gtk.Image()
                if app_info:
                    icon = app_info.get_icon()
                    if icon:
                        icon_image.set_from_gicon(icon) 
                    else:
                        icon_image.set_from_icon_name("application-x-executable")
                else:
                    icon_image.set_from_icon_name("application-x-executable")
                
                label = Gtk.Label(label=name, xalign=0)
                label.set_hexpand(True)

                hbox.append(icon_image)
                hbox.append(label)
                
                listbox_row = Gtk.ListBoxRow()
                listbox_row.set_child(hbox)
                self.listbox.append(listbox_row)

        first = self.listbox.get_row_at_index(0)
        if first:
            self.listbox.select_row(first)

    def on_entry_changed(self, entry):
        text = entry.get_text()
        self.update_list(text)

    def on_activate(self, entry):
        row = self.listbox.get_selected_row()
        if not row:
            row = self.listbox.get_row_at_index(0)
        
        if not row:
            print("No application selected or found to launch.")
            self.close()
            return
            
        hbox_child = row.get_child()
        if not hbox_child or not isinstance(hbox_child, Gtk.Box):
            print("Error: Selected row does not contain an expected Gtk.Box child.")
            self.close()
            return
        
        # Correctly get the Gtk.Label which is the second child of the HBox
        app_label = hbox_child.get_last_child() # The label is the last child in your hbox
        
        if not isinstance(app_label, Gtk.Label):
            print("Error: Expected a Gtk.Label as the second child of the Gtk.Box.")
            self.close()
            return

        app_name = app_label.get_text() # Get the text from the label
        found_app_info = None
        for name, desktop_id, app_info in self.apps:
            if name == app_name:
                found_app_info = app_info
                break
        
        if found_app_info:
            try:
                found_app_info.launch([], None)
                print(f"Launched: {app_name}")
            except Exception as e:
                print(f"Error launching '{app_name}': {e}")
        else:
            print(f"Error: Could not find AppInfo for selected application: {app_name}")
            
        self.close()

    def on_key_press(self, controller, keyval, keycode, state):
        if keyval == Gdk.KEY_Escape:
            self.close()
            return True
        elif keyval in (Gdk.KEY_Up, Gdk.KEY_Down, Gdk.KEY_Tab):
            current_row = self.listbox.get_selected_row()
            index = -1
            if current_row:
                index = current_row.get_index()
            
            delta = 1 # Default to move down/next for Down and Tab
            if keyval == Gdk.KEY_Up:
                delta = -1 # Move up for Up key
            
            new_row_index = index + delta

            # Correct way to get the number of rows in GTK4 ListBox
            num_rows = 0
            row_iter = self.listbox.get_first_child()
            while row_iter:
                num_rows += 1
                row_iter = row_iter.get_next_sibling()
            
            if num_rows > 0:
                if new_row_index < 0:
                    new_row_index = num_rows - 1
                elif new_row_index >= num_rows:
                    new_row_index = 0
            else:
                return True # No rows to navigate

            new_row = self.listbox.get_row_at_index(new_row_index)
            if new_row:
                self.listbox.select_row(new_row)
                new_row.grab_focus()
            return True
        return False

def main():
    app = Gtk.Application(application_id="org.example.DmenuLikeLauncher")

    def on_activate(gtk_app):
        win = DmenuLikeLauncher()
        win.set_application(gtk_app)
        win.present()

    app.connect("activate", on_activate)
    app.run(None)

if __name__ == "__main__":
    main()
