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
            chapters.set_sort_func (Utils.chapters_sort_func);
            chapters.set_filter_func (chapters_filter_func);
            chapters.selected_rows_changed.connect (
                () => {
                    if (chapters.get_selected_row () is Widgets.Chapter) {
                        chapter_selected ((chapters.get_selected_row () as Widgets.Chapter).chapter);
                    }
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
                var item = new Chapter (chapter);
                item.reorder_request.connect (reorder);
                chapter.bin_location_changed.connect (
                    (bin) => {
                        if (bin) {
                            chapters.unselect_all ();
                        }
                        chapters.invalidate_filter ();
                        if (!bin) {
                            item.activate ();
                        }
                    });
                chapters.add (item);
            }

            foreach (var item in chapters.get_children ()) {
                if (!(item as Chapter).chapter.bin) {
                    item.activate ();
                    break;
                }
            }
            current_project.chapter_created.connect (add_chapter);
        }

        public void add_chapter (Objects.Chapter chapter) {
            var item = new Chapter (chapter);
            item.reorder_request.connect (reorder);
            chapters.add (item);
            chapter.bin_location_changed.connect (
                (bin) => {
                    if (bin) {
                        chapters.unselect_all ();
                    }
                    chapters.invalidate_filter ();
                    if (!bin) {
                        item.activate ();
                    }
                });
            item.activate ();
        }

        public void reset () {
            foreach (var child in chapters.get_children ()) {
                child.destroy ();
            }
        }

        public void select_chapter (string chapter_name) {
            foreach (var child in chapters.get_children ()) {
                if ((child as Chapter).chapter.name == chapter_name) {
                    child.activate ();
                    break;
                }
            }
        }

        public void unselect_all () {
            chapters.unselect_all ();
        }

        private void reorder (int from, int to) {
            if (current_project != null) {
                current_project.reorder_chapters (from, to);
                chapters.invalidate_sort ();
            }
        }

        private bool chapters_filter_func (Gtk.ListBoxRow child) {
            var item = (Chapter)child;
            return !item.chapter.bin;
        }
    }
}