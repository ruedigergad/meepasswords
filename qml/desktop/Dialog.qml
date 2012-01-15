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

Rectangle {
    id: dialog
    anchors.fill: parent

    visible: true

    color: "black"
    opacity: 0

    z: 32

    signal opened()
    signal rejected()

    Behavior on opacity { PropertyAnimation { duration: 200 } }

    MouseArea{
        id: area
        anchors.fill: parent
        visible: dialog.visible

        onClicked: {
            close();
            rejected();
        }
    }

    function close(){
        opacity = 0
    }

    function open(){
        opacity = 0.9
        opened()
    }

    property Item content: Item{}

    onContentChanged: content.parent = dialog
}
