import QtQuick 2.0
import com.nokia.meego 1.0

Column {
    id: root

    signal copy
    property string label
    property string text

    anchors.left: parent.left
    anchors.right: parent.right

    Label {
        text: root.label
        color: "gray"
        font.pixelSize: 25
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Item {
        height: txt.height > but.height ? txt.height : but.height
        anchors.left: parent.left
        anchors.right: parent.right

        TextArea {
            id: txt
            text: root.text
            font.pixelSize: 25
            readOnly: true
            placeholderText: "Empty"
            platformEnableEditBubble: false
            anchors.left: parent.left
            anchors.right: but.left
            anchors.rightMargin: 10
        }

        Button {
            id: but
            enabled: txt.text !== ""
            width: 100
            text: "copy"
            anchors.right: parent.right
            onClicked: {
                txt.selectAll()
                txt.copy()
            }
        }
    }

//    Use QClipboard.setText() if current solution does not work on device
//    QClipboard {
//        id: clipboard
//    }
}
