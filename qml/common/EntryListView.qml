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
import meepasswords 1.0


ListView {
    id: entryListView
    width: parent.width

    model: entryStorage.getModel()
    delegate: Text {
        id: textDelegate
        width: parent.width

        text: name;
        font.pixelSize: 42
        horizontalAlignment: Text.AlignHCenter
        color: mouseArea.pressed ? "#78bfff" : "black"

        MouseArea{
            id: mouseArea
            anchors.fill: parent

            function createSimpleLink(name){
                return "<a href=\"" + name + "\" style=\"text-decoration:none; color:white\" >" + name + "</a>"
            }

            function beautifyNotes(text){
                var ret = text.replace(/(\S*:\/\/\S*)/g, '<a href="$1" style=\"text-decoration:none; color:#78bfff\" >$1<\/a>')
                ret = ret.replace(/\n/g, ' <br /> ')
                ret = ret.replace(/(www\.\S*)/g, '<a href="http://$1" style=\"text-decoration:none; color:#78bfff" >$1<\/a>')
                ret = ret.replace(/(\S*@\S*)/g, '<a href="http://$1" style=\"text-decoration:none; color:#78bfff" >$1<\/a>')
                return ret
            }

            function showEntry(){
                entryShowDialog.name = (name !== "") ? name : " ";
                entryShowDialog.userName = (userName !== "") ? createSimpleLink(userName) : " ";
                entryShowDialog.password = (password !== "") ? createSimpleLink(password) : " ";
                entryShowDialog.notes = beautifyNotes(notes);
                entryShowDialog.open();
            }

            onClicked: entryListView.currentIndex = index
            onDoubleClicked: showEntry();
            onPressAndHold: showEntry();
        }

        ListView.onRemove: SequentialAnimation {
            PropertyAction { target: textDelegate; property: "text"; value: "" }
            PropertyAction { target: textDelegate; property: "ListView.delayRemove"; value: true }
            NumberAnimation { target: textDelegate; property: "height"; to: 0; duration: 1500; easing.type: Easing.OutBounce }
            PropertyAction { target: textDelegate; property: "ListView.delayRemove"; value: false }
        }
    }

    highlightMoveDuration: 200
    highlight: Rectangle {
             color: "#78bfff"
             width: parent.width
         }

    section {
        property: "category"
        criteria: ViewSection.FullString
        delegate: Rectangle {
            gradient: Gradient{
                GradientStop{ position: 0.0; color: "#569ffd" }
                GradientStop{ position: 1.0; color: "#456aa2" }
            }
            width: parent.width
            height: childrenRect.height + 4
            Text { anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 30
                font.bold: true
                text: section
                font.capitalization: Font.SmallCaps
            }
        }
    }
}
