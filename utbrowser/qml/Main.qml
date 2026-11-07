import QtQuick 2.7
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Morph.Web 0.1
import QtWebEngine 1.5
import Qt.labs.settings 1.0
import "adblock.js" as Adblock

MainView {
    id: root
    applicationName: "utbrowser"
    backgroundColor: theme.bg
    anchorToKeyboard: true

    Theme { id: theme }

    Settings {
        id: appSettings
        category: "utbrowser"
        property int searchEngine: 0
        property bool desktopMode: false
        property bool adblockEnabled: true
    }

    readonly property string mobileUserAgent: "Mozilla/5.0 (Linux; Android 10; Redmi 7A) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36"
    readonly property string desktopUserAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"

    property var searchUrls: [
        "https://duckduckgo.com/?q=",
        "https://www.google.com/search?q=",
        "https://yandex.com/search/?text="
    ]

    property string currentUrl: ""
    property string currentTitle: "UT Browser"
    property bool homeVisible: true
    property bool isLoading: false
    property int loadProgress: 0
    property bool canGoBack: false
    property bool canGoForward: false
    property int currentTabId: -1
    property int nextTabId: 1
    property string toastText: ""

    WebEngineProfile {
        id: browserProfile
        storageName: "utbrowser"
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        httpCacheType: WebEngineProfile.DiskHttpCache
        httpUserAgent: appSettings.desktopMode ? root.desktopUserAgent : root.mobileUserAgent
    }

    ListModel {
        id: tabModel
    }

    WebEngineScript {
        id: adblockScript
        name: "utbrowser-adblock"
        sourceCode: Adblock.code
        injectionPoint: WebEngineScript.DocumentReady
        worldId: WebEngineScript.MainWorld
        runOnSubframes: true
    }

    function tabIndexById(id) {
        for (var i = 0; i < tabModel.count; ++i) {
            if (tabModel.get(i).tabId === id) {
                return i;
            }
        }
        return -1;
    }

    function tabDataById(id) {
        var idx = tabIndexById(id);
        return idx >= 0 ? tabModel.get(idx) : null;
    }

    function currentTabData() {
        return tabDataById(currentTabId);
    }

    function currentWebView() {
        var idx = tabIndexById(currentTabId);
        if (idx < 0) {
            return null;
        }
        return webRepeater.itemAt(idx);
    }

    function updateTab(id, key, value) {
        var idx = tabIndexById(id);
        if (idx >= 0) {
            tabModel.setProperty(idx, key, value);
        }
    }

    function createTab(url, makeCurrent) {
        var id = nextTabId;
        nextTabId = nextTabId + 1;
        var initialUrl = url ? url : "";
        tabModel.append({
            "tabId": id,
            "title": initialUrl.length > 0 ? "Загрузка…" : "Новая вкладка",
            "url": initialUrl,
            "home": initialUrl.length === 0
        });
        if (makeCurrent) {
            selectTab(id);
        }
        return id;
    }

    function selectTab(id) {
        var data = tabDataById(id);
        if (!data) {
            return;
        }
        currentTabId = id;
        currentUrl = data.url ? data.url : "";
        currentTitle = data.title ? data.title : "UT Browser";
        homeVisible = data.home;
        isLoading = false;
        loadProgress = 0;
        canGoBack = false;
        canGoForward = false;
        addressInput.focus = false;
        setAddressText(homeVisible ? "" : currentUrl, true);
        Qt.callLater(refreshFromCurrentWebView);
        Qt.callLater(function() {
            var w = currentWebView();
            if (w && !homeVisible) {
                w.forceActiveFocus();
            }
        });
    }

    function closeTab(id) {
        var idx = tabIndexById(id);
        if (idx < 0) {
            return;
        }
        var wasCurrent = (id === currentTabId);
        tabModel.remove(idx);
        if (tabModel.count === 0) {
            createTab("", true);
        } else if (wasCurrent) {
            var newIdx = Math.min(idx, tabModel.count - 1);
            selectTab(tabModel.get(newIdx).tabId);
        }
    }

    function closeAllTabs() {
        tabModel.clear();
        currentTabId = -1;
        createTab("", true);
    }

    function refreshFromCurrentWebView() {
        var w = currentWebView();
        if (!w) {
            canGoBack = false;
            canGoForward = false;
            isLoading = false;
            loadProgress = 0;
            return;
        }
        canGoBack = w.canGoBack;
        canGoForward = w.canGoForward;
        isLoading = w.loading;
        loadProgress = w.loadProgress;
        if (!homeVisible) {
            var u = w.url ? w.url.toString() : "";
            if (u.length > 0 && u !== "about:blank") {
                currentUrl = u;
                setAddressText(u, false);
            }
            if (w.title && w.title.length > 0) {
                currentTitle = w.title;
            }
        }
    }

    function setAddressText(value, force) {
        if (force || !addressInput.activeFocus) {
            addressInput.text = value;
        }
    }

    function hostOf(value) {
        if (!value) {
            return "";
        }
        var s = value.toString();
        s = s.replace(/^[a-zA-Z][a-zA-Z0-9+.-]*:\/\//, "");
        var slash = s.indexOf("/");
        if (slash >= 0) {
            s = s.substring(0, slash);
        }
        var query = s.indexOf("?");
        if (query >= 0) {
            s = s.substring(0, query);
        }
        return s;
    }

    function looksLikeUrl(value) {
        if (/\s/.test(value)) {
            return false;
        }
        if (/^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(value)) {
            return true;
        }
        if (/^localhost(:\d+)?(\/.*)?$/i.test(value)) {
            return true;
        }
        if (/^(\d{1,3}\.){3}\d{1,3}(:\d+)?(\/.*)?$/.test(value)) {
            return true;
        }
        if (/^[^\s\/]+\.[^\s\/]{2,}(:\d+)?([\/?#].*)?$/.test(value)) {
            return true;
        }
        return false;
    }

    function resolveInput(value) {
        var text = value.replace(/^\s+|\s+$/g, "");
        if (text.length === 0) {
            return "";
        }
        if (/^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(text)) {
            return text;
        }
        if (looksLikeUrl(text)) {
            return "https://" + text;
        }
        var engine = appSettings.searchEngine;
        if (engine < 0 || engine >= searchUrls.length) {
            engine = 0;
        }
        return searchUrls[engine] + encodeURIComponent(text);
    }

    function navigate(value) {
        var target = resolveInput(value);
        if (target.length === 0) {
            return;
        }
        loadInCurrentTab(target);
        addressInput.focus = false;
    }

    function loadInCurrentTab(target) {
        var idx = tabIndexById(currentTabId);
        if (idx < 0) {
            return;
        }
        tabModel.setProperty(idx, "url", target);
        tabModel.setProperty(idx, "home", false);
        tabModel.setProperty(idx, "title", "Загрузка…");
        homeVisible = false;
        currentUrl = target;
        currentTitle = "Загрузка…";
        setAddressText(target, true);
        var w = webRepeater.itemAt(idx);
        if (w) {
            w.url = target;
        }
    }

    function goBack() {
        if (homeVisible) {
            var data = currentTabData();
            if (data && data.url && data.url.length > 0) {
                homeVisible = false;
                updateTab(currentTabId, "home", false);
                var hiddenWeb = currentWebView();
                if (hiddenWeb) {
                    hiddenWeb.forceActiveFocus();
                }
                Qt.callLater(refreshFromCurrentWebView);
            }
            return;
        }
        var w = currentWebView();
        if (w && w.canGoBack) {
            w.goBack();
        }
    }

    function goForward() {
        if (homeVisible) {
            return;
        }
        var w = currentWebView();
        if (w && w.canGoForward) {
            w.goForward();
        }
    }

    function goHome() {
        if (homeVisible) {
            return;
        }
        var idx = tabIndexById(currentTabId);
        if (idx < 0) {
            return;
        }
        var w = currentWebView();
        if (w) {
            w.stop();
        }
        tabModel.setProperty(idx, "home", true);
        homeVisible = true;
        isLoading = false;
        loadProgress = 0;
        setAddressText("", true);
        addressInput.focus = false;
    }

    function reloadOrStop() {
        if (homeVisible) {
            return;
        }
        var w = currentWebView();
        if (!w) {
            return;
        }
        if (w.loading) {
            w.stop();
        } else {
            var u = w.url ? w.url.toString() : "";
            if (u.length > 0 && u !== "about:blank") {
                w.reload();
            }
        }
    }

    function setDesktopMode(enabled) {
        if (appSettings.desktopMode === enabled) {
            return;
        }
        appSettings.desktopMode = enabled;
        var w = currentWebView();
        if (w && !homeVisible && w.url.toString().length > 0) {
            w.reload();
        }
        showToast(enabled ? "Включена полная версия сайтов" : "Включена мобильная версия сайтов");
    }

    function setAdblockEnabled(enabled) {
        if (appSettings.adblockEnabled === enabled) {
            return;
        }
        appSettings.adblockEnabled = enabled;
        var w = currentWebView();
        if (w && !homeVisible && w.url.toString().length > 0) {
            w.reload();
        }
        showToast(enabled ? "Блокировка рекламы включена" : "Блокировка рекламы выключена");
    }

    function clearBrowsingData() {
        for (var i = 0; i < webRepeater.count; ++i) {
            var w = webRepeater.itemAt(i);
            if (w) {
                try {
                    w.runJavaScript("try{localStorage.clear();sessionStorage.clear();}catch(e){}");
                } catch (e) {
                }
            }
        }
        try {
            browserProfile.clearHttpCache();
        } catch (e2) {
        }
        try {
            if (browserProfile.cookieStore) {
                browserProfile.cookieStore.deleteAllCookies();
            }
        } catch (e3) {
        }
        clearResetTimer.restart();
        showToast("Очистка кэша, cookies и истории…");
    }

    function showToast(value) {
        toastText = value;
        toast.opacity = 1.0;
        toastTimer.restart();
    }

    Timer {
        id: toastTimer
        interval: 2300
        repeat: false
        onTriggered: toast.opacity = 0.0
    }

    Timer {
        id: clearResetTimer
        interval: 250
        repeat: false
        onTriggered: {
            closeAllTabs();
            showToast("Данные браузера очищены");
        }
    }

    Page {
        id: page
        anchors.fill: parent

        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            spacing: 0

            Rectangle {
                id: header
                Layout.fillWidth: true
                Layout.preferredHeight: units.gu(5.8)
                color: theme.surface

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: units.gu(1.4)
                    anchors.rightMargin: units.gu(0.8)
                    spacing: units.gu(1.0)

                    Rectangle {
                        Layout.preferredWidth: units.gu(3.4)
                        Layout.preferredHeight: units.gu(3.4)
                        radius: width / 2
                        color: theme.accent

                        Label {
                            anchors.centerIn: parent
                            text: "U"
                            color: "#071018"
                            font.pixelSize: units.gu(2.0)
                            font.weight: Font.Bold
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: units.gu(0.1)

                        Label {
                            Layout.fillWidth: true
                            text: root.homeVisible
                                  ? "UT Browser"
                                  : (root.currentTitle.length > 0 ? root.currentTitle : "UT Browser")
                            color: theme.text
                            font.pixelSize: units.gu(1.6)
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.homeVisible
                                  ? "Домашняя страница"
                                  : (root.hostOf(root.currentUrl).length > 0
                                     ? root.hostOf(root.currentUrl)
                                     : "UT Browser")
                            color: theme.textDim
                            font.pixelSize: units.gu(1.1)
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }

                    Icon {
                        Layout.preferredWidth: units.gu(2.0)
                        Layout.preferredHeight: units.gu(2.0)
                        name: root.currentUrl.indexOf("https://") === 0 ? "security-high" : "security-medium"
                        color: root.currentUrl.indexOf("https://") === 0 ? theme.success : theme.textDim
                        visible: !root.homeVisible
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: units.dp(1)
                color: theme.divider
            }

            Item {
                id: contentArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Rectangle {
                    anchors.fill: parent
                    color: theme.bg
                }

                Repeater {
                    id: webRepeater
                    model: tabModel

                    delegate: WebView {
                        id: webView
                        anchors.fill: parent
                        visible: tabId === root.currentTabId && !root.homeVisible
                        enabled: visible
                        profile: browserProfile
                        userScripts: appSettings.adblockEnabled ? [adblockScript] : []
                        zoomFactor: 1.0

                        settings.javascriptEnabled: true
                        settings.localStorageEnabled: true
                        settings.autoLoadImages: true
                        settings.javascriptCanOpenWindows: true
                        settings.pluginsEnabled: false

                        property int tabId: model.tabId

                        Component.onCompleted: {
                            if (model.url && model.url.length > 0) {
                                url = model.url;
                            }
                            if (tabId === root.currentTabId) {
                                Qt.callLater(root.refreshFromCurrentWebView);
                            }
                        }

                        onUrlChanged: {
                            var u = url.toString();
                            root.updateTab(tabId, "url", u);
                            if (u.length > 0 && u !== "about:blank"
                                    && (tabId !== root.currentTabId || !root.homeVisible)) {
                                root.updateTab(tabId, "home", false);
                            }
                            if (tabId === root.currentTabId && !root.homeVisible) {
                                root.currentUrl = u;
                                root.setAddressText(u, false);
                            }
                        }

                        onTitleChanged: {
                            var t = title;
                            if (!t || t.length === 0) {
                                t = root.hostOf(url.toString());
                            }
                            if (!t || t.length === 0) {
                                t = "Новая вкладка";
                            }
                            root.updateTab(tabId, "title", t);
                            if (tabId === root.currentTabId) {
                                root.currentTitle = t;
                            }
                        }

                        onLoadingChanged: {
                            if (loadRequest.status === WebEngineLoadRequest.LoadStartedStatus) {
                                if (tabId !== root.currentTabId || !root.homeVisible) {
                                    root.updateTab(tabId, "home", false);
                                }
                                if (tabId === root.currentTabId && !root.homeVisible) {
                                    root.isLoading = true;
                                    root.loadProgress = 0;
                                }
                            } else if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus) {
                                if (tabId === root.currentTabId && !root.homeVisible) {
                                    root.isLoading = false;
                                    root.loadProgress = 100;
                                    root.refreshFromCurrentWebView();
                                }
                                if (appSettings.adblockEnabled) {
                                    webView.runJavaScript(Adblock.code);
                                }
                            } else if (loadRequest.status === WebEngineLoadRequest.LoadFailedStatus) {
                                if (tabId === root.currentTabId && !root.homeVisible) {
                                    root.isLoading = false;
                                    root.refreshFromCurrentWebView();
                                    if (loadRequest.errorCode !== 3) {
                                        root.showToast("Не удалось загрузить: " + loadRequest.errorString);
                                    }
                                }
                            }
                        }

                        onLoadProgressChanged: {
                            if (tabId === root.currentTabId && !root.homeVisible) {
                                root.loadProgress = loadProgress;
                                root.isLoading = loadProgress < 100;
                                if (appSettings.adblockEnabled && loadProgress > 15 && loadProgress < 100) {
                                    webView.runJavaScript(Adblock.code);
                                }
                            }
                        }

                        onCanGoBackChanged: {
                            if (tabId === root.currentTabId) {
                                root.canGoBack = canGoBack;
                            }
                        }

                        onCanGoForwardChanged: {
                            if (tabId === root.currentTabId) {
                                root.canGoForward = canGoForward;
                            }
                        }

                        onNewViewRequested: {
                            if (request.requestedUrl
                                    && request.requestedUrl.toString().length > 0) {
                                root.createTab(request.requestedUrl.toString(), true);
                            }
                        }
                    }
                }

                HomePanel {
                    id: homePanel
                    anchors.fill: parent
                    theme: theme
                    visible: root.homeVisible
                    onOpenUrl: root.loadInCurrentTab(url)
                }

                ProgressBar {
                    id: progressBar
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: units.dp(4)
                    minimumValue: 0
                    maximumValue: 100
                    value: root.loadProgress
                    visible: root.isLoading && !root.homeVisible
                    z: 5
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: units.dp(1)
                color: theme.divider
            }

            Rectangle {
                id: footer
                Layout.fillWidth: true
                Layout.preferredHeight: footerLayout.implicitHeight + units.gu(1.4)
                color: theme.surface

                ColumnLayout {
                    id: footerLayout
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: units.gu(0.8)
                    anchors.rightMargin: units.gu(0.8)
                    anchors.topMargin: units.gu(0.8)
                    spacing: units.gu(0.6)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: units.gu(0.6)

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: units.gu(4.6)
                            radius: units.gu(0.9)
                            color: theme.field
                            border.width: units.dp(1)
                            border.color: addressInput.activeFocus ? theme.accent : theme.divider

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: units.gu(1.0)
                                anchors.rightMargin: units.gu(0.4)
                                spacing: units.gu(0.4)

                                Icon {
                                    Layout.preferredWidth: units.gu(1.8)
                                    Layout.preferredHeight: units.gu(1.8)
                                    name: "search"
                                    color: theme.textDim
                                }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Text {
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                        text: "Введите адрес или поисковый запрос"
                                        color: theme.textDim
                                        font.pixelSize: units.gu(1.4)
                                        elide: Text.ElideRight
                                        visible: addressInput.text.length === 0 && !addressInput.activeFocus
                                    }

                                    TextInput {
                                        id: addressInput
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        height: implicitHeight
                                        color: theme.text
                                        selectionColor: theme.accent
                                        selectedTextColor: "#071018"
                                        font.pixelSize: units.gu(1.5)
                                        clip: true
                                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                                        onAccepted: root.navigate(text)
                                        onActiveFocusChanged: {
                                            if (activeFocus) {
                                                selectAll();
                                            } else {
                                                root.setAddressText(root.homeVisible ? "" : root.currentUrl, true);
                                            }
                                        }
                                    }
                                }

                                IconButton {
                                    Layout.preferredWidth: units.gu(3.6)
                                    Layout.preferredHeight: units.gu(3.6)
                                    theme: theme
                                    iconName: "close"
                                    visible: addressInput.text.length > 0
                                    onClicked: {
                                        addressInput.text = "";
                                        addressInput.forceActiveFocus();
                                    }
                                }
                            }
                        }

                        IconButton {
                            Layout.preferredWidth: units.gu(4.6)
                            Layout.preferredHeight: units.gu(4.6)
                            theme: theme
                            iconName: root.isLoading ? "stop" : "reload"
                            onClicked: root.reloadOrStop()
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        IconButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: units.gu(5.2)
                            theme: theme
                            iconName: "go-previous"
                            enabled: root.homeVisible ? root.currentUrl.length > 0 : root.canGoBack
                            onClicked: root.goBack()
                        }

                        IconButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: units.gu(5.2)
                            theme: theme
                            iconName: "go-next"
                            enabled: !root.homeVisible && root.canGoForward
                            onClicked: root.goForward()
                        }

                        IconButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: units.gu(5.2)
                            theme: theme
                            iconName: "home"
                            onClicked: root.goHome()
                        }

                        IconButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: units.gu(5.2)
                            theme: theme
                            iconName: "tab"
                            badge: tabModel.count
                            onClicked: {
                                tabsPanel.opened = true;
                                menuPanel.opened = false;
                            }
                        }

                        IconButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: units.gu(5.2)
                            theme: theme
                            iconName: "navigation-menu"
                            onClicked: {
                                menuPanel.opened = true;
                                tabsPanel.opened = false;
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: toast
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: footer.height + units.gu(1.0)
            width: Math.min(parent.width - units.gu(3.0), toastLabel.implicitWidth + units.gu(3.0))
            height: units.gu(4.2)
            radius: units.gu(0.9)
            color: theme.surfaceAlt
            border.width: units.dp(1)
            border.color: theme.divider
            opacity: 0.0
            z: 300

            Behavior on opacity { NumberAnimation { duration: 180 } }

            Label {
                id: toastLabel
                anchors.centerIn: parent
                width: parent.width - units.gu(2.0)
                text: root.toastText
                color: theme.text
                font.pixelSize: units.gu(1.4)
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }

        TabsPanel {
            id: tabsPanel
            anchors.fill: parent
            theme: theme
            tabsModel: tabModel
            currentTabId: root.currentTabId
            onTabSelected: {
                root.selectTab(tabId);
                tabsPanel.opened = false;
            }
            onTabClosed: root.closeTab(tabId)
            onNewTabRequested: {
                root.createTab("", true);
                tabsPanel.opened = false;
                Qt.callLater(function() {
                    addressInput.forceActiveFocus();
                });
            }
            onClosed: tabsPanel.opened = false
        }

        MenuPanel {
            id: menuPanel
            anchors.fill: parent
            theme: theme
            searchEngine: appSettings.searchEngine
            desktopMode: appSettings.desktopMode
            adblockEnabled: appSettings.adblockEnabled
            onSearchEngineSelected: {
                appSettings.searchEngine = index;
                root.showToast("Поисковик: " + ["DuckDuckGo", "Google", "Yandex"][index]);
            }
            onDesktopModeToggled: root.setDesktopMode(enabled)
            onAdblockToggled: root.setAdblockEnabled(enabled)
            onNewTabRequested: {
                root.createTab("", true);
                menuPanel.opened = false;
            }
            onHomeRequested: {
                root.goHome();
                menuPanel.opened = false;
            }
            onClearDataRequested: {
                menuPanel.opened = false;
                root.clearBrowsingData();
            }
            onClosed: menuPanel.opened = false
        }
    }

    Component.onCompleted: {
        createTab("", true);
    }
}
