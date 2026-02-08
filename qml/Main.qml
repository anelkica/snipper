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

    property url currentScreenshotUrl

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

    Connections {
        target: SnipperManager

        // signals in snipper_manager.h btw
        function onScreenshotCaptured(screenshotUrl) {
            root.currentScreenshotUrl = screenshotUrl;

            selectionCanvasLoader.active = true;
            selectionCanvasLoader.item.screenshotSource = screenshotUrl;
        }

        function onCropCopiedToClipboard() {
            feedbackLabel.pulse("Copied to clipboard", false);
            titlebar.statusColor = Style.success;
        }

        function onCropSaved(croppedImageUrl) {
            feedbackLabel.pulse("Saved crop", false);
            titlebar.statusColor = Style.success;
        }

        function onErrorOccurred(message) {
            console.error("ERROR: ", message);
            feedbackLabel.pulse(message, true);
            titlebar.statusColor = Style.failure;
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
                selectionCanvasLoader.active = false;
                root.showNormal();
            }
        }
    }

    Rectangle {
        id: titlebarContainer

        height: 40
        color: "transparent"

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        z: 1 // for resize handles

        FluentTitlebar {
            id: titlebar
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
        anchors.top: titlebarContainer.bottom
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

                onClicked: SnipperManager.requestCaptureScreenshot(root)
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

                onClicked: SnipperManager.requestCopyToClipboard(currentScreenshotUrl);
            }
        }
    }

    Label {
        id: feedbackLabel

        text: "Saved.."
        font.italic: true
        font.letterSpacing: 1
        color: "#3CB371"
        opacity: 0
        anchors.top: toolbar.bottom;
        anchors.topMargin: 8
        anchors.horizontalCenter: toolbar.horizontalCenter

        function pulse(message, isError) {
            feedbackLabel.text = message;
            feedbackLabel.color = isError ? Qt.lighter(Style.failure, 1.2) : Qt.lighter(Style.success, 1.2);

            feedbackAnimation.restart();
        }

        SequentialAnimation on opacity {
            id: feedbackAnimation
            running: false;

            NumberAnimation { to: 1; duration: 200; easing.type: Easing.OutCubic }
            PauseAnimation { duration: 2000 }
            NumberAnimation { to: 0; duration: 800; easing.type: Easing.InCubic }
        }
    }

    WindowResizeHandlers { z: 2 }
}
