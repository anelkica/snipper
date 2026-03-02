import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import snipper

Item {
    id: palettePage

    Item {
        anchors.centerIn: parent
        visible: ColorHistory.colors.length === 0

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8

            Label {
                text: Icons.pipette
                font.family: Icons.family
                font.pixelSize: 32
                color: Qt.rgba(1, 1, 1, 0.15)
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "Pick colors to save them here"
                font.pixelSize: 12
                color: Qt.rgba(1, 1, 1, 0.3)
                font.letterSpacing: 0.5
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

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

            BaseButton {
                text: "Copy JSON"
                flat: true
                implicitHeight: 42
                onClicked: {
                    if (ColorHistory.colors.length < 0) return;

                    let json = ColorHistory.colorsToJsonString()
                    SnipperManager.requestCopyTextToClipboard(json)
                }
            }

            BaseButton {
                text: "Clear"
                flat: true
                visible: true //ColorHistory.colors.length > 0
                implicitHeight: 42
                Material.foreground: Material.color(Material.Red, Material.Shade300)
                onClicked: ColorHistory.clear()
            }
        }

        ListView {
            id: carousel
            Layout.fillWidth: true
            orientation: ListView.Horizontal
            model: ColorHistory.colors
            spacing: 8

            ScrollBar.horizontal: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            delegate: Item {
                width: 72
                height: 72

                required property string modelData
                required property int index

                Rectangle {
                    id: swatch
                    anchors.fill: parent
                    anchors.margins: 2 // safe zone so scale() doesn't squish border
                    anchors.bottomMargin: 16
                    radius: 4
                    color: modelData
                    border.color: Qt.rgba(1, 1, 1, 0.1)
                    border.width: 2

                    scale: tapHandler.pressed ? 0.92 : hoverHandler.hovered ? 1.05 : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                    }

                    TapHandler {
                        id: tapHandler
                        cursorShape: Qt.PointingHandCursor
                        onTapped: {
                            SnipperManager.requestCopyTextToClipboard(modelData)
                        }
                    }

                    HoverHandler { id: hoverHandler }
                }

                Label {
                    anchors.top: swatch.bottom
                    anchors.topMargin: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: modelData.toUpperCase()
                    color: Style.textPrimary
                    font.pixelSize: 10
                    font.family: "Monospace"
                    font.letterSpacing: 0.5
                }
            }
        }
    }
}
