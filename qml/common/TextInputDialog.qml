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
    id: textInputDialog

    property alias title: titleText.text
    property alias label: labelText.text
    property alias input: inputField.text

    signal accepted

    function accept() {
        close()
        accepted()
    }

    onOpening: {
        input = ""
        inputField.focus = true
    }

    content: Item {
        anchors.centerIn: parent
        width:parent.width

        Text {id: titleText; font.pixelSize: primaryFontSize; font.bold: true; anchors.bottom: labelText.top; anchors.bottomMargin: 30; anchors.horizontalCenter: parent.horizontalCenter; color: "white"}

        Text {
            id: labelText; font.pixelSize: primaryFontSize * 0.75; color: "lightgray"
            anchors {bottom: inputField.top; bottomMargin: primaryFontSize * 0.25}
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        CommonTextField {
            id: inputField;
            width: parent.width * 0.8;
            anchors.centerIn: parent
            focus: true
        }

        CommonButton{id: okButton; text: "OK"; anchors.top: inputField.bottom; anchors.topMargin: 30; anchors.horizontalCenter: parent.horizontalCenter
            width: cancelButton.width
            onClicked: accept()
        }

        CommonButton{id: cancelButton; text: "Cancel"; anchors.top: okButton.bottom; anchors.topMargin: 15; anchors.horizontalCenter: parent.horizontalCenter
            onClicked: reject()
        }
    }
}
