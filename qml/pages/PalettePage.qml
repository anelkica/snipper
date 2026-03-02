import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import snipper

Item {
    id: palettePage

    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 12
        anchors.topMargin: 0
        spacing: 0

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: "Color Palette"
                font.pixelSize: 16
                font.letterSpacing: 1
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            Button {
                text: "Copy JSON"
                flat: true
                visible: true //ColorHistory.colors.length > 0
                implicitHeight: 42
                onClicked: {
                    let json = ColorHistory.colorsToJsonString()
                    SnipperManager.requestCopyTextToClipboard(json)
                }
            }

            Button {
                text: "Clear"
                flat: true
                visible: true //ColorHistory.colors.length > 0
                implicitHeight: 42
                Material.foreground: Material.color(Material.Red, Material.Shade300)
                onClicked: ColorHistory.clear()
            }
        }
    }
}
