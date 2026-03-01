import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import snipper // SnipperManager, WindowManager

ApplicationWindow {
    id: root

    property int countdown: 0

    minimumWidth: 512
    minimumHeight: 256
    visible: true
    flags: Qt.Window | Qt.FramelessWindowHint

    color: "transparent"
    Material.theme: Material.Dark

    FontLoader {
        source: "qrc:/icons/lucide/lucide.ttf"
    }

    Connections {
        target: AppState
        function onIsSnippingChanged() {
            if (!AppState.isSnipping) return

            if (AppSettings.timerDelay > 0) {
                root.showMinimized()

                root.countdown = AppSettings.timerDelay
                countdownLoader.active = true
                countdownLoader.item.countdown = AppSettings.timerDelay

                countdownTimer.start()
            } else {
                SnipperManager.requestCaptureScreenshot(root)
            }
        }
    }

    Connections {
        target: SnipperManager
        function onScreenshotCaptured(screenshotUrl, currentScreen) {
            if (snippingOverlayLoader.active) return;

            AppState.currentScreenshotUrl = "";
            snippingOverlayLoader.active = true
            let overlay = snippingOverlayLoader.item
            if (overlay) {
                overlay.screen = currentScreen
                AppState.currentScreenshotUrl = screenshotUrl
            }
        }

        function onCropSaved(croppedImageUrl) {
            AppState.currentScreenshotUrl = croppedImageUrl
        }
    }

    // moves the color picker window smoothly, matching the Hz of the monitor
    FrameAnimation {
        running: AppState.isPickingColor

        onTriggered: {
            let colorPicker = colorPickerLoader.item;
            if (!colorPicker) return;

            let data = SnipperManager.requestColorAtCursor()
            if (!data.success) return;

            // this centers the rascal to the cursor
            colorPicker.x = data.globalCursorPosition.x - (colorPicker.width / 2)
            colorPicker.y = data.globalCursorPosition.y - (colorPicker.height / 2)

            colorPicker.pickerColor = data.pickedColor
            colorPicker.colorName = data.hex
        }
    }

    // if timer mode is enabled, starts a visible countdown timer on the screen
    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        onTriggered: {
            root.countdown--
            countdownLoader.item.countdown = countdown

            if (root.countdown <= 0) {
                stop()

                countdownLoader.active = false
                SnipperManager.requestCaptureScreenshot(root)
            }
        }
    }

    Loader {
        id: countdownLoader
        active: false
        source: "components/overlays/CountdownOverlay.qml"
    }

    Loader {
        id: colorPickerLoader
        active: AppState.isPickingColor
        source: "components/overlays/ColorPickerOverlay.qml"

        Connections {
            target: colorPickerLoader.item
            ignoreUnknownSignals: true

            function onColorAccepted(hex) {
                AppState.isPickingColor = false

                //let success = SnipperManager.requestCopyTextToClipboard(hex)
                //if (!success) return;

                ColorHistory.add(hex)
                //notify(`Added ${hex} to color palette`)
            }
        }
    }

    Loader {
        id: snippingOverlayLoader
        active: false
        source: "components/overlays/SnippingOverlay.qml"

        Connections {
            target: snippingOverlayLoader.item
            ignoreUnknownSignals: true

            function onStopCapturing() {
                AppState.isSnipping = false
                snippingOverlayLoader.active = false
                root.showNormal()
            }
        }
    }

    background: Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Material.backgroundColor

        border.color: Qt.rgba(1, 1, 1, 0.04)
        border.width: 1
    }

    // WINDOW CONTENT //

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 1
        spacing: 0

        Titlebar {
            id: titlebar
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            height: 8
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.1) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Material.backgroundColor

            Image {
                id: previewImage
                anchors.centerIn: parent
                source: AppState.currentScreenshotUrl
                fillMode: Image.PreserveAspectFit
                width: parent.width - 32
                height: parent.height - 32
                visible: AppState.currentScreenshotUrl !== ""

                // hover handler wrapper to make sure hover only procs on image hover
                Item {
                    anchors.centerIn: parent
                    width: previewImage.paintedWidth
                    height: previewImage.paintedHeight

                    HoverHandler {
                        id: imageHover
                    }
                }
            }

            // floating action bar for image
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: previewImage.bottom
                anchors.bottomMargin: 16

                visible: AppState.currentScreenshotUrl !== ""
                opacity: imageHover.hovered || barHover.hovered ? 1.0 : 0.0

                width: actionRow.implicitWidth + 16
                height: 36
                radius: 4
                color: Material.color(Material.Grey, Material.Shade900)
                border.color: Qt.rgba(1, 1, 1, 0.12)
                border.width: 1

                HoverHandler {
                    id: barHover
                }

                Behavior on opacity {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                RowLayout {
                    id: actionRow
                    anchors.centerIn: parent
                    spacing: 2

                    WindowToolButton {
                        text: Icons.copy
                        btnRadius: 4
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 28
                        // onClicked:
                    }

                    Rectangle {
                        width: 1; height: 16
                        color: Qt.rgba(1, 1, 1, 0.12)
                        Layout.alignment: Qt.AlignVCenter
                    }

                    WindowToolButton {
                        text: Icons.pin
                        btnRadius: 4
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 28
                        // onClicked:
                    }

                    WindowToolButton {
                        text: Icons.save
                        btnRadius: 4
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 28
                        // onClicked:
                    }
                }
            }
        }
    }

    DragHandler {
        target: null
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onActiveChanged: if (active) root.startSystemMove()
    }


    WindowResizeHandlers {}
}
