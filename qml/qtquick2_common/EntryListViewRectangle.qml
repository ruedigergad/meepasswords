/*
 *  Copyright 2013 Ruediger Gad <r.c.g@gmx.de>
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

Rectangle {
    id: entryListRectangle

    function addEntry() {
        editEntryRectangle.resetContent()
        editEntryRectangle.toggleEdit()
        editEntryRectangle.newEntry = true
        stackView.push(editEntryRectangle)
    }

    function deleteEntry() {
        deleteConfirmationDialog.entryId = entryListView.listView.currentItem.entryId
        deleteConfirmationDialog.entryName = entryListView.listView.currentItem.entryName
        deleteConfirmationDialog.open()
    }

    function editEntry() {
        stackView.push(editEntryRectangle)
    }

    EntryListView {
        id: entryListView

        anchors{top: parent.top; left: parent.left; right: parent.right; bottom: toolBar.top}
    }

    Rectangle {
        id: toolBar

        anchors {left: parent.left; right: parent.right; bottom: parent.bottom}
        height: meePasswordsToolBar.height * 1.25
        color: "lightgray"

        MeePasswordsToolBar {
            id: meePasswordsToolBar
            width: parent.width - (primaryBorderSize / 2)
            anchors.centerIn: parent
        }
    }

    AboutDialog {
        id: aboutDialog

        parent: main

        onClosed: entryListView.focus = true
    }

    ConfirmationDialog {
        id: deleteConfirmationDialog

        property int entryId: -1
        property string entryName

        message: "Are you sure you want to delete '" + entryName + "'?"
        parent: main
        titleText: "Delete '" + entryName + "'?"

        onAccepted: {
            entryStorage.getModel().removeById(entryId)
        }

        onOpened: {
            deleteConfirmationDialog.focus = true
        }

        onClosed: {
            entryListView.focus = true
        }

        Keys.onEscapePressed: reject()
        Keys.onEnterPressed: accept()
        Keys.onReturnPressed: accept()
    }

    EditEntryRectangle {
        id: editEntryRectangle
    }

    Menu {
        id: mainMenu

        parent: main

        onClosed: toolBar.enabled = true
        onOpened: toolBar.enabled = false
    }

    PasswordChangeDialog {
        id: passwordChangeDialog

        parent: main

        onClosed: entryListView.focus = true
    }
}
