/*
 *  Copyright 2011 - 2013 Ruediger Gad
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
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    width: nodeListDelegate.width
    height: (atTop || atBottom) ? nodeListDelegate.height + indicatorHeight : nodeListDelegate.height

    property bool atBottom: index === nodeListView.count - 1
    property bool atTop: index === 0
    property int indicatorHeight: 4

    Rectangle {
        id: topIndicator

        anchors.top: parent.top
        width: parent.width
        height: atTop ? indicatorHeight : 0

        color: "black"
        opacity: 0
        visible: atTop
    }

    NodeListDelegate {
        id: nodeListDelegate

        anchors.top: topIndicator.bottom
        nextButtonBackgroundColor: "transparent"
        nextButtonIcon: "../icons/next-white.png"
        textColor: Theme.primaryColor

        onPressAndHold: {
            contextMenu.open()
        }
    }

    Rectangle {
        id: bottomIndicator

        anchors.top: nodeListDelegate.bottom
        width: parent.width
        height: atBottom ? indicatorHeight : 0

        color: "black"
        opacity: 0
        visible: atBottom
    }
}
