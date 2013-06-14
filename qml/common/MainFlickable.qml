/*
 *  Copyright 2013 Ruediger Gad
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
import meepasswords 1.0

Flickable {
    id: mainFlickable

    contentWidth: contentItem.width
    focus: true

    property alias aboutDialog: aboutDialog
    property alias deleteConfirmationDialog: deleteConfirmationDialog
    property alias entryStorage: entryStorage
    property bool newStorage: false
    property alias passwordChangeDialog: passwordChangeDialog
    property alias listView: entryListView.listView
    property bool loggedIn: false

    onLoggedInChanged: {
        contentX = loggedIn ? width : 0
        passwordInput.focus = !loggedIn
        entryListView.focus = loggedIn

        if (!loggedIn) {
            entryStorage.getModel().clear()
            entryStorage.openStorage();
        } else {
            editEntryRectangle.hide()
        }
    }

    flickableDirection: Flickable.HorizontalFlick
    interactive: false
    boundsBehavior: Flickable.StopAtBounds
    property bool animationIsRunning: false

    Behavior on contentX {
        SequentialAnimation {
            PropertyAnimation { duration: 140 }
            ScriptAction { script: mainFlickable.animationIsRunning = false }
        }
    }

    function addEntry() {
        editEntryRectangle.resetContent()
        editEntryRectangle.toggleEdit()
        editEntryRectangle.newEntry = true
        editEntryRectangle.show()
    }

    function deleteEntry() {
        deleteConfirmationDialog.entryId = listView.currentItem.entryId
        deleteConfirmationDialog.entryName = listView.currentItem.entryName
        deleteConfirmationDialog.open()
    }

    function editEntry() {
        editEntryRectangle.show()
    }

    function logOut() {
        passwordInput.password = ""
        entryStorage.getModel().clear();
        entryStorage.setPassword("");
        editEntryRectangle.hide()
        passwordInput.focus = true
        if (listView.count <= 0) {
            passwordInput.state = "EnterPassword"
        } else {
            passwordInput.state = "NewPassword"
        }
        loggedIn = false
    }

    Item {
        id: contentItem

        height: parent.height
        width: parent.width * 2

        PasswordInputRectangle {
            id: passwordInput

            anchors{left: parent.left; top: parent.top; bottom: parent.bottom}
            width: mainFlickable.width

            onPasswordEntered: {
                if (newStorage) {
                    entryStorage.setPassword(password)
                    loggedIn = true
                } else {
                    entryStorage.migrateStorageIdentifier(password)
                    entryStorage.setPassword(password)
                    entryStorage.loadAndDecryptData()
                }
            }
        }

        Rectangle {
            id: mainContent
            anchors{left: passwordInput.right; top: parent.top; bottom: parent.bottom}
            width: mainFlickable.width
            color: "lightgray"

            property bool performLogOut

            Text {
                id: logText
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Log out."
                font.pointSize: primaryFontSize
                color: mainContent.performLogOut ? "black" : "gray"
            }

            Flickable {
                id: mainContentFlickable
                anchors.fill: parent

                contentWidth: mainFlickable.width * 3
                contentX: mainFlickable.width
                flickableDirection: Flickable.HorizontalFlick
                interactive: true
                flickDeceleration: 10000

                boundsBehavior: Flickable.DragOverBounds
                property bool animationIsRunning: false

                Behavior on contentX {
                    SequentialAnimation {
                        PropertyAnimation { duration: 120 }
                        ScriptAction { script: mainContentFlickable.animationIsRunning = false }
                    }
                }

                onContentXChanged: {
                    mainContent.performLogOut = contentX < mainFlickable.width - logText.width - primaryFontSize
                }

                onMovementEnded: {
                    if (contentX >= mainFlickable.width * 1.5) {
                        editEntryRectangle.show()
                    } else {
                        editEntryRectangle.hide()
                    }

                    if (mainContent.performLogOut) {
                        logOut()
                    }
                }

                Item {
                    id: dummyItem
                    anchors{left: parent.left; top: parent.top; bottom: parent.bottom}
                    width: mainFlickable.width
                }

                Rectangle {
                    id: entryListRectangle

                    anchors{left: dummyItem.right; top: parent.top; bottom: parent.bottom}

                    width: mainFlickable.width

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
                            width: parent.width * 0.9
                            anchors.centerIn: parent
                        }
                    }
                }

                EditEntryRectangle {
                    id: editEntryRectangle

                    anchors{left: entryListRectangle.right; top: parent.top; bottom: parent.bottom}
                    width: mainFlickable.width
                }
            }
        }
    }

    Component.onCompleted: {
        console.debug("Opening storage...")
        entryStorage.openStorage();
    }

    AboutDialog {
        id: aboutDialog
        parent: main
        onClosed: entryListView.focus = true
    }

    PasswordChangeDialog {
        id: passwordChangeDialog
        parent: main
        onClosed: entryListView.focus = true
    }

    EntryStorage {
        id: entryStorage

        onStorageOpenSuccess: {
            passwordInput.state = "EnterPassword"
            newStorage = false
        }
        onStorageOpenSuccessNewPassword: {
            passwordInput.state = "NewPassword"
            newStorage = true
        }

        onDecryptionFailed: {
            console.log("Decryption failed.")
        }

        onDecryptionSuccess: {
            console.log("Decryption successful, logging in.")
            loggedIn = true
            passwordInput.password = ""
        }

        onNewFileOpened: state = "LoginSuccess"

        onOperationFailed: {
            errorDialog.message = message;
            errorDialog.open();
        }
    }

    QClipboard{
        id: clipboard
    }

    ConfirmationDialog {
        id: deleteConfirmationDialog
        parent: main
        property int entryId: -1
        property string entryName
        titleText: "Delete '" + entryName + "'?"
        message: "Are you sure you want to delete '" + entryName + "'?"
        onAccepted: {
            entryStorage.getModel().removeById(entryId)
//            if (listView.count > 0) {
//                listView.currentIndex = 0
//            } else {
//                listView.currentIndex = -1
//            }
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
}
