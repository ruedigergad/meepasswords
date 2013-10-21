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

import QtQuick 2.0

CommonDialog {
    id: selectionDialog

    anchors.fill: parent

    property alias title: titleText.text
    property alias label: labelText.text
    property alias model: selectionlListView.model
    property alias selectedIndex: selectionlListView.currentIndex
    property alias selectedItem: selectionlListView.currentItem

    function accept() {
        close()
        accepted()
    }

    Item {
        anchors.fill: parent

        Text {
            id: titleText
            font {pointSize: primaryFontSize; bold: true}
            anchors {bottom: labelText.top; bottomMargin: primaryFontSize * 0.25; horizontalCenter: parent.horizontalCenter}
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "white"
        }

        Text {
            id: labelText; font.pointSize: primaryFontSize * 0.75; color: "lightgray"
            anchors {bottom: selectionListViewRectangle.top; bottomMargin: primaryFontSize}
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Rectangle {
            id: selectionListViewRectangle

            anchors.centerIn: parent
            height: parent.height * 0.5
            width: parent.width * 0.75;

            opacity: 0.8
            color: "darkgray"
//            radius: primaryFontSize * 0.5

            ListView {
                id: selectionlListView

                anchors.fill: parent
                clip: true

                delegate: Text {
                    width: parent.width
                    text: name
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: primaryFontSize
                    color: "white"

                    property string itemName: name

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selectionlListView.currentIndex = index
                            selectionDialog.accept()
                        }
                    }
                }
            }
        }

        CommonButton{
            id: cancelButton; text: "Cancel"
            anchors {top: selectionListViewRectangle.bottom; topMargin: primaryFontSize; horizontalCenter: parent.horizontalCenter}
            onClicked: reject()
        }
    }
}
