/*
 *  Copyright 2012, 2013 Ruediger Gad
 *
 *  This file is part of Q To-Do.
 *
 *  Q To-Do is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Q To-Do is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Q To-Do.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

SilicaListView {

    property Item contextMenu
    property alias contextMenuComponent: contextMenuComponent

    Component {
        id: contextMenuComponent

        ContextMenu {
            MenuItem {
                text: "Delete Entry"
                onClicked: deleteEntry()
            }
        }
    }

    PullDownMenu {
//        MenuItem{
//            text: "Export"
//            onClicked: {
//                mainFlickable.entryStorage.exportKeePassXml()
//                mainMenu.close()
//            }
//        }
//        MenuItem {
//            text: "Import"
//            onClicked: {
//                mainFlickable.entryStorage.importKeePassXml()
//                mainMenu.close()
//            }
//        }
        MenuItem {
            text: "Clear Sync Data"
            onClicked: {
                mainFlickable.confirmDeleteSyncMessage.open()
                mainMenu.close()
            }
        }
        MenuItem{
            text: "Sync Account Settings"
            onClicked: {
                mainFlickable.imapAccountSettings.open()
                mainMenu.close()
            }
        }
        MenuItem {
            text: "Change Password"
            onClicked: {
                mainFlickable.passwordChangeDialog.open()
                mainMenu.close()
            }
        }
        MenuItem {
            text: "About"
            onClicked: {
                mainFlickable.aboutDialog.open()
                mainMenu.close()
            }
        }
        MenuItem {
            text: "Sync"
            onClicked: {
                mainFlickable.confirmSyncToImapDialog.open()
                mainMenu.close()
            }
        }
        MenuItem {
            text: mainFlickable.settingsAdapter.fastScrollAnchor === "left" ? "Scroll Bar: Left" : "Scroll Bar: Right"
            onClicked: {
                if (mainFlickable.settingsAdapter.fastScrollAnchor === "left") {
                    mainFlickable.settingsAdapter.fastScrollAnchor = "right"
                } else {
                    mainFlickable.settingsAdapter.fastScrollAnchor = "left"
                }
            }
        }
        MenuItem {
            text: "Add Entry"
            onClicked: {
                mainFlickable.addEntry()
            }
        }
    }

    PushUpMenu {
        MenuItem {
            text: "Add Entry"
            onClicked: {
                mainFlickable.addEntry()
            }
        }
        MenuItem {
            text: mainFlickable.settingsAdapter.fastScrollAnchor === "left" ? "Scroll Bar: Left" : "Scroll Bar: Right"
            onClicked: {
                if (mainFlickable.settingsAdapter.fastScrollAnchor === "left") {
                    mainFlickable.settingsAdapter.fastScrollAnchor = "right"
                } else {
                    mainFlickable.settingsAdapter.fastScrollAnchor = "left"
                }
            }
        }
        MenuItem {
            text: "Sync"
            onClicked: {
                mainFlickable.confirmSyncToImapDialog.open()
                mainMenu.close()
            }
        }
        MenuItem {
            text: "About"
            onClicked: {
                mainFlickable.aboutDialog.open()
                mainMenu.close()
            }
        }
        MenuItem {
            text: "Change Password"
            onClicked: {
                mainFlickable.passwordChangeDialog.open()
                mainMenu.close()
            }
        }
        MenuItem{
            text: "Sync Account Settings"
            onClicked: {
                mainFlickable.imapAccountSettings.open()
                mainMenu.close()
            }
        }
        MenuItem {
            text: "Clear Sync Data"
            onClicked: {
                mainFlickable.confirmDeleteSyncMessage.open()
                mainMenu.close()
            }
        }
//        MenuItem {
//            text: "Import"
//            onClicked: {
//                mainFlickable.entryStorage.importKeePassXml()
//                mainMenu.close()
//            }
//        }
//        MenuItem{
//            text: "Export"
//            onClicked: {
//                mainFlickable.entryStorage.exportKeePassXml()
//                mainMenu.close()
//            }
//        }
    }
}
