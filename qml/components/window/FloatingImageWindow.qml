import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Effects
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
    property bool clickThrough: false

    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: true

    onClickThroughChanged: {
        if (clickThrough)
            root.flags |= Qt.WindowTransparentForInput // adds click through flag, keeps previous flags
        else
            root.flags &= ~Qt.WindowTransparentForInput // removes the click through flag specifically
    }

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
        onTapped: contextMenu.popup()
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (event) => {
            let delta = event.angleDelta.y > 0 ? 0.05 : -0.05
            root.opacity = Math.max(0.2, Math.min(1.0, root.opacity + delta)) // min 0.2 -> max 1.0 opacity
        }
    }

    Rectangle {
        id: backgroundCanvas
        anchors.fill: parent
        color: "transparent"

        // https://doc.qt.io/qt-6/qml-qtquick-controls-contextmenu.html
        ContextMenu.menu: Menu {
            id: contextMenu
            popupType: Menu.Native

            MenuItem {
                text: root.flags & Qt.WindowStaysOnTopHint ? "Unpin from Top" : "Pin to Top"
                onTriggered: root.flags ^= Qt.WindowStaysOnTopHint
            }

            MenuItem {
                text: root.clickThrough ? "Disable Click-Through" : "Enable Click-Through"
                onTriggered: root.clickThrough = !root.clickThrough
            }

            MenuSeparator {}

            MenuItem {
                text: "Close"
                onTriggered: WindowManager.requestRemovePinWindow(source)
            }
        }

        Image {
            id: image
            anchors.fill: parent
            anchors.margins: 0
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

        // -- IMAGE BORDER -- //
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.width: 1
            border.color: root.clickThrough ? Style.locked : Qt.rgba(1, 1, 1, 0.55)
            z: 1
        }
    }

    WindowResizeHandlers { z: 1; anchors.fill: parent }
}
