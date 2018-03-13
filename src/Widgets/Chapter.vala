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
    public class Chapter : Gtk.ListBoxRow {
        public Objects.Chapter chapter { get; private set; }

        public string title { get { return chapter.title; } }
        public int order { get { return chapter.order; } }

        Gtk.Label label;

        public Chapter (Objects.Chapter chapter) {
            this.chapter = chapter;
            build_ui ();
        }

        private void build_ui () {
            label = new Gtk.Label (chapter.name);
            label.expand = true;
            label.xalign = 0;

            var action_button = new Gtk.Button.from_icon_name ("user-trash-symbolic");
            action_button.get_style_context ().add_class ("flat");
            action_button.can_focus = false;
            action_button.halign = Gtk.Align.END;
            action_button.opacity = 0;

            action_button.clicked.connect (
                () => {
                    chapter.move_into_bin ();
                });
            action_button.enter_notify_event.connect (
                (event) => {
                    action_button.opacity = 1;
                    return false;
                });

            var content = new Gtk.Grid ();
            content.margin = 12;
            content.margin_right = 0;
            content.attach (label, 0, 0);
            content.attach (action_button, 1, 0);

            var event_box = new Gtk.EventBox ();
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
            event_box.add (content);

            this.add (event_box);
            this.show_all ();
        }
    }
}