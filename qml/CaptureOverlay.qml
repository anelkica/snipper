import QtQuick
import QtQuick.Window

Window {
    id: root

    visibility: Window.FullScreen
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    property alias image_source: image.source

    Image {
        id: image

        anchors.fill: parent
        cache: false
    }

    Shortcut {
        sequence: "Esc"
        onActivated: Qt.quit()
    }
}
