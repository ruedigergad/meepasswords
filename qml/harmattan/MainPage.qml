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
import com.nokia.meego 1.0
import meepasswords 1.0
import "../common"

Page {
    id: mainPage
    tools: commonTools

    orientationLock: PageOrientation.LockPortrait

    Item {
        anchors.fill: parent

        Rectangle {
            id: header
            height: 72
            color: "#0c61a8"
            anchors{left: parent.left; right: parent.right; top: parent.top}

            Text {
                text: "My Accounts"
                color: "white"
                font.family: "Nokia Pure Text Light"
                font.pixelSize: 32
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Label {
            id: noContentLabel
            visible: entryListView.count === 0
            text: "No Entries"
            font.pixelSize: 80; anchors.bottom: explanationLabel.top; anchors.bottomMargin: 50; anchors.horizontalCenter: parent.horizontalCenter; color: "lightgray"
        }

        Label {
            id: explanationLabel
            visible: entryListView.count === 0
            text: "Use + to add entries."
            font.pixelSize: 40;  color: "lightgray"; anchors.centerIn: parent
        }

        TextField {
            id: search
            platformStyle: TextFieldStyle {
                backgroundSelected: "image://theme/meegotouch-textedit-background-selected"
            }
            placeholderText: "Search"
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhPreferLowercase | Qt.ImhNoAutoUppercase

            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16 // TODO: Use platform margins

            // TODO: We need a QFilterProxyList in C++
            onTextChanged: entryStorage.getModel().setFilterFixedString(text)

            Image {
                anchors { top: parent.top; right: parent.right; margins: 5 }
                smooth: true
                fillMode: Image.PreserveAspectFit
                source: search.text ? "image://theme/icon-m-input-clear" : "image://theme/icon-m-common-search"
                height: parent.height - platformStyle.paddingMedium * 2
                width: parent.height - platformStyle.paddingMedium * 2

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -10 // Make area bigger than image
                    enabled: search.text
                    onClicked: search.text = ""
                }
            }
        }

        EntryListView {
            id: entryListView
            delegate: EntryDelegate {
                onPressAndHold: {
                    deleteConfirmationDialog.entryId = model.id
                    deleteConfirmationDialog.entryName = model.name
                    contextMenu.open()
                }
            }
            anchors.top: search.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            onCountChanged: {
                /*
                 * Needed to make SectionScroller happy.
                 * First we set the list property of the SectionScroller.
                 * This is done here for the sake of completeness.
                 */
                sectionScroller.listView = entryListView
                /*
                 * Second and more important, we force a re-initialization
                 * of the SectionScroller. Note: the requirement to do this
                 * may be due to the way the model is set for the list here.
                 */
                sectionScroller.listViewChanged()
            }
        }

        FastScroll {
            id: sectionScroller
            listView: entryListView
        }
    }

    ContextMenu {
        id: contextMenu
        MenuLayout {
            MenuItem {
                text: "Delete entry"
                onClicked: deleteConfirmationDialog.open()
            }
        }
    }

    AboutDialog {
        id: aboutDialog
    }

    QueryDialog {
        id: logoutConfirmationDialog
        titleText: "Logout?"
        message: "Logout from MeePasswords?"
        acceptButtonText: "OK"
        rejectButtonText: "Cancel"
        onAccepted: entryStorage.logout()
    }

    QueryDialog {
        id: deleteConfirmationDialog
        property int entryId: -1
        property string entryName
        titleText: "Really delete '" + entryName + "'?"
        acceptButtonText: "OK"
        rejectButtonText: "Cancel"
        onAccepted: {
            entryStorage.getModel().removeById(entryId)
        }
    }

    NfcWriteDialog {
        id: nfcWriteDialog
    }

    ToolBarLayout {
        id: commonTools

        ToolIcon {
            id: iconLogout; platformIconId: "toolbar-back"; 
//            onClicked: logoutConfirmationDialog.open()
            onClicked: entryStorage.logout()
        }

        ToolIcon {
            id: iconAdd
            platformIconId: "toolbar-add"
            onClicked: {
                var component = Qt.createComponent("EditEntrySheet.qml");
                var sheet = component.createObject(mainPage);
                sheet.open()
            }
        }

        ToolIcon {
            id: iconMenu
            platformIconId: "toolbar-view-menu"
            anchors.right: parent === undefined ? undefined : parent.right
            onClicked: myMenu.status === DialogStatus.Closed ? myMenu.open() : myMenu.close()
        }
    }

    Menu {
        id: myMenu

        MenuLayout {
            MenuItem { text: "Write NFC Tag"; onClicked: {
                    nfcWriteDialog.open()
                }
            }
            MenuItem { text: "Change Password"; onClicked: {
                    passwordChangeDialog.open()
                }
            }
            MenuItem { text: "Export"; onClicked: {
                    entryStorage.exportKeePassXml()
                }
            }
            MenuItem { text: "Import"; onClicked: {
                    entryStorage.importKeePassXml()
                }
            }
            // TODO: Implement multiple-delete
//            MenuItem {id: menuDelete; text: "Delete Entries";  onClicked: {
//                }
//            }
            MenuItem { text: "About"; onClicked: aboutDialog.open() }
        }
    }
}
