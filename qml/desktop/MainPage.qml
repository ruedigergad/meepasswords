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
import "../common"

Item {
    id: mainPage
    anchors.fill: parent

    onVisibleChanged: {
        entryListView.currentIndex = -1
        updateLabels()
    }

    function updateLabels() {
        var listEmpty = (entryStorage.getModel().rowCount() === 0);
        noContentLabel.visible = listEmpty;
        explanationLabel.visible = listEmpty;

        var itemSelected = !listEmpty && entryListView.currentIndex >= 0 && entryListView.currentIndex < entryStorage.getModel().rowCount();
        edit.enabled = itemSelected
    }

    AboutDialog{
        id: aboutDialog
    }

    ConfirmationDialog{
        id: logoutConfirmationDialog

        titleText: "Logout?"
        message: "Logout from MeePasswords?"

        onAccepted: {
            entryStorage.getModel().clear();
            main.state = "EnterPassword";
        }
    }


    ConfirmationDialog {
        id: deleteConfirmationDialog

        property int index: -1
        property string entryName: ""

        titleText: "Delete?"
        message: "Delete entry \"" + entryName + "\"?"

        onAccepted: {
            entryStorage.getModel().removeAt(index);
            updateLabels()
        }
    }

    Rectangle{
        id: listViewRectangle
        anchors.top: parent.top
        anchors.bottom: toolBar.top
        width: parent.width

        color: "white"

        Text {
            id: noContentLabel
            text: "No Entries"
            font.pixelSize: 80; anchors.bottom: explanationLabel.top; anchors.bottomMargin: 50; anchors.horizontalCenter: parent.horizontalCenter; color: "lightgray"
        }
        Text {
            id: explanationLabel
            text: "Use \"Add\" to add entries."
            font.pixelSize: 40;  color: "lightgray"; anchors.centerIn: parent;
        }

        EntryListView {
            id: entryListView
            delegate: EntryDelegate {}
            highlightMoveDuration: 200
            highlight: Rectangle {
                color: "#78bfff"
                width: parent.width
            }
            anchors.fill: parent

            onCountChanged: updateLabels();
            onCurrentIndexChanged: updateLabels();
        }
    }

    EditEntryDialog{
        id: editEntryDialog
        parent: listViewRectangle

        onOpening: {
            logout.enabled = false
            add.enabled = false
            edit.enabled = false
            menuButton.enabled = false
        }

        onOpened: {
            /*
             * Quite a hack to avoid the MouseArea of the EntryListView to "shine through".
             * Without this hack double clicking an are of the sheet where (below) an item
             * of the list is shown, the dialog showing the item info will pop up.
             */
            entryListView.visible = false
        }

        onClosing: {
            entryListView.visible = true
            logout.enabled = true
            add.enabled = true
            menuButton.enabled = true
            updateLabels()
        }
    }

    EntryShowDialog{
        id: entryShowDialog
    }

    Menu{
        id: menu
    }

    MessageDialog{
        id: messageDialog
    }

    PasswordChangeDialog{
        id: passwordChangeDialog
    }

    Rectangle{
        id: toolBar
        anchors.bottom: parent.bottom
        color: "lightgray"
        width: parent.width
        height: add.height


        CommonButton{
            id: logout
            anchors.left: parent.left
            width: parent.width * 0.25

            text: "Logout"

            onClicked: logoutConfirmationDialog.open()
        }
        CommonButton{
            id: add
            anchors.left: logout.right
            width: parent.width * 0.25

            text: "Add"

            onClicked: {
                editEntryDialog.text = "New Entry";
                editEntryDialog.name = "";
                editEntryDialog.category = "";
                editEntryDialog.userName = "";
                editEntryDialog.password = "";
                editEntryDialog.notes = "";
                editEntryDialog.edit = false;

                editEntryDialog.open();
            }
        }
        CommonButton{
            id: edit
            anchors.left: add.right
            width: parent.width * 0.25

            text: "Edit"

            onClicked: {
                var index = entryListView.currentIndex;
                var entry = entryStorage.getModel().at(index);

                editEntryDialog.text = "Edit Entry";
                editEntryDialog.name = entry.name;
                editEntryDialog.category = entry.category;
                editEntryDialog.userName = entry.userName;
                editEntryDialog.password = entry.password;
                editEntryDialog.notes = entry.notes;
                editEntryDialog.edit = true;
                editEntryDialog.index = index;

                editEntryDialog.open();
            }
        }
        CommonButton{
            id: menuButton
            anchors.left: edit.right
            anchors.right: parent.right
            width: parent.width * 0.25

            text: "Menu"

            onClicked: {
                if(! menu.visible){
                    menu.open();
                }
            }
        }
    }
}
