/* This file has been taken from: http://forum.meego.com/showthread.php?t=4600
 * Credits go to ph5.
 * As there was no explicitly mentioned licensing or copyright notice I assume
 * this code to be released to the public domain.
 * Following is an exact copy of the file taken from above forum thread.
 */

// FastScrollStyle.qml
import QtQuick 1.1
import com.nokia.meego 1.0 // for Style

Style {

    // Font
    property int fontPixelSize: 68
    property bool fontBoldProperty: true

    // Color
    property color textColor: inverted?"#000":"#fff"

    property string handleImage: "image://theme/meegotouch-fast-scroll-handle"+__invertedString
    property string magnifierImage: "image://theme/meegotouch-fast-scroll-magnifier"+__invertedString
    property string railImage: "image://theme/meegotouch-fast-scroll-rail"+__invertedString
}
