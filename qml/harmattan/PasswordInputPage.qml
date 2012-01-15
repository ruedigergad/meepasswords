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
import com.nokia.meego 1.0

Page {
    id: passwordInputPage

    anchors.fill: parent

    orientationLock: PageOrientation.LockPortrait

    property alias text: passwordLabel.text
    property alias password: passwordField.text
    signal clicked()
    onClicked: {}

    onStatusChanged: {
        if(status === DialogStatus.Open){
            passwordField.text = "";
            entryStorage.setPassword("");
            passwordField.forceActiveFocus();
        }
    }

    Rectangle{
        anchors.fill: parent
        color: "white"

        Label {
            id: appNameLabel
            text: "MeePasswords"
            font.pixelSize: 40
            font.bold: true

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: meePasswordsIcon.top
            anchors.bottomMargin: 10
        }

        Image {
            id: meePasswordsIcon
            source: "qrc:/meepasswords_150x150.png"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: descriptionLabel.top
            anchors.bottomMargin: 10
        }

        Label {
            id: descriptionLabel
            text: "Keep your passwords protected."
            anchors.centerIn: parent
        }

        Label {
            id: passwordLabel

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: descriptionLabel.bottom
            anchors.topMargin: 30
            width: parent.width

            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        TextField {
            id: passwordField

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: passwordLabel.bottom
            anchors.topMargin: 10

            echoMode: TextInput.Password
        }

        Button{
            id: passwordButton
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: passwordField.bottom
            anchors.topMargin: 10
            text: qsTr("OK")
            onClicked: {}
        }
    }

    Component.onCompleted: {
        passwordButton.clicked.connect(clicked)
    }
}
