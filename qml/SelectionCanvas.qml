import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
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
    id: canvasRoot

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    visibility: Window.FullScreen
    color: "transparent"

    property string currentScreenshotUrl: ""
    property rect selection: Qt.rect(0, 0, 0, 0)
    property point startPoint

    property alias selectionType: selectionCanvasToolbar.selectionType

    property real zoomLevel: 1.0
    property bool isDragging: false

    signal stopCapturing()

    Shortcut {
        sequence: "Esc"
        onActivated: {
            canvasRoot.stopCapturing()
        }
    }

    SelectionCanvasToolbar {
        id: selectionCanvasToolbar

        isDragging: canvasRoot.isDragging
        onStopCapturing: canvasRoot.stopCapturing()
    }

    // -- LAYER 1 -> DARKENED IMAGE
    Image {
        id: background

        anchors.fill: parent
        source: canvasRoot.currentScreenshotUrl
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

        x: canvasRoot.selection.x
        y: canvasRoot.selection.y
        width: canvasRoot.selection.width
        height: canvasRoot.selection.height
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

            width: background.width * canvasRoot.zoomLevel
            height: background.height * canvasRoot.zoomLevel

            x: -((selectionBox.x + selectionBox.width / 2) * canvasRoot.zoomLevel) + (selectionBox.width / 2)
            y: -((selectionBox.y + selectionBox.height / 2) * canvasRoot.zoomLevel) + (selectionBox.height / 2)

            smooth: false
        }
    }

    // DRAGGING / ZOOMING
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.CrossCursor
        hoverEnabled: true

        onPressed: (mouse) => {
            if (selectionCanvasToolbar.selectionType === "fullscreen") return;

            canvasRoot.isDragging = true
            canvasRoot.startPoint = Qt.point(mouse.x, mouse.y)
            canvasRoot.selection = Qt.rect(mouse.x, mouse.y, 0, 0)
        }

        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0)
                canvasRoot.zoomLevel = Math.min(canvasRoot.zoomLevel + 0.25, 5.0)
            else
                canvasRoot.zoomLevel = Math.max(canvasRoot.zoomLevel - 0.25, 1.0)
        }

        onPositionChanged: (mouse) => {
            if (!pressed) return;

            canvasRoot.selection = Qt.rect(
                Math.min(mouse.x, canvasRoot.startPoint.x),
                Math.min(mouse.y, canvasRoot.startPoint.y),
                Math.abs(mouse.x - canvasRoot.startPoint.x),
                Math.abs(mouse.y - canvasRoot.startPoint.y)
            );
        }

        onReleased: {
            function save(croppedRect) {
                SnipperManager.requestSaveCroppedRegion(canvasRoot.currentScreenshotUrl, croppedRect, canvasRoot.zoomLevel)
                canvasRoot.isDragging = false
                canvasRoot.zoomLevel = 1.0
                canvasRoot.stopCapturing()
            }

            function getPhysicalCropRect() {
                const { x, y, width, height } = canvasRoot.selection;
                const { zoomLevel, Screen } = canvasRoot;
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


            if (selectionCanvasToolbar.selectionType === "fullscreen") {
                save(Qt.rect(0, 0, Screen.width * Screen.devicePixelRatio, Screen.height * Screen.devicePixelRatio))
                return
            }

            const minSize = 10
            if (canvasRoot.selection.width < minSize || canvasRoot.selection.height < minSize) {
                canvasRoot.selection = Qt.rect(0, 0, 0, 0)
                canvasRoot.isDragging = false
                return
            }

            save(getPhysicalCropRect())
        }
    }
}
