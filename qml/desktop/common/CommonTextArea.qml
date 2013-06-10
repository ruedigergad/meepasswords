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

import QtQuick 1.1

Rectangle {
    id: textArea

    height: textEdit.height + textEdit.font.pointSize

    border.width: primaryFontSize / 8
    border.color: "lightgrey"
    radius: textEdit.font.pointSize * 0.75
    smooth: true

    property alias text: textEdit.text
    property int textFormat: TextEdit.PlainText

    signal enter()
    signal keyPressed(variant event)
    signal textChanged(string text)

    function forceActiveFocus() {
        textEdit.forceActiveFocus()
    }

    TextEdit {
        id: textEdit

        anchors.centerIn: parent
        width: parent.width - (2 * font.pointSize)
        focus: parent.focus

        font.pointSize: primaryFontSize * 0.75
        color: "black"
        textFormat: textArea.textFormat
        wrapMode: TextEdit.WordWrap

        onTextChanged: textArea.textChanged(text)

        onFocusChanged: {
            if(focus){
                textArea.border.color = "#569ffd";
                textEdit.cursorPosition = textEdit.text.length
            }else{
                textArea.border.color = "lightgray";
            }
        }
    }
}
