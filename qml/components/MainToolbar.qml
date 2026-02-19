import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import snipper

Rectangle {
    id: toolbarRoot
    Layout.alignment: Qt.AlignHCenter
    Layout.topMargin: 14
    Layout.preferredHeight: 40
    Layout.preferredWidth: Math.min(parent.width * 0.7, 640)
    color: Qt.lighter(Style.bgPrimary, 1.1)
    radius: Style.radius
    border.color: Qt.rgba(1, 1, 1, 0.1)

    property int selectedTimer: 0

    signal snipClicked()

    Popup {
        id: timerPopup
        closePolicy: Popup.CloseOnEscape

        x: timerButton.x - (width - timerButton.width) / 2
        y: toolbarRoot.height + 8

        width: timerRow.implicitWidth + 32
        height: 40
        padding: 0

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutCubic }
            NumberAnimation { property: "y"; from: toolbarRoot.height; to: toolbarRoot.height + 8; duration: 200; easing.type: Easing.OutBack }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150; easing.type: Easing.OutCubic }
            NumberAnimation { property: "y"; from: toolbarRoot.height + 8; to: toolbarRoot.height; duration: 150; easing.type: Easing.OutCubic }
        }

        background: Rectangle {
            color: Qt.lighter(Style.bgPrimary, 1.1)
            radius: Style.radius
            border.color: Qt.rgba(1, 1, 1, 0.1)
            border.width: 1
        }

        RowLayout {
            id: timerRow
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: [3, 5, 10]
                AppButton {
                    text: modelData + "s"
                    Layout.preferredWidth: 48
                    palette.windowText: toolbarRoot.selectedTimer === modelData ? Style.accent : "white"
                    onClicked: {
                        toolbarRoot.selectedTimer = toolbarRoot.selectedTimer === modelData ? 0 : modelData
                        timerPopup.close()
                    }
                }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        AppButton {
            icon.source: "qrc:/icons/scissors-cut-fill.svg"
            icon.width: 18; icon.height: 18; icon.color: "white"
            hoverColor: Qt.darker(Style.accent, 1.1)
            radius: 0
            topLeftRadius: Style.radius
            bottomLeftRadius: Style.radius
            Layout.fillWidth: true
            onClicked: snipClicked()
        }

        AppButton {
            id: timerButton
            icon.source: "qrc:/icons/timer-line.svg"
            icon.width: 18; icon.height: 18
            icon.color: toolbarRoot.selectedTimer > 0 ? Style.accent : "white"
            hoverColor: Qt.darker(Style.accent, 1.1)
            radius: 0
            Layout.fillWidth: true
            onClicked: timerPopup.opened ? timerPopup.close() : timerPopup.open()

            // activity line
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.6
                height: 3
                radius: 2
                color: Style.accent
                visible: toolbarRoot.selectedTimer > 0
            }
        }

        Rectangle {
            Layout.preferredWidth: 1; Layout.fillHeight: true
            Layout.topMargin: 8; Layout.bottomMargin: 8
            color: Qt.rgba(1, 1, 1, 0.15)
        }

        AppButton {
            icon.source: "qrc:/icons/file-copy-line.svg"
            icon.width: 18; icon.height: 18; icon.color: "white"
            radius: 0; hoverColor: Qt.darker(Style.accent, 1.1)
            Layout.fillWidth: true
            onClicked: SnipperManager.requestCopyImageToClipboard(currentScreenshotUrl)
        }

        AppButton {
            icon.source: "qrc:/icons/pushpin-line.svg"
            icon.width: 18; icon.height: 18; icon.color: "white"
            radius: 0; hoverColor: Qt.darker(Style.accent, 1.1)
            Layout.fillWidth: true
            onClicked: WindowManager.requestCreatePinWindow(currentScreenshotUrl)
        }

        AppButton {
            icon.source: "qrc:/icons/sip-line.svg"
            icon.width: 18; icon.height: 18; icon.color: "white"
            radius: 0; hoverColor: Qt.darker(Style.accent, 1.1)
            Layout.fillWidth: true
            onClicked: root.isPickingColor = !root.isPickingColor

            // activity line
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.6
                height: 3; radius: 2
                color: Style.accent
                visible: root.isPickingColor
            }
        }

        Rectangle {
            Layout.preferredWidth: 1; Layout.fillHeight: true
            Layout.topMargin: 8; Layout.bottomMargin: 8
            color: Qt.rgba(1, 1, 1, 0.1)
        }

        AppButton {
            icon.source: "qrc:/icons/save-3-fill.svg"
            icon.width: 18; icon.height: 18; icon.color: "white"
            radius: 0; hoverColor: Qt.darker(Style.accent, 1.1)
            Layout.fillWidth: true
            onClicked: if (root.currentScreenshotUrl !== "") saveCropDialog.open()
        }

        AppButton {
            icon.source: "qrc:/icons/more-fill.svg"
            icon.width: 18; icon.height: 18; icon.color: "white"
            radius: 0
            topRightRadius: Style.radius
            bottomRightRadius: Style.radius
            hoverColor: Qt.darker(Style.accent, 1.1)
            Layout.fillWidth: true
        }
    }
}
