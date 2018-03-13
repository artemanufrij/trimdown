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
            this.attach (scroll, 4, 0, 2, 3);


            this.show_all ();
        }

        private Gtk.Grid build_chapter_content () {
            var grid = new Gtk.Grid ();
            var scroll = new Gtk.ScrolledWindow (null, null);
            scroll.expand = true;

            chapters = new Gtk.ListBox ();
            scroll.add (chapters);
            chapters.selected_rows_changed.connect (
                () => {
                    reset ();
                    if (chapters.get_selected_row () is Chapter) {
                        var chapter = (chapters.get_selected_row () as Chapter).chapter;
                        foreach (var note in chapter.notes) {
                            if (chapter.bin || note.bin) {
                                var item = new Note (note);
                                notes.add (item);
                            }
                        }

                        foreach (var scene in chapter.scenes) {
                            if (chapter.bin || scene.bin) {
                                var item = new Scene (scene, Enums.ItemStyle.BIN);
                                scenes.add (item);
                            }
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
            foreach (var chapter in project.chapters) {
                if (chapter.bin || chapter.has_bin_children ()) {
                    var item = new Chapter (chapter);
                    chapters.add (item);
                }
            }
        }

        public void reset () {
            foreach (var child in scenes.get_children ()) {
                child.destroy ();
            }
            foreach (var child in notes.get_children ()) {
                child.destroy ();
            }
            text.buffer.text = "";
        }
    }
}