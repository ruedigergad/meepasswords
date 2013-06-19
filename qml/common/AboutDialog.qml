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

      Text {id: name; text: "MeePasswords"
           font {pointSize: primaryFontSize; bold: true}
           anchors {horizontalCenter: parent.horizontalCenter; bottom: description.top; bottomMargin: 0}
           color: "white"}

      Text {id: description; text: "Keep your passwords protected."
            font{pointSize: primaryFontSize * 0.6; bold: true}
            anchors{horizontalCenter: parent.horizontalCenter; bottom: version.top; bottomMargin: primaryFontSize * 0.5}
            color: "white"}

      Text {id: version; text: "Version: 2.0.0"
           font {pointSize: primaryFontSize * 0.6; bold: true}
           anchors {horizontalCenter: parent.horizontalCenter; bottom: homepage.top; bottomMargin: primaryFontSize * 0.5}
           color: "lightgray"}

      Text {id: homepage;
          text: "<a href=\"http://ruedigergad.github.io/meepasswords\"><img src=\"qrc:/meepasswords_100x100.png\" /></a><br /><a href=\"http://ruedigergad.github.io/meepasswords\" style=\"text-decoration:none; color:#78bfff\" >Home Page</a>";
          textFormat: Text.RichText;
          onLinkActivated: { Qt.openUrlExternally(link); }
          font.pointSize: primaryFontSize * 0.6; horizontalAlignment: Text.AlignHCenter;
          anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: author.top; anchors.bottomMargin: primaryFontSize * 0.5 }

      Text {id: author;
          text: "Author: Ruediger Gad <a href=\"mailto:r.c.g@gmx.de\" style=\"text-decoration:none; color:#78bfff\" >r.c.g@gmx.de</a><br />Contributor: Cornelius Hald (v1.9.3 Harmattan UI Improvements)";
          textFormat: Text.RichText;
          onLinkActivated: { Qt.openUrlExternally(link); }
          width: parent.width
          wrapMode: Text.WordWrap
          font.pointSize: primaryFontSize * 0.6; anchors.centerIn: parent; color: "lightgray"; horizontalAlignment: Text.AlignHCenter}

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
          font.pointSize: primaryFontSize * 0.4; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: author.bottom; anchors.topMargin: 10; width: parent.width; color: "lightgray"; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap}
    }
}
