pragma Singleton
import QtQuick

QtObject {
    readonly property string family:     "Lucide"

    readonly property string chevronLeft: "\ue06e"

    readonly property string minimize:    "\ue11c"
    readonly property string maximize:    "\ue167"
    readonly property string restore:     "\ue65a" // or "\ue657" (squares-exclude)
    readonly property string close:       "\ue1b2"
    readonly property string check:       "\ue06c"

    readonly property string plus:        "\ue13d"
    readonly property string scissors:    "\ue14e"
    readonly property string timer:       "\ue1e0"
    readonly property string crop:        "\ue0ab"
    readonly property string copy:        "\ue09e" // or "\ue085" (clipboard)
    readonly property string save:        "\ue14d"

    readonly property string pipette:     "\ue13b"
    readonly property string palette:     "\ue1dd"

    readonly property string pin:         "\ue259"
    readonly property string pinOff:      "\ue2b6"

    readonly property string fullscreen:  "\ue534"
    readonly property string region:      "\ue112"
}
