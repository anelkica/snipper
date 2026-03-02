import QtQuick
import QtQuick.Controls

Button {
    id: btn

    flat: true
    implicitHeight: 42

    contentItem: Label {
        text: btn.text
        font: btn.font
        color: btn.Material.foreground
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        scale: btn.pressed ? 0.92 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 100; easing.type: Easing.OutBack }
        }
    }
}
