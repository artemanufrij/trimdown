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
        public string title { get; private set; }
        public string kind { get; private set; }
        string path { get; set; }


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
                FileUtils.set_contents (prop, Utils.get_new_project_property (title, kind));
            }

            properties = new KeyFile ();
            properties.load_from_file (prop, KeyFileFlags.NONE);

            title = properties.get_string ("General", "title");
            kind = properties.get_string ("General", "kind");
        }

        private GLib.List<Chapter> get_chapter_collection () {
            GLib.List<Chapter> return_value = new GLib.List<Chapter> ();

            var chap = Path.build_filename (path, "Chapters");
            var directory = File.new_for_path (chap);
            var children = directory.enumerate_children ("standard::*," + FileAttribute.STANDARD_CONTENT_TYPE, GLib.FileQueryInfoFlags.NONE);
            FileInfo file_info = null;

            while ((file_info = children.next_file ()) != null) {
            }

            return return_value;
        }
    }
}