import QtQuick
import QtQuick.Controls

Menu {
    id: menu

    property int preferredWidth: 130
    width: preferredWidth

    x: parent ? (parent.width - width) / 2 + 4 : 0
    y: parent ? parent.height + 8 : 0

    padding: 4

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
        NumberAnimation { property: "scale"; from: 0.9; to: 1; duration: 150; easing.type: Easing.OutCubic }
    }

    background: Rectangle {
        implicitWidth: menu.preferredWidth
        color: Material.color(Material.Grey, Material.Shade900)
        radius: 4
        border.color: Qt.rgba(1, 1, 1, 0.15)
        border.width: 1
    }
}
