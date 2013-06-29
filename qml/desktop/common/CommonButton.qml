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
    id: commonButton

    property alias text: textItem.text
    property alias font: textItem.font

    property alias iconSource: iconImage.source;

    signal clicked

    width: text === "" ? height : textItem.width + (primaryFontSize * 2)
    height: textItem.height + (primaryFontSize / 2)
//    border.width: 1
//    radius: primaryBorderSize / 2
    smooth: true

    color: mouseArea.pressed ? "#4ea5f8" : "#0e65c8"
//    color: text === "" ? "transparent" : "#0e65c8" //"#9acfff"

    Text {
        id: textItem
        x: parent.width/2 - width/2; y: parent.height/2 - height/2
        font.pointSize: primaryFontSize * 0.75
        color: "black"
    }

    Image {
        id: iconImage
        height: parent.height * 0.8
        width: height
        fillMode: Image.PreserveAspectFit
        smooth: true
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: commonButton.clicked()
    }

    states: [
        State {
            name: "pressed"; when: mouseArea.pressed && mouseArea.containsMouse
//            PropertyChanges { target: commonButton; color: commonButton.text === "" ? "gray" : "#2e85d8" } //"#569ffd"
            PropertyChanges { target: textItem; x: textItem.x + 1; y: textItem.y + 1; explicit: true }
        },
        State {
            name: "disabled"; when: !commonButton.enabled
            PropertyChanges { target: commonButton; opacity: 0.5 }
        }
    ]
}

