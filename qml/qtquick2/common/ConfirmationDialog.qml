/*
 *  Copyright 2012, 2013 Ruediger Gad
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

Dialog {
    id: confirmationDialog

    property alias message: message.text
    property alias titleText: titleText.text

    signal accepted();

    function accept() {
        close()
        accepted()
    }

    Text {
        id: titleText

        anchors.bottom: message.top
        anchors.margins: 20
        color: "white"
        font.pointSize: primaryFontSize * 1.25
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        wrapMode: Text.Wrap
    }

    Text {
        id:message

        anchors.centerIn: parent
        color: "white"
        font.pointSize: primaryFontSize * 0.75
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        wrapMode: Text.Wrap
    }

    CommonButton {
        id: acceptButton

        anchors.top: message.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        text: "OK"
        width: parent.width * 0.5

        onClicked: {
            accept()
        }
    }

    CommonButton {
        id: rejectButton

        anchors.top: acceptButton.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Cancel"
        width: parent.width * 0.5

        onClicked: {
            reject()
        }
    }

    Keys.onEscapePressed: {
        reject()
    }

    Keys.onEnterPressed: {
        accept()
    }

    Keys.onReturnPressed: {
        accept()
    }
}
