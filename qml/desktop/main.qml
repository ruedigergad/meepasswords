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

import QtQuick 1.1
import meepasswords 1.0
import SyncToImap 1.0
import "../common"

Rectangle {
    id: main

    property int primaryFontSize: 16
    property int primaryBorderSize: primaryFontSize

    onRotationChanged: {
        console.log("Rotation changed...");
    }

    anchors.fill: parent

    color: "lightgray"

    Item {
        anchors.fill: parent

        Rectangle {
            id: header
            height: primaryFontSize * 2
            color: "#0c61a8"
            anchors{left: parent.left; right: parent.right; top: parent.top}

            Text {
                text: "MeePasswords"
                color: "white"
                font.family: "Nokia Pure Text Light"
                font.pointSize: primaryFontSize * 0.75
                anchors.left: parent.left
                anchors.leftMargin: primaryFontSize * 0.6
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MainFlickable {
            id: mainFlickable

            anchors{top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom}
        }
    }

    Menu {
        id: mainMenu

        parent: main
        anchors.bottomMargin: mainFlickable.meePasswordsToolBar.height
        onClosed: mainFlickable.meePasswordsToolBar.enabled = true
        onOpened: mainFlickable.meePasswordsToolBar.enabled = false

        CommonButton{
            id: changePassword
            anchors.bottom: syncToImap.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Change Password"
            onClicked: {
                mainFlickable.passwordChangeDialog.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: syncToImap
            anchors.bottom: syncAccountSettings.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Sync"
            onClicked: {
                confirmSyncToImapDialog.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: syncAccountSettings
            anchors.bottom: syncDeleteMessage.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Sync Account Settings"
            onClicked: {
                imapAccountSettings.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: syncDeleteMessage
            anchors.bottom: exportKeePassXml.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Clear Sync Data"
            onClicked: {
                confirmDeleteSyncMessage.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: exportKeePassXml
            anchors.bottom: importKeePassXml.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Export"
            onClicked: {
                mainFlickable.entryStorage.exportKeePassXml()
                mainMenu.close()
            }
        }

        CommonButton{
            id: importKeePassXml
            anchors.bottom: about.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Import"
            onClicked: {
                mainFlickable.entryStorage.importKeePassXml()
                mainMenu.close()
            }
        }

        CommonButton{
            id: about
            anchors.bottom: parent.bottom
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "About"
            onClicked: {
                mainFlickable.aboutDialog.open()
                mainMenu.close()
            }
        }
    }

    TextInputDialog {
        id: confirmSyncToImapDialog

        title: "Enter Password for Sync."
        label: "Please enter the password for decrypting the sync data. Note that for syncing you have to use the same password on all devices."

        echoMode: TextInput.Password

        onOpened: mainFlickable.meePasswordsToolBar.enabled = false
        onRejected: mainFlickable.meePasswordsToolBar.enabled = true

        onAccepted: {
            if (mainFlickable.entryStorage.canDecrypt(input)) {
                merger.setPassword(input)
                input = ""
                syncFileToImap.syncFile(mainFlickable.entryStorage.getStorageDirPath(), "encrypted.raw")
            } else {
                messageDialog.title = "Decryption Failed"
                messageDialog.message = "The decryption failed with the entered password. Please make sure you enter the correct password."
                messageDialog.open()
            }
        }
    }

    MessageDialog {
        id: messageDialog

        onOpened: mainFlickable.meePasswordsToolBar.enabled = false
        onRejected: mainFlickable.meePasswordsToolBar.enabled = true
    }

    SyncFileToImap {
        id: syncFileToImap

        imapFolderName: "meepasswords"
        merger: merger

        onFinished: {
            mainFlickable.meePasswordsToolBar.enabled = true
            mainFlickable.listView.focus = true
        }
        onStarted: mainFlickable.meePasswordsToolBar.enabled = false
    }

    Merger {
        id: merger
    }

    ImapAccountSettingsSheet {
        id: imapAccountSettings
    }

    ConfirmationDialog {
        id: confirmDeleteSyncMessage

        titleText: "Clear sync data?"
        message: "This may take some time."

        onOpened: mainFlickable.meePasswordsToolBar.enabled = false
        onRejected: mainFlickable.meePasswordsToolBar.enabled = true

        onAccepted: {
            syncMessageDeleter.deleteMessage("encrypted.raw")
        }
    }

    SyncMessageDeleter {
        id: syncMessageDeleter

        imapFolderName: "meepasswords"

        onFinished: {
            mainFlickable.meePasswordsToolBar.enabled = true
            mainFlickable.listView.focus = true
        }
        onStarted: mainFlickable.meePasswordsToolBar.enabled = false
    }
}
