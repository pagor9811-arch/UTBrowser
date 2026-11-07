import QtQuick 2.7
import Ubuntu.Components 1.3

Item {
    id: button
    property var theme
    property string iconName: ""
    property bool active: false
    property int badge: 0
    signal clicked()

    width: implicitWidth
    height: implicitHeight
    implicitWidth: units.gu(5)
    implicitHeight: units.gu(5)

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: button.active ? (button.theme ? button.theme.surfaceAlt : "#1f2630") : "transparent"
        opacity: mouseArea.pressed ? 0.7 : 1.0
    }

    Icon {
        anchors.centerIn: parent
        name: button.iconName
        width: units.gu(2.6)
        height: width
        color: button.enabled ? (button.theme ? button.theme.text : "#ffffff")
                              : (button.theme ? button.theme.textDim : "#777777")
        opacity: button.enabled ? 1.0 : 0.5
    }

    Rectangle {
        visible: button.badge > 0
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: units.gu(0.35)
        anchors.rightMargin: units.gu(0.35)
        width: Math.max(units.gu(2.0), badgeLabel.implicitWidth + units.gu(0.6))
        height: units.gu(2.0)
        radius: height / 2
        color: button.theme ? button.theme.accent : "#4cc2ff"

        Label {
            id: badgeLabel
            anchors.centerIn: parent
            text: button.badge > 99 ? "99+" : button.badge
            color: "#071018"
            font.pixelSize: units.gu(1.1)
            font.weight: Font.Bold
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: button.enabled
        onClicked: button.clicked()
    }
}
