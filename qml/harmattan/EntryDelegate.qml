import QtQuick 1.1

Item {
    id: root

    signal pressAndHold

    height: 80
    anchors.left: parent.left
    anchors.right: parent.right

    BorderImage {
        id: background
        anchors.fill: parent
        visible: mouseArea.pressed
        source: "image://theme/meegotouch-list-background-pressed-center"
    }

    Image {
        id: icon
        source: "../harmattan/icon_background.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        Text {
            font.pixelSize: 40
            text: name.substring(0, 2)
            color: "white"
            anchors.centerIn: parent
        }
    }

    Text {
        id: textDelegate
        text: name;
        font.pixelSize: 28
        elide: Text.ElideRight
        anchors.left: icon.right
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 10
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: pageStack.push(Qt.resolvedUrl("../harmattan/ShowEntryPage.qml"), { entry: model })
        onPressAndHold: root.pressAndHold()
    }

    ListView.onRemove: SequentialAnimation {
        PropertyAction { target: textDelegate; property: "text"; value: "" }
        PropertyAction { target: textDelegate; property: "ListView.delayRemove"; value: true }
        NumberAnimation { target: textDelegate; property: "height"; to: 0; duration: 1500; easing.type: Easing.OutBounce }
        PropertyAction { target: textDelegate; property: "ListView.delayRemove"; value: false }
    }
}
