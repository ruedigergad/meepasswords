/*
 *  Copyright 2011 Ruediger Gad
 *
 *  This file is part of MeePasswords.
 *
 *  MeePasswords is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  MeePasswords is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with MeePasswords.  If not, see <http://www.gnu.org/licenses/>.
 */

import Qt 4.7
import meepasswords 1.0


ListView {
    id: entryListView
    clip: true
    model: entryStorage.getModel()

    section {
        property: "category"
        criteria: ViewSection.FullString
        delegate: Item {
            width: parent.width
            height: sectionText.height

            Text {
                id: sectionText
                anchors.right: parent.right
                anchors.rightMargin: 10
                font.pixelSize: 30
                font.bold: true
                text: section
                color: "gray"
            }

            Rectangle {
                height: 1
                color: "gray"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }
    }
}
