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
    property int index: -1

    property alias name: nameInput.text
    property alias category: categoryInput.text
    property alias userName: userNameInput.text
    property alias password: passwordInput.text
    property alias notes: notesInput.text

    MessageDialog {
        id: noNameGivenDialog
        parent: mainPage
        text: "Please enter at least an entry name."
    }

    Flickable {
        id: inputFlickable
        anchors.fill: parent

        contentHeight: inputArea.height
        clip: true

        Item {
            id: inputArea
            width: parent.width
            height: 400

            Column {
                id: column

                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width

                spacing: primaryFontSize * 0.25

                Row {
                    id: nameRow

                    width: parent.width
                    height: nameInput.height

                    Text {
                        id: nameText
                        anchors.left: parent.left
                        font.pointSize: primaryFontSize
                        text: "Name:"
                    }

                    CommonTextField {
                        id: nameInput
                        anchors{left: nameText.right; leftMargin: primaryFontSize / 2; right: parent.right}
                    }
                }


                Row {
                    id: categoryRow
                    Text {
                        id: categoryText
                        anchors.left: parent.left
                        font.pointSize: primaryFontSize
                        text: "Category:"
                    }

                    CommonTextField {
                        id: categoryInput
                        anchors{left: nameText.right
                                leftMargin: primaryFontSize / 2; right: parent.right}
                    }
                }

//                /*
//                 * Placeholder for the combobox below... somehow the "stable" Fremantle Qt version
//                 * does not place the combobox correctly in the grid.
//                 */
//                Rectangle{width: 0.5 * parent.width; height: categoryInput.height; color: "white"}

//                QComboBox{id: categoryInput; width: 0.5 * parent.width; z: 3;
//                    /*
//                     * Next hack to place the combobox "in" the grid...
//                     * FIXME: Move this hack to some place such that only the Fremantle version uses it!
//                     */
//                    x: parent.width * 0.5 + 5
//                    y: nameInput.y
//                }

                Text {text: "User Name"}
                Text {text: "Password"}
                CommonTextField{id: userNameInput; width: 0.5 * parent.width}
                CommonTextField{id: passwordInput; width: 0.5 * parent.width}


                Text {
                    id: notesLabel
                    text: "Notes"
                }
                CommonTextArea{
                    id: notesInput
                    width: parent.width
                }
            }

        }
    }
}
