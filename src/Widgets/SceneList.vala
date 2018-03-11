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
    public class SceneList : Gtk.Grid {
        public signal void scene_selected (Objects.Scene scene);

        public Objects.Chapter ? current_chapter { get; private set; default = null; }

        Gtk.ListBox scenes;

        public SceneList () {
            build_ui ();
        }

        private void build_ui () {
            this.width_request = 150;
            this.expand = false;
            this.margin = 24;
            this.margin_left = 0;

            scenes = new Gtk.ListBox ();
            scenes.set_sort_func (scenes_sort_func);
            scenes.selected_rows_changed.connect (
                () => {
                    scene_selected ((scenes.get_selected_row () as Widgets.Scene).scene);
                });

            var scroll = new Gtk.ScrolledWindow (null, null);
            scroll.expand = true;
            scroll.add (scenes);

            var action_toolbar = new Gtk.ActionBar ();
            action_toolbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
            var add_button = new Gtk.Button.from_icon_name ("accessories-text-editor-symbolic");
            add_button.tooltip_text = _ ("Add a Scene");
            add_button.clicked.connect (
                () => {
                    if (current_chapter != null) {
                        current_chapter.generate_new_scene ();
                    }
                });
            action_toolbar.pack_start (add_button);

            var frame = new Gtk.Frame (null);

            var grid = new Gtk.Grid ();
            grid.attach (scroll, 0, 0);
            grid.attach (action_toolbar, 0, 1);

            frame.add (grid);

            this.attach (frame, 0, 0);
        }

        public void show_scenes (Objects.Chapter chapter) {
            if (current_chapter == chapter) {
                return;
            }

            if (current_chapter != null) {
                current_chapter.scene_created.disconnect (add_scene);
            }

            reset ();

            current_chapter = chapter;
            foreach (var scene in chapter.scenes) {
                var item = new Widgets.Scene (scene);
                scenes.add (item);
            }

            if (scenes.get_children ().length () > 0) {
                scenes.get_children ().first ().data.activate ();
            }

            current_chapter.scene_created.connect (add_scene);
        }

        public void reset () {
            foreach (var child in scenes.get_children ()) {
                child.destroy ();
            }
        }

        public void add_scene (Objects.Scene scene) {
            var item = new Widgets.Scene (scene);
            scenes.add (item);
            item.activate ();
        }

        private int scenes_sort_func (Gtk.ListBoxRow child1, Gtk.ListBoxRow child2) {
            var item1 = (Widgets.Scene)child1;
            var item2 = (Widgets.Scene)child2;
            if (item1 != null && item2 != null) {
                if (item1.order != item2.order) {
                    return item1.order - item2.order;
                }
                return item1.title.collate (item2.title);
            }
            return 0;
        }
    }
}