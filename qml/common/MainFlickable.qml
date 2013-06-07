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
    interactive: false
    boundsBehavior: Flickable.StopAtBounds
    property bool animationIsRunning: false

    Behavior on contentX {
        SequentialAnimation {
            PropertyAnimation { duration: 140 }
            ScriptAction { script: mainFlickable.animationIsRunning = false }
        }
    }

    function logOut() {
        showItemAt = 0
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
                    showItemAt = 1
                } else {
                    entryStorage.loadAndDecryptDataUsingPassword(password)
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

                contentWidth: mainFlickable.width * 2
                flickableDirection: Flickable.HorizontalFlick
                interactive: true

                onContentXChanged: {
                    mainContent.performLogOut = contentX < -logText.width - primaryFontSize
                }

                Rectangle {
                    id: entryListRectangle

                    anchors{left: parent.left; top: parent.top; bottom: parent.bottom}

                    width: mainFlickable.width

                    EntryListView {
                        anchors{top: parent.top; left: parent.left; right: parent.right; bottom: toolBar.top}
                    }

                    Rectangle {
                        id: toolBar

                        anchors {left: parent.left; right: parent.right; bottom: parent.bottom}
                        height: meePasswordsToolBar.height

                        color: "lightgray"

                        MeePasswordsToolBar {
                            id: meePasswordsToolBar
                        }
                    }
                }

                Rectangle {
                    id: showEntryRectangle

                    anchors{left: entryListRectangle.right; top: parent.top; bottom: parent.bottom}
                    width: mainFlickable.width

                    MouseArea {
                        anchors.fill: parent
                    }
                }
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
