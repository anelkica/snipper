import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import snipper

Rectangle {
    id: toast

    parent: Overlay.overlay
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottomMargin: 20

    width: toastLayout.implicitWidth + 32
    height: 36
    radius: Style.radius
    color: Qt.lighter(Style.bgPrimary, 1.2)
    border.color: Style.windowBorder
    border.width: 1

    visible: opacity > 0
    opacity: 0

    function show(message, isError) {
        toastLabel.text = message
        toastLabel.color = isError ? Qt.lighter(Style.failure, 1.3) : Qt.lighter(Style.success, 1.3)
        toastAnimation.restart()
    }

    RowLayout {
        id: toastLayout
        anchors.centerIn: parent
        spacing: 8

        Label {
            id: toastLabel
            font.italic: true
            font.letterSpacing: 1
            Layout.alignment: Qt.AlignVCenter
        }
    }

    SequentialAnimation on opacity {
        id: toastAnimation
        running: false
        NumberAnimation { to: 1; duration: 200; easing.type: Easing.OutCubic }
        PauseAnimation { duration: 2000 }
        NumberAnimation { to: 0; duration: 800; easing.type: Easing.InCubic }
    }
}
