import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import snipper

MenuItem {
    id: menuItem

    property string iconText: ""
    property bool isSelected: false

    font.pixelSize: 14

    implicitWidth: 130
    implicitHeight: 28

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    contentItem: Item {
        implicitWidth: menuItem.implicitWidth
        implicitHeight: menuItem.implicitHeight

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 10
                rightMargin: 10
            }
            spacing: 6

            Label {
                visible: menuItem.iconText !== ""
                text: menuItem.iconText
                font.family: Icons.family
                font.pixelSize: menuItem.font.pixelSize
                color: menuItem.isSelected ? Material.accent : Material.primaryTextColor
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: visible ? 16 : 0
            }

            Label {
                text: menuItem.text
                font.pixelSize: menuItem.font.pixelSize
                font.weight: menuItem.isSelected ? Font.Medium : Font.Normal
                color: menuItem.isSelected ? Material.accent : Material.primaryTextColor
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
            }
        }
    }

    background: Rectangle {
        anchors {
            fill: parent
            leftMargin: 3
            rightMargin: 3
            topMargin: 1
            bottomMargin: 1
        }
        radius: 3
        color: menuItem.highlighted ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

        Behavior on color {
            ColorAnimation { duration: 100 }
        }
    }
}
