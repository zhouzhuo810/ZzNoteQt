import QtQuick 2.15
import Qt.labs.platform 1.1
import Qt.labs.settings 1.1
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
Window {
    id: window
    visible: true
    width: 480
    height: 640
    title: qsTr("小周便签")

    Settings {
        id: settings
        property string input: ""
        property int fontSize: 15
        property int padding: 10
        property string fontFamily: ""
        property string bgColor: "#00000000"
        property string color: "#444444"
    }

    QtObject {
        id: attrs
        property int count
        property var noteId
        property var ip
        property bool isMarkdown: false
        property bool isLoadOk
        property int versionCode: 7
        property string versionName: "1.0.6"
        property var inStack: []
        property var outStack: []
    }

    Timer {
        id: countDown
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            heartBeat()
        }
    }

    Timer {
        id: getTimer
        interval: 200
        repeat: false
        onTriggered: {
            loadNote()
        }
    }


    Image {
        id: ivBg
        x: 0
        y: 0
        width: window.width
        height: window.height
        cache: true
        fillMode: Image.PreserveAspectCrop
    }

    Image {
        id: logo
        x: window.width / 2 - width / 2
        y: window.height / 2 - height * 2
        width: 100
        height: 100
        fillMode: Image.PreserveAspectFit
        source: "https://www.zznote.top/AndCode/image/logo_196.png"
    }

    Label {
        id: tvName
        x: window.width / 2 - width / 2
        y: logo.y + logo.height + 10
        font.pixelSize: 18
        text: qsTr("小周便签")
    }

    Label {
        id: tvVersion
        x: window.width / 2 - width / 2
        y: logo.y + logo.height + 40
        font.pixelSize: 14
        color: "#888888"
        text: qsTr("V:"+attrs.versionName)
    }


    Label {
        id: tvBottom
        x: window.width / 2 - width / 2
        y: window.height - 40
        font.pixelSize: 14
        color: "#cccccc"
        text: qsTr("Copyright © 2020 周卓 All Rights Reserved.")
    }


    Rectangle {
        id: ipLayout
        radius: 2
        x: window.width / 2 - width / 2
        y: window.height / 2 - height / 2
        border.width: 2
        border.color: "#dddddd"
        width: 240
        height: 30

        TextField {
            id: ipInput
            x: 0
            y: 0
            verticalAlignment: "AlignVCenter"
            horizontalAlignment: "AlignHCenter"
            width: ipLayout.width
            height: ipLayout.height
            background: null
            leftPadding: 5
            rightPadding: 5
            cursorVisible: true
            placeholderText: qsTr("长按便签的扫码按钮获取IP地址")
            selectByMouse: true
            text: settings.input
            font.pixelSize: 14
            onTextChanged: {
                if(isValidIP(getText(0, length))) {
                    settings.input = getText(0, length)
                    updateIp(getText(0, length))
                    if(focus) {
                        ipLayout.border.color = "#2775b6"
                    } else {
                        ipLayout.border.color = "#dddddd"
                    }
                } else {
                    ipLayout.border.color = "#ed3333"
                }
            }
        }

    }

    RoundButton {
        radius: 2
        id: btnShortcut
        width: 160
        x: window.width / 2 - width / 2
        y: window.height - height * 4.5
        text: qsTr("快捷键说明")
        onClicked: {
            showShortcuts()
        }
    }


    RoundButton {
        radius: 2
        width: 160
        id: btnCheckUpdate
        x: window.width / 2 - width / 2
        y: window.height - height * 3
        text: qsTr("检查更新")
        onClicked: {
            checkUpdate(true)
        }
    }

    Action {
        shortcut: "Ctrl+Shift+F"
        onTriggered: autoFormat()
    }

    Action {
        shortcut: "Page Up"
        onTriggered: scrollToTop()
    }

    Action {
        shortcut: "Page Down"
        onTriggered: scrollToBottom()
    }

    Action {
        shortcut: "Page Down"
        onTriggered: scrollToBottom()
    }


    Action {
        shortcut: "Ctrl+T"
        onTriggered: {
            fontSizeDialog.visible = true
        }
    }

    Action {
        shortcut: "Shift+Tab"
        onTriggered: {
            justPrint("shift + Tab")
            if(attrs.noteId === 0) {
                return
            }
            var text = textEdit.text
            var start = textEdit.selectionStart
            var end = textEdit.selectionEnd
            var reg = new RegExp( '/\t+/' , "g")
            var reg2 = new RegExp('　', "g")
            var contentY = flickView.contentY
            if (start === end) {
                textEdit.text = text.replace(reg, '').replace(reg2, "")
                textEdit.select(start, start)
                flickView.contentY = contentY
            } else {
                var selectionText = textEdit.selectedText
                var midStr = selectionText.replace(reg, '').replace(reg2, "")
                var befStr = text.substring(0, start)
                var endStr = text.substring(end, text.length)
                var fullStr = befStr + midStr + endStr
                textEdit.text = fullStr
                textEdit.select(start, start)
                flickView.contentY = contentY
            }
        }
    }

    Action {
        shortcut: "Ctrl+Shift+L"
        onTriggered: {
            justPrint("shift + Shift + L")
            if(attrs.noteId === 0) {
                return
            }
            var text = textEdit.text
            var start = textEdit.selectionStart
            var end = textEdit.selectionEnd
            var reg = /\n(\n)*( )*(\n)*\n/g
            var contentY = flickView.contentY
            if (start === end) {
                textEdit.text = text.replace(reg, '\n')
                textEdit.select(start, start)
                flickView.contentY = contentY
            } else {
                var selectionText = textEdit.selectedText
                var midStr = selectionText.replace(reg, '\n')
                var befStr = text.substring(0, start)
                var endStr = text.substring(end, text.length)
                var fullStr = befStr + midStr + endStr
                textEdit.text = fullStr
                textEdit.select(start, start)
                flickView.contentY = contentY
            }
        }
    }


    Action {
        shortcut: "Ctrl+Shift+T"
        onTriggered: {
            fontDialog.visible = true
        }
    }

    Action {
        shortcut: "Ctrl+P"
        onTriggered: {
            paddingDialog.visible = true
        }
    }

    Action {
        shortcut: "Ctrl+O"
        onTriggered: {
            colorDialog.visible = true
        }
    }

    Action {
        shortcut: "Ctrl+B"
        onTriggered: {
            bgColorDialog.visible = true
        }
    }

    Action {
        shortcut: "Ctrl+S"
        onTriggered: {
            postToSaveNow()
        }
    }

    Action {
        shortcut: "Ctrl+Z"
        onTriggered: {
            postToUndo()
        }
    }


    Action {
        shortcut: "Ctrl+Shift+Z"
        onTriggered: {
            postToRedo()
        }
    }


    ColorDialog {
        id: colorDialog
        visible:  false
        currentColor: settings.color
        title: qsTr("设置文字颜色")
        onAccepted: {
            settings.color = currentColor
        }
    }

    ColorDialog {
        id: bgColorDialog
        visible:  false
        currentColor: settings.bgColor
        title: qsTr("设置背景颜色")
        onAccepted: {
            settings.bgColor = currentColor
        }
    }

    FontDialog {
        id: fontDialog
        visible: false
        currentFont: textEdit.font
        title: qsTr("设置字体:"+settings.fa)
        onAccepted: {
            settings.fontSize = currentFont.pixelSize
            settings.fontFamily = currentFont.family
        }
    }

    Dialog {
        id: updateDialog
        title: "发现新版"
        visible: false
        x: window.width / 2 - width / 2
        y: window.height / 2 - height / 2
        Column {
            Label {
                id: updateLabel
                font.pixelSize: 16
                width: 220
                bottomPadding: 20
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                lineHeight: 1.1
                text: "现在去官网下载新版吗？"
            }
            Row {
                leftPadding: 0
                rightPadding: 0

                RoundButton {
                    radius: 2
                    width: 100
                    text: "取消"
                    onClicked: {
                        updateDialog.visible = false
                    }
                }

                Label {
                    width: 20
                }

                RoundButton {
                    id: msgOkBtn
                    radius: 2
                    width: 100
                    text: "确定"
                    onClicked: {
                        updateDialog.visible = false
                        jumpToWeb("https://www.zznote.top/AndCode/")
                    }
                }
            }
        }

    }

    Dialog {
        id: msgDialog
        visible: false
        x: window.width / 2 - width / 2
        y: window.height / 2 - height / 2
        width: 280
        Label {
            id: msgLabel
            font.pixelSize: 16
            lineHeight: 1.5
            width: 280
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }



    Dialog {
        id: fontSizeDialog
        visible: false
        title: qsTr("设置字体大小"+settings.fontSize)
        x: window.width / 2 - width / 2
        y: window.height / 2 - height / 2
        Slider {
            from: 0
            to: 40
            value: settings.fontSize
            onMoved: {
                fontSizeDialog.title = qsTr("设置字体大小"+Math.ceil(value))
                settings.fontSize = Math.ceil(value)
            }
        }
    }

    Dialog {
        id: paddingDialog
        visible: false
        title: qsTr("设置内边距："+settings.padding)
        x: window.width / 2 - width / 2
        y: window.height / 2 - height / 2
        Slider {
            from: 0
            to: 40
            value: settings.padding
            onMoved: {
                paddingDialog.title = qsTr("设置内边距："+Math.ceil(value))
                settings.padding = Math.ceil(value)
            }
        }
    }


    ScrollView {
        id: scrollView
        x: 0
        y: 0
        visible:  false
        width: window.width
        height: window.height
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.interactive: true


        Flickable {
            id: flickView
            x: 0
            y: 0
            width: window.width
            height: window.height
            contentWidth: textEdit.paintedWidth
            contentHeight: textEdit.paintedHeight

            FontLoader {
                id: myFont;
                source: ipInput.text.length == 0 ? null : "http://"+ipInput.text+":8080/desktop/fonts"
                onStatusChanged: {
                    if (status === FontLoader.Ready) {
                        if(settings.fontFamily.length > 0) {
                            textEdit.font.family = settings.fontFamily
                        } else {
                            textEdit.font.family = name
                        }
                    }
                }
            }


            function ensureVisible(r)
            {
                if (contentX >= r.x)
                    contentX = r.x;
                else if (contentX+width <= r.x+r.width)
                    contentX = r.x+r.width-width;
                if (contentY >= r.y)
                    contentY = r.y;
                else if (contentY+height <= r.y+r.height)
                    contentY = r.y+r.height-height;
            }

            TextEdit {
                id: textEdit
                x: 0
                y: 0
                width: scrollView.width
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                cursorVisible: true
                focus: true
                color: settings.color
                textMargin: settings.padding
                font.pixelSize: settings.fontSize
                tabStopDistance: settings.fontSize * 2
                font.family: settings.fontFamily
                onCursorRectangleChanged: flickView.ensureVisible(cursorRectangle)
                onSelectionStartChanged: {
                    postSelection(selectionStart, selectionEnd)
                }
                onTextChanged: {
                    justUpdateContent(getText(0, length))
                }
            }

        }
    }

    function showMsg(title, msg) {
        msgDialog.title = title
        msgLabel.text = msg
        msgDialog.visible = true
    }

    function showShortcuts() {
        showMsg("快捷键说明","Ctrl+S:保存\nCtrl+T:字体大小\nCtrl+O:文字颜色\nCtrl+P:内边距\nCtrl+Z:撤回\nCtrl+⬆️:聚焦到文首\nCtrl+⬇️:聚焦到文末\nCtrl+Shift+T:修改字体\nCtrl+Shift+F:段首缩进+插入空行\nCtrl+Shift+L:移除空行\nShift+Tab:移除段首缩进\nCtrl+Shift+Z:反撤回")
    }

    function jumpToWeb(url) {
        Qt.openUrlExternally(url)
    }

    function saveToTxt() {

    }

    function scrollToTop() {
         flickView.contentY = 0
    }

    function scrollToBottom() {
        flickView.contentY = flickView.contentHeight - flickView.height
    }

    function autoFormat() {
        var text = textEdit.text
        var start = textEdit.selectionStart
        var end = textEdit.selectionEnd

        var contentY = flickView.contentY
        if(attrs.isMarkdown === true) {
            var reg = /\n(\n)*( )*(\n)*\n/g
            var reg2 = /(  )*\n/g
            textEdit.text = text.replace(reg, '\n').replace(reg2, '\n').replace(/[\n\r]/g, '  \n\n')
        } else {
            var reg = /\n(\n)*( )*(\n)*\n/g
            var reg1 = new RegExp( '/\t+/' , "g")
            var reg2 = new RegExp('　', "g")
            textEdit.text = "　　" + text.replace(reg1, '').replace(reg2, "").replace(reg, '\n').replace(/[\n\r]/g, '\n\n　　')
        }

        textEdit.select(start, start)
        flickView.contentY = contentY
    }

    function postAutoFormat() {
        if(attrs.noteId === 0) {
            return
        }

        var request = new XMLHttpRequest();
        request.onreadystatechange=function() {
            // Need to wait for the DONE state or you'll get errors
            if(request.readyState === XMLHttpRequest.DONE) {
                if (request.status === 200) {
                    //                    console.log("Response = " + request.responseText);
                    // if response is JSON you can parse it
                    getTimer.start()
                }
                else {
                    // This is very handy for finding out why your web service won't talk to you
                    //                    console.log("Status: " + request.status + ", Status Text: " + request.statusText);
                }
            }
        }
        // Make sure whatever you post is URI encoded
        //        var encodedString = encodeURIComponent(postString);
        // This is for a POST request but GET etc. work fine too
        request.open("POST", "http://"+attrs.ip+":8080/desktop/autoFormat/", true); // only async supported
        // Post types other than forms should work fine too but I've not tried
        request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        // Form data is web service dependent - check parameter format
        var requestString = "noteId=" + attrs.noteId;
        request.send(requestString);

    }

    function isValidIP(ip) {
        var reg = /((25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))\.){3}(25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))/
        return reg.test(ip);
    }

    function updateIp(ip) {
        attrs.ip = ip
        if(!countDown.running) {
            countDown.start()
            checkUpdate(false)
        }
    }

    function justPrint(text: string) {
        console.log(text)
    }

    //发送心跳包
    function heartBeat() {
        httpForHeartBeat()
    }

    //加载便签
    function loadNote() {
        httpForLoadNote()
    }


    function clearStack() {
        attrs.inStack = []
        attrs.outStack = []
    }

    function addToInStack(content) {
        Array.prototype.remove=function(dx)
        {
            if(isNaN(dx)||dx>this.length){return false;}
            for(var i=0,n=0;i<this.length;i++)
            {
                if(this[i]!==this[dx])
                {
                    this[n++]=this[i]
                }
            }
            this.length-=1
        }
        if(content.length === 0) {
            return
        }

        if(attrs.inStack.length < 50) {
            attrs.inStack.push(content)
        } else {
            attrs.inStack.remove(0)
            attrs.inStack.push(content)
        }
//        justPrint(attrs.inStack)
    }

    function addToOutStack(content) {
        Array.prototype.remove=function(dx)
        {
            if(isNaN(dx)||dx>this.length){return false;}
            for(var i=0,n=0;i<this.length;i++)
            {
                if(this[i]!==this[dx])
                {
                    this[n++]=this[i]
                }
            }
            this.length-=1
        }
        if(content.length === 0) {
            return
        }

        if(attrs.outStack.length < 50) {
            attrs.outStack.push(content)
        } else {
            attrs.outStack.remove(0)
            attrs.outStack.push(content)
        }
//        justPrint(attrs.inStack)
    }

    function justUpdateContent(content) {
        addToInStack(content)
        if(attrs.noteId === 0 || !attrs.isLoadOk) {
            return
        }
        var request = new XMLHttpRequest();
        request.onreadystatechange=function() {
            // Need to wait for the DONE state or you'll get errors
            if(request.readyState === XMLHttpRequest.DONE) {
                if (request.status === 200) {
                    //                    console.log("Response = " + request.responseText);
                    // if response is JSON you can parse it
                }
                else {
                    // This is very handy for finding out why your web service won't talk to you
                    //                    console.log("Status: " + request.status + ", Status Text: " + request.statusText);
                }
            }
        }
        // This is for a POST request but GET etc. work fine too
        request.open("POST", "http://"+attrs.ip+":8080/desktop/modifyNoteContent/", true); // only async supported
        // Post types other than forms should work fine too but I've not tried
        request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        // Form data is web service dependent - check parameter format
        var requestString = "noteId=" + attrs.noteId +"&content="+ encodeURIComponent(content);
        request.send(requestString);
    }

    function reloadIvBg() {
        ivBg.source = ""
        ivBg.source = "http://"+attrs.ip+":8080/desktop/bgPicture/"
    }


    function httpForLoadNote() {
        //        justPrint("attrs.noteId =" + attrs.noteId)
        if(attrs.noteId === 0) {
            return
        }

        attrs.isLoadOk = false
        var request = new XMLHttpRequest();
        request.onreadystatechange=function() {
            // Need to wait for the DONE state or you'll get errors
            if(request.readyState === XMLHttpRequest.DONE) {
                if (request.status === 200) {
                    //                    console.log("Response = " + request.responseText);
                    // if response is JSON you can parse it
                    var response = JSON.parse(request.responseText);
                    var code = response.code
                    if(code === 0) {
                        attrs.isLoadOk = false
                        showIpInputView(true)
                    } else {
                        attrs.isLoadOk = true
                        showIpInputView(false)
                        attrs.noteId = response.data.noteId
                        attrs.isMarkdown = response.data.markdown
                        var content = response.data.content
                        textEdit.text = content
                    }
                } else {
                    // This is very handy for finding out why your web service won't talk to you
                    //                    console.log("Status: " + request.status + ", Status Text: " + request.statusText);
                    showIpInputView(true)
                    attrs.isLoadOk = false
                    textEdit.text = "请长按便签APP的扫码按钮启动服务"
                }
            }
        }

        // This is for a POST request but GET etc. work fine too
        request.open("GET", "http://"+attrs.ip+":8080/desktop/getNote/", true); // only async supported
        // Post types other than forms should work fine too but I've not tried
        request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        request.send()
    }

    function showIpInputView(visible) {
        scrollView.visible = !visible
        ipLayout.visible = visible   
        ipInput.focus = visible

        tvName.visible = visible
        tvVersion.visible = visible
        tvBottom.visible = visible
        logo.visible = visible
        btnCheckUpdate.visible = visible
        btnShortcut.visible = visible
    }

    function checkUpdate(byHand) {
        var request = new XMLHttpRequest();
        request.onreadystatechange=function() {
            // Need to wait for the DONE state or you'll get errors
            if(request.readyState === XMLHttpRequest.DONE) {
                //                justPrint("request.status="+request.status)
                //                justPrint("request.responseText="+request.responseText)
                if (request.status === 200) {
                    //                    console.log("Response = " + request.responseText);
                    // if response is JSON you can parse it
                    var response = JSON.parse(request.responseText);
                    var code = response.code
                    var msg = response.msg
                    if(code === 1) {
                        var note = response.data.upgradeNote
                        updateLabel.text = note
                        updateDialog.visible = true
                    } else {
                        if(byHand) {
                            showMsg("检查更新", msg)
                        }
                    }

                } else {
                    if(byHand) {
                        showMsg("检查更新","网络异常，请检查网络是否畅通～")
                    }
                }
            }
        }

        // This is for a POST request but GET etc. work fine too
        request.open("GET", "https://zznote.top/AndCode/v1/upgrade/checkUpdate?"+"appType=ZzNotePC&byHand="+byHand+"&versionCode="+attrs.versionCode, true); // only async supported
        // Post types other than forms should work fine too but I've not tried
        request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        request.send()
    }


    //提交心跳包
    function httpForHeartBeat() {
        var request = new XMLHttpRequest();
        request.onreadystatechange=function() {
            // Need to wait for the DONE state or you'll get errors
            if(request.readyState === XMLHttpRequest.DONE) {
                if (request.status === 200) {
//                    console.log("Response = " + request.responseText);
                    // if response is JSON you can parse it
                    var response = JSON.parse(request.responseText);
                    var noteId = response.editingNoteId
                    var charCount = response.editingCharCount
                    // then do something with it here
                    var changeNote = attrs.noteId !== noteId
                    attrs.noteId = noteId
                    if (response.editingMarkdown !== undefined) {
                        attrs.isMarkdown = response.editingMarkdown
                    }
                    if (noteId === 0) {
                        textEdit.text = "请打开一篇纯文本便签"
                        attrs.isLoadOk = false
                        showIpInputView(false)
                    } else if(changeNote) {
                        clearStack()
                        showIpInputView(false)
                        reloadIvBg()
                        loadNote()
                    } else if (noteId !== 0 && charCount !== undefined && charCount !== "") {
                        window.title = qsTr("小周便签 ( "+charCount+" 字)")
                    } else {
                        window.title = qsTr("小周便签")
                    }
                } else {
                    attrs.noteId = 0
                    attrs.isLoadOk = false
                    showIpInputView(true)
                    // This is very handy for finding out why your web service won't talk to you
                    //                    console.log("Status: " + request.status + ", Status Text: " + request.statusText);
                    textEdit.text = "请长按便签APP的扫码按钮启动服务"
                }
            }
        }

        // This is for a POST request but GET etc. work fine too
        request.open("GET", "http://"+attrs.ip+":8080/desktop/heartBeat/", true); // only async supported
        // Post types other than forms should work fine too but I've not tried
        request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        request.send()
    }

    //提交光标位置改变
    function postSelection(start, end) {
        if(attrs.noteId === 0) {
            return
        }

        var request = new XMLHttpRequest();
        request.onreadystatechange=function() {
            // Need to wait for the DONE state or you'll get errors
            if(request.readyState === XMLHttpRequest.DONE) {
                if (request.status === 200) {
                    //                    console.log("Response = " + request.responseText);
                    // if response is JSON you can parse it
                }
                else {
                    // This is very handy for finding out why your web service won't talk to you
                    //                    console.log("Status: " + request.status + ", Status Text: " + request.statusText);
                }
            }
        }
        // Make sure whatever you post is URI encoded
        //        var encodedString = encodeURIComponent(postString);
        // This is for a POST request but GET etc. work fine too
        request.open("POST", "http://"+attrs.ip+":8080/desktop/updateSelection/", true); // only async supported
        // Post types other than forms should work fine too but I've not tried
        request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        // Form data is web service dependent - check parameter format
        var requestString = "noteId=" + attrs.noteId +"&start="+start+"&end="+end;
        request.send(requestString);
    }

    function postToUndo() {
        if(attrs.noteId === 0) {
            return
        }

        if(attrs.inStack.length == 0) {
            return
        }

        var text = attrs.inStack.pop
        textEdit.text = text
        addToOutStack(text)
    }


    function postToRedo() {
        if(attrs.noteId === 0) {
            return
        }

        if(attrs.outStack.length == 0) {
            return
        }

        var text = attrs.outStack.pop
        textEdit.text = text
    }

    function postToSaveNow() {
        if(attrs.noteId === 0) {
            return
        }

        var request = new XMLHttpRequest();
        request.onreadystatechange=function() {
            // Need to wait for the DONE state or you'll get errors
            if(request.readyState === XMLHttpRequest.DONE) {
                if (request.status === 200) {
                    //                    console.log("Response = " + request.responseText);
                    // if response is JSON you can parse it
                }
                else {
                    // This is very handy for finding out why your web service won't talk to you
                    //                    console.log("Status: " + request.status + ", Status Text: " + request.statusText);
                }
            }
        }
        // Make sure whatever you post is URI encoded
        //        var encodedString = encodeURIComponent(postString);
        // This is for a POST request but GET etc. work fine too
        request.open("POST", "http://"+attrs.ip+":8080/desktop/saveNow/", true); // only async supported
        // Post types other than forms should work fine too but I've not tried
        request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        // Form data is web service dependent - check parameter format
        var requestString = "noteId=" + attrs.noteId;
        request.send(requestString);
    }




}
