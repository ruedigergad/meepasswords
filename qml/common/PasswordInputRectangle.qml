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

Rectangle{
    id: passwordInputRectangle

    color: "lightgray"

    property alias text: passwordLabel.text
    property alias password: passwordField.text
    signal passwordEntered()
    focus: true

    Component.onCompleted: {
        passwordButton.clicked.connect(passwordEntered)
        forceActiveFocus()
    }

    Text {
        id: appNameLabel
        text: "MeePasswords"
        font.pointSize: primaryFontSize * 0.8
        font.bold: true

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: primaryFontSize
    }

    Image {
        id: meePasswordsIcon
        source: "qrc:/meepasswords_150x150.png"

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: appNameLabel.bottom
    }

    Text {
        id: descriptionLabel
        text: "Keep your passwords protected."
        anchors.top: meePasswordsIcon.bottom
        width: parent.width
        font.pointSize: primaryFontSize * 0.7
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    Text {
        id: passwordLabel

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: descriptionLabel.bottom
        anchors.topMargin: primaryFontSize * 0.75
        width: parent.width

        font.pointSize: primaryFontSize * 0.6

        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    CommonTextField{
        id: passwordField
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: passwordLabel.bottom
        anchors.topMargin: primaryFontSize * 0.4
        echoMode: TextInput.Password
        width: parent.width * 0.5
        focus: passwordInputRectangle.focus

        Keys.onEnterPressed: passwordButton.clicked()
        Keys.onReturnPressed: passwordButton.clicked()
    }

    CommonButton{
        id: passwordButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: passwordField.bottom
        anchors.topMargin: primaryFontSize * 0.4
        width: parent.width * 0.25
        text: qsTr("OK")
    }

    states: [
        State {
            name: "NewPassword"
            PropertyChanges {
                target: passwordLabel
                text: qsTr("Please enter a new password.")
            }
        },
        State {
            name: "EnterPassword"
            PropertyChanges {
                target: passwordLabel
                text: qsTr("Enter Password:")
            }
        },
        State {
            name: "DecryptionFailed"
            PropertyChanges {
                target: passwordLabel
                text: qsTr("Decryption failed. Please make sure the password is correct.")
            }
        }
    ]
}
