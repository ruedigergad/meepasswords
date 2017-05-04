/*
 *  Copyright 2012, 2013 Ruediger Gad
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

Item {
    id: menu

    property int menuBottomOffset: menu.height
    /*
     * The following is a quite ugly hack to animate the menu.
     * This should be done via States rather than this hack.
     * Though, due to the limited time, for now this hack is used.
     */
    property bool isOpen: false
    property bool isOpening: false

    signal closed
    signal closing
    signal opened
    signal opening

    function close() {
        closing()
        isOpening = false
        menuBorder.height = 0
    }

    function open() {
        opening()
        isOpening = true
        enabled = true
        menuBorder.height = menuArea.height
    }

    anchors.fill: parent
    enabled: false
    visible: enabled
    z: 16

    Rectangle {
        id: background

        anchors.fill: parent
        color: "black"
        opacity: menu.enabled ? 0.75 : 0
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            close();
        }
    }

    Flickable {
        id: menuBorder

        anchors.bottom: parent.bottom
        anchors.bottomMargin: menu.menuBottomOffset

        clip: true
        contentHeight: menuArea.height
        opacity: secondaryBackgroundOpacity

        height: 0
        width: parent.width
        z: parent.z + 1

        Behavior on height {
            SequentialAnimation {
                PropertyAnimation { duration: 120 }
                ScriptAction {
                    script: {
                        if (menu.isOpening) {
                            menu.isOpen = true
                            menu.opened()
                        } else {
                            menu.isOpen = false
                            menu.enabled = false
                            menu.closed()
                        }
                    }
                }
            }
        }

        Item {
            id: menuArea

            anchors.centerIn: parent
            height: about.height * 7 + primaryFontSize / 3 * 8
            width: parent.width
            y: parent.y

            Rectangle {
                id: fontSizeRectangle

                anchors.bottom: toggleFastScrollAnchorPosition.top
                anchors.bottomMargin: primaryFontSize / 3
                anchors.horizontalCenter: parent.horizontalCenter

                color: "#0a3588"

                height: fontSizeRectangleText.height * 2 + (primaryFontSize / 2)

                width: parent.width - primaryFontSize

                Item {
                    anchors.fill: parent

                    Text {
                        id: fontSizeRectangleText
                        anchors.horizontalCenter: parent.horizontalCenter

                        font.pointSize: primaryFontSize * 0.75

                        text: qsTr("Font Size")
                    }

                    Item {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: primaryFontSize / 3

                        height: fontSizeMinusButton.height
                        width: parent.width - primaryFontSize * 2

                        CommonButton {
                            id: fontSizeMinusButton
                            anchors.left: parent.left
                            anchors.leftMargin:  primaryFontSize / 2
                            text: "-"
                            width: parent.width / 4

                            onClicked: primaryFontSize--
                        }

                        Text {
                            anchors.left: fontSizeMinusButton.right
                            anchors.right: fontSizePlusButton.left
                            anchors.bottom: parent.bottom

                            horizontalAlignment: Text.AlignHCenter

                            font.pointSize: primaryFontSize * 0.75
                            text: primaryFontSize
                        }

                        CommonButton {
                            id: fontSizePlusButton
                            anchors.right: parent.right
                            anchors.rightMargin:  primaryFontSize / 2
                            text: "+"
                            width: parent.width / 4

                            onClicked: primaryFontSize++
                        }
                    }
                }
            }

            CommonButton {
                id: toggleFastScrollAnchorPosition

                anchors.bottom: changePassword.top
                anchors.bottomMargin: primaryFontSize / 3
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Fast Scroll: " + (settingsAdapter.fastScrollAnchor === "right" ? "Right" : "Left")
                width: parent.width - primaryFontSize

                onClicked: {
                    settingsAdapter.fastScrollAnchor = settingsAdapter.fastScrollAnchor === "right" ? "left" : "right"
                }
            }

            CommonButton {
                id: changePassword

                anchors.bottom: exportKeePassXml.top
                anchors.bottomMargin: primaryFontSize / 3
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Change Password"
                width: parent.width - primaryFontSize

                onClicked: {
                    mainFlickable.passwordChangeDialog.open()
                    menu.close()
                }
            }

//            CommonButton {
//                id: syncToImap

//                anchors.bottom: syncDeleteMessage.top
//                anchors.bottomMargin: primaryFontSize / 3
//                anchors.horizontalCenter: parent.horizontalCenter
//                text: "Sync"
//                width: parent.width - primaryFontSize

//                onClicked: {
//                    mainFlickable.confirmSyncToImapDialog.open()
//                    menu.close()
//                }
//            }

//            CommonButton {
//                id: syncDeleteMessage

//                anchors.bottom: syncAccountSettings.top
//                anchors.bottomMargin: primaryFontSize / 3
//                anchors.horizontalCenter: parent.horizontalCenter
//                text: "Clear Sync Data"
//                width: parent.width - primaryFontSize

//                onClicked: {
//                    mainFlickable.confirmDeleteSyncMessage.open()
//                    menu.close()
//                }
//            }

//            CommonButton {
//                id: syncAccountSettings

//                anchors.bottom: exportKeePassXml.top
//                anchors.bottomMargin: primaryFontSize / 3
//                anchors.horizontalCenter: parent.horizontalCenter
//                text: "Sync Account Settings"
//                width: parent.width - primaryFontSize

//                onClicked: {
//                    mainFlickable.imapAccountSettings.open()
//                    menu.close()
//                }
//            }

            CommonButton {
                id: exportKeePassXml

                anchors.bottom: importKeePassXml.top
                anchors.bottomMargin: primaryFontSize / 3
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Export"
                width: parent.width - primaryFontSize

                onClicked: {
                    mainFlickable.entryStorage.exportKeePassXml()
                    menu.close()
                }
            }

            CommonButton {
                id: importKeePassXml

                anchors.bottom: about.top
                anchors.bottomMargin: primaryFontSize / 3
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Import"
                width: parent.width - primaryFontSize

                onClicked: {
                    mainFlickable.entryStorage.importKeePassXml()
                    menu.close()
                }
            }

            CommonButton {
                id: about

                anchors.bottom: parent.bottom
                anchors.bottomMargin: primaryFontSize / 3
                anchors.horizontalCenter: parent.horizontalCenter
                text: "About"
                width: parent.width - primaryFontSize

                onClicked: {
                    mainFlickable.aboutDialog.open()
                    menu.close()
                }
            }
        }
    }
}
