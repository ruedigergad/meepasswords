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

Row {
    id: toolBar

    anchors {
        left: parent.left; leftMargin: primaryBorderSize * 0.25
        right: parent.right; rightMargin: primaryBorderSize * 0.25
        verticalCenter: parent.verticalCenter
    }
    height: iconAdd.height
    spacing: primaryBorderSize * 0.25

    CommonToolIcon {
        id: iconBack

        iconSource: "qrc:/icons/back" + iconNameSuffix + ".png"
        opacity: enabled ? 1 : 0.5
        width: (parent.width - 4 * parent.spacing) / 5

        onClicked: logOut()
    }

    CommonToolIcon {
        id: iconAdd

        iconSource: "qrc:/icons/add" + iconNameSuffix + ".png"
        opacity: enabled ? 1 : 0.5
        width: (parent.width - 4 * parent.spacing) / 5

        onClicked: addEntry()
    }

    CommonToolIcon {
        id: iconDelete

        enabled: entryListView.listView.currentIndex > -1
        iconSource: "qrc:/icons/delete" + iconNameSuffix + ".png"
        opacity: enabled ? 1 : 0.5
        width: (parent.width - 4 * parent.spacing) / 5

        onClicked: deleteEntry()
    }

    CommonToolIcon {
        id: iconNext

        enabled: entryListView.listView.currentIndex > -1
        iconSource: "qrc:/icons/next" + iconNameSuffix + ".png"
        opacity: enabled ? 1 : 0.5
        width: (parent.width - 4 * parent.spacing) / 5

        onClicked: editEntry()
    }

    CommonToolIcon {
        id: iconMenu

        iconSource: "qrc:/icons/menu" + iconNameSuffix + ".png"
        opacity: enabled ? 1 : 0.5
        width: (parent.width - 4 * parent.spacing) / 5

        onClicked: ! mainMenu.isOpen ? mainMenu.open() : mainMenu.close()
    }
}
