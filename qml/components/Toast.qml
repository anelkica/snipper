import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import snipper

Rectangle {
    id: toast

    parent: Overlay.overlay
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.bottomMargin: 20
    anchors.leftMargin: 20

    implicitWidth: Math.min(toastLayout.implicitWidth + 32, 280)
    implicitHeight: 44
    radius: 4
    color: Material.backgroundColor
    border.color: Material.color(Material.Grey, Material.Shade800)
    border.width: 1

    visible: opacity > 0
    opacity: 0

    property bool isError: false
    property real slideOffset: 20

    function show(message, _isError = false) {
        toastLabel.text = message
        isError = _isError
        iconLabel.text = isError ? Icons.close : Icons.check
        iconLabel.color = isError
            ? Material.color(Material.Red, Material.Shade400)
            : Material.color(Material.Green, Material.Shade400)

        opacity = 0
        slideOffset = 20
        toastAnimation.restart()
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: {
            if (hoverHandler.hovered) {
                toastAnimation.pause()
            } else {
                toastAnimation.resume()
            }
        }
    }

    RowLayout {
        id: toastLayout
        anchors.centerIn: parent
        spacing: 10

        Label {
            id: iconLabel
            font.family: Icons.family
            font.pixelSize: 18
            Layout.alignment: Qt.AlignVCenter
        }

        Label {
            id: toastLabel
            font.pixelSize: 13
            font.letterSpacing: 0.5
            color: Material.foreground
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 280
            wrapMode: Text.Wrap
            elide: Text.ElideRight
        }
    }

    SequentialAnimation {
        id: toastAnimation
        running: false

        ParallelAnimation {
            NumberAnimation {
                target: toast
                property: "opacity"
                to: 1
                duration: 200
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: toast
                property: "slideOffset"
                to: 0
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        PauseAnimation { duration: 2000 }

        ParallelAnimation {
            NumberAnimation {
                target: toast
                property: "opacity"
                to: 0
                duration: 300
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: toast
                property: "slideOffset"
                to: 20
                duration: 300
                easing.type: Easing.InCubic
            }
        }
    }

    transform: Translate {
        y: toast.slideOffset
    }
}
