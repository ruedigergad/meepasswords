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
import "../common"

Item {
    id: menu

    anchors.fill: parent

    visible: false

    z: 16

    /*
     * The following is a quite ugly hack to animate the menu.
     * This should be done via States rather than this hack.
     * Though, due to the limited time, for now this hack is used.
     */
    property bool isOpen: true
    onHeightChanged: {
        menuBorder.y = height
        isOpen = true
    }

    Rectangle{
        id: background
        anchors.fill: parent
        color: "black"
        opacity: 0.6
    }

    MouseArea{
        anchors.fill: parent
        onClicked: {
            close();
        }
    }

    Rectangle{
        id: menuBorder
        y: parent.height
        width: parent.width
        height: menuArea.height + 40

        color: "lightgray"
        opacity: 1

        Behavior on y {
            SequentialAnimation {
                PropertyAnimation { duration: 120 }
                ScriptAction {
                    script: {
                        if(menu.isOpen){
                            menu.visible = false
                        }
                        menu.isOpen = ! menu.isOpen
                    }
                }
            }
        }

        Rectangle{
            id: menuArea
            anchors.centerIn: parent
            width: parent.width - 20
            height: 5 * changePassword.height + 40

            color:"white"
            radius: 20

            CommonButton{
                id: changePassword
                anchors.bottom: exportButton.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 40
                text: "Change Password"
                onClicked: {
                    menu.close()
                    passwordChangeDialog.open()
                }
            }
            CommonButton{
                id: exportButton
                anchors.bottom: importButton.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 40
                text: "Export"
                onClicked: {
                    menu.close();
                    entryStorage.exportKeePassXml()
                }
            }
            CommonButton{
                id: importButton
                anchors.bottom: deleteEntry.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 40
                text: "Import"
                onClicked: {
                    menu.close();
                    entryStorage.importKeePassXml()
                }
            }
            CommonButton{
                id: deleteEntry
                anchors.bottom: about.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 40
                text: "Delete Entry"

                onClicked: {
                    var index = entryListView.currentIndex
                    deleteConfirmationDialog.index = index
                    deleteConfirmationDialog.entryName = entryStorage.getModel().at(index).name
                    deleteConfirmationDialog.open()
                    menu.close()
                }
            }
            CommonButton{
                id: about
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 40
                text: "About"
                onClicked: {
                    aboutDialog.open()
                    menu.close()
                }
            }
        }
    }

    function close(){
        menuBorder.y = height
    }

    function open(){
        deleteEntry.enabled = entryListView.currentIndex >= 0 && entryListView.currentIndex < entryStorage.getModel().rowCount()
        menu.visible = true
        menuBorder.y = height - menuBorder.height
    }
}
