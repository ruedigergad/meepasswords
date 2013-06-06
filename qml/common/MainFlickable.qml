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

    property bool newStorage: false
    property int showItemAt: 0


    onShowItemAtChanged: {
        contentX = width * showItemAt
    }

    flickableDirection: Flickable.HorizontalFlick
    interactive: showItemAt > 0
    pressDelay: 0
    boundsBehavior: Flickable.StopAtBounds
    property bool animationIsRunning: false

    Behavior on contentX {
        SequentialAnimation {
            PropertyAnimation { duration: 140 }
            ScriptAction { script: mainFlickable.animationIsRunning = false }
        }
    }

    Item {
        id: contentItem

        anchors{top: parent.top; bottom: parent.bottom}
        width: parent.width * 3

        PasswordInputRectangle {
            id: passwordInput

            anchors{left: parent.left; top: parent.top; bottom: parent.bottom}
            width: mainFlickable.width

            onPasswordEntered: {
                if (newStorage) {
                    entryStorage.setPassword(password)
                    showItemAt = 1
                } else {
                    entryStorage.loadAndDecryptDataUsingPassword(password)
                }
            }
        }

        Rectangle {
            id: entryListRectangle

            anchors{left: passwordInput.right; top: parent.top; bottom: parent.bottom}
            width: mainFlickable.width

            EntryListView {
                anchors.fill: parent
            }
        }

        Rectangle {
            id: showEntryRectangle

            anchors{left: entryListRectangle.right; top: parent.top; bottom: parent.bottom}
            width: mainFlickable.width

            color: "red"

            MouseArea {
                anchors.fill: parent
                onClicked: showItemAt = 0
            }
        }
    }

    Component.onCompleted: {
        console.debug("Opening storage...")
        entryStorage.openStorage();
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

        onDecryptionSuccess: state = "LoginSuccess"
        onNewFileOpened: state = "LoginSuccess"

        onOperationFailed: {
            errorDialog.message = message;
            errorDialog.open();
        }
    }
}
