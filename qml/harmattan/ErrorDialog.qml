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
import com.nokia.meego 1.0
import "../common/constants.js" as Constants

Dialog{
    id: errorDialog
    anchors.fill: parent

    property alias message: errorMessage.message

    content: Item {
        anchors.fill: parent

        Label{
            id: errorLabel
            anchors.bottom: errorText.top
            anchors.bottomMargin: 50
            anchors.horizontalCenter: parent.horizontalCenter

            text: "Error!"
            font.pixelSize: 60
            font.bold: true
            color: "red"
        }

        Label{
            id: errorText
            text: "Ooops! An error has occured!"
            anchors.bottom: errorMessage.top
            anchors.bottomMargin: 50

            width: parent.width

            font.pixelSize: 30
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap

            color:  "white"
        }

        Label{
            id: errorMessage
            anchors.centerIn: parent
            width: parent.width

            property string message: ""
            text:  "The error message is: " + message

            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap

            color: "white"
        }

        Label{
            id: explanation
            anchors.top: errorMessage.bottom
            anchors.topMargin: 50
            width: parent.width

            text: "Please excuse the inconvenience!<br />"
//                  + "To help fixing this issue please file a bug report at the <a href=\"https://garage.maemo.org/tracker/?atid=7461&group_id=2222\">MeePasswords bug tracker</a>. "
                  + "To help fixing this issue please send a bug report to the author of MeePasswords via email to "
                  + "<a href=\"mailto:r.c.g@gmx.de?subject=MeePasswords Error Report&body=MeePasswords Version: " + Constants.VERSION + "\\nError Message: "+ message +"\">r.c.g@gmx.de</a>. "
                  + "Clicking the link will open a prepared email template. "
                  + "If you are in doubt what to do, just send it as is. Thanks!"

            textFormat: Text.RichText
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap

            onLinkActivated: { Qt.openUrlExternally(link); }

            color: "white"
        }
    }
}
