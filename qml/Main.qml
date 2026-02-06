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

        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.lighter(Style.bgPrimary, 1.1) }
            GradientStop { position: 1.0; color: Qt.darker(Style.bgPrimary, 1.15) }
        }
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
                console.log("STOP ITTT");

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

    // content
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12

        Text {
            Layout.alignment: Qt.AlignHCenter

            text: "Ready to Snip!"
            color: Style.textSecondary
            font.weight: Font.Medium
            font.pixelSize: 18
        }

        FluentButton {
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: parent.width * 0.75
            text: "New"

            backgroundColor: Style.accent
            hoverColor: Style.accentHover

            onClicked: SnipperManager.capture_screenshot(root)
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
