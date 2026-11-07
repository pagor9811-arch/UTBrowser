import QtQuick 2.7
import Ubuntu.Components 1.3

Item {
    id: toggle
    property var theme
    property bool checked: false
    signal toggled()

    width: implicitWidth
    height: implicitHeight
    implicitWidth: units.gu(6.4)
    implicitHeight: units.gu(3.4)

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: toggle.checked ? (toggle.theme ? toggle.theme.accent : "#4cc2ff")
                              : (toggle.theme ? toggle.theme.field : "#222a35")
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Rectangle {
        id: knob
        width: parent.height - units.dp(6)
        height: width
        radius: width / 2
        color: "#ffffff"
        anchors.verticalCenter: parent.verticalCenter
        x: toggle.checked ? parent.width - width - units.dp(3) : units.dp(3)
        Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: toggle.toggled()
    }
}
