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

    property QtObject entry

    anchors.fill: parent

    Connections{
        target: mainPage
        onStatusChanged: {
            if(mainPage.status === PageStatus.Deactivating){
                editEntrySheet.reject()
            }
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
            text: "Save"
            onClicked: {
                if(nameInput.text === ""){
                    noNameGivenDialog.open();
                }else{
                    editEntrySheet.accept();
                }
            }
        }
    }

    content: Flickable {
        contentHeight: grid.height
        anchors.fill: parent

        Column {
            id: grid
            spacing: 16

            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20

            LabeledInput {
                id: nameInput
                label: "Account Name"
                text: entry ? entry.name : ""
                placeholderText: label
                anchors.left: parent.left
                anchors.right: parent.right
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right

                Label {
                    text: "Category"
                    color: "gray"
                    font.pixelSize: 25
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.right: parent.right
                }

                Item {
                    height: childrenRect.height
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Button {
                        id: categoryInput
                        text: (entry && entry.category !== "") ? entry.category : "Default"
                        iconSource: "image://theme/icon-m-common-combobox-arrow"
                        anchors.left: parent.left
                        anchors.right: categoryBtn.left
                        anchors.rightMargin: 10
                        anchors.top: parent.top
                        onClicked: categorySelectionDialog.open()
                    }

                    Button {
                        id: categoryBtn
                        width: 100
                        text: "New"
                        anchors.top: parent.top
                        anchors.right: parent.right
                        onClicked: newCategoryDialog.open()
                    }
                }
            }

            LabeledInput {
                id: userNameInput
                label: "User Name"
                text: entry ? entry.userName : ""
                placeholderText: label
                anchors.left: parent.left
                anchors.right: parent.right
            }

            LabeledInput {
                id: passwordInput
                label: "Password"
                text: entry ? entry.password : ""
                placeholderText: label
                anchors.left: parent.left
                anchors.right: parent.right
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right

                Label {
                    text: "Notes"
                    color: "gray"
                    font.pixelSize: 25
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.right: parent.right
                }

                TextArea {
                    id: notesInput
                    text: entry ? entry.notes : ""
                    placeholderText: "Notes"
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
            }
        }

        // Currently does not work. No idea why.
        ScrollDecorator {
            flickableItem: parent
        }
    }

    onAccepted: {
        // If category is "Default", don't save category at all
        entryStorage.getModel().addOrUpdateEntry(nameInput.text,
                                                 categoryInput.text,
                                                 userNameInput.text,
                                                 passwordInput.text,
                                                 notesInput.text,
                                                 (entry ? entry.id : -1))
    }

    Dialog {
        id: noNameGivenDialog

        content: Text {
            anchors.centerIn: parent
            text: "Please enter at least an entry name."
            font.pixelSize: 30
            color: "white"
            horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap
        }

        onRejected: {
            nameInput.forceActiveFocus();
        }
    }

    ListModel {
        id: catModel
        Component.onCompleted: {
            catModel.append({"name": "Default"})
            var catList = entryStorage.getModel().getItemNames()
            for (var i = 0; i < catList.length; i++) {
                catModel.append({"name": catList[i]})
            }
        }
    }

    SelectionDialog {
        id: categorySelectionDialog
        anchors.fill: parent // Currently needed otherwise sometimes nothing is displayed
        selectedIndex: 0 // Another bug. If not set sometimes nothing is displayed
        titleText: "Select category"
        // It should be possible to directly bind to the StringList, but currently its blocked by a bug.
        // The following workaround seems to do it for now.
        model: catModel //entryStorage.getModel().getItemNames()
        onSelectedIndexChanged: {
            categoryInput.text = selectedIndex < 1 ? "Default" : model.get(selectedIndex).name
        }
    }

    QueryDialog {
        id: newCategoryDialog
        titleText: "Enter new category"
        acceptButtonText: "OK"
        rejectButtonText: "Cancel"
        content: TextField {
            id: newCatTxt
            width: 400
            focus: true
            placeholderText: "Category"
            anchors.centerIn: parent
        }
        onAccepted: {
            categoryInput.text = newCatTxt.text
            newCatTxt.text = ""
        }
        onRejected: {
            newCatTxt.text = ""
        }
    }
}
