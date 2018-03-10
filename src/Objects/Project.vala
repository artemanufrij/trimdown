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
    public class Project : GLib.Object {
        public signal void chapter_created (Objects.Chapter chapter);

        public string title { get; private set; }
        public string kind { get; private set; }
        public string path { get; private set; }

        string chapters_path;

        GLib.List<Chapter> ? _chapters = null;
        public GLib.List<Chapter> chapters {
            get {
                if (_chapters == null) {
                    _chapters = get_chapter_collection ();
                }
                return _chapters;
            }
        }

        KeyFile properties;

        public Project (string path, string kind = "") {
            this.path = path;
            this.kind = kind;
            this.title = Path.get_basename (path);

            load_properties ();
        }

        private void load_properties () {
            var prop = Path.build_filename (path, title + ".td");
            if (!FileUtils.test (prop, FileTest.EXISTS)) {
                try {
                    FileUtils.set_contents (prop, Utils.get_new_project_property (title, kind));
                } catch (Error err) {
                    warning (err.message);
                    return;
                }
            }

            properties = new KeyFile ();
            try {
                properties.load_from_file (prop, KeyFileFlags.NONE);
            } catch (Error err) {
                    warning (err.message);
                return;
            }

            title = get_string_property ("General", "title");
            kind = get_string_property ("General", "kind");
        }

        private GLib.List<Chapter> get_chapter_collection () {
            GLib.List<Chapter> return_value = new GLib.List<Chapter> ();

            chapters_path = Path.build_filename (path, "Chapters");
            var directory = File.new_for_path (chapters_path);
            try {
                var children = directory.enumerate_children ("standard::*," + FileAttribute.STANDARD_CONTENT_TYPE, GLib.FileQueryInfoFlags.NONE);
                FileInfo file_info = null;

                while ((file_info = children.next_file ()) != null) {
                    if (file_info.get_file_type () == FileType.DIRECTORY) {
                        var chapter = new Objects.Chapter (this, file_info.get_name ());
                        return_value.append (chapter);
                    }
                }
            } catch (Error err) {
                    warning (err.message);
            }

            return return_value;
        }

        public Objects.Chapter create_chapter (string title, int order) {
            var new_chapter = new Objects.Chapter (this, title, order);
            return new_chapter;
        }

        public Objects.Chapter generate_new_chapter () {
            int i = 1;
            string new_chapter_title = "";
            do {
                new_chapter_title = "Chapter_%d".printf (i);
                i++;
            } while (FileUtils.test (Path.build_filename (chapters_path, new_chapter_title), FileTest.EXISTS));

            var new_chapter = create_chapter (new_chapter_title, i);
            new_chapter.set_new_title (_("New Chapter"));
            chapter_created (new_chapter);
            return new_chapter;
        }

        private string get_string_property (string group, string key) {
            try {
                return properties.get_string (group, key);
            } catch (Error err) {
                warning (err.message);
            }

            return "";
        }
    }
}