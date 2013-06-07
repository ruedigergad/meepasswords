import Qt 4.7

Text {
    id: textDelegate
    width: parent.width

    text: name;
    font.pixelSize: primaryFontSize * 1.25
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

        function setData(){
            entryListView.currentIndex = index
            editEntryRectangle.index = index
            editEntryRectangle.category = category
            editEntryRectangle.name = (name !== "") ? name : " ";
            editEntryRectangle.userName = userName
            editEntryRectangle.password = password
//            editEntryRectangle.userName = (userName !== "") ? createSimpleLink(userName) : " ";
//            editEntryRectangle.password = (password !== "") ? createSimpleLink(password) : " ";
            editEntryRectangle.notes = notes
//            editEntryRectangle.notes = beautifyNotes(notes);
        }

        onClicked: {
            setData()
        }

        onDoubleClicked: {
            setData()
            editEntry()
        }
        onPressAndHold: {
            setData()
        }
    }
}
