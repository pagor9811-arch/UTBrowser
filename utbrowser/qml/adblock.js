.pragma library

function install() {
    if (window.__utBrowserAdblockInstalled) {
        return;
    }
    window.__utBrowserAdblockInstalled = true;

    var css = [
        "ins.adsbygoogle, .adsbygoogle, [id^='google_ads'], [id^='div-gpt-ad'],",
        "[id*='taboola'], [class*='taboola'], [id*='outbrain'], [class*='outbrain'],",
        "[class*='advert'], [id*='advert'], [class*='sponsored'], [data-ad-slot], [data-ad]",
        "{ display: none !important; visibility: hidden !important; height: 0 !important; }",
        "iframe[src*='doubleclick.net'], iframe[src*='googlesyndication.com'],",
        "iframe[src*='googleadservices.com'], iframe[src*='adservice'],",
        "iframe[src*='taboola.com'], iframe[src*='outbrain.com'],",
        "img[src*='google-analytics.com'], img[src*='facebook.com/tr'],",
        "img[src*='doubleclick.net']",
        "{ display: none !important; visibility: hidden !important; width: 0 !important; height: 0 !important; }",
        ".ytp-ad-module, .video-ads, .ytp-ad-overlay-slot, .ytp-ad-progress-list",
        "{ display: none !important; }"
    ].join("\n");

    function addStyle() {
        if (document.getElementById("__utbrowser-adblock-style")) {
            return;
        }
        var parent = document.head || document.documentElement;
        if (!parent) {
            return;
        }
        var style = document.createElement("style");
        style.id = "__utbrowser-adblock-style";
        style.type = "text/css";
        style.appendChild(document.createTextNode(css));
        parent.appendChild(style);
    }

    var selectors = [
        "ins.adsbygoogle",
        ".adsbygoogle",
        "[id^='google_ads']",
        "[id^='div-gpt-ad']",
        "[id^='aswift']",
        "[id*='taboola']",
        "[class*='taboola']",
        "[id*='outbrain']",
        "[class*='outbrain']",
        "[class*='advert']",
        "[id*='advert']",
        "[class*='sponsored']",
        "[data-ad-slot]",
        "[data-ad]",
        "iframe[src*='doubleclick.net']",
        "iframe[src*='googlesyndication.com']",
        "iframe[src*='googleadservices.com']",
        "iframe[src*='adservice']",
        "iframe[src*='taboola.com']",
        "iframe[src*='outbrain.com']",
        "img[src*='google-analytics.com']",
        "img[src*='facebook.com/tr']",
        "img[src*='doubleclick.net']"
    ].join(",");

    function nuke(rootNode) {
        if (!rootNode || rootNode.nodeType !== 1) {
            return;
        }
        try {
            var nodes = rootNode.querySelectorAll(selectors);
            for (var i = 0; i < nodes.length; i++) {
                var node = nodes[i];
                if (node && node.parentNode) {
                    node.parentNode.removeChild(node);
                }
            }
        } catch (e) {
        }
        try {
            var frames = rootNode.querySelectorAll("iframe");
            for (var j = 0; j < frames.length; j++) {
                var frame = frames[j];
                var src = (frame.src || "").toLowerCase();
                if (src.indexOf("doubleclick.net") >= 0 ||
                    src.indexOf("googlesyndication.com") >= 0 ||
                    src.indexOf("googleadservices.com") >= 0 ||
                    src.indexOf("adservice") >= 0 ||
                    src.indexOf("taboola.com") >= 0 ||
                    src.indexOf("outbrain.com") >= 0 ||
                    src.indexOf("popads") >= 0 ||
                    src.indexOf("propellerads") >= 0) {
                    if (frame.parentNode) {
                        frame.parentNode.removeChild(frame);
                    }
                }
            }
        } catch (e2) {
        }
    }

    function run() {
        addStyle();
        nuke(document.documentElement);
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", run, false);
    } else {
        run();
    }

    try {
        var observer = new MutationObserver(function(mutations) {
            for (var i = 0; i < mutations.length; i++) {
                var added = mutations[i].addedNodes;
                for (var j = 0; j < added.length; j++) {
                    var node = added[j];
                    if (node.nodeType === 1) {
                        nuke(node);
                        if (node.parentNode) {
                            nuke(node.parentNode);
                        }
                    }
                }
            }
        });
        if (document.documentElement) {
            observer.observe(document.documentElement, { childList: true, subtree: true });
        }
    } catch (e3) {
    }
}

var code = "(" + install.toString() + ")();";
