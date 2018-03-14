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
        Gtk.Button action_button;
        Gtk.Image redo_img;
        Gtk.Image trash_img;

        public Note (Objects.Note note) {
            this.note = note;
            this.note.title_saved.connect (
                (new_title) => {
                    label.label = new_title;
                    (this.parent as Gtk.ListBox).invalidate_sort ();
                });
            this.note.bin_location_changed.connect (
                () => {
                    if (note.bin) {
                        action_button.set_image (redo_img);
                    } else {
                        action_button.set_image (trash_img);
                    }
                });
            build_ui ();
        }

        private void build_ui () {
            label = new Gtk.Label (note.title);
            label.xalign = 0;
            label.expand = true;

            var event_box = new Gtk.EventBox ();
            var content = new Gtk.Grid ();
            content.margin = 6;

            redo_img = new Gtk.Image.from_icon_name ("edit-redo-symbolic", Gtk.IconSize.BUTTON);
            trash_img = new Gtk.Image.from_icon_name ("user-trash-symbolic", Gtk.IconSize.BUTTON);

            action_button = new Gtk.Button ();

            if (!note.parent.bin) {
                if (note.bin) {
                    action_button.set_image (redo_img);
                } else {
                    action_button.set_image (trash_img);
                }
                action_button.get_style_context ().add_class ("flat");
                action_button.can_focus = false;
                action_button.halign = Gtk.Align.END;
                action_button.opacity = 0;

                action_button.clicked.connect (
                    () => {
                        if (note.bin) {
                            note.restore_from_bin ();
                        } else {
                            note.move_into_bin ();
                        }
                    });
                action_button.enter_notify_event.connect (
                    (event) => {
                        action_button.opacity = 1;
                        return false;
                    });

                event_box.enter_notify_event.connect (
                    (event) => {
                        action_button.opacity = 0.5;
                        return false;
                    });
                event_box.leave_notify_event.connect (
                    (event) => {
                        action_button.opacity = 0;
                        return false;
                    });
                content.attach (action_button, 1, 0);
            }

            content.margin_right = 0;
            content.attach (label, 0, 0);
            event_box.add (content);

            this.add (event_box);
            this.show_all ();
        }
    }
}