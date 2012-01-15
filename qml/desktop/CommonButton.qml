/*
 * The following code is based on the code from:
 * http://developer.qt.nokia.com/wiki/QmlComponentsButton
 * which is released under the terms of the Creative Commons Attribution-ShareAlike 2.5 Generic license.
 * Therefore this code is also released under the terms of the Creative Commons Attribution-ShareAlike 2.5 Generic license.
 */

import Qt 4.7

Rectangle {
    id: commonButton

    property alias text: textItem.text
    property alias font: textItem.font

    signal clicked

    width: textItem.width + 40; height: textItem.height + 10
    border.width: 1
    radius: height/4
    smooth: true

    gradient: Gradient {
        GradientStop { id: topGrad; position: 0.0; color: "#9acfff" }
        GradientStop { id: bottomGrad; position: 1.0; color: "#79aeee" }
    }

    Text {
        id: textItem
        x: parent.width/2 - width/2; y: parent.height/2 - height/2
        font.pixelSize: 30
        color: "black"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: commonButton.clicked()
    }

    states: [
        State {
            name: "pressed"; when: mouseArea.pressed && mouseArea.containsMouse
            PropertyChanges { target: topGrad; color: "#569ffd" }
            PropertyChanges { target: bottomGrad; color: "#456aa2" }
            PropertyChanges { target: textItem; x: textItem.x + 1; y: textItem.y + 1; explicit: true }
        },
        State {
            name: "disabled"; when: !commonButton.enabled
            PropertyChanges { target: topGrad; color: "white" }
            PropertyChanges { target: bottomGrad; color: "lightgray" }
        }
    ]
}

