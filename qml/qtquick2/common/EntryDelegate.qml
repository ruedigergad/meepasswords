import QtQuick 2.0

Text {
    id: textDelegate

    signal pressAndHold

    color: primaryFontColor
    font.pointSize: primaryFontSize    
    horizontalAlignment: Text.AlignHCenter
    text: name
    width: parent.width
    wrapMode: Text.WordWrap

    MouseArea{
        id: mouseArea
        anchors.fill: parent

        function createSimpleLink(name){
            return "<a href=\"" + name + "\" style=\"text-decoration:none; color:white\" >" + name + "</a>"
        }

        function beautifyNotes(text){
            var ret = text.replace(/(\S*:\/\/\S*)/g, '<a href="$1" style=\"text-decoration:none; color:#78bfff\" >$1<\/a>')
            ret = ret.replace(/\n/g, ' <br /> ')
            ret = ret.replace(/(www\.\S*)/g, '<a href="http://$1" style=\"text-decoration:none; color:#78bfff" >$1<\/a>')
            ret = ret.replace(/(\S*@\S*)/g, '<a href="http://$1" style=\"text-decoration:none; color:#78bfff" >$1<\/a>')
            return ret
        }

        onClicked: {
            entryListView.currentIndex = index
            if (settingsAdapter.clickToOpen) {
                editEntry()
            }
        }

        onDoubleClicked: {
            entryListView.currentIndex = index
            editEntry()
        }

        onPressAndHold: textDelegate.pressAndHold()
    }
}
