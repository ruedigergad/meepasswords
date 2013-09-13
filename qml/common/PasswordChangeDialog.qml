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

import QtQuick 2.0

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
        anchors.top: parent.top
        width:parent.width

        Text {
            id: name; text: "Change Password"
            font {pointSize: primaryFontSize * 0.75; bold: true}
            anchors {top: parent.top; horizontalCenter: parent.horizontalCenter}
            color: "white"
        }

        Text {
            id: oldPasswordLabel; text: "Old Password: "
            font.pointSize: primaryFontSize * 0.6; color: "lightgray"
            anchors {top: name.bottom; topMargin: primaryBorderSize / 3; horizontalCenter: parent.horizontalCenter}
        }
        CommonTextField {
            id: oldPasswordInput;
            width: parent.width * 0.5;
            pointSize: primaryFontSize * 0.6
            anchors {top: oldPasswordLabel.bottom; topMargin: primaryBorderSize / 8; horizontalCenter: parent.horizontalCenter}
            echoMode: TextInput.Password
        }

        Text {
            id: newPasswordLabel; text: "New Password: ";
            font.pointSize: primaryFontSize * 0.6; color: "lightgray";
            anchors {top: oldPasswordInput.bottom; topMargin: primaryBorderSize / 8; horizontalCenter: parent.horizontalCenter}
        }
        CommonTextField {
            id: newPasswordInput;
            width: parent.width * 0.5;
            pointSize: primaryFontSize * 0.6
            anchors {top: newPasswordLabel.bottom; topMargin: primaryBorderSize / 8; horizontalCenter: parent.horizontalCenter}
            echoMode: TextInput.Password
        }

        Text {
            id: confirmPasswordLabel
            text: "Re-type new Password: "; font.pointSize: primaryFontSize * 0.6; color: "lightgray";
            anchors {top: newPasswordInput.bottom; topMargin: primaryBorderSize / 8; horizontalCenter: parent.horizontalCenter}
        }
        CommonTextField {
            id: confirmPasswordInput;
            width: parent.width * 0.5;
            pointSize: primaryFontSize * 0.6
            anchors {top: confirmPasswordLabel.bottom; topMargin: primaryBorderSize / 8; horizontalCenter: parent.horizontalCenter}
            echoMode: TextInput.Password
        }

        CommonButton{
            id: okButton; text: "OK";
            anchors {top: confirmPasswordInput.bottom; topMargin: primaryBorderSize / 3; horizontalCenter: parent.horizontalCenter}
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

        CommonButton{
            id: cancelButton; text: "Cancel";
            anchors {top: okButton.bottom; topMargin: primaryBorderSize / 8; horizontalCenter: parent.horizontalCenter}
            onClicked: {
                passwordChangeDialog.close()
            }
        }
    }
}
