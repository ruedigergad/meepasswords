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

import QtQuick 2.0
import meepasswords 1.0

Rectangle {
    id: editEntryRectangle

    color: "white"

    property bool edit: false
    property bool newEntry: false
    property int entryId: -1
    property bool isShown: false

    property alias name: nameInput.text
    property alias category: categoryInput.text
    property alias userName: userNameInput.text
    property alias password: passwordInput.text
    property alias notes: notesInput.text

    function hide() {
        edit = false
        newEntry = false
        mainContentFlickable.contentX = mainFlickable.width
        isShown = false
        entryListView.focus = true
        inputFlickable.contentY = 0
    }

    function resetContent() {
        edit = false
        newEntry = false
        entryId = -1
        name = ""
        category = "Default"
        userName = ""
        password = ""
        notes = ""
    }

    function save() {
        focus = true
        entryStorage.getModel().addOrUpdateEntry(name,
                                                 category,
                                                 userName,
                                                 password,
                                                 notes,
                                                 entryId)
        hide()
    }

    function show() {
        mainContentFlickable.contentX = mainFlickable.width * 2
        isShown = true
    }

    function toggleEdit() {
        edit = !edit
    }

    onEditChanged: {
        if (edit) {
            nameInput.focus = true
        } else {
            entryListView.focus = true
        }
    }

//    MessageDialog {
//        id: noNameGivenDialog
//        parent: mainPage
//        text: "Please enter at least an entry name."
//    }

    Flickable {
        id: inputFlickable

        anchors{top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right; margins: primaryFontSize * 0.5}

        contentHeight: inputArea.height * 1.75
        clip: true

        Item {
            id: inputArea
            width: parent.width * 0.975
            anchors.horizontalCenter: parent.horizontalCenter
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
                    font.pointSize: primaryFontSize * 0.6
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

                        Keys.onEnterPressed: userNameInput.focus = true
                        Keys.onReturnPressed: userNameInput.focus = true
                        Keys.onTabPressed: userNameInput.focus = true
                        Keys.onBacktabPressed: notesInput.focus = true
                        Keys.onEscapePressed: toggleEdit()
                        Keys.onPressed: {
                            switch (event.key) {
                            case Qt.Key_S:
                                if (event.modifiers & Qt.ControlModifier) {
                                    save()
                                }
                                break
                            default:
                                break
                            }
                        }
                    }
                }

                Text {
                    id: categoryText
                    anchors.left: parent.left
                    font.pointSize: primaryFontSize * 0.6
                    text: "Category"
                }
                Row {
                    id: categoryRow

                    width: parent.width
                    height: nameInput.height

                    CommonButton {
                        id: categoryInput
                        anchors{left: parent.left; right: addCategoryIcon.left
                                rightMargin: primaryBorderSize * 0.4; verticalCenter: parent.verticalCenter}
                        enabled: edit || newEntry
                        onClicked: categorySelectionDialog.open()
                    }

                    CommonToolIcon {
                        id: addCategoryIcon
                        iconSource: ":/icons/add.png"
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        enabled: edit || newEntry
                        onClicked: newCategoryDialog.open()
                    }
                }

                Text {
                    id: userNameText
                    anchors.left: parent.left
                    font.pointSize: primaryFontSize * 0.6
                    text: "User Name"
                }
                Row {
                    id: userNameRow

                    width: parent.width

                    CommonTextField {
                        id: userNameInput
                        anchors{left: parent.left; right: userNameCopyButton.left; rightMargin: primaryBorderSize * 0.4}
                        enabled: edit || newEntry
//                        pointSize: primaryFontSize * 0.6

                        Keys.onEnterPressed: passwordInput.focus = true
                        Keys.onReturnPressed: passwordInput.focus = true
                        Keys.onTabPressed: passwordInput.focus = true
                        Keys.onBacktabPressed: nameInput.focus = true
                        Keys.onEscapePressed: toggleEdit()
                        Keys.onPressed: {
                            switch (event.key) {
                            case Qt.Key_S:
                                if (event.modifiers & Qt.ControlModifier) {
                                    save()
                                }
                                break
                            default:
                                break
                            }
                        }
                    }
                    CommonButton {
                        id: userNameCopyButton
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: userNameInput.height
                        font.pointSize: primaryFontSize * 0.6
                        text: "Copy"
                        onClicked: clipboard.setText(userName)
                    }
                }


                Text {
                    id: passwordText
                    anchors.left: parent.left
                    font.pointSize: primaryFontSize * 0.6
                    text: "Password"
                }
                Row {
                    id: passwordRow

                    width: parent.width

                    CommonTextField {
                        id: passwordInput
                        anchors{left: parent.left; right: passwordCopyButton.left; rightMargin: primaryBorderSize * 0.4}
//                        pointSize: primaryFontSize * 0.6
                        enabled: edit || newEntry

                        Keys.onEnterPressed: notesInput.focus = true
                        Keys.onReturnPressed: notesInput.focus = true
                        Keys.onTabPressed: notesInput.focus = true
                        Keys.onBacktabPressed: userNameInput.focus = true
                        Keys.onEscapePressed: toggleEdit()
                        Keys.onPressed: {
                            switch (event.key) {
                            case Qt.Key_S:
                                if (event.modifiers & Qt.ControlModifier) {
                                    save()
                                }
                                break
                            default:
                                break
                            }
                        }
                    }
                    CommonButton {
                        id: passwordCopyButton
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: passwordInput.height
                        font.pointSize: primaryFontSize * 0.6
                        text: "Copy"
                        onClicked: clipboard.setText(password)
                    }
                }

                Text {
                    id: notesLabel
                    text: "Notes"
                    font.pointSize: primaryFontSize * 0.6
                }
                CommonTextArea{
                    id: notesInput
                    width: parent.width
                    enabled: edit || newEntry
                    textFormat: Text.PlainText

                    Keys.onTabPressed: nameInput.focus = true
                    Keys.onBacktabPressed: passwordInput.focus = true
                    Keys.onEscapePressed: toggleEdit()
                    Keys.onPressed: {
                        switch (event.key) {
                        case Qt.Key_S:
                            if (event.modifiers & Qt.ControlModifier) {
                                save()
                            }
                            break
                        default:
                            break
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: primaryBorderSize

                    Rectangle {
                        anchors.centerIn: parent
                        height: primaryBorderSize / 6
                        width: parent.width

                        color: "darkgray"

                    }
                }

                CommonToolBar {
                    id: editToolBar

                    width: parent.width
                    spacing: primaryBorderSize

                    CommonToolIcon {
                        id: iconBack
                        width: parent.width / 3 - 2/3 * parent.spacing
                        iconSource: ":/icons/back.png"
                        onClicked: {
                            hide()
                        }
                    }
                    CommonButton {
                        id: editButton
                        width: parent.width / 3 - 2/3 * parent.spacing
                        text: "Edit"
                        visible: !newEntry
                        onClicked: {
                            toggleEdit()
                        }
                        color: edit ? "red" : "#0e65c8"
                    }
                    CommonButton {
                        id: saveButton
                        width: parent.width / 3 - 2/3 * parent.spacing
                        anchors.right: parent.right
                        text: "Save"
                        enabled: edit || newEntry
                        onClicked: {
                            save()
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                z: -1
                onClicked: {
                    parent.focus = true
                }
            }
        }
    }

    TextInputDialog {
        id: newCategoryDialog

        parent: main

        title: "New Category"
        label: "Category Name"
        input: ""

        onAccepted: {
            console.log("Accepted new category: " + input)
            if (input !== "") {
                catModel.append({"name": input})
            }
        }
    }

    ListModel {
        id: catModel

        Component.onCompleted: {
            catModel.clear()
            catModel.append({"name": "Default"})
        }
    }

    Connections {
        target: entryStorage
        onDecryptionSuccess: {
            catModel.clear()
            catModel.append({"name": "Default"})
            var catList = entryStorage.getModel().getItemNames()
            for (var i = 0; i < catList.length; i++) {
                var cat = catList[i]
                if (cat !== "Default") {
                    catModel.append({"name": cat})
                }
            }
        }
        onNewFileOpened: {
            catModel.clear()
            catModel.append({"name": "Default"})
        }
    }

    SelectionDialog {
        id: categorySelectionDialog

        parent: main

        model: catModel
        title: "Category"
        label: "Please select a category."

        onAccepted: {
            categoryInput.text = catModel.get(selectedIndex).name
        }
    }
}
