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
import meepasswords 1.0

Sheet{
    id: editEntrySheet
    anchors.fill: parent

    visualParent: mainPage

    property bool edit: false
    property int index: -1

    property alias text: entryLabel.text
    property alias name: nameInput.text
    property alias category: categoryInput.text
    property alias userName: userNameInput.text
    property alias password: passwordInput.text
    property alias notes: notesInput.text

    Dialog{
        id: noNameGivenDialog
        anchors.fill: parent

        content: Text {
            anchors.centerIn: parent
            width: parent.width
            text: "Please enter at least an entry name."
            font.pointSize: 30
            color: "white"
            horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap
        }

        onRejected: {
            //acceptButton.enabled = false;
            nameInput.forceActiveFocus();
        }
    }

    onStatusChanged: {
        if(status === DialogStatus.Opening){
            categoryInput.setItems(entryStorage.getModel().getItemNames());
            //acceptButton.enabled = edit;
        }else if(status === DialogStatus.Closing){
            textInput.closeSoftwareInputPanel();
        }else if(status === DialogStatus.Open){
            nameInput.forceActiveFocus();
        }
    }

    buttons: Item {
        anchors.fill: parent
        SheetButton{
            id: rejectButton
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: "Cancel"
            onClicked: editEntrySheet.reject();
        }

        SheetButton{
            id: acceptButton
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            platformStyle: SheetButtonAccentStyle { }
            text: "OK"
            onClicked: {
                if(nameInput.text === ""){
                    noNameGivenDialog.open();
                }else{
                    editEntrySheet.accept();
                }
            }
        }
    }

    content: Rectangle {
            anchors.fill: parent
            color: "white"

            Label {id: entryLabel; text: "Entry"; font.pixelSize: 30; font.capitalization: Font.SmallCaps; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top}
            Grid{
                id: grid
                z: 2

                anchors.top: entryLabel.bottom
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter

                width: parent.width
                columns: 2

                Label {text: "Name"}
                Label {text: "Category"}
                TextField{id: nameInput; width: 0.5 * parent.width;
                    placeholderText: "Enter Name"
                    //onPlatformPreeditChanged: acceptButton.enabled = true
                }
                QComboBox{id: categoryInput; width: 0.5 * parent.width; z: 3
                    TextInput{ id: textInput }

                    onFocusIn: textInput.openSoftwareInputPanel()

                    onFocusOut: textInput.closeSoftwareInputPanel()
                }
/*
                MTextEdit{id: categoryInput; width: 0.5 * parent.width;
                    TextInput{
                        id: textInput
                    }

                    MouseArea{
                        anchors.fill: parent;
                        width: categoryInput.width;
                        height: categoryInput.height;
                        onClicked: {
                            categoryInput.focus();
                            textInput.openSoftwareInputPanel();
                        }
                    }
                }
*/

                Label {text: "User Name"}
                Label {text: "Password"}
                TextField{id: userNameInput; width: 0.5 * parent.width}
                TextField{id: passwordInput; width: 0.5 * parent.width}
            }

            Label {id: notesLabel; text: "Notes"; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: grid.bottom; z: 1}
            TextArea{id: notesInput;
                anchors.horizontalCenter: parent.horizontalCenter; anchors.top: notesLabel.bottom;
                width: parent.width; z: 1; textFormat: TextEdit.PlainText}
    }

    onAccepted: {
        /*
         * Hack to get a usable category even when categoryInput is still focused.
         * categoryInput needs to loose focus at least once in order to return a usable QString.
         */
        nameInput.focus = true;
        if(edit){
            entryStorage.getModel().updateEntryAt(index, nameInput.text, categoryInput.text, userNameInput.text, passwordInput.text, notesInput.text);
        }else{
            entryStorage.getModel().addEntry(nameInput.text, categoryInput.text, userNameInput.text, passwordInput.text, notesInput.text);
        }
        editEntrySheet.close();
    }

    onRejected: editEntrySheet.close();
}
