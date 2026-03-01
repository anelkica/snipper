import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/*
    flat window buttons for stuff such as minimize, maximize, close, etc.
*/

ToolButton {
    id: btn

    property color hoverColor: Qt.rgba(1, 1, 1, 0.1)
    property color pressedColor: Qt.rgba(1, 1, 1, 0.2)
    property color iconColor: Material.foreground
    property color hoverIconColor: iconColor
    property int btnRadius: 0

    font.family: Icons.family
    font.pixelSize: 16

    Layout.preferredWidth: 52
    Layout.fillHeight: true

    background: Rectangle {
        anchors.fill: parent
        radius: btnRadius

        color: btn.pressed ? btn.pressedColor :
                             (btn.hovered ? btn.hoverColor : "transparent")

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }

    contentItem: Label {
        text: btn.text
        font: btn.font
        color: btn.hovered ? btn.hoverIconColor : btn.iconColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        scale: btn.pressed ? 0.9 : 1.0
        Behavior on scale {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutBack
            }
        }
    }
}
