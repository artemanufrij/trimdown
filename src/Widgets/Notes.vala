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

namespace TrimDown.Widgets {
    public class Notes : Gtk.Grid {
        Gtk.ListBox notes;

        public Notes () {
            build_ui ();
        }

        private void build_ui () {
            this.width_request = 320;
            this.height_request = 200;

            notes = new Gtk.ListBox ();
            var scroll = new Gtk.ScrolledWindow (null, null);
            scroll.width_request = 90;
            scroll.vexpand = true;
            scroll.add (notes);

            var text = new Gtk.SourceView ();
            text.expand = true;

            var action_toolbar = new Gtk.ActionBar ();
            action_toolbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
            var add_button = new Gtk.Button.from_icon_name ("list-add-symbolic");
            add_button.tooltip_text = _ ("Add a Note");
            add_button.clicked.connect (
                () => {

                });
            action_toolbar.pack_start (add_button);

            this.attach (scroll, 0, 0);
            this.attach (action_toolbar, 0, 1);
            this.attach (new Gtk.Separator (Gtk.Orientation.VERTICAL), 1, 0, 1, 2);
            this.attach (text, 2, 0, 1, 2);

            this.show_all ();
        }

        public void show_notes (Objects.Chapter chapter) {
            reset ();
            foreach (var note in chapter.notes) {
                var item = new Widgets.Note (note);
                notes.add (item);
            }
        }

        public void reset () {
            foreach (var child in notes.get_children ()) {
                child.destroy ();
            }
        }
    }
}