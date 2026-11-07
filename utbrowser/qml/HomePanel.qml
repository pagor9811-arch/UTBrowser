import QtQuick 2.7
import Ubuntu.Components 1.3

Item {
    id: home
    property var theme
    signal openUrl(string url)

    Rectangle {
        anchors.fill: parent
        color: home.theme ? home.theme.bg : "#0e1116"
        gradient: Gradient {
            GradientStop { position: 0.0; color: home.theme ? home.theme.bg : "#0e1116" }
            GradientStop { position: 1.0; color: home.theme ? home.theme.surface : "#161b22" }
        }
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: homeColumn.implicitHeight + units.gu(4)
        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: homeColumn
            width: parent.width - units.gu(3.0)
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: units.gu(3.0)
            spacing: units.gu(2.0)

            Row {
                width: parent.width
                spacing: units.gu(1.2)

                Rectangle {
                    width: units.gu(5.0)
                    height: width
                    radius: units.gu(1.2)
                    color: home.theme ? home.theme.accent : "#4cc2ff"

                    Label {
                        anchors.centerIn: parent
                        text: "U"
                        color: "#071018"
                        font.pixelSize: units.gu(3.0)
                        font.weight: Font.Bold
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: units.gu(0.2)

                    Label {
                        text: "UT Browser"
                        color: home.theme ? home.theme.text : "#e6edf3"
                        font.pixelSize: units.gu(2.6)
                        font.weight: Font.DemiBold
                    }

                    Label {
                        text: "Быстрый и удобный интернет"
                        color: home.theme ? home.theme.textDim : "#8b98a5"
                        font.pixelSize: units.gu(1.4)
                    }
                }
            }

            Label {
                text: "БЫСТРЫЙ ДОСТУП"
                color: home.theme ? home.theme.textDim : "#8b98a5"
                font.pixelSize: units.gu(1.3)
                font.weight: Font.DemiBold
                font.letterSpacing: units.dp(1)
            }

            Grid {
                width: parent.width
                columns: 2
                spacing: units.gu(1.2)

                Repeater {
                    model: [
                        { name: "DuckDuckGo", url: "https://duckduckgo.com", color: "#de5833", letter: "D" },
                        { name: "Google", url: "https://www.google.com", color: "#4285f4", letter: "G" },
                        { name: "YouTube", url: "https://m.youtube.com", color: "#ff0033", letter: "Y" },
                        { name: "Wikipedia", url: "https://ru.m.wikipedia.org", color: "#636466", letter: "W" },
                        { name: "Yandex", url: "https://yandex.ru", color: "#fc3f1d", letter: "Я" },
                        { name: "GitHub", url: "https://github.com", color: "#6e5494", letter: "G" },
                        { name: "Reddit", url: "https://www.reddit.com", color: "#ff4500", letter: "R" },
                        { name: "Ubuntu", url: "https://ubuntu.com", color: "#e95420", letter: "U" },
                        { name: "Habr", url: "https://habr.com", color: "#629fbc", letter: "H" },
                        { name: "Stack Overflow", url: "https://stackoverflow.com", color: "#f48024", letter: "S" }
                    ]

                    delegate: Rectangle {
                        width: (homeColumn.width - units.gu(1.2)) / 2
                        height: units.gu(9.0)
                        radius: units.gu(1.2)
                        color: home.theme ? home.theme.tile : "#1b222c"
                        border.width: units.dp(1)
                        border.color: home.theme ? home.theme.divider : "#2a323d"

                        Column {
                            anchors.fill: parent
                            anchors.margins: units.gu(1.2)
                            spacing: units.gu(0.5)

                            Rectangle {
                                width: units.gu(3.4)
                                height: width
                                radius: units.gu(0.8)
                                color: modelData.color

                                Label {
                                    anchors.centerIn: parent
                                    text: modelData.letter
                                    color: "#ffffff"
                                    font.pixelSize: units.gu(1.8)
                                    font.weight: Font.Bold
                                }
                            }

                            Item {
                                width: units.dp(1)
                                height: units.gu(0.3)
                            }

                            Label {
                                width: parent.width
                                text: modelData.name
                                color: home.theme ? home.theme.text : "#e6edf3"
                                font.pixelSize: units.gu(1.5)
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                            Label {
                                width: parent.width
                                text: modelData.url.replace("https://", "").replace("www.", "")
                                color: home.theme ? home.theme.textDim : "#8b98a5"
                                font.pixelSize: units.gu(1.1)
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: home.openUrl(modelData.url)
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: units.gu(6.0)
                radius: units.gu(1.0)
                color: home.theme ? home.theme.surfaceAlt : "#1f2630"

                Column {
                    anchors.fill: parent
                    anchors.margins: units.gu(1.0)
                    spacing: units.gu(0.2)

                    Label {
                        text: "Совет"
                        color: home.theme ? home.theme.accent : "#4cc2ff"
                        font.pixelSize: units.gu(1.2)
                        font.weight: Font.DemiBold
                    }

                    Label {
                        width: parent.width
                        text: "Введите адрес или поисковый запрос в строке снизу. Поисковик можно сменить в меню."
                        color: home.theme ? home.theme.textDim : "#8b98a5"
                        font.pixelSize: units.gu(1.2)
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}
