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

import Qt 4.7
import meepasswords 1.0
import "../common"

Rectangle{
    id: editEntryDialog
    anchors.bottom: parent.bottom
    anchors.top: parent.bottom
    width: parent.width

    color: "white"
    visible: false
    z: 1

    property bool edit: false
    property int index: -1

    property alias text: entryLabel.text
    property alias name: nameInput.text
    property alias category: categoryInput.text
    property alias userName: userNameInput.text
    property alias password: passwordInput.text
    property alias notes: notesInput.text

    signal closed()
    signal closing()
    signal opened()
    signal opening()

    function finished(){
        console.log("finished")
        if(state === "closed"){
            visible = false
            closed()
        }else{
            opened()
        }
    }

    function close(){
        inputFlickable.contentY = 0

        closing()
        state = "closed"
    }

    function open(){
        console.log("open")
        categoryInput.setItems(entryStorage.getModel().getItemNames())
        acceptButton.enabled = edit

        visible = true
        inputFlickable.contentY = 0

        opening()
        state = "open"
    }

    onStateChanged: {
        console.log("Edit entry dialog state changed: " + state)
    }

    states: [
        State {
            name: "open"
            AnchorChanges { target: editEntryDialog; anchors.top: parent.top }
        },
        State {
            name: "closed"
            AnchorChanges { target: editEntryDialog; anchors.top: parent.bottom }
        }
    ]

    transitions: Transition {
        SequentialAnimation {
            AnchorAnimation { duration: 250; easing.type: Easing.OutCubic }
            ScriptAction { script: editEntryDialog.finished() }
        }
    }

    MessageDialog{
        id: noNameGivenDialog
        parent: mainPage
        text: "Please enter at least an entry name."

        onRejected: {
            acceptButton.enabled = false
            nameInput.forceActiveFocus()
        }
    }

    Rectangle {
        id: buttonBar
        anchors.top: parent.top
        height: rejectButton.height + 6
        width: parent.width
        z: 4

        color: "lightgray"

        CommonButton{
            id: rejectButton
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: "Cancel"
            onClicked: editEntryDialog.close();
        }

        Text {id: entryLabel; text: "Entry"; font.pixelSize: 30; font.capitalization: Font.SmallCaps; font.bold: true; anchors.centerIn: parent}

        CommonButton{
            id: acceptButton
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: "OK"
            onClicked: {
                if(nameInput.text === ""){
                    noNameGivenDialog.open();
                }else{
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
                    editEntryDialog.close();
                }
            }
        }
    }

    Flickable{
        id: inputFlickable
        anchors.top: buttonBar.bottom
        anchors.bottom: parent.bottom
        width: parent.width

        contentHeight: inputArea.height

        Rectangle {
            id: inputArea
            width: parent.width
            height: grid.height + notesLabel.height + (notesInput.height * 1.1)

            color: "white"

            Grid{
                id: grid
                z: 2

                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter

                width: parent.width
                columns: 2
                spacing: 5

                Text {text: "Name"}
                Text {text: "Category"}
                CommonTextField{id: nameInput; width: 0.5 * parent.width;
                    onTextChanged: acceptButton.enabled = true
                }

                /*
                 * Placeholder for the combobox below... somehow the "stable" Fremantle Qt version
                 * does not place the combobox correctly in the grid.
                 */
                Rectangle{width: 0.5 * parent.width; height: categoryInput.height; color: "white"}

                QComboBox{id: categoryInput; width: 0.5 * parent.width; z: 3;
                    /*
                     * Next hack to place the combobox "in" the grid...
                     * FIXME: Move this hack to some place such that only the Fremantle version uses it!
                     */
                    x: parent.width * 0.5 + 5
                    y: nameInput.y
                }

                Text {text: "User Name"}
                Text {text: "Password"}
                CommonTextField{id: userNameInput; width: 0.5 * parent.width}
                CommonTextField{id: passwordInput; width: 0.5 * parent.width}
            }

            Text {id: notesLabel; text: "Notes"; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: grid.bottom; z: 1}
            CommonTextArea{id: notesInput; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: notesLabel.bottom; width: parent.width; z: 1}
        }
    }

}
