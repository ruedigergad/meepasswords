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
import QtQuick.Controls 1.0
import meepasswords 1.0
import SyncToImap 1.0
import "../qtquick2_common"

Rectangle {
    id: main

    property bool loggedIn: false
    property bool newStorage: false
    property int primaryBorderSize: primaryFontSize
    property int primaryFontSize: 16

    function cleanOldFiles() {
        console.log("Cleaning left overs from last run.")
        fileHelper.rmAll(entryStorage.getStorageDirPath(), ".encrypted.");
    }

    function logOut() {
        entryStorage.getModel().clear()
        entryStorage.openStorage();
        stackView.pop()
    }

    width: 100
    height: 200
    color: "lightgray"

    onRotationChanged: {
        console.log("Rotation changed...");
    }

    Component.onCompleted: {
        cleanOldFiles()
        entryStorage.openStorage()
        passwordInput.focusPasswordInputField()
    }

    Item {
        id: mainItem

        anchors.fill: parent

        Rectangle {
            id: header

            height: primaryFontSize * 2
            color: "#0c61a8"
            anchors {left: parent.left; right: parent.right; top: parent.top}

            Text {
                id: headerText

                text: "MeePasswords"
                color: "white"
                font.pointSize: primaryFontSize * 0.75
                anchors.left: parent.left
                anchors.leftMargin: primaryFontSize * 0.6
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        StackView {
            id: stackView
            anchors {top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }

            initialItem: passwordInput
        }
    }

    EntryListViewRectangle {
        id: entryListViewRectangle
    }

    EntryStorage {
        id: entryStorage

        onStorageOpenSuccess: {
            console.log("Storage opened.")
            passwordInput.state = "EnterPassword"
            newStorage = false
        }
        onStorageOpenSuccessNewPassword: {
            console.log("New storage opened.")
            passwordInput.state = "NewPassword"
            newStorage = true
        }

        onDecryptionFailed: {
            console.log("Decryption failed.")
            passwordInput.state = "DecryptionFailed"
        }

        onDecryptionSuccess: {
            console.log("Decryption successful, logging in.")
            loggedIn = true
            passwordInput.password = ""
            stackView.push(entryListViewRectangle)
        }

        onNewFileOpened: {
            console.log("New file opened.")
            state = "LoginSuccess"
            stackView.push(entryListViewRectangle)
        }

        onOperationFailed: {
            console.log("Error in entry storage: " + message)
            errorDialog.message = message;
            errorDialog.open();
        }
    }

    FileHelper {
        id: fileHelper
    }

    PasswordInputRectangle {
        id: passwordInput

        onPasswordEntered: {
            if (newStorage) {
                entryStorage.setPassword(password)
                passwordInput.password = ""
                stackView.push(entryListViewRectangle)
            } else {
                entryStorage.migrateStorageIdentifier(password)
                entryStorage.setPassword(password)
                entryStorage.loadAndDecryptData()
            }
        }
    }

    QClipboard{
        id: clipboard
    }

    SettingsAdapter {
        id: settingsAdapter
    }

}
