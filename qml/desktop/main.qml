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
import meepasswords 1.0
import "../common"

Rectangle {
    id: main

    property int primaryFontSize: 20

    onRotationChanged: {
        console.log("Rotation changed...");
    }

    anchors.fill: parent

    color: "lightgray"

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
                font.family: "Nokia Pure Text Light"
                font.pointSize: primaryFontSize * 1.1
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

//    Component.onCompleted: {
//        console.debug("Opening storage...")
//        entryStorage.openStorage();
//    }

//    Component.onDestruction: {
//        console.debug("Shutting down...");
//    }

//    onStateChanged: {
//        console.log("State changed: " + state);
//    }

//    states: [
//        State {
//            name: "NewPassword"
//            PropertyChanges {target: passwordInputPage;
//                visible: true;
//                text: qsTr("Please enter a new password. "
//                           + "Please keep the password at a safe place. "
//                           + "There is no way to recover a lost password.");
//                password: "";
//                onClicked: {
//                    entryStorage.setPassword(passwordInputPage.password);
//                    main.state = "LoginSuccess";
//                }
//            }
//            PropertyChanges {
//                target: mainPage;
//                visible: false;
//            }
//        },
//        State {
//            name: "EnterPassword"
//            PropertyChanges {target: passwordInputPage;
//                visible: true;
//                text: qsTr("Enter Password:");
//                password: "";
//                onClicked: {
//                    entryStorage.loadAndDecryptDataUsingPassword(passwordInputPage.password);
//                }
//            }
//            PropertyChanges {
//                target: mainPage;
//                visible: false;
//            }
//        },
//        State {
//            name: "WrongPassword"
//            PropertyChanges {target: passwordInputPage;
//                visible: true;
//                text: qsTr("You entered a wrong password. Please reenter Password:");
//                password: "";
//                onClicked: {
//                    entryStorage.loadAndDecryptDataUsingPassword(passwordInputPage.password);
//                }
//            }
//            PropertyChanges {
//                target: mainPage;
//                visible: false;
//            }
//        },
//        State {
//            name: "LoginSuccess"
//            PropertyChanges {
//                target: passwordInputPage;
//                visible: false;
//            }
//            PropertyChanges {
//                target: mainPage;
//                visible: true;
//            }
//        }

//    ]

//    PasswordInputPage{
//        id: passwordInputPage
//    }



//    EntryStorage {
//        id: entryStorage

//        onStorageOpenSuccess: state = "EnterPassword"
//        onStorageOpenSuccessNewPassword: state = "NewPassword"

//        onDecryptionFailed: state = "WrongPassword"
//        onDecryptionSuccess: state = "LoginSuccess"
//        onNewFileOpened: state = "LoginSuccess"

//        onOperationFailed: {
//            errorDialog.message = message;
//            errorDialog.open();
//        }
//    }

}


