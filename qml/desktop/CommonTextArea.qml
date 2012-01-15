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
    id: textArea

    height: textEdit.height + textEdit.font.pointSize

    border.width: 3
    border.color: "lightgrey"
    radius: textEdit.font.pointSize
    smooth: true

    property alias text: textEdit.text
    property int textFormat: TextEdit.PlainText

    signal textChanged(string text)


    TextEdit {
        id: textEdit

        anchors.centerIn: parent
        width: parent.width - (2 * font.pointSize)

        font.pointSize: 17
        color: "black"
        textFormat: textArea.textFormat

        onTextChanged: textArea.textChanged(text)

        onFocusChanged: {
            if(focus){
                textArea.border.color = "#569ffd";
            }else{
                textArea.border.color = "lightgray";
            }
        }
    }

}
