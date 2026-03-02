import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import snipper

ToolBar {
    id: titlebar
    width: parent.width
    padding: 0
    Material.background: Material.color(Material.Grey, Material.Shade900)

    property int delay: 0

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // window controls
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.leftMargin: 12

            Label {
                text: "snipper"
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 0

                WindowToolButton {
                    text: Icons.minimize
                    font.pixelSize: 16
                    onClicked: {
                        Window.window.visibility = Window.Minimized
                    }
                }

                // TODO: fix whatever bullshittery is going on here
                // showMinimized() prevents using showNormal() to restore window.. peak
                WindowToolButton {
                    text: Window.window.visibility === Window.Maximized ? Icons.restore : Icons.maximize
                    font.pixelSize: 14

                        onClicked: {
                            if (Window.window.visibility === Window.Maximized)
                                Window.window.showNormal()
                            else
                                Window.window.showMaximized()
                        }
                }

                WindowToolButton {
                    text: Icons.close
                    font.pixelSize: 16

                    hoverColor: Material.color(Material.Red, Material.Shade800)
                    pressedColor: Material.color(Material.Red, Material.Shade700)

                    onClicked: Window.window.close()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.topMargin: 4

            WindowToolButton {
                text: Icons.chevronLeft
                visible: Navigator.canGoBack
                onClicked: Navigator.pop()
            }

            WindowToolButton {
                text: Icons.scissors
                onClicked: AppState.isSnipping = true
            }

            WindowToolButton {
                text: AppSettings.selectionType === "fullscreen" ? Icons.fullscreen : Icons.region
                iconColor: AppSettings.selectionType !== "rectangle" ? Material.accent : Material.foreground
                onClicked: selectionMenu.open()

                DropdownMenu {
                    id: selectionMenu

                    DropdownMenuItem {
                        iconText: Icons.region
                        text: "Rectangle"
                        isSelected: AppSettings.selectionType === "rectangle"
                        onTriggered: AppSettings.selectionType = "rectangle"
                    }

                    DropdownMenuItem {
                        iconText: Icons.fullscreen
                        text: "Fullscreen"
                        isSelected: AppSettings.selectionType === "fullscreen"
                        onTriggered: AppSettings.selectionType = "fullscreen"
                    }
                }
            }

            WindowToolButton {
                text: Icons.timer
                iconColor: AppSettings.timerDelay === 0 ? Material.foreground : Material.accent

                onClicked: timerMenu.open()

                DropdownMenu {
                    id: timerMenu

                    DropdownMenuItem {
                        text: "3-second delay"
                        isSelected: AppSettings.timerDelay === 3
                        onTriggered: AppSettings.timerDelay = isSelected ? 0 : 3
                    }

                    DropdownMenuItem {
                        text: "5-second delay"
                        isSelected: AppSettings.timerDelay === 5
                        onTriggered: AppSettings.timerDelay = isSelected ? 0 : 5
                    }

                    DropdownMenuItem {
                        text: "10-second delay"
                        isSelected: AppSettings.timerDelay === 10
                        onTriggered: AppSettings.timerDelay = isSelected ? 0 : 10
                    }
                }
            }

            ToolSeparator {
                Layout.fillHeight: true
            }

            WindowToolButton {
                text: Icons.pipette
                iconColor: AppState.isPickingColor ? Material.accent : Material.foreground
                onClicked: AppState.isPickingColor = !AppState.isPickingColor

                // bottoma activity line indicator
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 12
                    height: 2
                    radius: 1
                    color: Material.accent
                    visible: AppState.isPickingColor

                    Behavior on visible {
                        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
                    }
                }
            }

            WindowToolButton {
                text: Icons.palette
                iconColor: AppState.hasUnseenColors ? Material.accent : Material.foreground
                onClicked: {
                    Navigator.push("pages/PalettePage.qml")
                    AppState.hasUnseenColors = false
                }

                // notification dot
                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 3
                    anchors.rightMargin: 6

                    width: 6
                    height: 6
                    radius: 3

                    color: Material.accent
                    visible: AppState.hasUnseenColors

                    SequentialAnimation on opacity {
                        running: AppState.hasUnseenColors
                        loops: 3

                        NumberAnimation { to: 0.3; duration: 600; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
                    }
                }
            }
        }
    }
}
