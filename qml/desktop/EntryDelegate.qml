import QtQuick 1.1

Text {
    id: textDelegate
    width: parent.width

    text: name;
    font.pixelSize: 42
    horizontalAlignment: Text.AlignHCenter
    color: mouseArea.pressed ? "#78bfff" : "black"

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

        function showEntry(){
            entryShowDialog.name = (name !== "") ? name : " ";
            entryShowDialog.userName = (userName !== "") ? createSimpleLink(userName) : " ";
            entryShowDialog.password = (password !== "") ? createSimpleLink(password) : " ";
            entryShowDialog.notes = beautifyNotes(notes);
            entryShowDialog.open();
        }

        onClicked: entryListView.currentIndex = index
        onDoubleClicked: showEntry();
        onPressAndHold: showEntry();
    }
}
