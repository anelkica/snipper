import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import ".." // Style.qml


Button {
    id: button

    flat: true // VERY IMPORTANT
    highlighted: false
    hoverEnabled: true

    Layout.fillHeight: true

    property real radius: Style.radius
    property real topLeftRadius: radius
    property real topRightRadius: radius
    property real bottomLeftRadius: radius
    property real bottomRightRadius: radius

    property color backgroundColor: "transparent"
    property color hoverColor: Style.bgHover
    property color pressedColor: Style.bgPressed
    property real pixelSize: 12

    scale: pressed ? 0.95 : 1.0
    padding: Style.padding

    background: Rectangle {
        anchors.fill: parent

        color: {
            if (button.pressed) return button.pressedColor
            if (button.hovered) return button.hoverColor

            return button.backgroundColor
        }

        topLeftRadius: button.topLeftRadius
        topRightRadius: button.topRightRadius
        bottomLeftRadius: button.bottomLeftRadius
        bottomRightRadius: button.bottomRightRadius

        Behavior on color {
            ColorAnimation { duration: 120; easing.type: Easing.OutCubic }
        }
    }
}
