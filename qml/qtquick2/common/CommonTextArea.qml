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

Rectangle {
    id: textArea

    property alias text: textEdit.text
    property int textFormat: TextEdit.PlainText
    property alias pointSize: textEdit.font.pointSize

    signal enter()
    signal keyPressed(variant event)

    function forceActiveFocus() {
        textEdit.forceActiveFocus()
    }

    border.width: primaryBorderSize / 8
    border.color: textEdit.focus ? "#0e65c8" : "#4ea5f8"
    color: enabled ? "white" : "#e0e0e0"
    height: textEdit.height + textEdit.font.pointSize
    smooth: true

    TextEdit {
        id: textEdit

        anchors.centerIn: parent
        color: "black"
        focus: textArea.focus
        font.pointSize: primaryFontSize * 0.75
        textFormat: textArea.textFormat
        width: parent.width - primaryBorderSize
        wrapMode: TextEdit.WordWrap

        onTextChanged: textArea.textChanged(text)

        onFocusChanged: {
            if(focus){
                textEdit.cursorPosition = textEdit.text.length
                Qt.inputMethod.show()
            } else {
                Qt.inputMethod.hide()
            }
        }
    }
}
