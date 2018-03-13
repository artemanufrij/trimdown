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
    public class Scene : BaseObject {

        public Chapter parent { get; private set; }

        string content_path;

        public Scene (Chapter chapter, string name, int order = 0) {
            this.parent = chapter;
            this.title = name;
            this.order = order;
            this.name = name;

            path = Path.build_filename (parent.scenes_path, name);
            properties_path = Path.build_filename (path, "properties");
            content_path = Path.build_filename (path, "content");

            load_properties ();
        }

        private void load_properties () {
            if (!FileUtils.test (path, FileTest.EXISTS)) {
                DirUtils.create_with_parents (path, 0755);
            }

            if (!FileUtils.test (properties_path, FileTest.EXISTS)) {
                try {
                    FileUtils.set_contents (properties_path, Utils.get_new_scene_property (name, order));
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

            try {
                properties.load_from_file (properties_path, KeyFileFlags.NONE);
            } catch (Error err) {
                    warning (err.message);
                return;
            }

            title = get_string_property ("General", "title");
            order = get_integer_property ("General", "order");
            bin = get_boolean_property ("General", "bin");
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
    }
}