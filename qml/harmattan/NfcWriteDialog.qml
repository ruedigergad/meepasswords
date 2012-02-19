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

import com.nokia.meego 1.0
import QtQuick 1.1
import meepasswords 1.0
import "../common"

QueryDialog {
    id: nfcWriteDialog
    //anchors.fill: parent

    acceptButtonText: "Write"
    rejectButtonText: "Cancel"

    content: Item {
        anchors.fill: parent

        Label {
            id: nfcWriteLabel

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: passwordLabel.top
            anchors.bottomMargin: 40
            width: parent.width

            color: "white"
            font.pixelSize: 30
            font.bold: true
            horizontalAlignment: Text.AlignHCenter

            text: "Write NFC Tag"
        }

        Label {
            id: passwordLabel

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: passwordField.top
            anchors.bottomMargin: 20
            width: parent.width

            color: "white"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap

            text: "Please confirm you password:"
        }

        TextField {
            id: passwordField

            anchors.centerIn: parent

            echoMode: TextInput.Password
        }
    }

    MessageDialog{
        id: informationDialog
        parent: mainPage
    }

    MessageDialog{
        id: writingDialog
        parent: mainPage
        text: "Writing NFC Tag.\n\nPlease hold your NFC card next to your device."
        onRejected: nfcTagWriter.stopWriting()
    }

    NfcTagWriter{
        id: nfcTagWriter

        onWriteSuccess: {
            writingDialog.close();
            informationDialog.text = "Successfully wrote NFC tag."
            informationDialog.open();
        }

        onWriteFailed: {
            writingDialog.close();
            informationDialog.text = "Failed to write NFC tag.\n\nThe error message is:\n" + errorMsg
            informationDialog.open();
        }
    }

    onAccepted: {
        var pass = passwordField.text

        if(entryStorage.equalsStoredPassword(pass)){
            writingDialog.open()
            nfcTagWriter.writeTextTag(entryStorage.getBase64Hash(pass))
        }else if(pass === "random"){
            var randomKey = entryStorage.getRandomKeyAsString()
            writingDialog.open()
            nfcTagWriter.writeTextTag("random_key:" + randomKey)
            clipboard.setText(randomKey)
        }else{
            informationDialog.text = "Ooops, an error occured:\n\nThe password you entered does not match the stored password.\nPlease try again."
            informationDialog.open();
        }
        passwordField.text = ""
    }

    onStatusChanged: {
        if(status === DialogStatus.Open){
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }else if(status === DialogStatus.Closed){
            passwordField.text = ""
        }
    }

}
