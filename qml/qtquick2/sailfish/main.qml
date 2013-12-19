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

import QtQuick 2.0
import Sailfish.Silica 1.0
import meepasswords 1.0
import SyncToImap 1.0

ApplicationWindow {
    id: mainWindow

    property int primaryFontSize: Theme.fontSizeMedium
    property int primaryBorderSize: 25

    property string primaryFontColor: Theme.primaryColor
    property string secondaryFontColor: Theme.secondaryColor

    property string primaryBackgroundColor: "transparent"
    property double primaryBackgroundOpacity: 0.9
    property string secondaryBackgroundColor: "transparent"
    property double secondaryBackgroundOpacity: 0.9

    property string iconNameSuffix: "-white"

    initialPage: Page {
        id: mainPage

        Item {
            id: main

            anchors.fill: parent

            onRotationChanged: {
                console.log("Rotation changed...");
            }

            Component.onCompleted: {
                cleanOldFiles()
            }

            function cleanOldFiles() {
                console.log("Cleaning left overs from last run.")
                mainFlickable.fileHelper.rmAll(mainFlickable.entryStorage.getStorageDirPath(), ".encrypted.");
            }

            Item {
                anchors.fill: parent

                MainFlickable {
                    id: mainFlickable

                    anchors{top: parent.top; left: parent.left; right: parent.right; bottom: parent.bottom}
                    showToolBar: false
                }
            }
        }
    }
}
