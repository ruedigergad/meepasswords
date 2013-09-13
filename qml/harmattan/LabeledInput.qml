import QtQuick 2.0
import com.nokia.meego 1.0

Column {
    id: root

    property alias label: txt.text
    property alias text: textField.text
    property alias placeholderText: textField.placeholderText

    anchors.left: parent.left
    anchors.right: parent.right

    Label {
        id: txt
        color: "gray"
        font.pixelSize: 25
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
    }

    TextField {
        id: textField
        anchors.left: parent.left
        anchors.right: parent.right
    }
}
