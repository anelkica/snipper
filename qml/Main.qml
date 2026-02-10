import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Dialogs
import QtCore

import "." // Style.qml
import "components"
import snipper // SnipperManager, WindowManager

/*
    TODO:
        - keep gradient or nah?
        - maximize functionality?
        - previous snips?
*/

ApplicationWindow {
    id: root

    property url currentScreenshotUrl

    minimumWidth: 512
    minimumHeight: 256
    visible: true

    flags: Qt.Window | Qt.FramelessWindowHint
    color: "transparent"

    onClosing: Qt.quit() // to kill all leftover windows

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
            selectionCanvasLoader.item.currentScreenshotUrl = screenshotUrl;
        }

        function onCropCopiedToClipboard() {
            feedbackLabel.pulse("Copied to clipboard", false);
            titlebar.statusColor = Style.success;
        }

        function onCropSaved(croppedImageUrl) {
            feedbackLabel.pulse("Saved crop", false);
            titlebar.statusColor = Style.success;

            currentScreenshotUrl = croppedImageUrl
            preview.source = croppedImageUrl
        }

        function onErrorOccurred(message) {
            console.error("ERROR: ", message);
            feedbackLabel.pulse(message, true);
            titlebar.statusColor = Style.failure;
        }
    }

    Connections {
        target: WindowManager

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

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: titlebarContainer
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "transparent"
            z: 1

            Titlebar {
                id: titlebar
                anchors.fill: parent
            }

            DragHandler {
                target: null
                margin: 8
                onActiveChanged: if (active) root.startSystemMove()
            }
        }

        Rectangle {
            id: toolbar
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 16
            Layout.preferredHeight: 40
            Layout.preferredWidth: Math.min(parent.width * 0.8, 640)

            color: Qt.lighter(Style.bgPrimary, 1.1)
            radius: 24
            border.color: Qt.rgba(1, 1, 1, 0.1)

            RowLayout {
                anchors.fill: parent
                spacing: 0

                SnipperButton {
                    text: "Snip"
                    font.pixelSize: 14

                    icon.source: "qrc:/icons/scissors-cut-fill.svg"
                    icon.width: 18
                    icon.height: 18
                    icon.color: "white"

                    radius: 0
                    topLeftRadius: 24
                    bottomLeftRadius: 24

                    hoverColor: Qt.darker(Style.accent, 1.1)
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0

                    onClicked: SnipperManager.requestCaptureScreenshot(root)
                }

                SnipperButton {
                    text: "Copy"
                    font.pixelSize: 14

                    icon.source: "qrc:/icons/file-copy-line.svg"
                    icon.width: 18
                    icon.height: 18
                    icon.color: "white"

                    radius: 0

                    hoverColor: Qt.darker(Style.accent, 1.1)
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0

                    onClicked: SnipperManager.requestCopyToClipboard(currentScreenshotUrl)
                }

                SnipperButton {
                    text: "Pin"
                    font.pixelSize: 14

                    icon.source: "qrc:/icons/pushpin-line.svg"
                    icon.width: 18
                    icon.height: 18
                    icon.color: "white"

                    radius: 0

                    hoverColor: Qt.darker(Style.accent, 1.1)
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0

                    onClicked: WindowManager.requestCreatePinWindow(currentScreenshotUrl)
                }

                SnipperButton {
                    text: "Save"
                    font.pixelSize: 14

                    icon.source: "qrc:/icons/save-3-fill.svg"
                    icon.width: 18
                    icon.height: 18
                    icon.color: "white"

                    radius: 0
                    topRightRadius: 24
                    bottomRightRadius: 24

                    hoverColor: Qt.darker(Style.accent, 1.1)
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0

                    onClicked: {}
                }
            }
        }

        Label {
            id: feedbackLabel
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 8

            text: "Saved.."
            font.italic: true
            font.letterSpacing: 1
            color: "#3CB371"
            opacity: 0

            function pulse(message, isError) {
                feedbackLabel.text = message;
                feedbackLabel.color = isError ? Qt.lighter(Style.failure, 1.2) : Qt.lighter(Style.success, 1.2);
                feedbackAnimation.restart();
            }

            SequentialAnimation on opacity {
                id: feedbackAnimation
                running: false
                NumberAnimation { to: 1; duration: 200; easing.type: Easing.OutCubic }
                PauseAnimation { duration: 2000 }
                NumberAnimation { to: 0; duration: 800; easing.type: Easing.InCubic }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 20

            Image {
                id: preview
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: root.currentScreenshotUrl

                smooth: true
                mipmap: true
                antialiasing: true
            }
        }
    }


    WindowResizeHandlers { z: 2 }
}
