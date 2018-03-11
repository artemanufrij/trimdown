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

namespace TrimDown {
    public class TrimDownApp : Gtk.Application {
        Settings settings;

        static TrimDownApp _instance = null;
        public static TrimDownApp instance {
            get {
                if (_instance == null) {
                    _instance = new TrimDownApp ();
                }
                return _instance;
            }
        }

        construct {
            this.application_id = "com.github.artemanufrij.trimdown";
            settings = Settings.get_default ();

            var action_new_chapter = new SimpleAction ("new-chapter", null);
            add_action (action_new_chapter);
            add_accelerator ("<Control><Shift>c", "app.new-chapter", null);
            action_new_chapter.activate.connect (
                () => {
                    if (mainwindow != null) {
                        mainwindow.new_chapter_action ();
                    }
                });

            var action_new_scene = new SimpleAction ("new-scene", null);
            add_action (action_new_scene);
            add_accelerator ("<Control><Shift>s", "app.new-scene", null);
            action_new_scene.activate.connect (
                () => {
                    if (mainwindow != null) {
                        mainwindow.new_scene_action ();
                    }
                });
        }

        private TrimDownApp () {
            create_project_folder ();
        }

        public MainWindow mainwindow { get; private set; default = null; }

        private void create_project_folder () {
            var library_path = File.new_for_path (settings.projects_location);
            if (settings.projects_location == "" || !library_path.query_exists ()) {
                settings.projects_location = Path.build_filename (GLib.Environment.get_user_special_dir (GLib.UserDirectory.DOCUMENTS), "Trimdown");
                library_path = File.new_for_path (settings.projects_location);
                if (!library_path.query_exists ()) {
                    try {
                        library_path.make_directory ();
                    } catch (Error err) {
                        warning (err.message);
                    }
                }
            }
        }

        protected override void activate () {
            if (mainwindow == null) {
                mainwindow = new MainWindow ();
                mainwindow.application = this;
            }
            mainwindow.present ();
        }
    }
}

public static int main (string [] args) {
    Gtk.init (ref args);
    var app = TrimDown.TrimDownApp.instance;
    return app.run (args);
}
