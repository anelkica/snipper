import QtQuick
import QtQuick.Controls
import Qt.labs.platform

import snipper

Window {
    id: main_window

    width: 512
    height: 256
    visible: true
    title: qsTr("snipper")

    Component.onCompleted: Snipper.set_main_window(main_window)

    Button {
        text: "Snip!"
        anchors.centerIn: parent

        onClicked: Snipper.start_snipping()
    }

    Loader {
        id: capture_overlay_loader

        active: false;
        source: "CaptureOverlay.qml"
    }

    Connections {
        target: Snipper
        function onScreenshot_captured(image) {
            let image_path = StandardPaths.writableLocation(StandardPaths.TempLocation) + "/screenshot.png";

            capture_overlay_loader.active = true;
            if (!capture_overlay_loader.item) return;

            capture_overlay_loader.item.image_source = image_path;
        }
    }
}
