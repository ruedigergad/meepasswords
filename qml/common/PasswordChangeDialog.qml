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

CommonDialog {
    id: passwordChangeDialog

    property alias oldPassword: oldPasswordInput.text

    function resetFields() {
        oldPasswordInput.text = ""
        newPasswordInput.text = ""
        confirmPasswordInput.text = ""
        oldPasswordInput.forceActiveFocus()
    }

    onClosed: {
        resetFields()
    }

    onOpened: {
        resetFields()
    }

    MessageDialog{
        id: informationDialog

        property bool propagateClose: false

        onRejected: {
            if (propagateClose) {
                passwordChangeDialog.close()
            }
        }
    }

    content: Item {
        anchors.centerIn: parent
        width:parent.width

        Text {id: name; text: "Change Password"; font.pixelSize: primaryFontSize; font.bold: true; anchors.bottom: oldPasswordLabel.top; anchors.bottomMargin: 30; anchors.horizontalCenter: parent.horizontalCenter; color: "white"}

        Text {id: oldPasswordLabel; text: "Old Password: "; font.pixelSize: primaryFontSize * 0.75; color: "lightgray"; anchors.bottom: oldPasswordInput.top; anchors.horizontalCenter: parent.horizontalCenter}
        CommonTextField {
            id: oldPasswordInput;
            width: parent.width * 0.5;
            anchors.bottom: newPasswordLabel.top;
            anchors.bottomMargin: 10;
            anchors.horizontalCenter: parent.horizontalCenter;
            echoMode: TextInput.Password
        }

        Text {id: newPasswordLabel; text: "New Password: "; font.pixelSize: primaryFontSize * 0.75; color: "lightgray"; anchors.bottom: newPasswordInput.top; anchors.horizontalCenter: parent.horizontalCenter}
        CommonTextField {id: newPasswordInput;
            width: parent.width * 0.5;
            anchors.centerIn: parent;
            anchors.horizontalCenter: parent.horizontalCenter;
            echoMode: TextInput.Password}

        Text {
            id: confirmPasswordLabel
            text: "Re-type new Password: "; font.pixelSize: primaryFontSize * 0.75; color: "lightgray";
            anchors {top: newPasswordInput.bottom; horizontalCenter: parent.horizontalCenter}
        }
        CommonTextField {id: confirmPasswordInput;
            width: parent.width * 0.5;
            anchors {top: confirmPasswordLabel.bottom; horizontalCenter: parent.horizontalCenter}
            echoMode: TextInput.Password
        }

        CommonButton{id: okButton; text: "OK"; anchors.top: confirmPasswordInput.bottom; anchors.topMargin: 30; anchors.horizontalCenter: parent.horizontalCenter
            width: cancelButton.width
            onClicked: {
                if (newPasswordInput.text !== confirmPasswordInput.text) {
                    informationDialog.text = "New passwords do not match!"
                    informationDialog.propagateClose = false
                    informationDialog.open()
                    return
                }

                if (entryStorage.equalsStoredPassword(oldPasswordInput.text)
                        || entryStorage.equalsStoredHash(oldPasswordInput.text)) {
                    entryStorage.setPassword(newPasswordInput.text)
                    entryStorage.storeModel()

                    informationDialog.text = "Password successfully changed."
                    informationDialog.propagateClose = true
                    informationDialog.open()
                } else {
                    informationDialog.text = "Failed to set new password!\nOld password was not correct."
                    informationDialog.propagateClose = false
                    informationDialog.open()
                }
            }
        }

        CommonButton{id: cancelButton; text: "Cancel"; anchors.top: okButton.bottom; anchors.topMargin: 15; anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                passwordChangeDialog.close()
            }
        }
    }
}
