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

import QtQuick 2.0

Rectangle {
    id: progressDialog

    property double currentValue
    property double maxValue
    property alias message: message.text
    property alias title: titleText.text

    function close(){
        closing()
        opacity = 0
        toolBar.enabled = true
        enabled = false
    }

    function open(){
        opening()
        enabled = true
        toolBar.enabled = false
        opacity = 0.9
    }

    signal closed()
    signal closing()
    signal opened()
    signal opening()

    anchors.fill: parent
    color: "black"
    enabled: false
    visible: enabled
    opacity: 0
    z: 32

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
            color: "white"
            height: primaryFontSize * 3
            width: parent.width * 0.8

            Rectangle {
                id: progressIndicator

                anchors {left: parent.left; top: parent.top; bottom: parent.bottom}
                color: "steelblue"
                width: parent.width * (currentValue === 0 ? 0 : (currentValue/maxValue))
            }
        }

        Text {
            id: message

            anchors.top: progressIndicatorBackground.bottom
            anchors.margins: primaryFontSize
            color: "white"
            font.pointSize: primaryFontSize
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            wrapMode: Text.Wrap
        }

        MouseArea {
            anchors.fill: parent
        }
    }
}
