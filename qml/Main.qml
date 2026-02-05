import QtQuick
import QtQuick.Controls
import QtCore

import snipper

ApplicationWindow {
    id: root

    width: 400
    height: 250
    visible: true

    title: "snipper"

    Component.onCompleted: SnipperManager.set_main_window(root)

    Loader {
        id: selection_canvas_loader

        anchors.fill: parent
        active: false

        source: "SelectionCanvas.qml"

        Connections {
            target: selection_canvas_loader.item
            ignoreUnknownSignals: true

            function onStopCapturing() {
                console.log("Deactivating Loader and cleaning RAM...");

                selection_canvas_loader.active = false;
                root.showNormal();
            }
        }


    }

    Button {
        anchors.centerIn: parent
        text: "New Snip"
        onClicked: SnipperManager.capture_screenshot()
    }

    Connections {
        target: SnipperManager
        function onScreenshot_captured(image) {
            console.log("Image received in QML!");

            let screenshot_file_path = StandardPaths.writableLocation(StandardPaths.TempLocation) + "/screenshot.png";

            selection_canvas_loader.active = true;
            selection_canvas_loader.item.screenshot_source = screenshot_file_path;
        }
    }
}
