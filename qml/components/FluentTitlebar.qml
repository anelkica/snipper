import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Effects
import ".." // Style.qml

// note: always match the titlebar button cornerRadius with window cornerRadius :)

Rectangle {
   id: titlebar

   width: parent.width
   height: 40
   color: Qt.darker(Style.bgPrimary, 1.15)

   topLeftRadius: Style.radius
   topRightRadius: Style.radius

   anchors {
       fill: parent
       margins: 1
   }

   property string title: "snipper"
   property color statusColor: Style.accent

   onStatusColorChanged: resetTimer.restart()

   RowLayout {
       anchors.fill: parent
       anchors.leftMargin: Style.spacingM
       anchors.bottomMargin: 1 // for the bottom divider guy
       spacing: 0

       RowLayout {
              spacing: 12

              // cute activity icon :3
              Rectangle {
                  id: activity_icon
                  width: 12
                  height: 12
                  radius: 6

                  color: titlebar.statusColor
                  Layout.alignment: Qt.AlignVCenter
                  Layout.topMargin: 1.5

                  Timer {
                     id: resetTimer
                     interval: 3500
                     onTriggered: titlebar.statusColor = Style.accent
                  }

                  Behavior on color {
                     ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
                  }

                  layer.enabled: true
                  layer.effect: MultiEffect {
                     blurEnabled: true
                     blur: 0.15

                     brightness: 0.2
                     contrast: 0.2
                  }
              }

              Label {
                  text: titlebar.title
                  color: Style.textPrimary
                  font.weight: Font.Medium
                  font.pixelSize: 14
                  Layout.alignment: Qt.AlignVCenter
              }
       }

       Item { Layout.fillWidth: true } // spacer

       FluentButton {
           text: "—"
           radius: 0

           implicitWidth: 46

           onClicked: Window.window.showMinimized()
       }

       FluentButton {
           text: "✕"
           radius: 0

           hoverColor: "#a82319"
           pressedColor: "#87231b"
           topRightRadius: Style.radius

           implicitWidth: 46

           onClicked: Window.window.close()
       }
   }

   // bottom divider line
   Rectangle {
       anchors.bottom: parent.bottom
       width: parent.width
       height: 1
       color: Qt.rgba(1, 1, 1, 0.08)
   }
}
