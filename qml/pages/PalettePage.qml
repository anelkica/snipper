import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import snipper

Item {
    id: palettePage

    signal toastRequested(string msg, bool isError)

    // -- header pinned to top --
    RowLayout {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        height: 40

        Label {
            text: "Color Palette"
            color: Style.textPrimary
            font.pixelSize: 16
            font.letterSpacing: 1
            Layout.fillWidth: true
        }

        Rectangle {
            visible: ColorHistory.colors.length > 0
            height: 32
            width: buttonRow.implicitWidth
            color: Qt.lighter(Style.bgPrimary, 1.1)
            radius: Style.radius
            border.color: Style.windowBorder
            border.width: 1

            RowLayout {
                id: buttonRow
                anchors.fill: parent
                spacing: 0

                AppButton {
                    text: "Copy JSON"
                    palette.windowText: Style.textSecondary
                    radius: 0
                    topLeftRadius: Style.radius
                    bottomLeftRadius: Style.radius
                    Layout.fillHeight: true

                    onClicked: {
                        let json = ColorHistory.colorsToJsonString()
                        SnipperManager.requestCopyTextToClipboard(json)

                        toastRequested("Copied as JSON", false)
                    }
                }

                Rectangle {
                    width: 1
                    Layout.fillHeight: true
                    Layout.topMargin: 6
                    Layout.bottomMargin: 6
                    color: Qt.rgba(1, 1, 1, 0.15)
                }

                AppButton {
                    text: "Clear"
                    palette.windowText: Style.failureText
                    hoverColor: Qt.alpha(Style.failure, 0.15)
                    radius: 0
                    topRightRadius: Style.radius
                    bottomRightRadius: Style.radius
                    Layout.fillHeight: true

                    onClicked: ColorHistory.clear()
                }
            }
        }
    }

    // -- content below header --
    ColumnLayout {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        anchors.topMargin: 12
        spacing: 12

        // empty state
        Label {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "Pick colors with the eyedropper to save them here"
            color: Style.textDisabled
            font.italic: true
            font.letterSpacing: 1
            visible: ColorHistory.colors.length === 0
        }

        // -- carousel --
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            visible: ColorHistory.colors.length > 0

            ListView {
                id: carousel
                anchors.fill: parent
                orientation: ListView.Horizontal
                spacing: 10
                clip: true
                model: ColorHistory.colors

                ScrollBar.horizontal: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                delegate: Item {
                    width: 60
                    height: 60

                    required property string modelData
                    required property int index

                    Rectangle {
                        id: swatch
                        anchors.fill: parent
                        anchors.margins: 2 // safe zone so scale() doesn't squish border
                        anchors.bottomMargin: 16
                        radius: Style.radius
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
                                toastRequested(`Copied ${modelData}`, false)
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

        Item { Layout.fillHeight: true }
    }
}
