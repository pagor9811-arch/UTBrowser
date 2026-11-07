import QtQuick 2.7
import Ubuntu.Components 1.3

Rectangle {
    id: chip
    property var theme
    property string text: ""
    property bool selected: false
    signal clicked()

    width: implicitWidth
    height: implicitHeight
    implicitWidth: chipLabel.implicitWidth + units.gu(3.0)
    implicitHeight: units.gu(4.2)
    radius: height / 2
    color: selected ? (theme ? theme.accent : "#4cc2ff")
                    : (theme ? theme.field : "#222a35")
    border.width: selected ? 0 : units.dp(1)
    border.color: theme ? theme.divider : "#2a323d"

    Label {
        id: chipLabel
        anchors.centerIn: parent
        text: chip.text
        color: chip.selected ? "#071018" : (chip.theme ? chip.theme.text : "#ffffff")
        font.pixelSize: units.gu(1.5)
        font.weight: chip.selected ? Font.DemiBold : Font.Normal
    }

    MouseArea {
        anchors.fill: parent
        onClicked: chip.clicked()
    }
}
