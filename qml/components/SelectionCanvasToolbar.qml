import QtQuick
import QtQuick.Layouts
import snipper

Item {
    id: selectionToolbar

    // State management
    property string activePanel: "" // "" - "selection"
    property string selectionType: "rectangle" // "rectangle" - "window"
    property bool isDragging: false

    signal stopCapturing()
    signal capturingDeclined()

    anchors.top: parent.top
    anchors.topMargin: 20
    anchors.horizontalCenter: parent.horizontalCenter

    width: primaryBar.width
    height: primaryBar.height + (secondaryBar.visible ? secondaryBar.height + 8 : 0)

    visible: opacity > 0
    opacity: isDragging ? 0.0 : 1.0
    z: 2

    Rectangle {
        id: primaryBar
        width: primaryRow.implicitWidth + 40
        height: 48
        color: Qt.darker(Style.bgPrimary, 1.1)
        radius: Style.radius
        border.color: Qt.rgba(1, 1, 1, 0.1)
        border.width: 1
        anchors.horizontalCenter: parent.horizontalCenter

        RowLayout {
            id: primaryRow
            anchors.centerIn: parent
            spacing: 12

            AppButton {
                icon.source: "qrc:/icons/crop-line.svg"
                icon.width: 18
                icon.height: 18
                icon.color: selectionToolbar.selectionType !== "rectangle" ? Style.accent : "white"
                Layout.preferredWidth: 48
                onClicked: selectionToolbar.activePanel = (selectionToolbar.activePanel === "selection" ? "" : "selection")
            }

            Rectangle { width: 1; height: 20; color: Qt.rgba(1, 1, 1, 0.2) }

            AppButton {
                text: "✕"
                hoverColor: "#a82319"
                Layout.preferredWidth: 48
                onClicked: capturingDeclined()
            }
        }
    }

    Rectangle {
        id: secondaryBar
        width: secondaryStack.implicitWidth + 40
        height: 42
        color: Style.bgPrimary
        radius: Style.radius
        border.color: Qt.rgba(1, 1, 1, 0.1)
        border.width: 1

        anchors.top: primaryBar.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        visible: opacity > 0
        opacity: activePanel !== "" ? 1.0 : 0.0
        anchors.topMargin: activePanel !== "" ? 8 : -20
        z: -1

        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on anchors.topMargin { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

        StackLayout {
            id: secondaryStack

            anchors.fill: parent
            anchors.margins: 4
            currentIndex: {
                if (activePanel === "selection") return 0;
                return -1;
            }

            // -- PANEL 0: Selection Types -- //
            RowLayout {
                spacing: 4
                Repeater {
                    model: [
                        { label: "Rectangle", value: "rectangle", icon: "qrc:/icons/rect.svg" },
                        { label: "Fullscreen", value: "fullscreen", icon: "qrc:/icons/fullscreen.svg" },
                        //{ label: "Window",    value: "window",    icon: "qrc:/icons/window.svg" }
                    ]
                    AppButton {
                        text: modelData.label
                        font.bold: true
                        Layout.fillWidth: true
                        palette.windowText: selectionToolbar.selectionType === modelData.value ? Style.accent : "white"
                        onClicked: {
                            selectionToolbar.selectionType = modelData.value
                            selectionToolbar.activePanel = ""
                        }
                    }
                }
            }
        }
    }
}
