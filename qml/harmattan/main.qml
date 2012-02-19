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
import QtMobility.connectivity 1.2
import QtMobility.systeminfo 1.2
import com.nokia.meego 1.0
import meepasswords 1.0
import "../common"

PageStackWindow {
    id: appWindow
    initialPage: passwordInputPage

    Component.onCompleted: {
        console.debug("Opening storage...")
        entryStorage.openStorage();
    }

    Component.onDestruction: {
        console.debug("Shutting down...");
    }

    ErrorDialog{
        id: errorDialog
    }

    PasswordInputPage{
        id: passwordInputPage

        states: [
            State {
                name: "NewPassword"
                PropertyChanges {
                    target: passwordInputPage
                    text: qsTr("Please enter a new password. "
                               + "Please keep the password at a safe place. "
                               + "There is no way to recover a lost password.")
                    onClicked: {
                        entryStorage.setPassword(passwordInputPage.password)
                        entryStorage.showEntries()
                    }
                }
            },
            State {
                name: "EnterPassword"
                PropertyChanges {
                    target: passwordInputPage
                    text: qsTr("Enter Password:")
                    onClicked: entryStorage.loadAndDecryptDataUsingPassword(passwordInputPage.password)
                }
            },
            State {
                name: "WrongPassword"
                PropertyChanges {
                    target: passwordInputPage
                    text: qsTr("You entered a wrong password. Please reenter Password:")
                    onClicked: entryStorage.loadAndDecryptDataUsingPassword(passwordInputPage.password)
                }
            }
        ]
    }

    MainPage{id: mainPage}

    EntryStorage {
        id: entryStorage

        property bool isOpen: false

        onStorageOpenSuccess: passwordInputPage.state = "EnterPassword"
        onStorageOpenSuccessNewPassword: passwordInputPage.state = "NewPassword"

        onDecryptionFailed: passwordInputPage.state = "WrongPassword"
        onDecryptionSuccess: showEntries()
        onNewFileOpened: showEntries()

        onOperationFailed: {
            errorDialog.message = message;
            errorDialog.open();
        }

        function showEntries() {
            pageStack.push(mainPage)
            passwordInputPage.password = ""
            isOpen = true
            console.log("showEntries()")
        }

        function logout(){
            if(isOpen){
                entryStorage.getModel().clear();
                entryStorage.setPassword("");
                passwordInputPage.state = "EnterPassword"
                pageStack.pop(null, false)
                isOpen = false
            }
        }
    }

    QClipboard{
        id: clipboard
    }

    PasswordChangeDialog{
        id: passwordChangeDialog
    }

    DeviceInfo {
        id: deviceInfo

        monitorLockStatusChanges: true
        onLockStatusChanged: {
            if(lockStatus !== 0){
                entryStorage.logout()
            }
        }
    }

    NearField{
        filter: [NdefFilter { type: "urn:nfc:wkt:T"; minimum: 1 }]
        orderMatch: false

        onMessageRecordsChanged: {
            console.log("Got NFC data.")

            if(!entryStorage.isOpen){
                console.log("Trying to authenticate via NFC.")

                for(var i = 0; i < messageRecords.length; i++){
                    console.log("Found text record.")
                    var text = messageRecords[i].text

                    if(text.match(/^meepasswords:random_key/)){
                        console.log("Found MeePasswords random key.")

                        var randomKey = text.split(":")[2]
                        if(entryStorage.canDecrypt(randomKey)){
                            entryStorage.loadAndDecryptDataUsingPassword(randomKey)
                            return
                        }else{
                            passwordInputPage.password = randomKey

                        }
                    }else if(text.match(/^meepasswords/)){
                        console.log("Found MeePasswords password hash.")
                        entryStorage.loadAndDecryptDataUsingHash(text.split(":")[1])
                        return
                    }
                }
            }else if (passwordChangeDialog.status === DialogStatus.Open){
                console.log("Trying to set old password in password change dialog from NFC tag.")

                for(var i = 0; i < messageRecords.length; i++){
                    console.log("Found text record.")
                    var text = messageRecords[i].text

                    if(text.match(/^meepasswords:random_key/)){
                        console.log("Found MeePasswords random key.")
                        passwordChangeDialog.oldPassword = text.split(":")[2]
                        return
                    }else if(text.match(/^meepasswords/)){
                        console.log("Found MeePasswords password hash.")
                        passwordChangeDialog.oldPassword = text.split(":")[1]
                        return
                    }
                }
            }else{
                console.log("Storage already opened. Doing nothing.")
            }
        }
    }
}
