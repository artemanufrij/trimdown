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

namespace TrimDown.Dialogs {
    public class NewProject : Gtk.Dialog {
        public NewProject(Gtk.Window parent) {
            Object (
transient_for: parent,
resizable: false,
                use_header_bar: 1
                );
            build_ui ();
        }

        private void build_ui () {
            // HEADER
            var header = this.get_header_bar () as Gtk.HeaderBar;
            header.get_style_context ().add_class ("default-decoration");
            header.set_custom_title (
                new Gtk.Label (_ ("New Project")) {
                    margin_top = 6
                });

            // CONTENT
            Gtk.Box content = this.get_content_area () as Gtk.Box;

            var grid = new Gtk.Grid ();
            grid.margin = 12;
            grid.row_spacing = 12;

            var project_name = new Gtk.Entry ();
            project_name.hexpand = true;
            project_name.placeholder_text = _ ("Project name");
            project_name.get_style_context ().add_class ("h3");
            grid.attach (project_name, 0, 0);

            var project_type = new Gtk.ComboBoxText ();
            grid.attach (project_type, 0, 1);

            content.pack_start (grid);

            // ACTION BUTTONS
            Gtk.Box actions = this.get_action_area () as Gtk.Box;

            var create_button = new Gtk.Button.with_label (_ ("Create"));
            create_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            create_button.clicked.connect (
                () => {
                    this.response (Gtk.ResponseType.ACCEPT);
                });

            actions.add (create_button);

            this.show_all ();
        }
    }
}