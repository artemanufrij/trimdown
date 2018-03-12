/*-
 * Copyright (c) 2018-2018 Artem Anufrij <artem.anufrij@live.de>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * The Noise authors hereby grant permission for non-GPL compatible
 * GStreamer plugins to be used and distributed together with GStreamer
 * and Noise. This permission is above and beyond the permissions granted
 * by the GPL license by which Noise is covered. If you modify this code
 * you may extend this exception to your version of the code, but you are not
 * obligated to do so. If you do not wish to do so, delete this exception
 * statement from your version.
 *
 * Authored by: Artem Anufrij <artem.anufrij@live.de>
 */

namespace TrimDown {
    public class MainWindow : Gtk.Window {
        Services.ProjectManager project_manager;
        Settings settings;

        Gtk.HeaderBar headerbar;
        Gtk.Stack content;
        Gtk.MenuButton app_menu;
        Gtk.Button open_proj;
        Gtk.Button new_proj;
        Gtk.Button notes_button;

        Widgets.Views.Writer writer;

        construct {
            settings = Settings.get_default ();
            project_manager = Services.ProjectManager.instance;
        }

        public MainWindow () {
            load_settings ();
            build_ui ();
            this.configure_event.connect (
                (event) => {
                    settings.window_width = event.width;
                    settings.window_height = event.height;
                    return false;
                });

            this.delete_event.connect (
                () => {
                    save_settings ();
                    return false;
                });
        }

        private void build_ui () {
            headerbar = new Gtk.HeaderBar ();
            headerbar.title = "TrimDown";
            headerbar.show_close_button = true;
            headerbar.get_style_context ().add_class ("default-decoration");
            this.set_titlebar (headerbar);

            new_proj = new Gtk.Button.from_icon_name ("document-new", Gtk.IconSize.LARGE_TOOLBAR);
            new_proj.clicked.connect (create_project_action);
            headerbar.pack_start (new_proj);

            open_proj = new Gtk.Button.from_icon_name ("document-open", Gtk.IconSize.LARGE_TOOLBAR);
            open_proj.clicked.connect (open_project_action);
            headerbar.pack_start (open_proj);

            // SETTINGS MENU
            app_menu = new Gtk.MenuButton ();
            app_menu.valign = Gtk.Align.CENTER;
            app_menu.set_image (new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR));

            var settings_menu = new Gtk.Menu ();

            var menu_item_preferences = new Gtk.MenuItem.with_label (_ ("Preferences"));
            menu_item_preferences.activate.connect (
                () => {
                });
            settings_menu.append (menu_item_preferences);
            settings_menu.show_all ();

            app_menu.popup = settings_menu;
            headerbar.pack_end (app_menu);

            // NOTES
            var notes = new Widgets.Notes ();

            notes_button = new Gtk.Button.from_icon_name ("format-text-highlight", Gtk.IconSize.LARGE_TOOLBAR);

            var notes_popup = new Gtk.Popover (notes_button);
            notes_popup.closed.connect (
                () => {
                    notes.save_note ();
                });
            notes_popup.add (notes);
            notes_button.clicked.connect (
                () => {
                    if (writer.current_chapter != null) {
                        notes.show_notes (writer.current_chapter);
                    }
                    notes_popup.show_all ();
                });
            headerbar.pack_end (notes_button);

            var bin_items = new Gtk.Button.from_icon_name ("user-deleted-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            headerbar.pack_end (bin_items);

            content = new Gtk.Stack ();

            var welcome = new Widgets.Views.Welcome ();
            welcome.new_project_clicked.connect (create_project_action);
            welcome.open_project_clicked.connect (open_project_action);

            writer = new Widgets.Views.Writer ();

            content.add_named (welcome, "welcome");
            content.add_named (writer, "writer");
            this.add (content);
            this.show_all ();
            new_proj.hide ();
            open_proj.hide ();
            notes_button.hide ();
        }

        private void open_project_action () {
            var project = project_manager.open_project ();
            if (project != null) {
                open_project (project);
            }
        }

        private void create_project_action () {
            var new_project = new Dialogs.NewProject (this);
            if (new_project.run () == Gtk.ResponseType.ACCEPT) {
                var project = project_manager.create_new_project (new_project.project_title, new_project.project_kind);
                if (project != null) {
                    open_project (project);
                }
            }
            new_project.destroy ();
        }

        public void new_chapter_action () {
            if (content.visible_child_name == "writer" && writer.current_project != null) {
                writer.current_project.generate_new_chapter ();
            }
        }

        public void new_scene_action () {
            if (content.visible_child_name == "writer" && writer.current_chapter != null) {
                writer.current_chapter.generate_new_scene ();
            }
        }

        private void open_project (Objects.Project project) {
            headerbar.title = project.title;
            writer.show_project (project);
            content.visible_child_name = "writer";
            open_proj.show ();
            new_proj.show ();
            notes_button.show ();
        }

        private void load_settings () {
            this.set_default_size (settings.window_width, settings.window_height);

            if (settings.window_x < 0 || settings.window_y < 0 ) {
                this.window_position = Gtk.WindowPosition.CENTER;
            } else {
                this.move (settings.window_x, settings.window_y);
            }
        }

        private void save_settings () {
            int x, y;
            this.get_position (out x, out y);
            settings.window_x = x;
            settings.window_y = y;
        }
    }
}
