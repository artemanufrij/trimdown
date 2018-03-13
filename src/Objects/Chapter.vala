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
        public signal void note_created (Note note);

        public Project parent { get; private set; }
        public string scenes_path { get; private set; }
        public string notes_path { get; private set; }

        GLib.List<Scene> ? _scenes = null;
        public GLib.List<Scene> scenes {
            get {
                if (_scenes == null) {
                    _scenes = get_scene_collection ();
                }
                return _scenes;
            }
        }

        GLib.List<Note> ? _notes = null;
        public GLib.List<Note> notes {
            get {
                if (_notes == null) {
                    _notes = get_note_collection ();
                }
                return _notes;
            }
        }

        public Chapter (Objects.Project project, string name = "", int order = 0) {
            this.parent = project;
            this.title = name;
            this.name = name;
            this.order = order;

            path = Path.build_filename (parent.chapters_path, name);
            properties_path = Path.build_filename (path, "properties");
            scenes_path = Path.build_filename (path, _ ("Scenes"));
            notes_path = Path.build_filename (path, _ ("Notes"));

            init ();
        }

        private void init () {
            if (!FileUtils.test (scenes_path, FileTest.EXISTS)) {
                DirUtils.create_with_parents (scenes_path, 0755);
            }

            if (!FileUtils.test (notes_path, FileTest.EXISTS)) {
                DirUtils.create_with_parents (notes_path, 0755);
            }

            load_properties ();
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

        private GLib.List<Note> get_note_collection () {
            GLib.List<Note> return_value = new GLib.List<Note> ();

            var directory = File.new_for_path (notes_path);
            try {
                var children = directory.enumerate_children ("standard::*," + FileAttribute.STANDARD_CONTENT_TYPE, GLib.FileQueryInfoFlags.NONE);
                FileInfo file_info = null;

                while ((file_info = children.next_file ()) != null) {
                    if (file_info.get_content_type () == "text/plain") {
                        var note = new Note (this, file_info.get_name ());
                        note.removed.connect (
                            () => {
                                _notes.remove (note);
                            });
                        return_value.append (note);
                    }
                }
            } catch (Error err) {
                    warning (err.message);
            }
            return return_value;
        }

        public Scene create_new_scene (string name, int order) {
            var new_scene = new Scene (this, name, order);
            return new_scene;
        }

        public Scene generate_new_scene () {
            int i = 1;
            string new_scene_name = "";
            do {
                new_scene_name = _ ("Scene %d").printf (i);
                i++;
            } while (FileUtils.test (Path.build_filename (scenes_path, new_scene_name), FileTest.EXISTS));

            var new_scene = create_new_scene (new_scene_name, i);
            _scenes.append (new_scene);
            scene_created (new_scene);
            return new_scene;
        }

        public Note create_new_note (string title) {
            var new_note = new Note (this, title);
            return new_note;
        }

        public Note generate_new_note () {
            int i = 1;
            string new_note_name = "";
            do {
                new_note_name = _ ("Note %d").printf (i);
                i++;
            } while (FileUtils.test (Path.build_filename (notes_path, new_note_name), FileTest.EXISTS));

            var new_note = create_new_note (new_note_name);
            _notes.append (new_note);
            new_note.removed.connect (
                () => {
                    _notes.remove (new_note);
                });
            note_created (new_note);
            return new_note;
        }
    }
}