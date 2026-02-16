import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import snipper

// -- ONLY FOR USE IN Main.qml -- //
// -- root = ApplicationWindow -- //

Rectangle {
    id: toolbarRoot

    Layout.alignment: Qt.AlignHCenter
    Layout.topMargin: 14
    Layout.preferredHeight: 40
    Layout.preferredWidth: Math.min(parent.width * 0.7, 640)

    color: Qt.lighter(Style.bgPrimary, 1.1)
    radius: Style.radius
    border.color: Qt.rgba(1, 1, 1, 0.1)

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
            onClicked: SnipperManager.requestCaptureScreenshot(root)
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            color: Qt.rgba(1, 1, 1, 0.15)
        }

        AppButton {
            icon.source: "qrc:/icons/file-copy-line.svg"
            icon.width: 18; icon.height: 18; icon.color: "white"
            radius: 0
            hoverColor: Qt.darker(Style.accent, 1.1)
            Layout.fillWidth: true
            onClicked: SnipperManager.requestCopyToClipboard(currentScreenshotUrl)
        }

        AppButton {
            icon.source: "qrc:/icons/pushpin-line.svg"
            icon.width: 18; icon.height: 18; icon.color: "white"
            radius: 0
            hoverColor: Qt.darker(Style.accent, 1.1)
            Layout.fillWidth: true
            onClicked: WindowManager.requestCreatePinWindow(currentScreenshotUrl)
        }

        AppButton {
            icon.source: "qrc:/icons/sip-line.svg"
            icon.width: 18; icon.height: 18; icon.color: "white"
            radius: 0
            hoverColor: Qt.darker(Style.accent, 1.1)
            Layout.fillWidth: true
            onClicked: root.isPickingColor = !root.isPickingColor

            // bottom activity line
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.6
                height: 3
                radius: 2
                color: Style.accent
                visible: root.isPickingColor
            }
        }

        AppButton {
            icon.source: "qrc:/icons/save-3-fill.svg"
            icon.width: 18; icon.height: 18; icon.color: "white"
            radius: 0

            hoverColor: Qt.darker(Style.accent, 1.1)
            Layout.fillWidth: true
            onClicked: if (root.currentScreenshotUrl !== "") saveCropDialog.open()
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            color: Qt.rgba(1, 1, 1, 0.1)
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
