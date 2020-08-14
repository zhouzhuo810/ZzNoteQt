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
        property bool isLoadOk
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
        text: qsTr("V:1.0.0")
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
            fontDialog.visible = true
        }
    }

    Action {
        shortcut: "Ctrl+Shift+T"
        onTriggered: {
            fontSizeDialog.visible = true
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
            saveToTxt()
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
            textEdit.font.family =  currentFont.family
            textEdit.font.pixelSize = currentFont.pixelSize
            settings.fontSize = currentFont.pixelSize
            settings.fontFamily = currentFont.family
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
        visible: false
        width: window.width
        height: window.height
        contentWidth: 16
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

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


        TextEdit {
            id: textEdit
            x: 0
            y: 0
            width: scrollView.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            selectByMouse: true
            cursorVisible: true
            color: settings.color
            textMargin: settings.padding
            font.pixelSize: settings.fontSize
            tabStopDistance: settings.fontSize * 2
            font.family: settings.fontFamily
            onSelectionStartChanged: {
                postSelection(selectionStart, selectionEnd)
            }
            onTextChanged: {
                justUpdateContent(getText(0, length))
            }

        }

    }

    function saveToTxt() {

    }

    function scrollToTop() {

    }

    function scrollToBottom() {

    }

    function autoFormat() {
        postAutoFormat()
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
                    loadNote()
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

    function justUpdateContent(content) {
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
        var requestString = "noteId=" + attrs.noteId +"&content="+content;
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
                        var content = response.data.content
                        textEdit.text = content
                    }
                } else {
                    // This is very handy for finding out why your web service won't talk to you
//                    console.log("Status: " + request.status + ", Status Text: " + request.statusText);
                    showIpInputView(true)
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
        tvName.visible = visible
        tvVersion.visible = visible
        tvBottom.visible = visible
        logo.visible = visible
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
                    // then do something with it here
                    var changeNote = attrs.noteId !== noteId
                    attrs.noteId = noteId
                    if (noteId === 0) {
                        textEdit.text = "请打开一篇纯文本便签"
                        attrs.isLoadOk = false
                        showIpInputView(false)
                    } else if(changeNote) {
                        showIpInputView(false)
                        reloadIvBg()
                        loadNote()
                    }
                } else {
                    showIpInputView(true)
                    // This is very handy for finding out why your web service won't talk to you
//                    console.log("Status: " + request.status + ", Status Text: " + request.statusText);
                    textEdit.text = "请长按便签APP的扫码按钮启动服务"
                    attrs.isLoadOk = false
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


}