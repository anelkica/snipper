import QtQuick
import snipper

/*
    negative offset method :3

    layer 1
        - renders the darkened image of a fullscreen screenshot
    layer 2
        - creates a draggable selection box that acts like a window or hole
        - any visual effects are placed inside here (zooming, borders)
    layer 3
        - a clear image inside the selection box
        - it shifts in the opposite direction of the box

        - the zooming is done using this formula on an image:
        - x = -(selectionBox_center * zoomLevel) + (selectionBox_center)

    !! potential negative: rendering two images :p !!
*/

Window {
    id: root

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    visibility: Window.FullScreen
    color: "transparent"

    property string currentScreenshotUrl: ""
    property rect selection: Qt.rect(0, 0, 0, 0)
    property point startPoint

    property real zoomLevel: 1.0
    property bool isDragging: false

    signal stopCapturing()

    Shortcut {
        sequence: "Esc"
        onActivated: root.stopCapturing()
    }

    // -- LAYER 1 -> DARKENED IMAGE
    Image {
        id: background

        anchors.fill: parent
        source: root.currentScreenshotUrl
        sourceSize.width: Screen.width * Screen.devicePixelRatio // without dpr, the screenshot is blurry
        sourceSize.height: Screen.height * Screen.devicePixelRatio
        cache: false

        // dimming
        Rectangle {
            anchors.fill: parent
            color: "#95000000"
        }
    }

    // -- LAYER 2 -> SELECTION BOX
    Rectangle {
        id: selectionBox

        x: root.selection.x
        y: root.selection.y
        width: root.selection.width
        height: root.selection.height
        color: "transparent"
        visible: width > 0
        clip: true

        // border
        Rectangle {
            id: selectionBoxBorder

            anchors.fill: parent
            color: "transparent"
            border.color: "white"
            border.width: 1

            z: 1
        }

        // LAYER 3 -> CLEAN IMAGE
        Image {
            source: background.source

            width: background.width * root.zoomLevel
            height: background.height * root.zoomLevel

            x: -((selectionBox.x + selectionBox.width / 2) * root.zoomLevel) + (selectionBox.width / 2)
            y: -((selectionBox.y + selectionBox.height / 2) * root.zoomLevel) + (selectionBox.height / 2)

            smooth: false
        }
    }

    // DRAGGING / ZOOMING
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.CrossCursor
        hoverEnabled: true

        onPressed: (mouse) => {
            root.isDragging = true
            root.startPoint = Qt.point(mouse.x, mouse.y)
            root.selection = Qt.rect(mouse.x, mouse.y, 0, 0)
        }

        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0)
                root.zoomLevel = Math.min(root.zoomLevel + 0.25, 5.0)
            else
                root.zoomLevel = Math.max(root.zoomLevel - 0.25, 1.0)
        }

        onPositionChanged: (mouse) => {
            if (!pressed) return;

            root.selection = Qt.rect(
                Math.min(mouse.x, root.startPoint.x),
                Math.min(mouse.y, root.startPoint.y),
                Math.abs(mouse.x - root.startPoint.x),
                Math.abs(mouse.y - root.startPoint.y)
            );
        }

        onReleased: {
            function getPhysicalCropRect() {
                const { x, y, width, height } = root.selection;
                const { zoomLevel, Screen } = root;
                const dpr = Screen.devicePixelRatio;

                const realW = width / zoomLevel;
                const realH = height / zoomLevel;

                const realX = (x + width / 2) - (realW / 2);
                const realY = (y + height / 2) - (realH / 2);

                return Qt.rect(
                    Math.round(realX * dpr),
                    Math.round(realY * dpr),
                    Math.round(realW * dpr),
                    Math.round(realH * dpr)
                );
            }

            let croppedRect = getPhysicalCropRect();

            SnipperManager.requestSaveCroppedRegion(root.currentScreenshotUrl, croppedRect, root.zoomLevel);

            root.isDragging = false;
            root.zoomLevel = 1.0;
            root.stopCapturing();
        }
    }
}
