import QtQuick

Window {
    id: countdownOverlay

    property int countdown

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.WindowTransparentForInput
    visibility: Window.FullScreen
    color: "transparent"

    Text {
        id: countdownText
        anchors.centerIn: parent
        text: countdownOverlay.countdown
        color: "white"
        font.pixelSize: 180
        font.bold: true

        Behavior on text {
            SequentialAnimation {
                NumberAnimation { target: countdownText; property: "scale"; to: 1.3; duration: 100 }
                NumberAnimation { target: countdownText; property: "scale"; to: 1.0; duration: 100 }
            }
        }
    }
}
