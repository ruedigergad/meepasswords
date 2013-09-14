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
    id: dialog

    property Item content: Item{}

    signal closed()
    signal closing()
    signal opened()
    signal opening()
    signal rejected()

    function close(){
        closing()
        opacity = 0
    }

    function open(){
        opening()
        focus = true
        opacity = 0.9
    }

    function reject() {
        close();
        rejected();
    }

    anchors.fill: parent
    color: "black"
    opacity: 0
    visible: true
    z: 32

    onContentChanged: content.parent = dialog

    onClosed: {
        parent.focus = true
    }

    Keys.onPressed: {
        event.accepted = true
        reject()
    }

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

    MouseArea{
        id: area

        anchors.fill: parent
        visible: dialog.visible

        onClicked: {
            reject()
        }
    }
}
