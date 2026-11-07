import QtQuick 2.7
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3

BottomSheet {
    id: tabsPanel
    property var tabsModel
    property int currentTabId: -1
    signal tabSelected(int tabId)
    signal tabClosed(int tabId)
    signal newTabRequested()

    title: "Вкладки"
    preferredHeight: units.gu(62)

    content: [
        Column {
            width: parent.width
            spacing: units.gu(0.8)

        Repeater {
            model: tabsPanel.tabsModel

            delegate: Rectangle {
                width: parent.width
                height: units.gu(7.2)
                radius: units.gu(1.0)
                color: tabId === tabsPanel.currentTabId
                       ? (tabsPanel.theme ? tabsPanel.theme.surfaceAlt : "#1f2630")
                       : (tabsPanel.theme ? tabsPanel.theme.tile : "#1b222c")
                border.width: units.dp(1)
                border.color: tabId === tabsPanel.currentTabId
                              ? (tabsPanel.theme ? tabsPanel.theme.accent : "#4cc2ff")
                              : (tabsPanel.theme ? tabsPanel.theme.divider : "#2a323d")

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: units.gu(1.2)
                    anchors.rightMargin: units.gu(0.6)
                    spacing: units.gu(0.8)

                    Rectangle {
                        Layout.preferredWidth: units.gu(4.2)
                        Layout.preferredHeight: units.gu(4.2)
                        Layout.alignment: Qt.AlignVCenter
                        radius: units.gu(1.0)
                        color: tabId === tabsPanel.currentTabId
                               ? (tabsPanel.theme ? tabsPanel.theme.accent : "#4cc2ff")
                               : (tabsPanel.theme ? tabsPanel.theme.field : "#222a35")

                        Label {
                            anchors.centerIn: parent
                            text: index + 1
                            color: tabId === tabsPanel.currentTabId
                                   ? "#071018"
                                   : (tabsPanel.theme ? tabsPanel.theme.textDim : "#8b98a5")
                            font.pixelSize: units.gu(1.4)
                            font.weight: Font.Bold
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: units.gu(0.2)

                        Label {
                            Layout.fillWidth: true
                            text: title && title.length > 0 ? title : "Новая вкладка"
                            color: tabsPanel.theme ? tabsPanel.theme.text : "#e6edf3"
                            font.pixelSize: units.gu(1.6)
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Label {
                            Layout.fillWidth: true
                            text: home ? "Домашняя страница"
                                       : (url && url.length > 0 ? url : "Пустая вкладка")
                            color: tabsPanel.theme ? tabsPanel.theme.textDim : "#8b98a5"
                            font.pixelSize: units.gu(1.2)
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }

                    IconButton {
                        Layout.preferredWidth: units.gu(4.5)
                        Layout.preferredHeight: units.gu(4.5)
                        Layout.alignment: Qt.AlignVCenter
                        theme: tabsPanel.theme
                        iconName: "close"
                        onClicked: tabsPanel.tabClosed(tabId)
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.rightMargin: units.gu(5.2)
                    onClicked: tabsPanel.tabSelected(tabId)
                }
            }
        }

        Rectangle {
            width: parent.width
            height: units.gu(5.2)
            radius: units.gu(1.0)
            color: tabsPanel.theme ? tabsPanel.theme.field : "#222a35"
            border.width: units.dp(1)
            border.color: tabsPanel.theme ? tabsPanel.theme.divider : "#2a323d"

            RowLayout {
                anchors.centerIn: parent
                spacing: units.gu(1.0)

                Icon {
                    Layout.preferredWidth: units.gu(2.2)
                    Layout.preferredHeight: units.gu(2.2)
                    name: "add"
                    color: tabsPanel.theme ? tabsPanel.theme.accent : "#4cc2ff"
                }

                Label {
                    text: "Новая вкладка"
                    color: tabsPanel.theme ? tabsPanel.theme.text : "#e6edf3"
                    font.pixelSize: units.gu(1.6)
                    font.weight: Font.DemiBold
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: tabsPanel.newTabRequested()
            }
        }
        }
    ]
}
