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
        }
    }

    AboutDialog {
        id: aboutDialog

        parent: main

        onClosed: entryListView.focus = true
    }

    ConfirmationDialog {
        id: confirmDeleteSyncMessage

        parent: main

        titleText: "Clear sync data?"
        message: "This may take some time."

        onOpened: toolBar.enabled = false
        onRejected: toolBar.enabled = true

        onAccepted: {
            syncMessageDeleter.deleteMessage("encrypted.raw")
            cleanOldFiles()
        }
    }

    TextInputDialog {
        id: confirmSyncToImapDialog

        echoMode: TextInput.Password
        label: "Please enter the password for decrypting the sync data. Note that for syncing you have to use the same password on all devices."
        parent: main
        title: "Enter Password for Sync."

        onOpened: toolBar.enabled = false
        onRejected: toolBar.enabled = true

        onAccepted: {
            if (entryStorage.canDecrypt(input)) {
                merger.setPassword(input)
                input = ""
                syncFileToImap.syncFile(entryStorage.getStorageDirPath(), "encrypted.raw")
            } else {
                messageDialog.title = "Decryption Failed"
                messageDialog.message = "The decryption failed with the entered password. Please make sure you enter the correct password."
                messageDialog.open()
            }
        }
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

    ImapAccountSettingsSheet {
        id: imapAccountSettings
        parent: main
    }

    Menu {
        id: mainMenu

        parent: main

        onClosed: toolBar.enabled = true
        onOpened: toolBar.enabled = false
    }

    Merger {
        id: merger
    }

    MessageDialog {
        id: messageDialog

        parent: main

        onOpened: toolBar.enabled = false
        onRejected: toolBar.enabled = true
    }

    PasswordChangeDialog {
        id: passwordChangeDialog

        parent: main

        onClosed: entryListView.focus = true
    }

    ProgressDialog {
        id: progressDialog

        title: "Syncing..."
        message: "Sync is in progess."

        maxValue: 6
        currentValue: 0
    }

    SyncFileToImap {
        id: syncFileToImap

        imapFolderName: "meepasswords"
        merger: merger
        messageDialog: messageDialog
        progressDialog: progressDialog
        useDialogs: true

        onFinished: {
            toolBar.enabled = true
            entryListView.listView.focus = true
            _fileHelper.rm(_imapSyncFile + ".backup")
        }
        onStarted: toolBar.enabled = false
        onMessageDialogClosed: entryListView.listView.focus = true
    }

    SyncMessageDeleter {
        id: syncMessageDeleter

        imapFolderName: "meepasswords"
        messageDialog: messageDialog
        progressDialog: progressDialog
        useDialogs: true

        onFinished: {
            toolBar.enabled = true
            entryListView.listView.focus = true
        }
        onStarted: toolBar.enabled = false
    }

}
