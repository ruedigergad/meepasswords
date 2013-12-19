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
import Sailfish.Silica 1.0

SilicaFlickable {
    id: placeHolderFlickable

    anchors.fill: parent
    contentHeight: childrenItem.height

    PullDownMenu {
        MenuItem {
            text: "Add Entry"
            onClicked: mainFlickable.addEntry()
        }
    }

    Item {
        id: childrenItem

        width: placeHolderFlickable.width
        height: placeHolderFlickable.height

        Text {
            id: noEntriesText

            anchors.centerIn: parent
            color: secondaryFontColor
            font.pointSize: primaryFontSize * 1.25
            horizontalAlignment: Text.AlignHCenter
            text: "No entries yet."
            wrapMode: Text.WordWrap
        }

        Text {
            anchors{ top: noEntriesText.bottom; topMargin: primaryFontSize * 0.5
                     left: parent.left; right: parent.right}
            color: secondaryFontColor
            font.pointSize: primaryFontSize
            horizontalAlignment: Text.AlignHCenter
            text: "Pull down and choose \"Add Entry\" to add a new entry."
            wrapMode: Text.WordWrap
        }
    }
}
