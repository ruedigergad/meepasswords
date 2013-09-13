/*
 *  Copyright 2013 Ruediger Gad
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
    id: progressDialog

    anchors.fill: parent
    visible: true
    color: "black"
    opacity: 0

    z: 32

    signal closed()
    signal closing()
    signal opened()
    signal opening()

    Behavior on opacity {
        SequentialAnimation {
            PropertyAnimation { duration: 200 }
            ScriptAction {script: {
                    if (opacity === 0) {
                        closed()
                    } else {
                        opened()
                    }
                }
            }
        }
    }

    function close(){
        closing()
        opacity = 0
        mainFlickable.meePasswordsToolBar.enabled = true
    }

    function open(){
        opening()
        mainFlickable.meePasswordsToolBar.enabled = false
        opacity = 0.9
    }

    property double maxValue
    property double currentValue

    property alias title: titleText.text
    property alias message: message.text

    Item {
        anchors.fill: parent

        Text {
            id: titleText
            anchors.bottom: progressIndicatorBackground.top
            anchors.margins: primaryFontSize
            width: parent.width
            color: "white"
            font.pointSize: primaryFontSize * 1.5
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        Rectangle {
            id: progressIndicatorBackground
            anchors.centerIn: parent

            width: parent.width * 0.8
            height: primaryFontSize * 3

            color: "white"

            Rectangle {
                id: progressIndicator

                color: "steelblue"

                anchors {left: parent.left; top: parent.top; bottom: parent.bottom}
                width: parent.width * (currentValue === 0 ? 0 : (currentValue/maxValue))
            }
        }

        Text {
            id: message

            anchors.top: progressIndicatorBackground.bottom
            anchors.margins: primaryFontSize

            width: parent.width
            color: "white"
            font.pointSize: primaryFontSize
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        MouseArea {
            anchors.fill: parent
        }
    }
}
