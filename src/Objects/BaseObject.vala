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
        public signal void bin_location_changed (bool bin);

        public string path { get; protected set; }
        public string title { get; protected set; }
        public string name { get; protected set; }
        public int order { get; protected set; default = 0; }
        public bool bin { get; protected set; default = false; }

        protected string properties_path;
        protected KeyFile properties;

        construct {
            properties = new KeyFile ();
        }

        protected void load_properties () {
            if (!FileUtils.test (properties_path, FileTest.EXISTS)) {
                try {
                    if (this is Chapter) {
                        FileUtils.set_contents (properties_path, Utils.get_new_chapter_property (name, order));
                    } else if (this is Scene) {
                        FileUtils.set_contents (properties_path, Utils.get_new_scene_property (name, order));
                    } else if (this is Note) {
                        FileUtils.set_contents (properties_path, Utils.get_new_note_property (name, order));
                    }
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

            var t = get_string_property ("General", "title");
            if (t != "") {
                title = t;
            }
            if (!(this is Project)) {
                order = get_integer_property ("General", "order");
                name = get_string_property ("General", "name");
                bin = get_boolean_property ("General", "bin");
            }
        }

        public void move_into_bin () {
            if (set_boolean_property ("General", "bin", true)) {
                bin = true;
                bin_location_changed (bin);
            }
        }

        public void restore_from_bin () {
            if (set_boolean_property ("General", "bin", false)) {
                bin = false;
                bin_location_changed (bin);
            }
        }

        protected string get_string_property (string group, string key) {
            try {
                return properties.get_string (group, key);
            } catch (Error err) {
                warning ("%s: %s\n", err.message, properties_path);
            }
            return "";
        }

        protected int get_integer_property (string group, string key) {
            try {
                return properties.get_integer (group, key);
            } catch (Error err) {
                warning ("%s: %s\n", err.message, properties_path);
            }
            return 0;
        }

        protected bool get_boolean_property (string group, string key) {
            try {
                return properties.get_boolean (group, key);
            } catch (Error err) {
                warning ("%s: %s\n", err.message, properties_path);
            }
            return false;
        }

        protected bool set_string_property (string group, string key, string val) {
            properties.set_string (group, key, val);
            return save_property_file ();
        }

        protected bool set_boolean_property (string group, string key, bool val) {
            properties.set_boolean (group, key, val);
            return save_property_file ();
        }

        protected bool set_integer_property (string group, string key, int val) {
            properties.set_integer (group, key, val);
            return save_property_file ();
        }


        private bool save_property_file () {
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

        public void set_new_order (int new_order) {
            if (set_integer_property ("General", "order", new_order)) {
                order = new_order;
            }
        }
    }
}