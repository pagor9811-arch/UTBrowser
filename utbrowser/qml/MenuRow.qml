import QtQuick 2.7
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3

Rectangle {
    id: row
    property var theme
    property string iconName: ""
    property string text: ""
    signal clicked()

    width: parent ? parent.width : implicitWidth
    height: units.gu(5.4)
    radius: units.gu(1.0)
    color: mouseArea.pressed ? (theme ? theme.surfaceAlt : "#1f2630")
                             : (theme ? theme.tile : "#1b222c")
    border.width: units.dp(1)
    border.color: theme ? theme.divider : "#2a323d"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: units.gu(1.2)
        anchors.rightMargin: units.gu(1.0)
        spacing: units.gu(1.0)

        Icon {
            Layout.preferredWidth: units.gu(2.2)
            Layout.preferredHeight: units.gu(2.2)
            name: row.iconName
            color: row.theme ? row.theme.accent : "#4cc2ff"
        }

        Label {
            Layout.fillWidth: true
            text: row.text
            color: row.theme ? row.theme.text : "#e6edf3"
            font.pixelSize: units.gu(1.5)
            elide: Text.ElideRight
        }

        Icon {
            Layout.preferredWidth: units.gu(1.6)
            Layout.preferredHeight: units.gu(1.6)
            name: "go-next"
            color: row.theme ? row.theme.textDim : "#8b98a5"
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: row.clicked()
    }
}
