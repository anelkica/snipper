import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import snipper

/*
    so basically.. resizing causes invisible space around the image (transparent window)
    to negate that, we sync the width and height to the image !!

    it's an ass implementation but it works, with the only issue being a slight jitter after resizing
    bugs:
        resizing but holding still causes a jitter
        slightly blurry image?
*/

Window {
    id: root

    property url source: ""

    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: true

    function resizeWindowToImage() {
        if (image.status !== Image.Ready) return;

        root.width = Math.ceil(image.paintedWidth)
        root.height = Math.ceil(image.paintedHeight)
    }

    onWidthChanged: snapTimer.restart()
    onHeightChanged: snapTimer.restart()

    Timer {
        id: snapTimer
        interval: 250 // Wait 250ms after the last resize event to snap
        repeat: false
        onTriggered: root.resizeWindowToImage()
    }


    HoverHandler { cursorShape: Qt.OpenHandCursor }

    DragHandler {
        target: null
        onActiveChanged: {
            cursorShape = active ? Qt.ClosedHandCursor : Qt.OpenHandCursor;
            root.startSystemMove();
        }
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: root.close()
    }

    Image {
        id: image
        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true

        onStatusChanged: {
            if (status !== Image.Ready) return

            // for comedically large crops, the pinned image gets limited to 50% of screen
            let maxWidth = Screen.desktopAvailableWidth * 0.5
            let maxHeight = Screen.desktopAvailableHeight * 0.5
            let scale = Math.min(1.0, maxWidth / implicitWidth, maxHeight / implicitHeight)

            root.width = Math.ceil(implicitWidth * scale)
            root.height = Math.ceil(implicitHeight * scale)
        }
    }

    WindowResizeHandlers { z: 1; anchors.fill: parent }
}
