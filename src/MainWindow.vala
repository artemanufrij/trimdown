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
    public class MainWindow : Gtk.Window {
        Services.ProjectManager project_manager;
        Settings settings;

        Gtk.HeaderBar headerbar;
        Gtk.Stack content;

        Widgets.Views.Writer writer;

        construct {
            settings = Settings.get_default ();
            project_manager = Services.ProjectManager.instance;
        }

        public MainWindow () {
            build_ui ();
        }

        private void build_ui () {
            headerbar = new Gtk.HeaderBar ();
            headerbar.title = "TrimDown";
            headerbar.show_close_button = true;
            headerbar.get_style_context ().add_class ("default-decoration");
            this.set_titlebar (headerbar);

            content = new Gtk.Stack ();

            var welcome = new Widgets.Views.Welcome ();
            welcome.new_project_clicked.connect (
                () => {
                    var new_project = new Dialogs.NewProject (this);
                    if (new_project.run () == Gtk.ResponseType.ACCEPT) {
                        var project = project_manager.create_new_project (new_project.project_title, new_project.project_kind);
                        if (project != null) {
                            open_project (project);
                        }
                    }
                    new_project.destroy ();
                });

            writer = new Widgets.Views.Writer ();

            content.add_named (welcome, "welcome");
            content.add_named (writer, "writer");
            this.add (content);
            this.show_all ();
        }

        private void open_project (Objects.Project project) {
            writer.show_project (project);
            content.visible_child_name = "writer";
        }
    }
}
