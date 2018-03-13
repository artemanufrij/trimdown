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
    public class Note : Gtk.ListBoxRow {
        public Objects.Note note { get; private set; }

        public string title { get { return note.title; } }

        Gtk.Label label;

        public Note (Objects.Note note) {
            this.note = note;
            this.note.title_saved.connect (
                (new_title) => {
                    label.label = new_title;
                    (this.parent as Gtk.ListBox).invalidate_sort ();
                });
            this.note.removed.connect (
                ()=> {
                    this.dispose ();
                });
            build_ui ();
        }

        private void build_ui () {
            label = new Gtk.Label (note.title);
            label.margin = 6;
            label.xalign = 0;

            this.add (label);
            this.show_all ();
        }
    }
}