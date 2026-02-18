import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import snipper

/*
    this has to be the DUMBEST solution ever.
    like genuinely, wtf? it works, it's flexible, but my god is it such a hacky way

    basically, a transparent tracker window is tracking the cursor (with a color display below the cursor)
    if the user clicks, it saves the color

    my god what a pain this was, all that for just a color picker? lol
*/

Window {
    id: pickerDisplay
    width: 360
    height: 200
    flags: Qt.ToolTip | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: true

    readonly property int margin: 10
    readonly property int yOffset: 30
    readonly property int opticalX: 8 // the display should be horizontally centered on the mouse, it looks ugly asf without this

    // these properties are for detecting where the display is located
    // if it's on the bottom of the screen, the display springs up, likewise for left/right edges of the screen
    readonly property bool isAtBottom: (pickerDisplay.y + (height / 2)) > (Screen.desktopAvailableHeight - 80)
    readonly property real globalRightEdge: pickerDisplay.x + (width / 2) + (contentDisplay.width / 2)
    readonly property real globalLeftEdge: pickerDisplay.x + (width / 2) - (contentDisplay.width / 2)

     // position of cursor = (width / 2), (height / 2)

    property alias pickerColor: colorIndicator.color
    property alias colorName: hexLabel.text

    signal colorAccepted(string hex)


    TapHandler {
        onTapped: {
            contentDisplay.scale = 0.95
            colorAccepted(colorName)
        }
    }

    Rectangle {
        id: contentDisplay
        width: 150
        height: 50

        // cursor pos = (parent.width / 2)

        // adaptive positioning, checks if it hits right/left edge and adjusts
        x: {
            let preferred = (parent.width / 2) - (width / 2) + opticalX;
            if (globalRightEdge > Screen.desktopAvailableWidth - margin) {
                return preferred - (globalRightEdge - Screen.desktopAvailableWidth + margin);
            }
            if (globalLeftEdge < margin) {
                return preferred + (margin - globalLeftEdge);
            }
            return preferred;
        }

        // ditto, checks if it's on bottom, adjusts
        y: isAtBottom ? (parent.height / 2) - height - yOffset
                      : (parent.height / 2) + yOffset

        color: Qt.darker(Style.bgPrimary, 1.2)
        radius: Style.radius
        border.width: 1
        border.color: Style.windowBorder

        Behavior on scale { NumberAnimation { duration: 100 } }
        Behavior on x { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

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

            ColumnLayout {
                Layout.fillWidth: true

            }
            Text {
                id: hexLabel
                color: "white"
                font.pixelSize: 14
                font.family: "Monospace"
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
