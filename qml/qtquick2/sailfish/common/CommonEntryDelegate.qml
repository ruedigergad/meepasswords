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
import Sailfish.Silica 1.0

Item {
    id: listItem
    property bool menuOpen: entryListView.contextMenu != null && entryListView.contextMenu.parent === listItem.parent

    width: parent.width
    height: menuOpen ? entryListView.contextMenu.height + entryItem.height : entryItem.height

    BackgroundItem {
        id: entryItem

        height: entryDelegate.height
        width: parent.width

        EntryDelegate {
            id: entryDelegate

            onPressAndHold: {
                if (!entryListView.contextMenu)
                    entryListView.contextMenu = entryListView.contextMenuComponent.createObject(entryListView)
                entryListView.contextMenu.show(listItem.parent)
            }
        }
    }
}
