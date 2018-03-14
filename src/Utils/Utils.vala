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
    public static string get_new_project_property (string title, string kind) {
        return """[General]
title=""" + title + """
[Metadata]
kind=""" + kind + """
""";
    }

    public static string get_new_chapter_property (string title, int order) {
        return """[General]
title=""" + title + """
name=""" + title + """
order=""" + order.to_string () + """
bin=false
""";
    }

    public static string get_new_scene_property (string title, int order) {
        return """[General]
title=""" + title + """
name=""" + title + """
order=""" + order.to_string () + """
bin=false
""";
    }

    public static string get_new_note_property (string title, int order) {
        return """[General]
title=""" + title + """
name=""" + title + """
order=""" + order.to_string () + """
bin=false
""";
    }
}