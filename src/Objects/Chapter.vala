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
    public class Chapter : GLib.Object {
        public signal void content_saved ();
        public signal void title_saved (string title);

        public Objects.Project parent { get; private set; }
        public string title { get; private set; }
        public int order { get; private set; }

        string chapter_root;
        string content_path;
        string properties_path;
        KeyFile properties;

        public Chapter (Objects.Project project, string title = "", int order = 0) {
            this.parent = project;
            this.title = title;
            this.order = order;

            chapter_root = Path.build_filename (parent.path, "Chapters", title);
            properties_path = Path.build_filename (chapter_root, "properties");
            content_path = Path.build_filename (chapter_root, "content");
            load_properties ();
        }

        public string get_content () {
            string content = "";
            try {
                FileUtils.get_contents (content_path, out content);
            } catch (Error err) {
                    warning (err.message);
            }

            return content;
        }

        public bool save_content (string content) {
            try {
                FileUtils.set_contents (content_path, content);
            } catch (Error err) {
                    warning (err.message);
                return false;
            }

            content_saved ();

            return true;
        }

        private void load_properties () {
            if (!FileUtils.test (chapter_root, FileTest.EXISTS)) {
                DirUtils.create_with_parents (chapter_root, 0755);
            }

            if (!FileUtils.test (properties_path, FileTest.EXISTS)) {
                try {
                    FileUtils.set_contents (properties_path, Utils.get_new_chapter_property (title, order));
                } catch (Error err) {
                    warning (err.message);
                    return;
                }
            }

            if (!FileUtils.test (content_path, FileTest.EXISTS)) {
                try {
                    FileUtils.set_contents (content_path, "");
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

        private string get_string_property (string group, string key) {
            try {
                return properties.get_string (group, key);
            } catch (Error err) {
                    warning (err.message);
            }

            return "";
        }

        private int get_integer_property (string group, string key) {
            try {
                return properties.get_integer (group, key);
            } catch (Error err) {
                    warning (err.message);
            }

            return 0;
        }

        private bool set_string_property (string group, string key, string val) {
            properties.set_string (group, key, val);
            try {
                properties.save_to_file (properties_path);
            } catch (Error err) {
                    warning (err.message);
                return false;
            }

            return true;
        }

        public void set_new_title (string new_title) {
            if (set_string_property ("General", "title", new_title)) {
                title = new_title;
            }

            title_saved (title);
        }
    }
}