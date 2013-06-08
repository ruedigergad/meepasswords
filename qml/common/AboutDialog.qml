/*
 *  Copyright 2011, 2012, 2013 Ruediger Gad
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
import "../common"

CommonDialog {
    id: aboutDialog

    //anchors.fill: parent

    content: Item {
      anchors.fill: parent

      Text {id: name; text: "MeePasswords"; font.pixelSize: primaryFontSize * 1.25; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: homepage.top; anchors.bottomMargin: 0; color: "white"}

      Text {id: homepage;
          text: "<a href=\"http://meepasswords.garage.maemo.org\" style=\"text-decoration:none; color:#78bfff\" >Home Page</a><br /><a href=\"http://meepasswords.garage.maemo.org\"><img src=\"qrc:/meepasswords_100x100.png\" /></a>";
          textFormat: Text.RichText;
          onLinkActivated: { Qt.openUrlExternally(link); }
          font.pixelSize: primaryFontSize * 0.75; horizontalAlignment: Text.AlignHCenter;
          anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: description.top; anchors.bottomMargin: 0 }

      Text {id: description; text: "Keep your passwords protected."; font.pixelSize: 20; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: author.top; anchors.bottomMargin: 0; color: "white"}

      Text {id: author;
          text: "Author: Ruediger Gad <a href=\"mailto:r.c.g@gmx.de\" style=\"text-decoration:none; color:#78bfff\" >r.c.g@gmx.de</a>";
          textFormat: Text.RichText;
          onLinkActivated: { Qt.openUrlExternally(link); }
          font.pixelSize: primaryFontSize * 0.75; anchors.centerIn: parent; color: "lightgray"; horizontalAlignment: Text.AlignHCenter}

      Text {id: license;
          text: "MeePasswords is free software: you can redistribute it and/or modify "
            + "it under the terms of the GNU General Public License as published by "
            + "the Free Software Foundation, either version 3 of the License, or "
            + "(at your option) any later version.<br />"
            + "MeePasswords is distributed in the hope that it will be useful, "
            + "but WITHOUT ANY WARRANTY; without even the implied warranty of "
            + "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the "
            + "GNU General Public License for more details.<br />"
            + "You should have received a copy of the GNU General Public License "
            + "along with MeePasswords.  If not, see <a href=\"http://www.gnu.org/licenses\" style=\"text-decoration:none; color:#78bfff\" >http://www.gnu.org/licenses</a>.";
          textFormat: Text.RichText;
          onLinkActivated: { Qt.openUrlExternally(link); }
          font.pixelSize: primaryFontSize * 0.5; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: author.bottom; anchors.topMargin: 10; width: parent.width; color: "lightgray"; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap}
    }
}