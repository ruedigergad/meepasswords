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

    property alias category: categoryInput.text
    property bool edit: false
    property int entryId: -1
    property bool isShown: false
    property alias name: nameInput.text
    property bool newEntry: false
    property alias notes: notesInput.text
    property alias password: passwordInput.text
    property alias userName: userNameInput.text

    color: primaryBackgroundColor

    function close() {
        resetContent()
        entryListView.focus = true
        inputFlickable.contentY = 0
//        stackView.pop()
        hide()
    }

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
        close()
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

        anchors{top: parent.top; bottom: parent.bottom; left: parent.left
                right: parent.right; margins: primaryFontSize * 0.5}
        clip: true
        contentHeight: inputArea.height * 1.75

        Item {
            id: inputArea

            anchors.horizontalCenter: parent.horizontalCenter
            height: column.height
            width: parent.width * 0.975

            Column {
                id: column

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10
                spacing: primaryFontSize * 0.25
                width: parent.width

                Text {
                    id: nameText

                    color: primaryFontColor
                    font.pointSize: primaryFontSize * 0.6
                    text: "Entry Name"
                }

                CommonTextField {
                    id: nameInput

                    enabled: edit || newEntry
                    width: parent.width

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

                Text {
                    id: categoryText

                    color: primaryFontColor
                    font.pointSize: primaryFontSize * 0.6
                    text: "Category"
                }

                Row {
                    id: categoryRow

                    height: nameInput.height
                    spacing: primaryBorderSize * 0.5
                    width: parent.width

                    CommonButton {
                        id: categoryInput

                        enabled: edit || newEntry
                        width: parent.width - addCategoryIcon.width - parent.spacing

                        onClicked: categorySelectionDialog.open()
                    }

                    CommonToolIcon {
                        id: addCategoryIcon

                        enabled: edit || newEntry
                        iconSource: "qrc:/icons/add" + iconNameSuffix + ".png"

                        onClicked: newCategoryDialog.open()
                    }
                }

                Text {
                    id: userNameText

                    color: primaryFontColor
                    font.pointSize: primaryFontSize * 0.6
                    text: "User Name"
                }

                Row {
                    id: userNameRow

                    spacing: primaryBorderSize * 0.5
                    width: parent.width

                    CommonTextField {
                        id: userNameInput

                        enabled: edit || newEntry
                        width: parent.width - userNameCopyButton.width - parent.spacing

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

                        font.pointSize: primaryFontSize * 0.6
                        height: userNameInput.height
                        text: "Copy"

                        onClicked: clipboard.setText(userName)
                    }
                }


                Text {
                    id: passwordText

                    color: primaryFontColor
                    font.pointSize: primaryFontSize * 0.6
                    text: "Password"
                }

                Row {
                    id: passwordRow

                    spacing: primaryBorderSize * 0.5
                    width: parent.width

                    CommonTextField {
                        id: passwordInput

                        enabled: edit || newEntry
                        width: parent.width - passwordCopyButton.width - parent.spacing

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

                        font.pointSize: primaryFontSize * 0.6
                        height: passwordInput.height
                        text: "Copy"

                        onClicked: clipboard.setText(password)
                    }
                }

                Text {
                    id: notesLabel

                    color: primaryFontColor
                    font.pointSize: primaryFontSize * 0.6
                    text: "Notes"
                }

                CommonTextArea{
                    id: notesInput

                    enabled: edit || newEntry
                    textFormat: Text.PlainText
                    width: parent.width

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
                    id: horizontalBarItem

                    width: parent.width
                    height: primaryBorderSize

                    Rectangle {
                        id: horizontalBarRectangle

                        anchors.centerIn: parent
                        color: secondaryFontColor
                        height: primaryBorderSize / 6
                        width: parent.width
                    }
                }

                Row {
                    id: editToolBar

                    spacing: primaryBorderSize
                    width: parent.width

                    CommonToolIcon {
                        id: iconBack

                        iconSource: "qrc:/icons/back" + iconNameSuffix + ".png"
                        width: parent.width / 3 - 2/3 * parent.spacing

                        onClicked: {
                            close()
                        }
                    }

                    CommonButton {
                        id: editButton

                        color: edit ? "red" : "#0e65c8"
                        opacity: !newEntry ? 1 : 0
                        text: "Edit"
                        width: parent.width / 3 - 2/3 * parent.spacing

                        onClicked: {
                            toggleEdit()
                        }
                    }

                    CommonButton {
                        id: saveButton

                        enabled: edit || newEntry
                        text: "Save"
                        width: parent.width / 3 - 2/3 * parent.spacing

                        onClicked: {
                            save()
                        }
                    }
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
