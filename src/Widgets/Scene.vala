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
    public class Scene : Gtk.ListBoxRow {
        public Objects.Scene scene { get; private set; }

        public new string name { get { return scene.name; } }
        public int order { get { return scene.order; } }

        Enums.ItemStyle item_style;

        Gtk.Label label;

        public Scene (Objects.Scene scene, Enums.ItemStyle item_style = Enums.ItemStyle.DEFAULT) {
            this.scene = scene;
            this.item_style = item_style;

            build_ui ();
        }

        private void build_ui () {
            label = new Gtk.Label (scene.name);
            label.expand = true;
            label.xalign = 0;

            var event_box = new Gtk.EventBox ();
            var content = new Gtk.Grid ();

            if (!scene.parent.bin) {
                Gtk.Button action_button = null;
                if (scene.bin) {
                    action_button = new Gtk.Button.from_icon_name ("edit-redo-symbolic");
                } else {
                    action_button = new Gtk.Button.from_icon_name ("user-trash-symbolic");
                }
                action_button.get_style_context ().add_class ("flat");
                action_button.can_focus = false;
                action_button.halign = Gtk.Align.END;
                action_button.opacity = 0;

                action_button.clicked.connect (
                    () => {
                        if (scene.bin) {
                            scene.restore_from_bin ();
                        } else {
                            scene.move_into_bin ();
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


            switch (item_style) {
            case Enums.ItemStyle.BIN :
                content.margin = 6;
                break;
            default :
                content.margin = 12;
                break;
            }
            content.margin_right = 0;

            content.attach (label, 0, 0);

            event_box.add (content);

            this.add (event_box);
            this.show_all ();
        }
    }
}