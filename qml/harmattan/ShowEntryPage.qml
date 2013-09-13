import QtQuick 1.1
import com.nokia.meego 1.0
import meepasswords 1.0

Page {
    id: root

    orientationLock: PageOrientation.LockPortrait

    property QtObject entry

    tools: ToolBarLayout {

        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }

        ToolIcon {
            platformIconId: "toolbar-edit"
            onClicked: {
                var component = Qt.createComponent("EditEntrySheet.qml");
                var sheet = component.createObject(root);
                sheet.entry = entry
                sheet.open()
            }
        }

// Maybe add later again if needed. Could open menu with delete, share, etc.
//        ToolIcon {
//            platformIconId: "toolbar-view-menu"
//            onClicked: console.log("menu clicked")
//        }
    }

    Rectangle {
        id: header
        height: 72
        color: "#0c61a8"
        anchors{left: parent.left; right: parent.right; top: parent.top}

        Text {
            text: entry.name
            color: "white"
            font.family: "Nokia Pure Text Light"
            font.pixelSize: 32
            elide: Text.ElideRight
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Flickable {
        id: flickable
        clip: true
        contentHeight: column.height + 20
        anchors.top: header.bottom
        anchors.topMargin: 15
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Column {
            id: column
            spacing: 20
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20

            EntryLabel {
                label: "User Name"
                text: entry.userName
            }

            EntryLabel {
                label: "Password"
                text: entry.password
            }

            EntryLabel {
                label: "Notes"
                text: entry.notes
            }
        }
    }

    ScrollDecorator {
        flickableItem: flickable
    }
}
