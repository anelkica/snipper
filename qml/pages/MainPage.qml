import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls
import snipper

Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: Material.backgroundColor

    FileDialog {
        id: saveCropDialog
        title: "Save Snip As"
        fileMode: FileDialog.SaveFile
        nameFilters: ["Image files (*.png *.jpg)", "All files (*)"]
        currentFile: "snip" + ".png"
        defaultSuffix: "png"

        onAccepted: {
            SnipperManager.requestSaveCropAs(AppState.currentScreenshotUrl, saveCropDialog.selectedFile)
        }
    }

    Item {
        anchors.centerIn: parent
        visible: AppState.currentScreenshotUrl === ""

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8

            Label {
                text: Icons.scissors
                font.family: Icons.family
                font.pixelSize: 32
                color: Qt.rgba(1, 1, 1, 0.15)
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "Click to take a snip"
                font.pixelSize: 12
                color: Qt.rgba(1, 1, 1, 0.3)
                font.letterSpacing: 0.5
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    Image {
        id: previewImage
        anchors.centerIn: parent
        anchors.margins: 1
        source: AppState.currentScreenshotUrl
        fillMode: Image.PreserveAspectFit
        width: parent.width - 32
        height: parent.height - 32
        visible: AppState.currentScreenshotUrl !== ""

        scale: (copyBtn.pressed || pinBtn.pressed || saveBtn.pressed) ? 0.97 : 1.0 // if buttons are held/pressed, so is image

        Behavior on scale {
            NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
        }

        // hover handler wrapper to make sure hover only procs on image hover
        Item {
            anchors.centerIn: parent
            width: previewImage.paintedWidth
            height: previewImage.paintedHeight

            HoverHandler {
                id: imageHover
            }
        }
    }

    // image border
    Rectangle {
        anchors.centerIn: parent
        width: previewImage.paintedWidth + 2
        height: previewImage.paintedHeight + 2
        color: "transparent"
        border.color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1
        visible: previewImage.visible
    }

    // floating action bar for image
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: previewImage.bottom
        anchors.bottomMargin: 16

        visible: AppState.currentScreenshotUrl !== ""
        opacity: imageHover.hovered || barHover.hovered ? 1.0 : 0.0

        width: actionRow.implicitWidth + 16
        height: 36
        radius: 4
        color: Material.color(Material.Grey, Material.Shade900)
        border.color: Qt.rgba(1, 1, 1, 0.12)
        border.width: 1

        HoverHandler {
            id: barHover
        }

        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        RowLayout {
            id: actionRow
            anchors.centerIn: parent
            spacing: 2

            WindowToolButton {
                id: copyBtn
                text: Icons.copy
                btnRadius: 4
                Layout.preferredWidth: 32
                Layout.preferredHeight: 28
                onClicked: SnipperManager.requestCopyImageToClipboard(AppState.currentScreenshotUrl)
            }

            Rectangle {
                width: 1; height: 16
                color: Qt.rgba(1, 1, 1, 0.12)
                Layout.alignment: Qt.AlignVCenter
            }

            WindowToolButton {
                id: pinBtn
                text: AppState.isCurrentScreenshotPinned ? Icons.pinOff : Icons.pin
                btnRadius: 4
                Layout.preferredWidth: 32
                Layout.preferredHeight: 28
                onClicked: {
                    let windowExists = WindowManager.requestWindowExists(AppState.currentScreenshotUrl)

                    if (windowExists) {
                        WindowManager.requestRemovePinWindow(AppState.currentScreenshotUrl)
                        AppState.isCurrentScreenshotPinned = false
                    } else {
                        WindowManager.requestCreatePinWindow(AppState.currentScreenshotUrl)
                        AppState.isCurrentScreenshotPinned = true
                    }
                }
            }

            WindowToolButton {
                id: saveBtn
                text: Icons.save
                btnRadius: 4
                Layout.preferredWidth: 32
                Layout.preferredHeight: 28
                onClicked: if (AppState.currentScreenshotUrl !== "") saveCropDialog.open()
            }
        }
    }
}
