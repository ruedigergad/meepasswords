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

Page{
//    id: entryInputPage

//    property bool edit: false
//    property int index: -1

//    property alias text: entryLabel.text
//    property alias name: nameInput.text
//    property alias category: categoryInput.text
//    property alias userName: userNameInput.text
//    property alias password: passwordInput.text
//    property alias notes: notesInput.text
//    property alias okEnabled: okButton.enabled

//    Label {id: entryLabel; text: "Entry"; font.pixelSize: 30; font.capitalization: Font.SmallCaps; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top}
//    Grid{
//        id: grid

//        anchors.top: entryLabel.bottom
//        anchors.topMargin: 10
//        anchors.horizontalCenter: parent.horizontalCenter

//        width: parent.width
//        columns: 2

//        Label {text: "Name"}
//        Label {text: "Category"}
//        TextField{id: nameInput; width: 0.5 * parent.width; onTextChanged: okButton.enabled = true}
//        TextField{id: categoryInput; width: 0.5 * parent.width}
//        Label {text: "User Name"}
//        Label {text: "Password"}
//        TextField{id: userNameInput; width: 0.5 * parent.width}
//        TextField{id: passwordInput; width: 0.5 * parent.width}
//    }

//    Label {id: notesLabel; text: "Notes"; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: grid.bottom}
//    TextArea{id: notesInput; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: notesLabel.bottom; width: parent.width}

//    Button{id: cancelButton; text: "Cancel"; anchors.top: notesInput.bottom; anchors.topMargin: 10; anchors.left: parent.left; anchors.right: okButton.left; width: 0.5 * parent.width; onClicked: pageStack.pop()}
//    Button{id: okButton; text: "Ok"; anchors.top: notesInput.bottom; anchors.topMargin: 10; anchors.right: parent.right; width: 0.5 * parent.width; enabled: false;
//        onClicked: {
//            if(edit){
//                entryStorage.getModel().updateEntryAt(index, nameInput.text, categoryInput.text, userNameInput.text, passwordInput.text, notesInput.text);
//            }else{
//                entryStorage.getModel().addEntry(nameInput.text, categoryInput.text, userNameInput.text, passwordInput.text, notesInput.text);
//            }
//            pageStack.pop()
//        }
//    }
}
