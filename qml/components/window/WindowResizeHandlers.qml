import QtQuick

Item {
    anchors.fill: parent

    readonly property int thickness: 6

    MouseArea {
            id: topLeft
            width: thickness; height: thickness; anchors { top: parent.top; left: parent.left }
            cursorShape: Qt.SizeFDiagCursor
            onPressed: root.startSystemResize(Qt.TopEdge | Qt.LeftEdge)
        }
        MouseArea {
            id: topRight
            width: thickness; height: thickness; anchors { top: parent.top; right: parent.right }
            cursorShape: Qt.SizeBDiagCursor
            onPressed: root.startSystemResize(Qt.TopEdge | Qt.RightEdge)
        }
        MouseArea {
            id: bottomLeft
            width: thickness; height: thickness; anchors { bottom: parent.bottom; left: parent.left }
            cursorShape: Qt.SizeBDiagCursor
            onPressed: root.startSystemResize(Qt.BottomEdge | Qt.LeftEdge)
        }
        MouseArea {
            id: bottomRight
            width: thickness; height: thickness; anchors { bottom: parent.bottom; right: parent.right }
            cursorShape: Qt.SizeFDiagCursor
            onPressed: root.startSystemResize(Qt.BottomEdge | Qt.RightEdge)
        }



        MouseArea {
            id: topSide
            height: thickness; anchors { top: parent.top; left: parent.left; right: parent.right; leftMargin: thickness; rightMargin: thickness }
            cursorShape: Qt.SizeVerCursor
            onPressed: root.startSystemResize(Qt.TopEdge)
        }
        MouseArea {
            id: bottomSide
            height: thickness; anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: thickness; rightMargin: thickness }
            cursorShape: Qt.SizeVerCursor
            onPressed: root.startSystemResize(Qt.BottomEdge)
        }
        MouseArea {
            id: leftSide
            width: thickness; anchors { left: parent.left; top: parent.top; bottom: parent.bottom; topMargin: thickness; bottomMargin: thickness }
            cursorShape: Qt.SizeHorCursor
            onPressed: root.startSystemResize(Qt.LeftEdge)
        }
        MouseArea {
            id: rightSide
            width: thickness; anchors { right: parent.right; top: parent.top; bottom: parent.bottom; topMargin: thickness; bottomMargin: thickness }
            cursorShape: Qt.SizeHorCursor
            onPressed: root.startSystemResize(Qt.RightEdge)
        }
}
