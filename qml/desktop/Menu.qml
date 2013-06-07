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
import "../common"

Item {
    id: menu

    anchors.fill: parent
    visible: false
    z: 16

    signal closed
    signal opened

    function close(){
        menuBorder.y = height
        closed()
    }

    function open(){
        menu.visible = true
        menuBorder.y = height - menuBorder.height
        opened()
    }

    /*
     * The following is a quite ugly hack to animate the menu.
     * This should be done via States rather than this hack.
     * Though, due to the limited time, for now this hack is used.
     */
    property bool isOpen: true
    onHeightChanged: {
        menuBorder.y = height
        isOpen = true
    }

    onChildrenChanged: {
        menuArea.children = children
    }

    Rectangle{
        id: background
        anchors.fill: parent
        color: "black"
        opacity: 0.6
    }

    MouseArea{
        anchors.fill: parent
        onClicked: {
            close();
        }
    }

    Rectangle{
        id: menuBorder
        y: parent.height
        width: parent.width
        height: menuArea.height

        color: "lightgray"
        opacity: 1

        Behavior on y {
            SequentialAnimation {
                PropertyAnimation { duration: 120 }
                ScriptAction {
                    script: {
                        if(menu.isOpen){
                            menu.visible = false
                        }
                        menu.isOpen = ! menu.isOpen
                    }
                }
            }
        }

        Rectangle{
            id: menuArea
            anchors.centerIn: parent
            width: parent.width
            height: childrenRect.height

            color: "lightgray"
        }
    }
}
