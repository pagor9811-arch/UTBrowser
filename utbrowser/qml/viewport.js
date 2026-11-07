.pragma library

// Мобильный viewport для QtWebEngine.
//
// QtWebEngine не включает поддержку <meta name="viewport"> без Chromium-флага
// --enable-viewport (он передаётся через QTWEBENGINE_CHROMIUM_FLAGS в
// utbrowser.sh). Даже с флагом сайты, у которых мета-тега нет, получают
// «десктопный» layout шириной ~980 CSS-пикселей — именно из-за этого страницы
// выглядят как на компьютере.
//
// Здесь мы:
//   1) добавляем <meta name="viewport" content="width=device-width, initial-scale=1">,
//      если сайт не задал его сам (или задал фиксированную ширину);
//   2) убираем жёсткие ограничения ширины у html/body, из-за которых
//      страница растягивается на десктопную ширину.

function ensureViewport() {
    var head = document.head || document.documentElement;
    if (!head) {
        return;
    }

    var META_NAME = "__utbrowser_viewport";
    var existing = null;
    var metas = document.getElementsByTagName("meta");
    for (var i = 0; i < metas.length; ++i) {
        var name = (metas[i].getAttribute("name") || "").toLowerCase();
        if (name === "viewport") {
            existing = metas[i];
            break;
        }
    }

    var needsFix = false;
    if (!existing) {
        needsFix = true;
    } else {
        var content = (existing.getAttribute("content") || "").toLowerCase();
        // Уже корректный адаптивный viewport — не трогаем.
        var hasDeviceWidth = content.indexOf("device-width") >= 0;
        var hasFixedWidth = /(^|[,;\s])width\s*=\s*\d+/.test(content);
        needsFix = !hasDeviceWidth || hasFixedWidth;
    }

    if (needsFix) {
        var meta = existing;
        if (!meta) {
            meta = document.createElement("meta");
            meta.setAttribute("name", "viewport");
            head.appendChild(meta);
        }
        meta.setAttribute("content", "width=device-width, initial-scale=1, viewport-fit=cover");
        meta.setAttribute(META_NAME, "1");
    }

    // Некоторые сайты жёстко фиксируют минимальную ширину контейнера,
    // из-за чего даже с device-width появляется горизонтальный скролл.
    if (!document.getElementById("__utbrowser_viewport_css")) {
        var style = document.createElement("style");
        style.id = "__utbrowser_viewport_css";
        style.type = "text/css";
        style.appendChild(document.createTextNode(
            "html, body { max-width: 100% !important; overflow-x: hidden !important; "
            + "-webkit-text-size-adjust: 100% !important; text-size-adjust: 100% !important; }"
        ));
        head.appendChild(style);
    }
}

function install() {
    if (window.__utbrowserViewportInstalled) {
        return;
    }
    window.__utbrowserViewportInstalled = true;
    ensureViewport();

    // Сайты часто перерисовывают <head> динамически (SPA) — повторяем проверку.
    var attempts = 0;
    var timer = setInterval(function() {
        attempts += 1;
        ensureViewport();
        if (attempts > 20) {
            clearInterval(timer);
        }
    }, 250);
}

install();
