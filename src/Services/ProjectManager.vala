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

        public bool project_name_exists (string title) {
            if (title.strip () == "") {
                return true;
            }

            var project_path = Path.build_filename (settings.projects_location, title);
            return FileUtils.test (project_path, FileTest.EXISTS);
        }

        public Objects.Project ? create_new_project (string title, string kind = "") {
            var project_path = Path.build_filename (settings.projects_location, title);
            if (!FileUtils.test (project_path, FileTest.EXISTS)) {
                var basic_struct = Path.build_filename (project_path, _("Chapters"));
                DirUtils.create_with_parents (basic_struct, 0755);

                var new_project = new Objects.Project (project_path, kind);
                new_project.create_new_chapter (_("Prologue"), 0);
                return new_project;
            }

            return null;
        }

        public Objects.Project ? open_project () {
            Objects.Project ? return_value = null;
            Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (
                _ ("Open a TrimDown project."), TrimDownApp.instance.mainwindow, Gtk.FileChooserAction.OPEN,
                _ ("_Cancel"), Gtk.ResponseType.CANCEL,
                _ ("_Open"), Gtk.ResponseType.ACCEPT);

            var filter = new Gtk.FileFilter ();
            filter.set_filter_name (_ ("TrimDown Project"));
            filter.add_pattern ("*.td");

            chooser.add_filter (filter);

            if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                var dir = Path.get_dirname (chooser.get_file ().get_path ());
                return_value = new Objects.Project (dir);
            }

            chooser.destroy ();
            return return_value;
        }
    }
}