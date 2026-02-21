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

    property int countdown: 0

    minimumWidth: 512
    minimumHeight: 256
    visible: true
    flags: Qt.Window | Qt.FramelessWindowHint
    color: "transparent"

    onClosing: Qt.quit()

    function notify(msg, isError = false) {
        toast.show(msg, isError)
        titlebar.statusColor = isError ? Style.failure : Style.success
    }

    function snipClicked() {
        if (AppState.timerDelay > 0) {
            root.showMinimized()

            countdown = AppState.timerDelay
            countdownLoader.active = true
            countdownLoader.item.countdown = AppState.timerDelay

            countdownTimer.start()
        } else {
            SnipperManager.requestCaptureScreenshot(root)
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

    background: Rectangle {
        color: Style.bgPrimary
        radius: Style.radius
        border.width: 1
        border.color: Style.windowBorder
        anchors.fill: parent
        anchors.margins: 2
    }

    Shortcut {
        sequence: "Escape"
        context: Qt.ApplicationShortcut

        onActivated: {
            AppState.isPickingColor = !AppState.isPickingColor
        }
    }

    Shortcut {
        sequence: "CTRL+R"
        context: Qt.ApplicationShortcut

        onActivated: WindowManager.requestRaiseAllPins();
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

    Connections {
        target: SnipperManager

        function onScreenshotCaptured(screenshotUrl, currentScreen) {
            if (selectionCanvasLoader.active) return;

            AppState.currentScreenshotUrl = "";
            selectionCanvasLoader.active = true
            let canvas = selectionCanvasLoader.item
            if (canvas) {
                canvas.screen = currentScreen
                AppState.currentScreenshotUrl = screenshotUrl
            }
        }

        function onCropCopiedToClipboard() {
            notify("Copied to clipboard")
        }

        function onCropSaved(croppedImageUrl) {
            notify("Snip cached")
            AppState.currentScreenshotUrl = croppedImageUrl
        }

        function onErrorOccurred(message) {
            notify(message, true)
        }
    }

    Connections {
        target: WindowManager

        function onErrorOccurred(message) {
            notify(message, true)
        }

        function onRaisedAllPins(amountOfPins) {
            notify(`Reset pins: ${amountOfPins}`)
        }
    }

    FileDialog {
        id: saveCropDialog
        title: "Save Snip As"
        fileMode: FileDialog.SaveFile
        nameFilters: ["Image files (*.png *.jpg)", "All files (*)"]
        defaultSuffix: "png"

        onAccepted: {
            SnipperManager.requestSaveCropAs(AppState.currentScreenshotUrl, saveCropDialog.selectedFile)
            notify("Saved snip")
        }
    }

    Loader {
        id: countdownLoader
        active: false
        source: "components/CountdownOverlay.qml"
    }

    Loader {
        id: colorPickerLoader
        active: AppState.isPickingColor
        source: "components/ColorPickerDisplay.qml"

        Connections {
            target: colorPickerLoader.item
            ignoreUnknownSignals: true

            function onColorAccepted(hex) {
                AppState.isPickingColor = false

                //let success = SnipperManager.requestCopyTextToClipboard(hex)
                //if (!success) return;

                ColorHistory.add(hex)
                notify(`Added ${hex} to color palette`)
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
                selectionCanvasLoader.active = false
                root.showNormal()
            }
        }
    }

    Toast { id: toast }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 2
        spacing: 0

        Titlebar { id: titlebar }

        StackView {
            id: stackView
            Layout.fillWidth: true
            Layout.fillHeight: true
            initialItem: "pages/MainPage.qml"

            onCurrentItemChanged: {
                if (!currentItem) return;

                // map of signal name to root handler
                const connections = {
                    "snipClicked":      root.snipClicked,
                    "toastRequested":   (msg, isError) => notify(msg, isError)
                }

                for (const [signal, handler] of Object.entries(connections)) {
                    if (currentItem[signal])
                        currentItem[signal].connect(handler)
                }
            }
        }
    }

    AppButton {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 12
        icon.source: stackView.depth > 1 ? "qrc:/icons/arrow-left-s-line.svg" : "qrc:/icons/palette-line.svg"
        icon.width: 18; icon.height: 18; icon.color: "white"
        onClicked: {
            if (stackView.depth > 1)
                stackView.pop()
            else
                stackView.push("pages/PalettePage.qml")
        }
    }

    WindowResizeHandlers { z: 2 }
}
