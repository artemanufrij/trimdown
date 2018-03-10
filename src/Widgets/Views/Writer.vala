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

namespace TrimDown.Widgets.Views {
    public class Writer : Gtk.Grid {
        public Objects.Project ? current_project { get; private set; default = null; }
        public Objects.Chapter ? current_chapter { get; private set; default = null; }

        Widgets.ChapterList chapters;
        Gtk.Entry title;
        Gtk.SourceView body;

        public Writer () {
            build_ui ();
        }

        private void build_ui () {
            var chapter_paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            var scene_paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            chapters = new Widgets.ChapterList ();
            chapters.chapter_selected.connect (
                (chapter) => {
                    if (current_chapter != null) {
                        current_chapter.save_content (body.buffer.text.strip ());
                    }
                    current_chapter = chapter;
                    title.text = chapter.title;
                    body.buffer.text = chapter.get_content ();
                });

            chapter_paned.add1 (chapters);
            chapter_paned.add2 (scene_paned);

            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            box.get_style_context ().add_class ("card");
            box.margin = 12;

            title = new Gtk.Entry ();
            title.get_style_context ().add_class ("flat");
            title.get_style_context ().add_class ("h2");
            title.xalign = 0.5f;
            title.changed.connect (
                () => {
                    if (current_chapter != null) {
                        current_chapter.set_new_title (title.text);
                    }
                });
            box.pack_start (title, false, false);

            var body_scroll = new Gtk.ScrolledWindow (null, null);
            body_scroll.expand = true;

            body = new Gtk.SourceView ();
            body_scroll.add (body);

            box.pack_end (body_scroll, true, true);

            scene_paned.pack1 (box, true, true);

            this.add (chapter_paned);
            this.show_all ();
        }

        public void show_project (Objects.Project project) {
            if (current_project == project) {
                return;
            }
            if (current_project != null) {
                current_project.chapter_created.disconnect (chapter_created);
            }
            current_project = project;
            chapters.show_chapters (project);

            current_project.chapter_created.connect_after (chapter_created);
        }

        private void chapter_created (Objects.Chapter chapter) {
            title.grab_focus ();
            title.select_region (0, chapter.title.length);
        }
    }
}