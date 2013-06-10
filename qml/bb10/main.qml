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

    property int primaryFontSize: 11

    onRotationChanged: {
        console.log("Rotation changed...");
    }

    anchors.fill: parent

    color: "lightgray"

    Item {
        anchors.fill: parent

        Rectangle {
            id: header
            height: headerText.height * 1.25
            color: "#0c61a8"
            anchors{left: parent.left; right: parent.right; top: parent.top}

            Text {
                id: headerText
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
}


