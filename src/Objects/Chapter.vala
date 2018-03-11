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

namespace TrimDown.Objects {
    public class Chapter : BaseObject {
        public signal void scene_created (Scene scene);

        public Project parent { get; private set; }
        public string scenes_path { get; private set; }

        GLib.List<Scene> ? _scenes = null;
        public GLib.List<Scene> scenes {
            get {
                if (_scenes == null) {
                    _scenes = get_scene_collection ();
                }
                return _scenes;
            }
        }

        public Chapter (Objects.Project project, string title = "", int order = 0) {
            this.parent = project;
            this.title = title;
            this.order = order;

            path = Path.build_filename (parent.chapters_path, title);
            properties_path = Path.build_filename (path, "properties");
            scenes_path = Path.build_filename (path, "Scenes");

            load_properties ();
        }

        private void load_properties () {
            if (!FileUtils.test (path, FileTest.EXISTS)) {
                var basic_struct = Path.build_filename (path, "Scenes");
                DirUtils.create_with_parents (basic_struct, 0755);
            }

            if (!FileUtils.test (properties_path, FileTest.EXISTS)) {
                try {
                    FileUtils.set_contents (properties_path, Utils.get_new_chapter_property (title, order));
                } catch (Error err) {
                    warning (err.message);
                    return;
                }
            }

            properties = new KeyFile ();
            try {
                properties.load_from_file (properties_path, KeyFileFlags.NONE);
            } catch (Error err) {
                    warning (err.message);
                return;
            }

            title = get_string_property ("General", "title");
            order = get_integer_property ("General", "order");
        }

        private GLib.List<Scene> get_scene_collection () {
            GLib.List<Scene> return_value = new GLib.List<Scene> ();

            var directory = File.new_for_path (scenes_path);
            try {
                var children = directory.enumerate_children ("standard::*," + FileAttribute.STANDARD_CONTENT_TYPE, GLib.FileQueryInfoFlags.NONE);
                FileInfo file_info = null;

                while ((file_info = children.next_file ()) != null) {
                    if (file_info.get_file_type () == FileType.DIRECTORY) {
                        var scene = new Scene (this, file_info.get_name ());
                        return_value.append (scene);
                    }
                }
            } catch (Error err) {
                    warning (err.message);
            }

            return return_value;
        }

        public Scene create_new_scene (string title, int order) {
            var new_scene = new Scene (this, title, order);
            return new_scene;
        }

        public Scene generate_new_scene () {
            int i = 1;
            string new_scene_title = "";
            do {
                new_scene_title = "Scene %d".printf (i);
                i++;
            } while (FileUtils.test (Path.build_filename (scenes_path, new_scene_title), FileTest.EXISTS));

            var new_scene = create_new_scene (new_scene_title, i);
            _scenes.append (new_scene);
            scene_created (new_scene);
            return new_scene;
        }
    }
}