import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Effects
import QtCore

import "." // Style.qml
import "components"
import snipper

/*
    TODO:
        - keep gradient or nah?
        - maximize functionality?
        - previous snips?
        - snake_case -> camelCase
*/

ApplicationWindow {
    id: root

    // + x <- drop shadow
    minimumWidth: 512
    minimumHeight: 256
    visible: true

    flags: Qt.Window | Qt.FramelessWindowHint
    color: "transparent"

    background: Rectangle {
        color: Style.bgPrimary
        radius: Style.radius
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.15)

        // gradient: Gradient {
        //     GradientStop { position: 0.0; color: Qt.lighter(Style.bgPrimary, 1.1) }
        //     GradientStop { position: 1.0; color: Qt.darker(Style.bgPrimary, 1.15) }
        // }
    }

    Loader {
        id: selectionCanvasLoader

        anchors.fill: parent
        active: false

        source: "SelectionCanvas.qml"

        Connections {
            target: selectionCanvasLoader.item
            ignoreUnknownSignals: true

            function onStopCapturing() {

                selectionCanvasLoader.active = false;
                root.showNormal();
            }
        }
    }

    Rectangle {
        id: titlebar

        height: 40
        color: "transparent"

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        z: 1 // for resize handles

        FluentTitlebar {
            anchors.fill: parent
        }

        DragHandler {
            target: null
            margin: 8 // for resize handles

            onActiveChanged: if (active) root.startSystemMove()
        }
    }

    Rectangle {
        id: toolbar

        height: 40
        width: Math.min(parent.width * 0.618, 640) // 640px maximum wdith
        anchors.top: titlebar.bottom
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter

        color: Qt.lighter(Style.bgPrimary, 1.1)
        radius: 24
        border.color: Qt.rgba(1, 1, 1, 0.1)

        RowLayout {
            anchors.fill: parent
            spacing: 0

            FluentButton {
                text: "Snip"
                font.pixelSize: 14
                spacing: 8

                icon.source: "qrc:/icons/scissors-cut-fill.svg"
                icon.width: 18
                icon.height: 18
                icon.color: "white"

                topLeftRadius: 24
                bottomLeftRadius: 24
                topRightRadius: 0
                bottomRightRadius: 0

                hoverColor: Qt.darker(Style.accent, 1.1)

                Layout.fillWidth: true
                Layout.preferredWidth: 0

                onClicked: SnipperManager.capture_screenshot(root)
            }

            FluentButton {
                text: "Copy"
                font.pixelSize: 14
                spacing: 8

                icon.source: "qrc:/icons/file-copy-line.svg"
                icon.width: 18
                icon.height: 18
                icon.color: "white"

                topLeftRadius: 0
                bottomLeftRadius: 0
                topRightRadius: 24
                bottomRightRadius: 24

                hoverColor: Qt.darker(Style.accent, 1.1)

                Layout.fillWidth: true
                Layout.preferredWidth: 0
            }
        }
    }

    Connections {
        target: SnipperManager
        function onScreenshot_captured(screenshot_url) {
            selectionCanvasLoader.active = true;
            selectionCanvasLoader.item.screenshot_source = screenshot_url;
        }
    }

    WindowResizeHandlers { z: 2 }
}
