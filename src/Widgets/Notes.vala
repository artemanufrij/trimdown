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

namespace TrimDown.Widgets {
    public class Notes : Gtk.Grid {
        public Objects.Chapter current_chapter { get; private set; default = null; }
        public Objects.Note current_note { get; private set; default = null; }

        Gtk.ListBox notes;
        Gtk.Entry title;
        Gtk.SourceView text;

        public Notes () {
            build_ui ();
        }

        private void build_ui () {
            this.width_request = 380;
            this.height_request = 320;

            notes = new Gtk.ListBox ();
            notes.set_sort_func (Utils.notes_sort_func);
            notes.set_filter_func (notes_filter_func);
            notes.selected_rows_changed.connect (
                () => {
                    save_note ();
                    if (notes.get_selected_row () is Widgets.Note) {
                        open_note ((notes.get_selected_row () as Widgets.Note).note);
                    }
                });
            var scroll = new Gtk.ScrolledWindow (null, null);
            scroll.width_request = 120;
            scroll.vexpand = true;
            scroll.add (notes);

            title = new Gtk.Entry ();
            title.xalign = 0.5f;
            title.has_frame = false;
            title.get_style_context ().add_class ("h3");
            title.focus_out_event.connect (
                () => {
                    save_title ();
                    return false;
                });

            text = new Gtk.SourceView ();
            text.expand = true;
            text.top_margin = text.bottom_margin = text.left_margin = text.right_margin = 6;

            var note = new Gtk.Grid ();
            note.attach (title, 0, 0);
            note.attach (text, 0, 1);

            var action_toolbar = new Gtk.ActionBar ();
            var add_button = new Gtk.Button.from_icon_name ("list-add-symbolic");
            add_button.tooltip_text = _ ("Add a Note");
            add_button.clicked.connect (
                () => {
                    current_chapter.generate_new_note ();
                });
            action_toolbar.pack_start (add_button);

            this.attach (scroll, 0, 0);
            this.attach (action_toolbar, 0, 1);
            this.attach (new Gtk.Separator (Gtk.Orientation.VERTICAL), 1, 0, 1, 2);
            this.attach (note, 2, 0, 1, 2);

            this.show_all ();
        }

        public void show_notes (Objects.Chapter chapter) {
            if (current_chapter == chapter) {
                return;
            }

            if (current_chapter != null) {
                current_chapter.note_created.disconnect (add_note);
            }

            reset ();
            foreach (var note in chapter.notes) {
                var item = new Widgets.Note (note);
                note.bin_location_changed.connect (refilter_note);
                notes.add (item);
            }
            refilter_note ();

            current_chapter = chapter;

            current_chapter.note_created.connect (add_note);
        }

        public void reset () {
            current_chapter = null;
            current_note = null;
            foreach (var child in notes.get_children ()) {
                child.destroy ();
            }
        }

        private void add_note (Objects.Note note) {
            var item = new Widgets.Note (note);
            notes.add (item);
            note.bin_location_changed.connect (refilter_note);
            item.activate ();
            title.grab_focus ();
        }

        private void open_note (Objects.Note note) {
            if (current_note == note) {
                return;
            }

            if (current_note != null) {
                current_note.title_saved.disconnect (set_new_title);
            }

            current_note = note;
            title.text = note.title;
            text.buffer.text = note.get_content ();
            current_note.title_saved.connect (set_new_title);
        }

        public void save_note () {
            if (current_note != null) {
                current_note.save_content (text.buffer.text);
                save_title ();
            }
        }

        private void save_title () {
            if (current_note != null) {
                var note_title = title.text.strip ();
                if (current_note.title != note_title) {
                    current_note.set_new_title (note_title);
                }
            }
        }

        private void refilter_note () {
            save_note ();
            notes.invalidate_filter ();
            current_note = null;
            title.text = "";
            text.buffer.text = "";
        }

        private void set_new_title (string new_title) {
            title.text = new_title;
        }

        private bool notes_filter_func (Gtk.ListBoxRow child) {
            var item = (Widgets.Note)child;
            return !item.note.bin;
        }
    }
}