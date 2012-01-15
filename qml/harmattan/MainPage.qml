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
import "../common"

Page {
    id: mainPage
    tools: commonTools

    orientationLock: PageOrientation.LockPortrait

    onVisibleChanged: {
        if(visible)   {
            updateLabels();
        }
    }

    function updateLabels() {
        var listEmpty = (entryStorage.getModel().rowCount() === 0)
        noContentLabel.visible = listEmpty
        explanationLabel.visible = listEmpty

        var itemSelected = !listEmpty && entryListView.currentIndex >= 0 && entryStorage.getModel().rowCount()
        iconEdit.enabled = itemSelected
        menuDelete.enabled = itemSelected
    }

    Rectangle{
        anchors.fill: parent
        color: "white"

        Label {
            id: noContentLabel
            text: "No Entries"
            font.pixelSize: 80; anchors.bottom: explanationLabel.top; anchors.bottomMargin: 50; anchors.horizontalCenter: parent.horizontalCenter; color: "lightgray"
        }
        Label {
            id: explanationLabel
            text: "Use + to add entries."
            font.pixelSize: 40;  color: "lightgray"; anchors.centerIn: parent
        }

        EntryListView{
            id: entryListView
            anchors.fill: parent

            onCountChanged: {
                updateLabels()
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
            onCurrentIndexChanged: updateLabels()
        }

        SectionScroller{
            id: sectionScroller
            listView: entryListView
        }
    }

    AboutDialog{
        id: aboutDialog
    }

    EntryShowDialog{
        id: entryShowDialog
    }

    EditEntrySheet{
        id: editEntrySheet

        onStatusChanged: {
            if(status === DialogStatus.Open){
                /*
                 * Quite a hack to avoid the MouseArea of the EntryListView to "shine through".
                 * Without this hack double clicking an are of the sheet where (below) an item
                 * of the list is shown, the dialog showing the item info will pop up.
                 */
                entryListView.visible = false
            }else if (status === DialogStatus.Closing){
                entryListView.visible = true
            }else if (status === DialogStatus.Opening){
                iconLogout.enabled = false
                iconAdd.enabled = false
                iconEdit.enabled = false
                iconMenu.enabled = false
            }else if (status === DialogStatus.Closed){
                iconLogout.enabled = true
                iconAdd.enabled = true
                iconMenu.enabled = true
                updateLabels()
            }
        }
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

        property int index: -1

        titleText: "Delete?"
        acceptButtonText: "OK"
        rejectButtonText: "Cancel"
        onAccepted: {
            entryStorage.getModel().removeAt(index)
        }
    }

    NfcWriteDialog {
        id: nfcWriteDialog
    }

    ToolBarLayout {
        id: commonTools

        ToolIcon { id: iconLogout; platformIconId: "toolbar-previous"; onClicked: logoutConfirmationDialog.open();
            onEnabledChanged: {
                if(enabled){
                    platformIconId = "toolbar-previous"
                }else{
                    platformIconId = "toolbar-previous-dimmed"
                }
            }
        }
        ToolIcon { id: iconAdd; platformIconId: "toolbar-add";
            onClicked: {
                editEntrySheet.text = "New Entry"
                editEntrySheet.name = ""
                editEntrySheet.category = ""
                editEntrySheet.userName = ""
                editEntrySheet.password = ""
                editEntrySheet.notes = ""
                editEntrySheet.edit = false

                editEntrySheet.open()
            }
            onEnabledChanged: {
                if(enabled){
                    platformIconId = "toolbar-add"
                }else{
                    platformIconId = "toolbar-add-dimmed"
                }
            }
        }
        ToolIcon { id: iconEdit; platformIconId: "toolbar-edit"
            onClicked: {
                var index = entryListView.currentIndex
                var entry = entryStorage.getModel().at(index)

                editEntrySheet.text = "Edit Entry"
                editEntrySheet.name = entry.name
                editEntrySheet.category = entry.category
                editEntrySheet.userName = entry.userName
                editEntrySheet.password = entry.password
                editEntrySheet.notes = entry.notes
                editEntrySheet.edit = true
                editEntrySheet.index = index

                editEntrySheet.open()
            }
            onEnabledChanged: {
                if(enabled){
                    platformIconId = "toolbar-edit"
                }else{
                    platformIconId = "toolbar-edit-dimmed"
                }
            }
        }
//        ToolIcon { id: iconSearch; platformIconId: "toolbar-search"}
        ToolIcon { id: iconMenu; platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
             onEnabledChanged: {
                 if(enabled){
                     platformIconId = "toolbar-view-menu"
                 }else{
                     platformIconId = "toolbar-view-menu-dimmed"
                 }
             }
        }
    }

    Menu {
        id: myMenu
        visualParent: pageStack
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
            MenuItem {id: menuDelete; text: "Delete Entry";  onClicked: {
                    var index = entryListView.currentIndex
                    deleteConfirmationDialog.index = index
                    deleteConfirmationDialog.message = "Delete entry \"" + entryStorage.getModel().at(index).name +"\"?"
                    deleteConfirmationDialog.open()
                }
                onEnabledChanged: {
                    opacity = enabled ? 1.0 : 0.5
                }
            }
            MenuItem { text: "About"; onClicked: aboutDialog.open() }
        }

        onStatusChanged: {
            if(status === DialogStatus.Opening){
                iconLogout.enabled = false
                iconAdd.enabled = false
                iconEdit.enabled = false
            }else if(status === DialogStatus.Closed){
                iconLogout.enabled = true
                iconAdd.enabled = true
                updateLabels()
            }
        }
    }
}
