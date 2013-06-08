/*
 *  Copyright 2013 Ruediger Gad
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

Rectangle {
    id: editEntryRectangle

    color: "lightgray"

    property bool edit: false
    property bool newEntry: false
    property int index: -1

    property alias name: nameInput.text
    property alias category: categoryInput.text
    property alias userName: userNameInput.text
    property alias password: passwordInput.text
    property alias notes: notesInput.text

    function resetContent() {
        edit = false
        newEntry = false
        index = -1
        name = ""
        category = ""
        userName = ""
        password = ""
        notes = ""
    }

    onNameChanged: {
        nameInput.focus = true
    }

//    MessageDialog {
//        id: noNameGivenDialog
//        parent: mainPage
//        text: "Please enter at least an entry name."
//    }

    Flickable {
        id: inputFlickable

        anchors{top: parent.top; bottom: editToolBarRectangle.top; left: parent.left; right: parent.right; margins: primaryFontSize * 0.5}

        contentHeight: inputArea.height
        clip: true

        Item {
            id: inputArea
            width: parent.width
            height: column.height

            Column {
                id: column

                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width

                spacing: primaryFontSize * 0.25

                Text {
                    id: nameText
                    anchors.left: parent.left
                    font.pointSize: primaryFontSize * 0.75
                    text: "Entry Name"
                }
                Row {
                    id: nameRow

                    width: parent.width
                    height: nameInput.height

                    CommonTextField {
                        id: nameInput
                        width: parent.width
                        enabled: edit || newEntry

                        Keys.onEnterPressed: categoryInput.focus = true
                        Keys.onReturnPressed: categoryInput.focus = true
                        Keys.onTabPressed: categoryInput.focus = true
                    }
                }

                Text {
                    id: categoryText
                    anchors.left: parent.left
                    font.pointSize: primaryFontSize * 0.75
                    text: "Category"
                }
                Row {
                    id: categoryRow

                    width: parent.width
                    height: nameInput.height

                    CommonTextField {
                        id: categoryInput
                        anchors{left: parent.left; right: addCategoryIcon.left; rightMargin: primaryFontSize * 0.25}
                        enabled: edit || newEntry

                        Keys.onEnterPressed: userNameInput.focus = true
                        Keys.onReturnPressed: userNameInput.focus = true
                        Keys.onTabPressed: userNameInput.focus = true
                    }

                    CommonToolIcon {
                        id: addCategoryIcon
                        iconSource: ":/icons/add.png"
                        anchors.right: parent.right
                        onClicked: newCategoryDialog.open()
                    }
                }

                Text {
                    id: userNameText
                    anchors.left: parent.left
                    font.pointSize: primaryFontSize * 0.75
                    text: "User Name"
                }
                Row {
                    id: userNameRow

                    width: parent.width

                    CommonTextField {
                        id: userNameInput
                        anchors{left: parent.left; right: userNameCopyButton.left; rightMargin: primaryFontSize * 0.5}
                        enabled: edit || newEntry

                        Keys.onEnterPressed: passwordInput.focus = true
                        Keys.onReturnPressed: passwordInput.focus = true
                        Keys.onTabPressed: passwordInput.focus = true
                    }
                    CommonButton {
                        id: userNameCopyButton
                        anchors.right: parent.right
                        text: "Copy"
                    }
                }


                Text {
                    id: passwordText
                    anchors.left: parent.left
                    font.pointSize: primaryFontSize * 0.75
                    text: "Password"
                }
                Row {
                    id: passwordRow

                    width: parent.width

                    CommonTextField {
                        id: passwordInput
                        anchors{left: parent.left; right: passwordCopyButton.left; rightMargin: primaryFontSize * 0.5}
                        enabled: edit || newEntry

                        Keys.onEnterPressed: notesInput.focus = true
                        Keys.onReturnPressed: notesInput.focus = true
                        Keys.onTabPressed: notesInput.focus = true
                    }
                    CommonButton {
                        id: passwordCopyButton
                        anchors.right: parent.right
                        text: "Copy"
                    }
                }

                Text {
                    id: notesLabel
                    text: "Notes"
                    font.pointSize: primaryFontSize * 0.75
                }
                CommonTextArea{
                    id: notesInput
                    width: parent.width
                    enabled: edit || newEntry
                    textFormat: Text.RichText

                    Keys.onTabPressed: nameInput.focus = true
                }
            }
        }
    }

    TextInputDialog {
        id: newCategoryDialog

        title: "New Category"
        label: "Category Name"
        input: ""
    }

    Rectangle {
        id: editToolBarRectangle

        anchors{ left:parent.left; right: parent.right; bottom: parent.bottom }
        height: editToolBar.height
        color: "lightgray"

        CommonToolBar {
            id: editToolBar

            width: parent.width

            CommonToolIcon {
                id: iconBack
                anchors {right: editButton.left; rightMargin: primaryFontSize * 3}
                iconSource: ":/icons/back.png"
                opacity: enabled ? 1 : 0.5
                onClicked: {
                    resetContent()
                    mainContentFlickable.contentX = 0
                }
            }
            CommonButton {
                id: editButton
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Edit"
                visible: !newEntry
                opacity: 1
                onClicked: {
                    edit = !edit
                    if (edit) {
                        nameInput.focus = true
                    }
                }
                color: edit ? "red" : "#0e65c8"
            }
            CommonButton {
                id: saveButton
                anchors {left: editButton.right; leftMargin: primaryFontSize * 3}
                text: "Save"
                enabled: edit || newEntry
                onClicked: {
                    entryStorage.getModel().addOrUpdateEntry(name,
                                                             category,
                                                             userName,
                                                             password,
                                                             notes,
                                                             index)
                    mainContentFlickable.contentX = 0
                }
            }
        }
    }
}
