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

    Item {
        anchors.fill: parent

        Rectangle {
            id: header
            height: 72
            color: "#0c61a8"
            anchors{left: parent.left; right: parent.right; top: parent.top}

            Text {
                text: "MeePasswords"
                color: "white"
                font.family: "Nokia Pure Text Light"
                font.pixelSize: 32
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Column {
            spacing: 20
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 40

            Image {
                id: meePasswordsIcon
                source: "qrc:/meepasswords_150x150.png"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                id: descriptionLabel
                text: "Keep your passwords protected."
                horizontalAlignment: Text.Center
                anchors.left: parent.left
                anchors.right: parent.right
            }

            Label {
                id: passwordLabel
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.Center
                anchors.left: parent.left
                anchors.right: parent.right
            }

            TextField {
                id: passwordField
                echoMode: TextInput.Password
                placeholderText: "Password"
                anchors.left: parent.left
                anchors.right: parent.right
            }

            Button {
                id: passwordButton
                text: qsTr("OK")
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: passwordInputPage.clicked()
            }
        }
    }
}
