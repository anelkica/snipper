import QtQuick
import QtQuick.Controls

import "."
import "components" as UI

Window {
    id: root

    width: 512
    height: 256
    color: "white"

    property url iconSource: "qrc:/icons/scissors-cut-fill.svg"

    Button {
        text: "OK"

        icon.source: iconSource
    }

}
