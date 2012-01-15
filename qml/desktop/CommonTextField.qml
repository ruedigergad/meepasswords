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

import Qt 4.7

Rectangle {
    id: textField

    width: parent.width
    height: textInput.height * 1.8

    border.width: 3
    border.color: "lightgrey"
    radius: height/4
    smooth: true

    property alias text: textInput.text
    property int echoMode: TextInput.Normal

    signal textChanged(string text)


    TextInput {
        id: textInput

        width: parent.width - (2 * font.pointSize)
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        font.pointSize: 17

        color: "black"
        echoMode: textField.echoMode

        onTextChanged: textField.textChanged(text)

        onFocusChanged: {
            if(focus){
                textField.border.color = "#569ffd";
            }else{
                textField.border.color = "lightgray";
            }
        }
    }

}
