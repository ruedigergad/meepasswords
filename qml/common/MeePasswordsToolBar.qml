/*
 *  Copyright 2012, 2013 Ruediger Gad
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

import QtQuick 2.0

CommonToolBar {
    id: toolBar

    property int minWidth: iconAdd.width + iconNext.width + iconDelete.width + iconBack.width + iconMenu.width
    height: 40

    spacing: (width - minWidth) / 4

    CommonToolIcon {
        id: iconBack
        iconSource: "qrc:/icons/back.png"
        opacity: enabled ? 1 : 0.5
        onClicked: logOut()
    }
    CommonToolIcon {
        id: iconAdd
        iconSource: "qrc:/icons/add.png"
        opacity: enabled ? 1 : 0.5
        onClicked: addEntry()
    }
    CommonToolIcon {
        id: iconDelete
        iconSource: "qrc:/icons/delete.png"
        enabled: listView.currentIndex > -1
        opacity: enabled ? 1 : 0.5
        onClicked: deleteEntry()
    }
    CommonToolIcon {
        id: iconNext
        iconSource: "qrc:/icons/next.png"
        enabled: listView.currentIndex > -1
        opacity: enabled ? 1 : 0.5
        onClicked: editEntry()
    }
    CommonToolIcon {
        id: iconMenu
        iconSource: "qrc:/icons/menu.png"
        anchors.right: parent === undefined ? undefined : parent.right
        onClicked: ! mainMenu.isOpen ? mainMenu.open() : mainMenu.close()
        opacity: enabled ? 1 : 0.5
    }
}
