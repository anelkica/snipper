import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import snipper

Item {
    id: mainPage

    signal snipClicked()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        MainPageToolbar {
            id: toolbar

            onSnipClicked: mainPage.snipClicked()
        }

        // preview of last snip
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 20

            // these margins are for the bottom buttons (Palette button)
            Layout.leftMargin: 56
            Layout.rightMargin: 56

            Image {
                id: preview
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: AppState.currentScreenshotUrl
                smooth: true; mipmap: true; //antialiasing: true
                sourceSize.width: -1
                sourceSize.height: -1
            }
        }
    }
}
