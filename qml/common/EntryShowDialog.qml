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

CommonDialog {
    id: entryShowDialog

    property alias name: name.text
    property alias userName: userName.text
    property alias password: password.text
    property alias notes: notes.text

    property bool clipboardUsed: false

    ConfirmationDialog{
        id: copyToClipboardDialog

        property string content: ""
        property string type: ""

        titleText: "Copy to Clipboard?"
        message: "Copy " + type + " to clipboard?"

        onAccepted: {
            clipboardUsed = true
            clipboard.setText(content)
        }
    }

    onOpened: clipboardUsed = false

    onRejected: {
        if(clipboardUsed){
            clipboard.setText("")
        }
    }

    content: Item {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: name.height + grid.height + notesLabel.height + notes.height

        Text {id: name; font.pixelSize: 40; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter; color: "white"}

        Grid{
            id: grid

            anchors.top: name.bottom
            anchors.topMargin: 18
            anchors.horizontalCenter: parent.horizontalCenter

            columns: 2
            spacing: 10

            Text {text: "User Name: "; font.pixelSize: 30; color: "lightgray"}
            Text {id: userName; font.pixelSize: 30; color: "white"; font.bold: true
                onLinkActivated: {
                    copyToClipboardDialog.content = link
                    copyToClipboardDialog.type = "user name"
                    copyToClipboardDialog.open()
                }
            }
            Text {text: "Password: "; font.pixelSize: 30; color: "lightgray"}
            Text {id: password; font.pixelSize: 30; color: "white"; font.bold: true
                onLinkActivated: {
                    copyToClipboardDialog.content = link
                    copyToClipboardDialog.type = "password"
                    copyToClipboardDialog.open()
                }
            }
        }

        Text {id: notesLabel; text: "Notes"; anchors.top: grid.bottom; anchors.topMargin: 18; anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: 30; color: "lightgray"}
        Text {id: notes
            anchors.horizontalCenter: parent.horizontalCenter; anchors.top: notesLabel.bottom; anchors.topMargin: 6;
            font.pixelSize: 30; color: "white"
            textFormat: Text.RichText; horizontalAlignment: Text.AlignLeft; wrapMode: Text.NoWrap
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }
}
