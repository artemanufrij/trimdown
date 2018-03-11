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

            scenes = new Gtk.ListBox ();
          //  scenes.set_sort_func (scenes_sort_func);
            scenes.selected_rows_changed.connect (
                () => {
                    scene_selected ((scenes.get_selected_row () as Widgets.Scene).scene);
                });

            var scroll = new Gtk.ScrolledWindow (null, null);
            scroll.expand = true;
            scroll.add (scenes);

            this.attach (scroll, 0, 0);
        }

        public void show_scenes (Objects.Chapter chapter) {
            if (current_chapter == chapter) {
                return;
            }

            if (current_chapter != null) {
                // current_chapter.scene_created.disconnect (add_scene);
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

           // current_chapter.scene_created.connect (add_scene);
        }

        public void reset () {
            foreach (var child in scenes.get_children ()) {
                child.destroy ();
            }
        }
    }
}