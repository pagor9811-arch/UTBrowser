import QtQuick 2.7
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3

Item {
    id: panel
    property var theme
    property bool opened: false
    property string title: ""
    property int preferredHeight: units.gu(58)
    property alias content: contentColumn.data
    signal closed()

    anchors.fill: parent
    visible: opacity > 0.001
    opacity: opened ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 150 } }
    z: 100

    Rectangle {
        anchors.fill: parent
        color: "#b3000000"

        MouseArea {
            anchors.fill: parent
            onClicked: panel.closed()
        }
    }

    Rectangle {
        id: sheet
        anchors.left: parent.left
        anchors.right: parent.right
        height: Math.min(parent.height * 0.88, panel.preferredHeight)
        color: panel.theme ? panel.theme.surface : "#161b22"
        radius: units.gu(1.6)
        y: panel.opened ? parent.height - height : parent.height
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        Rectangle {
            id: handle
            width: units.gu(5)
            height: units.dp(4)
            radius: height / 2
            color: panel.theme ? panel.theme.divider : "#2a323d"
            anchors.top: parent.top
            anchors.topMargin: units.gu(0.8)
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ColumnLayout {
            id: outerLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: units.gu(1.5)
            anchors.rightMargin: units.gu(1.5)
            anchors.bottomMargin: units.gu(1.5)
            anchors.topMargin: units.gu(2.4)
            spacing: units.gu(0.8)

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: units.gu(4.5)

                Label {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: panel.title
                    color: panel.theme ? panel.theme.text : "#e6edf3"
                    font.pixelSize: units.gu(2.2)
                    font.weight: Font.DemiBold
                }

                IconButton {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    theme: panel.theme
                    iconName: "close"
                    onClicked: panel.closed()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: units.dp(1)
                color: panel.theme ? panel.theme.divider : "#2a323d"
            }

            Flickable {
                id: flick
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: width
                contentHeight: contentColumn.childrenRect.height
                clip: true
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: contentColumn
                    width: flick.width
                    spacing: units.gu(1)
                }
            }
        }
    }
}
