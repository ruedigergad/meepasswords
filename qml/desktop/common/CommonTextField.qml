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

import QtQuick 1.1

Rectangle {
    id: textField

    width: parent.width
    height: textInput.height * 1.5

    border.width: primaryFontSize / 8
    border.color: textInput.focus ? "#0e65c8" : "#4ea5f8"
    color: enabled ? "white" : "#f0f0f0"
    radius: primaryFontSize / 2
    smooth: true

    property int echoMode: TextInput.Normal
    property alias pointSize: textInput.font.pointSize
    property alias text: textInput.text

    signal textChanged(string text)


    TextInput {
        id: textInput

        focus: textField.focus
        width: parent.width - (2 * font.pointSize)
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        font.pointSize: primaryFontSize * 0.6

        color: "black"
        echoMode: textField.echoMode

        onTextChanged: textField.textChanged(text)
    }

}
