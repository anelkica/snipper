import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Dialogs
import QtCore

import "components"
import snipper // SnipperManager, WindowManager

ApplicationWindow {
    id: root

    property url currentScreenshotUrl
    property bool isPickingColor: false

    minimumWidth: 512
    minimumHeight: 256
    visible: true
    flags: Qt.Window | Qt.FramelessWindowHint
    color: "transparent"

    onClosing: Qt.quit()

    background: Rectangle {
        color: Style.bgPrimary
        radius: Style.radius
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.15)

        // gradient: Gradient {
        //      GradientStop { position: 0.0; color: Qt.lighter(Style.bgPrimary, 1.1) }
        //      GradientStop { position: 1.0; color: Qt.darker(Style.bgPrimary, 1.15) }
        // }
    }

    Shortcut {
        sequence: "Escape"
        context: Qt.ApplicationShortcut

        onActivated: {
            isPickingColor = !isPickingColor
        }
    }

    Shortcut {
        sequence: "CTRL+T"
        context: Qt.ApplicationShortcut

        onActivated: WindowManager.requestRaiseAllPins();
    }

    // moves the color picker window smoothly, matching the Hz of the monitor
    FrameAnimation {
        running: isPickingColor

        onTriggered: {
            let colorPicker = colorPickerLoader.item;
            if (!colorPicker) return;

            let data = SnipperManager.requestColorAtCursor()
            if (!data.success) return;

            colorPicker.x = data.globalCursorPosition.x + 15
            colorPicker.y = data.globalCursorPosition.y + 15

            colorPicker.pickerColor = data.pickedColor
            colorPicker.colorName = data.hex
        }
    }

    Connections {
        target: SnipperManager

        function onScreenshotCaptured(screenshotUrl, currentScreen) {
            root.currentScreenshotUrl = screenshotUrl;

            selectionCanvasLoader.active = true;

            let canvas = selectionCanvasLoader.item;
            if (canvas) {
                canvas.screen = currentScreen;
                canvas.currentScreenshotUrl = screenshotUrl;
            }
        }

        function onCropCopiedToClipboard() {
            feedbackLabel.pulse("Copied to clipboard", false);
            titlebar.statusColor = Style.success;
        }

        function onCropSaved(croppedImageUrl) {
            feedbackLabel.pulse("Cached crop", false);
            titlebar.statusColor = Style.success;
            currentScreenshotUrl = croppedImageUrl;
            preview.source = croppedImageUrl;
        }

        function onErrorOccurred(message) {
            feedbackLabel.pulse(message, true);
            titlebar.statusColor = Style.failure;
        }
    }

    Connections {
        target: WindowManager
        function onErrorOccurred(message) {
            feedbackLabel.pulse(message, true);
            titlebar.statusColor = Style.failure;
        }

        function onRaisedAllPins(amountOfPins) {
            feedbackLabel.pulse(`Pins raised: ${amountOfPins}`, false);
            titlebar.statusColor = Style.success;
        }
    }

    FileDialog {
        id: saveCropDialog
        title: "Save Snip As"
        fileMode: FileDialog.SaveFile
        nameFilters: ["Image files (*.png *.jpg)", "All files (*)"]
        defaultSuffix: "png"

        onAccepted: {
            SnipperManager.requestSaveCropAs(root.currentScreenshotUrl, saveCropDialog.selectedFile)
            feedbackLabel.pulse("Saved!", false);
            titlebar.statusColor = Style.success;
        }
    }

    Loader {
        id: colorPickerLoader
        active: root.isPickingColor
        source: "components/ColorPickerDisplay.qml"

        Connections {
            target: colorPickerLoader.item
            ignoreUnknownSignals: true

            function onColorPicked(globalCursorPosition, color, hexColor) {
                let colorPicker = colorPickerLoader.item

                if (!colorPicker || !root.isPickingColor) return;

                colorPicker.updateColorPicker(globalCursorPosition, hexColor, color)
            }
        }
    }

    Loader {
        id: selectionCanvasLoader
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

        // -- Titlebar -- //
        Titlebar { id: titlebar }

         // -- Toolbar (under Titlebar) -- //
        MainToolbar { id: toolbar }

         // -- Status Text under Toolbar -- //
        Label {
            id: feedbackLabel
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 8
            text: "Saved.."
            font.italic: true; font.letterSpacing: 1
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

         // -- Preview Image after Snipping -- //
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 20

            Image {
                id: preview
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: root.currentScreenshotUrl
                smooth: true; mipmap: true; antialiasing: true
            }
        }
    }

    WindowResizeHandlers { z: 2 }
}
