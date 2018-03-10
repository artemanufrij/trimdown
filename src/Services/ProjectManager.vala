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

namespace TrimDown.Services {
    public class ProjectManager : GLib.Object {
        Settings settings;

        static ProjectManager _instance = null;
        public static ProjectManager instance {
            get {
                if (_instance == null) {
                    _instance = new ProjectManager ();
                }
                return _instance;
            }
        }

        construct {
            settings = Settings.get_default ();
        }

        private ProjectManager() {
        }

        public bool project_name_exists (string name) {
            var project_path = Path.build_path (settings.projects_location, name);
            return FileUtils.test ( project_path, FileTest.EXISTS);
        }
    }
}