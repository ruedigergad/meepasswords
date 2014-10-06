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
import meepasswords 1.0

Rectangle {
    id: entryListViewRectangle

    property alias listView: entryListView

//    color: "lightgoldenrodyellow"
    color: primaryBackgroundColor

    Item {
        id: placeHolder
        anchors.fill: parent
        visible: entryListView.model.count <= 0

        CommonPlaceHolder {

        }
    }

    CommonEntryListView {
        id: entryListView

        function setData(){
            if (count > 0 && currentIndex >= 0) {
                editEntryRectangle.entryId = currentItem.entryId
                editEntryRectangle.category = currentItem.entryCategory
                editEntryRectangle.name = currentItem.entryName
                editEntryRectangle.userName = currentItem.entryUserName
                editEntryRectangle.password = currentItem.entryPassword
        //            editEntryRectangle.userName = (userName !== "") ? createSimpleLink(userName) : " ";
        //            editEntryRectangle.password = (password !== "") ? createSimpleLink(password) : " ";
                editEntryRectangle.notes = currentItem.entryNotes
        //            editEntryRectangle.notes = beautifyNotes(notes);
            } else {
                editEntryRectangle.resetContent()
            }
        }

        anchors.fill: parent
        clip: true
        model: entryStorage.getModel()
        visible: model.count

        onCurrentIndexChanged: {
            if (currentIndex >= count) {
                currentIndex = count - 1
            }

            if (count > 0 && currentIndex >= 0) {
                setData()
            } else {
                editEntryRectangle.resetContent()
            }
        }

        delegate: Rectangle {
            id: entryRectangle

            property int entryIndex: index
            property int entryId: id
            property string entryName: name
            property string entryCategory: category
            property string entryUserName: userName
            property string entryPassword: password
            property string entryNotes: notes

            color: secondaryBackgroundColor
            height: entryDelegate.height
            width: parent.width

            CommonEntryDelegate {
                id: entryDelegate
            }
        }

        highlightFollowsCurrentItem: true
        highlightMoveDuration: 100
        highlight: Rectangle {
            anchors.fill: entryListView.delegate
//            height: entryListView.delegate.height
//            width: entryListView.width * 0.98
//            anchors.horizontalCenter: parent.horizontalCenter
//            radius: primaryBorderSize / 2
//            border.width: primaryBorderSize / 10
//            border.color: "red"
//            color: "transparent"
            smooth: true
            color: "gray"
            opacity: 0.5
        }

        section {
            property: "category"
            criteria: ViewSection.FullString
            delegate: Item {
                width: parent.width
                height: sectionText.height * 1.25

                Text {
                    id: sectionText
                    anchors.right: parent.right
                    anchors.rightMargin: primaryBorderSize / 2
                    anchors.bottom: underLine.top
                    font.pointSize: primaryFontSize
//                    font.bold: true
                    text: section
                    color: secondaryFontColor
                }

                Rectangle {
                    id: underLine
                    height: primaryBorderSize / 10
                    color: secondaryFontColor
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                }
            }
        }
    }

    FastScroll {
        id: sectionScroller
        listView: entryListView
    }

    Keys.onUpPressed: listView.currentIndex--
    Keys.onDownPressed: listView.currentIndex++
    Keys.onRightPressed: editEntryRectangle.show()
    Keys.onLeftPressed: {
        if (editEntryRectangle.isShown) {
            editEntryRectangle.hide()
        } else {
            loggedIn = false
        }
    }
    Keys.onPressed: {
        switch (event.key) {
        case Qt.Key_D:
            if (!editEntryRectangle.isShown) {
                deleteEntry()
            }
            break
        case Qt.Key_A:
        case Qt.Key_E:
        case Qt.Key_I:
            if (editEntryRectangle.isShown) {
                editEntryRectangle.toggleEdit()
            } else {
                addEntry()
            }
            break
        default:
            break
        }
    }
}
