pragma Singleton
import QtQuick

QtObject {
    readonly property color bgPrimary:     "#1f232a" // colorNeutralBackground1 [main app background]
    readonly property color bgSecondary:   "#242424" // colorNeutralBackground2 [sidebars, toolbars]
    readonly property color bgTertiary:    "#2f2f2f" // colorNeutralBackground3 [cards, panels]

    readonly property color bgHover:       "#2d333d"
    readonly property color bgPressed:     "#252a32"

    readonly property color accent:        "#8263D8" // Vibrant, lighter purple
    readonly property color accentHover:   "#9175E0" // Slightly lighter for hover
    readonly property color accentPress:   "#6A4BBF"

    readonly property color textPrimary:   "#F0F0F0"
    readonly property color textSecondary: "#d6d6d6"
    readonly property color textDisabled:  "#5c5c5c"

    readonly property color borderMain:    "#2a2f38"
    readonly property color borderLight:   "#2d2d2d"

    readonly property real  spacingM:       12.0
    readonly property real  padding:       8.0
    readonly property real  radius:        8.0
}
