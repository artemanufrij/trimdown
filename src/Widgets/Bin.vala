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
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
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
    public class Bin : Gtk.Grid {
        Gtk.ListBox chapters;
        Gtk.ListBox scenes;
        Gtk.ListBox notes;
        Gtk.SourceView text;

        public Bin () {
            build_ui ();
        }

        private void build_ui () {
            this.expand = true;
            this.height_request = 320;
            this.width_request = 640;

            var chapter = build_chapter_content ();

            var scene = build_scene_content ();

            var note = build_note_content ();

            var scroll = new Gtk.ScrolledWindow (null, null);
            text = new Gtk.SourceView ();
            text.expand = true;
            text.editable = false;
            scroll.add (text);

            this.attach (chapter, 0, 0, 1, 3);
            this.attach (new Gtk.Separator (Gtk.Orientation.VERTICAL), 1, 0, 1, 3);
            this.attach (scene, 2, 0);
            this.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 2, 1);
            this.attach (note, 2, 2);
            this.attach (new Gtk.Separator (Gtk.Orientation.VERTICAL), 3, 0, 1, 3);
            this.attach (scroll, 4, 0, 3, 3);

            this.show_all ();
        }

        private Gtk.Grid build_chapter_content () {
            var grid = new Gtk.Grid ();
            var scroll = new Gtk.ScrolledWindow (null, null);
            scroll.expand = true;

            chapters = new Gtk.ListBox ();
            chapters.set_filter_func (chapters_filter_func);
            chapters.set_sort_func (Utils.chapters_sort_func);
            scroll.add (chapters);
            chapters.selected_rows_changed.connect (
                () => {
                    reset_children ();
                    if (chapters.get_selected_row () is Chapter) {
                        var chapter = (chapters.get_selected_row () as Chapter).chapter;
                        foreach (var note in chapter.notes) {
                            var item = new Note (note);
                            note.bin_location_changed.connect (refilter_bin_notes_content);
                            notes.add (item);
                        }

                        foreach (var scene in chapter.scenes) {
                            var item = new Scene (scene, Enums.ItemStyle.BIN);
                            scene.bin_location_changed.connect (refilter_bin_scenes_content);
                            scenes.add (item);
                        }
                    }
                });

            grid.add (scroll);
            return grid;
        }

        private Gtk.Grid build_scene_content () {
            var grid = new Gtk.Grid ();
            var scroll = new Gtk.ScrolledWindow (null, null);
            scroll.expand = true;

            scenes = new Gtk.ListBox ();
            scenes.set_filter_func (scenes_filter_func);
            scenes.set_sort_func (Utils.scenes_sort_func);
            scenes.selected_rows_changed.connect (
                () => {
                    if (scenes.get_selected_row () is Scene) {
                        notes.unselect_all ();
                        text.buffer.text = (scenes.get_selected_row () as Scene).scene.get_content ();
                    }
                });
            scroll.add (scenes);

            grid.add (scroll);

            return grid;
        }

        private Gtk.Grid build_note_content () {
            var grid = new Gtk.Grid ();
            var scroll = new Gtk.ScrolledWindow (null, null);
            scroll.expand = true;

            notes = new Gtk.ListBox ();
            notes.set_filter_func (notes_filter_func);
            notes.set_sort_func (Utils.notes_sort_func);
            notes.selected_rows_changed.connect (
                () => {
                    if (notes.get_selected_row () is Note) {
                        scenes.unselect_all ();
                        text.buffer.text = (notes.get_selected_row () as Note).note.get_content ();
                    }
                });

            scroll.add (notes);

            grid.add (scroll);
            return grid;
        }

        public void show_content (Objects.Project project) {
            reset ();

            foreach (var chapter in project.chapters) {
                var item = new Chapter (chapter);
                chapter.bin_location_changed.connect (refilter_bin_chapters_content);
                chapters.add (item);
            }
        }

        public void reset () {
            foreach (var child in chapters.get_children ()) {
                (child as Chapter).chapter.bin_location_changed.disconnect (refilter_bin_chapters_content);
                child.destroy ();
            }
        }

        public void reset_children () {
            foreach (var child in scenes.get_children ()) {
                (child as Scene).scene.bin_location_changed.disconnect (refilter_bin_scenes_content);
                child.destroy ();
            }
            foreach (var child in notes.get_children ()) {
                (child as Note).note.bin_location_changed.disconnect (refilter_bin_notes_content);
                child.destroy ();
            }
            text.buffer.text = "";
        }

        private void refilter_bin_scenes_content () {
            scenes.invalidate_filter ();
            chapters.invalidate_filter ();
            text.buffer.text = "";
        }

        private void refilter_bin_notes_content () {
            notes.invalidate_filter ();
            chapters.invalidate_filter ();
            text.buffer.text = "";
        }

        private void refilter_bin_chapters_content () {
            chapters.invalidate_filter ();
            notes.invalidate_filter ();
            scenes.invalidate_filter ();
            text.buffer.text = "";
        }

        private bool scenes_filter_func (Gtk.ListBoxRow child) {
            var item = (Widgets.Scene)child;
            return item.scene.bin || item.scene.parent.bin;
        }

        private bool notes_filter_func (Gtk.ListBoxRow child) {
            var item = (Widgets.Note)child;
            return item.note.bin || item.note.parent.bin;
        }

        private bool chapters_filter_func (Gtk.ListBoxRow child) {
            var item = (Widgets.Chapter)child;
            return item.chapter.bin || item.chapter.has_bin_children ();
        }
    }
}