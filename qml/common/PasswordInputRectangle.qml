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

    Component.onCompleted: {
        passwordButton.clicked.connect(passwordEntered)
    }

    Text {
        id: appNameLabel
        text: "MeePasswords"
        font.pixelSize: 40
        font.bold: true

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: meePasswordsIcon.top
        anchors.bottomMargin: 0
    }

    Image {
        id: meePasswordsIcon
        source: "qrc:/meepasswords_150x150.png"

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: descriptionLabel.top
        anchors.bottomMargin: 0
    }

    Text {
        id: descriptionLabel
        text: "Keep your passwords protected."
        anchors.centerIn: parent
        width: parent.width
        font.pixelSize: 25
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    Text {
        id: passwordLabel

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: descriptionLabel.bottom
        anchors.topMargin: 10
        width: parent.width

        font.pixelSize: 20

        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    CommonTextField{
        id: passwordField
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: passwordLabel.bottom
        anchors.topMargin: 10
        echoMode: TextInput.Password
        width: parent.width * 0.5
        focus: true

        Keys.onEnterPressed: passwordButton.clicked()
        Keys.onReturnPressed: passwordButton.clicked()
    }

    CommonButton{
        id: passwordButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: passwordField.bottom
        anchors.topMargin: 10
        width: parent.width * 0.25
        text: qsTr("OK")
    }

    states: [
        State {
            name: "NewPassword"
            PropertyChanges {
                target: passwordLabel
                text: qsTr("Please enter a new password. "
                           + "Please keep the password at a safe place. "
                           + "There is no way to recover a lost password.")
            }
        },
        State {
            name: "EnterPassword"
            PropertyChanges {
                target: passwordLabel
                text: qsTr("Enter Password:")
            }
        }
    ]

    onStateChanged: {
        password = ""
    }
}
