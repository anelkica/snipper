import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import snipper

Item {
    id: selectionToolbar

    property string activePanel: ""
    property string selectionType: "rectangle"
    property bool isDragging: false

    signal capturingDeclined()

    anchors.top: parent.top
    anchors.topMargin: 20
    anchors.horizontalCenter: parent.horizontalCenter

    width: primaryBar.width
    height: primaryBar.height

    visible: opacity > 0
    opacity: isDragging ? 0.0 : 1.0
    z: 2

    Behavior on opacity {
        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
    }

    Rectangle {
        id: primaryBar

        height: 40
        width: primaryRow.implicitWidth
        color: Material.color(Material.Grey, Material.Shade900)
        radius: 4
        border.color: Qt.rgba(1, 1, 1, 0.12)
        border.width: 1
        anchors.horizontalCenter: parent.horizontalCenter

        RowLayout {
            id: primaryRow
            anchors.fill: parent
            spacing: 0

            Item { Layout.preferredWidth: 6 }

            WindowToolButton {
                id: selectionBtn
                text: selectionToolbar.selectionType === "fullscreen" ? Icons.fullscreen : Icons.region
                iconColor: selectionToolbar.selectionType !== "rectangle" ? Material.accent : Material.foreground
                font.pixelSize: 16
                btnRadius: 2
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.alignment: Qt.AlignVCenter
                onClicked: selectionMenu.open()

                DropdownMenu {
                    id: selectionMenu

                    DropdownMenuItem {
                        text: "Rectangle"
                        iconText: Icons.region
                        font.pixelSize: 14
                        isSelected: selectionToolbar.selectionType === "rectangle"
                        onTriggered: selectionToolbar.selectionType = "rectangle"
                    }
                    DropdownMenuItem {
                        text: "Fullscreen"
                        iconText: Icons.fullscreen
                        font.pixelSize: 14
                        isSelected: selectionToolbar.selectionType === "fullscreen"
                        onTriggered: selectionToolbar.selectionType = "fullscreen"
                    }
                }
            }

            Item { Layout.preferredWidth: 4 }

            Rectangle {
                width: 1
                height: 18
                color: Qt.rgba(1, 1, 1, 0.12)
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.preferredWidth: 4 }

            WindowToolButton {
                id: closeBtn
                text: Icons.close
                font.pixelSize: 16
                btnRadius: 2
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                Layout.alignment: Qt.AlignVCenter
                onClicked: selectionToolbar.capturingDeclined()
            }

            Item { Layout.preferredWidth: 6 }
        }
    }
}
