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
    public class BaseObject : GLib.Object {
        public signal void content_saved ();
        public signal void title_saved (string title);

        public string path { get; protected set; }
        public string title { get; protected set; }
        public string name { get; protected set; }
        public int order { get; protected set; }

        protected string properties_path;
        protected KeyFile properties;

        construct {
            properties = new KeyFile ();
        }

        protected string get_string_property (string group, string key) {
            try {
                return properties.get_string (group, key);
            } catch (Error err) {
                warning (err.message);
            }
            return "";
        }

        protected int get_integer_property (string group, string key) {
            try {
                return properties.get_integer (group, key);
            } catch (Error err) {
                warning (err.message);
            }
            return 0;
        }

        protected bool set_string_property (string group, string key, string val) {
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