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
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
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

namespace TrimDown.Dialogs {
    public class Preferences : Gtk.Dialog {
        Settings settings;

        construct {
            settings = Settings.get_default ();
        }

        public Preferences (Gtk.Window parent) {
            Object (transient_for: parent, deletable: false, resizable: false);
            build_ui ();
        }

        private void build_ui () {
            var use_dark_theme = new Gtk.Switch ();
            use_dark_theme.active = settings.use_dark_theme;
            use_dark_theme.notify["active"].connect (
                () => {
                    settings.use_dark_theme = use_dark_theme.active;
                });

            var remember_last_project = new Gtk.Switch ();
            remember_last_project.active = settings.remember_last_project;
            remember_last_project.notify["active"].connect (
                () => {
                    settings.remember_last_project = remember_last_project.active;
                });


            var genera_grid = new Gtk.Grid ();
            genera_grid.column_spacing = 12;
            genera_grid.row_spacing = 12;
            genera_grid.margin = 12;

            genera_grid.attach (label_generator (_ ("Use Dark Theme")), 0, 0);
            genera_grid.attach (use_dark_theme, 1, 0);
            genera_grid.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 1, 2, 1);
            genera_grid.attach (label_generator (_ ("Remember last Project")), 0, 2);
            genera_grid.attach (remember_last_project, 1, 2);

            var content = this.get_content_area () as Gtk.Box;
            content.pack_start (genera_grid, false, false, 0);



            var close_button = new Gtk.Button.with_label (_ ("Close"));
            close_button.clicked.connect (() => { this.destroy (); });

            Gtk.Box actions = this.get_action_area () as Gtk.Box;
            actions.add (close_button);

            this.show_all ();
        }

        private Gtk.Label ? label_generator (string content) {
            return new Gtk.Label (content) {
                       halign = Gtk.Align.START,
                       hexpand = true
            };
        }
    }
}