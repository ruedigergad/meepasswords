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
import SyncToImap 1.0

Rectangle {
    id: main

    width: 400
    height: 500
    color: "lightgray"

    property int primaryFontSize: 16
    property int primaryBorderSize: primaryFontSize

    onRotationChanged: {
        console.log("Rotation changed...");
    }

    Component.onCompleted: {
        cleanOldFiles()
    }

    function cleanOldFiles() {
        console.log("Cleaning left overs from last run.")
        mainFlickable.fileHelper.rmAll(mainFlickable.entryStorage.getStorageDirPath(), ".encrypted.");
    }

    Item {
        anchors.fill: parent

        Rectangle {
            id: header
            height: primaryFontSize * 2
            color: "#0c61a8"
            anchors{left: parent.left; right: parent.right; top: parent.top}

            Text {
                text: "MeePasswords"
                color: "white"
                font.pointSize: primaryFontSize * 0.75
                anchors.left: parent.left
                anchors.leftMargin: primaryFontSize * 0.6
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MainFlickable {
            id: mainFlickable

            anchors{top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom}
        }
    }

    Menu {
        id: mainMenu

        parent: main
        anchors.bottomMargin: mainFlickable.toolBar.height
        onClosed: mainFlickable.meePasswordsToolBar.enabled = true
        onOpened: mainFlickable.meePasswordsToolBar.enabled = false

        CommonButton{
            id: changePassword
            anchors.bottom: syncToImap.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Change Password"
            onClicked: {
                mainFlickable.passwordChangeDialog.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: syncToImap
            anchors.bottom: syncDeleteMessage.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Sync"
            onClicked: {
                mainFlickable.confirmSyncToImapDialog.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: syncDeleteMessage
            anchors.bottom: syncAccountSettings.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Clear Sync Data"
            onClicked: {
                mainFlickable.confirmDeleteSyncMessage.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: syncAccountSettings
            anchors.bottom: exportKeePassXml.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Sync Account Settings"
            onClicked: {
                mainFlickable.imapAccountSettings.open()
                mainMenu.close()
            }
        }

        CommonButton{
            id: exportKeePassXml
            anchors.bottom: importKeePassXml.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Export"
            onClicked: {
                mainFlickable.entryStorage.exportKeePassXml()
                mainMenu.close()
            }
        }

        CommonButton{
            id: importKeePassXml
            anchors.bottom: about.top
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "Import"
            onClicked: {
                mainFlickable.entryStorage.importKeePassXml()
                mainMenu.close()
            }
        }

        CommonButton{
            id: about
            anchors.bottom: parent.bottom
            anchors.bottomMargin: primaryFontSize / 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - primaryFontSize
            text: "About"
            onClicked: {
                mainFlickable.aboutDialog.open()
                mainMenu.close()
            }
        }
    }
}
