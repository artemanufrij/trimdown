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

namespace TrimDown.Widgets {
    public class ChapterList : Gtk.Grid {
        public signal void chapter_selected (Objects.Chapter chapter);

        Gtk.ListBox chapters;

        public Objects.Project ? current_project { get; private set; default = null; }

        public ChapterList () {
            build_ui ();
        }

        private void build_ui () {
            this.width_request = 200;
            chapters = new Gtk.ListBox ();
            chapters.set_sort_func (chapters_sort_func);
            chapters.selected_rows_changed.connect (
                () => {
                    chapter_selected ((chapters.get_selected_row () as Widgets.Chapter).chapter);
                });

            var scroll = new Gtk.ScrolledWindow (null, null);
            scroll.expand = true;
            scroll.add (chapters);

            var action_toolbar = new Gtk.ActionBar ();
            action_toolbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
            var add_button = new Gtk.Button.from_icon_name ("document-new-symbolic");
            add_button.tooltip_text = _ ("Add a Chapter");
            add_button.clicked.connect (
                () => {
                    if (current_project != null) {
                        current_project.generate_new_chapter ();
                    }
                });
            action_toolbar.pack_start (add_button);

            this.attach (scroll, 0, 0);
            this.attach (action_toolbar, 0, 1);
        }

        public void show_chapters (Objects.Project project) {
            if (current_project == project) {
                return;
            }

            if (current_project != null) {
                current_project.chapter_created.disconnect (add_chapter);
            }

            reset ();

            current_project = project;
            foreach (var chapter in project.chapters) {
                var item = new Widgets.Chapter (chapter);
                chapters.add (item);
            }

            if (chapters.get_children ().length () > 0) {
                chapters.get_children ().first ().data.activate ();
            }

            current_project.chapter_created.connect (add_chapter);
        }

        public void add_chapter (Objects.Chapter chapter) {
            var item = new Widgets.Chapter (chapter);
            chapters.add (item);
            item.activate ();
        }

        public void reset () {
            foreach (var child in chapters.get_children ()) {
                child.destroy ();
            }
        }

        private int chapters_sort_func (Gtk.ListBoxRow child1, Gtk.ListBoxRow child2) {
            var item1 = (Widgets.Chapter)child1;
            var item2 = (Widgets.Chapter)child2;
            if (item1 != null && item2 != null) {

                if (item1.order != item2.order){
                    return item1.order - item2.order;
                }
                return item1.title.collate (item2.title);
            }
            return 0;
        }
    }
}