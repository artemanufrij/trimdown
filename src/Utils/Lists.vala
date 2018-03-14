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

namespace TrimDown.Utils {
    public static int chapters_sort_func (Gtk.ListBoxRow child1, Gtk.ListBoxRow child2) {
        var item1 = (Widgets.Chapter)child1;
        var item2 = (Widgets.Chapter)child2;
        if (item1 != null && item2 != null) {
            if (item1.order != item2.order) {
                return item1.order - item2.order;
            }
            return item1.title.collate (item2.title);
        }
        return 0;
    }

    public static int scenes_sort_func (Gtk.ListBoxRow child1, Gtk.ListBoxRow child2) {
        var item1 = (Widgets.Scene)child1;
        var item2 = (Widgets.Scene)child2;
        if (item1 != null && item2 != null) {
            if (item1.order != item2.order) {
                return item1.order - item2.order;
            }
            return item1.name.collate (item2.name);
        }
        return 0;
    }

    public static int notes_sort_func (Gtk.ListBoxRow child1, Gtk.ListBoxRow child2) {
        var item1 = (Widgets.Note)child1;
        var item2 = (Widgets.Note)child2;
        if (item1 != null && item2 != null) {
            return item1.title.collate (item2.title);
        }
        return 0;
    }
}