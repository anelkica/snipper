import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Effects
import ".."

Rectangle {
    id: titlebarRoot

    property string title: "snipper"
    property color statusColor: Style.accent

    radius: Style.radius
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.05)

    Layout.fillWidth: true
    Layout.preferredHeight: 40

    color: Qt.darker(Style.bgPrimary, 1.15)

    topLeftRadius: Style.radius
    topRightRadius: Style.radius
    bottomLeftRadius: 0
    bottomRightRadius: 0

    z: 1

    // Integrated Dragging Logic
    DragHandler {
        target: null
        onActiveChanged: if (active) root.startSystemMove()
    }

    onStatusColorChanged: resetTimer.restart()

    RowLayout {
        anchors.fill: parent
        anchors.topMargin: 1 // prevents buttons from overlapping with the app border
        anchors.leftMargin: Style.spacingM
        spacing: 0

        RowLayout {
            spacing: 12
            Rectangle {
                id: activity_icon
                width: 10; height: 10; radius: 5
                color: titlebarRoot.statusColor
                Layout.alignment: Qt.AlignVCenter

                Timer {
                    id: resetTimer
                    interval: 3500
                    onTriggered: titlebarRoot.statusColor = Style.accent
                }

                Behavior on color { ColorAnimation { duration: 400 } }

                layer.enabled: true
                layer.effect: MultiEffect { blurEnabled: true; blur: 0.15; brightness: 0.2 }
            }

            Label {
                text: titlebarRoot.title
                color: Style.textPrimary
                font.weight: Font.Medium
                font.pixelSize: 13
                Layout.alignment: Qt.AlignVCenter
            }
        }

        Item { Layout.fillWidth: true } // Spacer

        AppButton {
            text: "—"
            radius: 0
            implicitWidth: 58
            Layout.fillHeight: true
            onClicked: root.showMinimized()
        }

        AppButton {
            text: "✕"
            radius: 0
            hoverColor: "#a82319"
            pressedColor: "#87231b"
            topRightRadius: Style.radius
            implicitWidth: 58
            Layout.fillHeight: true
            onClicked: root.close()
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Qt.rgba(1, 1, 1, 0.08)
    }
}
