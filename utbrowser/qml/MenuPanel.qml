import QtQuick 2.7
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3

BottomSheet {
    id: menuPanel
    property int searchEngine: 0
    property bool desktopMode: false
    property bool adblockEnabled: true
    property string versionLabel: "UT Browser"
    signal searchEngineSelected(int index)
    signal desktopModeToggled(bool enabled)
    signal adblockToggled(bool enabled)
    signal newTabRequested()
    signal homeRequested()
    signal clearDataRequested()

    title: "Меню и настройки"
    preferredHeight: units.gu(74)

    content: [
        Column {
            width: parent.width
            spacing: units.gu(1.6)

        Label {
            text: "ПОИСКОВАЯ СИСТЕМА"
            color: menuPanel.theme ? menuPanel.theme.textDim : "#8b98a5"
            font.pixelSize: units.gu(1.2)
            font.weight: Font.DemiBold
            font.letterSpacing: units.dp(1)
        }

        Flow {
            width: parent.width
            height: childrenRect.height
            spacing: units.gu(0.8)

            Repeater {
                model: ["DuckDuckGo", "Google", "Yandex"]

                delegate: SelectChip {
                    theme: menuPanel.theme
                    text: modelData
                    selected: index === menuPanel.searchEngine
                    onClicked: menuPanel.searchEngineSelected(index)
                }
            }
        }

        Label {
            text: "ВЕРСИЯ САЙТОВ"
            color: menuPanel.theme ? menuPanel.theme.textDim : "#8b98a5"
            font.pixelSize: units.gu(1.2)
            font.weight: Font.DemiBold
            font.letterSpacing: units.dp(1)
        }

        Flow {
            width: parent.width
            height: childrenRect.height
            spacing: units.gu(0.8)

            SelectChip {
                theme: menuPanel.theme
                text: "Мобильная"
                selected: !menuPanel.desktopMode
                onClicked: menuPanel.desktopModeToggled(false)
            }

            SelectChip {
                theme: menuPanel.theme
                text: "Полная (Desktop)"
                selected: menuPanel.desktopMode
                onClicked: menuPanel.desktopModeToggled(true)
            }
        }

        Rectangle {
            width: parent.width
            height: units.dp(1)
            color: menuPanel.theme ? menuPanel.theme.divider : "#2a323d"
        }

        RowLayout {
            width: parent.width
            spacing: units.gu(1.0)

            ColumnLayout {
                Layout.fillWidth: true
                spacing: units.gu(0.1)

                Label {
                    Layout.fillWidth: true
                    text: "Блокировка рекламы и трекеров"
                    color: menuPanel.theme ? menuPanel.theme.text : "#e6edf3"
                    font.pixelSize: units.gu(1.5)
                    font.weight: Font.DemiBold
                }

                Label {
                    Layout.fillWidth: true
                    text: "Скрывает рекламные баннеры и трекеры на страницах"
                    color: menuPanel.theme ? menuPanel.theme.textDim : "#8b98a5"
                    font.pixelSize: units.gu(1.1)
                    wrapMode: Text.WordWrap
                }
            }

            ToggleSwitch {
                theme: menuPanel.theme
                checked: menuPanel.adblockEnabled
                onToggled: menuPanel.adblockToggled(!menuPanel.adblockEnabled)
            }
        }

        Rectangle {
            width: parent.width
            height: units.dp(1)
            color: menuPanel.theme ? menuPanel.theme.divider : "#2a323d"
        }

        MenuRow {
            theme: menuPanel.theme
            iconName: "add"
            text: "Новая вкладка"
            onClicked: menuPanel.newTabRequested()
        }

        MenuRow {
            theme: menuPanel.theme
            iconName: "home"
            text: "Домашняя страница"
            onClicked: menuPanel.homeRequested()
        }

        MenuRow {
            theme: menuPanel.theme
            iconName: "delete"
            text: "Очистить кэш, cookies и историю"
            onClicked: menuPanel.clearDataRequested()
        }

        Rectangle {
            width: parent.width
            height: units.dp(1)
            color: menuPanel.theme ? menuPanel.theme.divider : "#2a323d"
        }

        Label {
            width: parent.width
            text: menuPanel.versionLabel
            color: menuPanel.theme ? menuPanel.theme.textDim : "#8b98a5"
            font.pixelSize: units.gu(1.1)
            horizontalAlignment: Text.AlignHCenter
        }
        }
    ]
}
