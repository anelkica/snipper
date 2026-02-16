import QtQuick
import QtQuick.Window
import QtQuick.Layouts // Required for RowLayout
import snipper

Window {
    id: pickerDisplay
    width: 150
    height: 50
    flags: Qt.ToolTip | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: true

    property alias pickerColor: colorIndicator.color
    property alias colorName: hexLabel.text

    Rectangle {
        anchors.fill: parent
        color: Qt.darker(Style.bgPrimary, 1.2)
        radius: Style.radius
        border.width: 1
        border.color: Style.windowBorder

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 12

            Rectangle {
                id: colorIndicator
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignVCenter

                radius: Style.radius / 2
                border.width: 1
                border.color: Style.windowBorder
            }

            Text {
                id: hexLabel
                color: "white"
                font.pixelSize: 14
                font.family: "Monospace"
                Layout.fillWidth: true // Takes up remaining space
                Layout.alignment: Qt.AlignVCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
