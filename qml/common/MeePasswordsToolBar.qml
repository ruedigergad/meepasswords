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

import QtQuick 1.1

CommonToolBar {
    id: toolBar

    property int minWidth: iconAdd.width + iconNext.width + iconDelete.width + iconBack.width + iconMenu.width

    spacing: (width - minWidth) / 4

    CommonToolIcon {
        id: iconBack
        iconSource: ":/icons/back.png"
        opacity: enabled ? 1 : 0.5
        onClicked: logOut()
    }
    CommonToolIcon {
        id: iconAdd
        iconSource: ":/icons/add.png"
        opacity: enabled ? 1 : 0.5
        onClicked: mainRectangle.addItem()
    }
    CommonToolIcon {
        id: iconDelete
        iconSource: ":/icons/delete.png"
        opacity: enabled ? 1 : 0.5
    }
    CommonToolIcon {
        id: iconNext
        iconSource: ":/icons/next.png"
        opacity: enabled ? 1 : 0.5
    }
    CommonToolIcon {
        id: iconMenu
        iconSource: ":/icons/menu.png"
        anchors.right: parent === undefined ? undefined : parent.right
        onClicked: ! mainMenu.isOpen ? mainMenu.open() : mainMenu.close()
        opacity: enabled ? 1 : 0.5
    }
}
