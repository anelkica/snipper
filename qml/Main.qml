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

    Loader {
        id: selection_canvas_loader

        anchors.fill: parent
        active: false

        source: "SelectionCanvas.qml"

        Connections {
            target: selection_canvas_loader.item
            ignoreUnknownSignals: true

            function onStopCapturing() {
                selection_canvas_loader.active = false;


                root.showNormal();
            }
        }


    }

    Button {
        anchors.centerIn: parent
        text: "New Snip"
        onClicked: SnipperManager.capture_screenshot(root)
    }

    Connections {
        target: SnipperManager
        function onScreenshot_captured(screenshot_url) {
            selection_canvas_loader.active = true;
            selection_canvas_loader.item.screenshot_source = screenshot_url;
        }
    }
}
