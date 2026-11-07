# UT Browser

Мобильный браузер для Ubuntu Touch 16.04 (xenial): QML + QtWebEngine через
`Morph.Web`.

## Что нового в 1.1.0

### 1. Сайты больше не открываются в «десктопном» виде

Причина была не в User-Agent, а в движке: QtWebEngine не учитывает
`<meta name="viewport">` без Chromium-флага `--enable-viewport`. В итоге
Chromium верстал страницу под ширину окна в физических пикселях
(720–1080 CSS-px) — отсюда мелкий текст и десктопный layout.

Что сделано:

- `utbrowser.sh` — launcher, который выставляет
  `QTWEBENGINE_CHROMIUM_FLAGS="--enable-viewport
  --main-frame-resizes-are-orientation-changes --enable-pinch
  --enable-overlay-scrollbar"` перед стартом `qmlscene`;
- `qml/viewport.js` — user script, который добавляет адаптивный
  `<meta name="viewport">`, если сайт его не задал (или задал фиксированную
  ширину), и снимает жёсткие `min-width` у `html/body`;
- режим «Полная (Desktop)» отключает этот скрипт, чтобы десктопная вёрстка
  оставалась широкой.

### 2. Вкладки открываются внутри приложения

- `onNewViewRequested` теперь «усыновляет» созданный движком WebContents в новый
  `WebView` через `request.openIn(view)`, а не теряет его. `target="_blank"`,
  `window.open()` и кнопки «открыть в новой вкладке» остаются в UT Browser.
- Вкладки создаются императивно (`createTab` / `adoptNewView`), ссылка на
  `WebView` хранится в модели вкладок — при закрытии вкладки view уничтожается,
  память не течёт, как было с `Repeater`.
- Фоновые вкладки (`NewViewInBackgroundTab`) не выхватывают фокус.
- Поддержан полноэкранный режим видео (`fullScreenSupportEnabled`).

### 3. Движок и совместимость

- User-Agent больше не врёт про `Chrome/124`: версия Chromium определяется у
  самого движка при старте (`detectEngine()`), UA формируется в формате
  Ubuntu Touch (как в Morph Browser).
- Переключение «Мобильная / Полная версия» применяется сразу: QtWebEngine 5.9
  в `setHttpUserAgent()` дергает `SetUserAgentOverride()` для всех страниц
  профиля, после чего вкладки перезагружаются.
- Версия движка видна в меню: `UT Browser 1.1 · Chromium 56 · Ubuntu Touch`.

## Сборка

Нужен [Clickable](https://clickable-ut.dev) 8.x и Docker.

```bash
clickable build --arch armhf   # собрать .click в build/
clickable                      # собрать + установить на подключённое устройство
clickable logs                 # логи приложения с устройства
```

`clickable.yaml` уже настроен: builder `pure`, framework `ubuntu-sdk-16.04.4`,
исходники берутся из `utbrowser/`. Собранные `*.click` в git не попадают
(см. `.gitignore`) — пакет надо пересобрать после правок, старый
`utbrowser_1.0.0_all.click` из репозитория удалён именно поэтому.

## Установка на устройство вручную

```bash
clickable build --arch armhf
scp build/armhf/utbrowser_1.1.0_all.click phablet@<IP>:/home/phablet/
ssh phablet@<IP>
pkcon install-local --allow-untrusted /home/phablet/utbrowser_1.1.0_all.click
```

Проверить, что нужен именно `armhf`: на Redmi 7A (arm32) ставится `armhf`,
на arm64-устройствах — `arm64`. Приложение architecture-independent (`all`),
поэтому подходит любой из вариантов.

## Откат

```bash
click unregister utbrowser utbrowser   # снять приложение
```
