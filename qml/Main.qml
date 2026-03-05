import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import snipper // SnipperManager, WindowManager

ApplicationWindow {
    id: root

    property int countdown: 0

    minimumWidth: 578
    minimumHeight: 320
    visible: true
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowMinMaxButtonsHint

    color: "transparent"
    Material.theme: Material.Dark
    Material.accent: Material.Purple

    Component.onCompleted: {
        Navigator.setStackView(stackView)
    }

    FontLoader {
        source: "qrc:/icons/lucide/lucide.ttf"
    }

    Shortcut {
        sequence: "Escape"
        enabled: AppState.isPickingColor
        onActivated: AppState.isPickingColor = false
    }

    Shortcut {
        sequence: "Ctrl+R"
        onActivated: WindowManager.requestRaiseAllPins()
    }

    Shortcut {
        sequence: "Ctrl+C"
        onActivated: {
            let page = stackView.currentItem
            if (page && page.triggerImageAnimation)
                page.triggerImageAnimation()

            SnipperManager.requestCopyImageToClipboard(AppState.currentScreenshotUrl)
        }
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
        target: Navigator
        function onPushRequested(url) { stackView.push(url) }
        function onPopRequested() { stackView.pop() }
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

        // cache in temp
        function onCropSaved(croppedImageUrl) {
            AppState.currentScreenshotUrl = croppedImageUrl
            AppState.isCurrentScreenshotPinned = false
            toast.show("Snipped", false)
        }

        function onCropSavedAs(fileUrl) {
            toast.show("Saved", false)
        }

        function onCropCopiedToClipboard() {
            toast.show("Copied to clipboard", false)
        }

        function onErrorOccurred(message) {
            toast.show(message, true)
        }
    }

    Connections {
        target: WindowManager
        function onPinRemoved(imageUrl) {
            if (imageUrl.toString() === AppState.currentScreenshotUrl.toString()) {
                AppState.isCurrentScreenshotPinned = false
                toast.show("Pin removed", false)
            }
        }

        function onPinCreated(pinWindow) {
            toast.show("Pin created", false)
        }

        function onRaisedAllPins(amountOfPins) {
            toast.show("Raised " + amountOfPins + " pin" + (amountOfPins > 1 ? "s" : ""), false)
        }

        function onErrorOccurred(message) {
            toast.show(message, true)
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

                if (Navigator.currentPage !== "pages/PalettePage.qml")
                    AppState.hasUnseenColors = true

                ColorHistory.add(hex)
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

    Toast {
        id: toast
    }

    background: Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Material.backgroundColor

        border.color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1
    }

    // WINDOW CONTENT //

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.visibility === Window.Maximized ? 0 : 1 // make sure there's enough padding for window border
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

        StackView {
            id: stackView
            Layout.fillWidth: true
            Layout.fillHeight: true
            initialItem: "pages/MainPage.qml"
        }
    }

    DragHandler {
        target: null
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        enabled: root.visibility !== Window.Maximized
        onActiveChanged: if (active) root.startSystemMove()
    }

    WindowResizeHandlers {
        visible: root.visibility !== Window.Maximized
    }
}
