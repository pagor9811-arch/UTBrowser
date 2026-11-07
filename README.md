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

## Установка на устройство

На Ubuntu Touch **нет `git`**, `apt install` не поможет (корневая ФС read-only),
поэтому исходники на телефон забираем через `wget`/`curl` и запускаем локальный
сборщик `build-click.py` (нужен только `python3` из прошивки — ни Docker, ни
Clickable, ни `ar` не требуются).

### 1. Скачать исходники и собрать на телефоне

```bash
mkdir -p ~/utb && cd ~/utb
wget -O - https://codeload.github.com/pagor9811-arch/UTBrowser/tar.gz/refs/heads/arena/01d4f8b9-utbrowser | tar xz --strip-components=1
python3 build-click.py
# → utbrowser_1.1.0_all.click
```

### 2. Установить

```bash
pkcon install-local --allow-untrusted ~/utb/utbrowser_1.1.0_all.click
```

Альтернатива, если `pkcon` ругается на неподписанный пакет:

```bash
click install --user=phablet ~/utb/utbrowser_1.1.0_all.click
```

Перезапустить приложение (иконка на рабочем столе/в лаунчере).

### 3. Собрать на ПК и скопировать (если удобнее)

```bash
./build-click.sh                  # или: clickable build --arch armhf
scp utbrowser_1.1.0_all.click phablet@<IP>:/home/phablet/
ssh phablet@<IP>
pkcon install-local --allow-untrusted /home/phablet/utbrowser_1.1.0_all.click
```

Пакет architecture-independent (`all`), поэтому один и тот же файл подходит и
для armhf, и для arm64.

## Проверка после установки

1. Меню → внизу строка `UT Browser 1.1 · Chromium 56 · Ubuntu Touch`
   (число — реальная версия движка вашей прошивки).
2. Открыть сайт и сравнить: текст должен быть крупным, без горизонтального
   скролла (мобильный режим).
3. Тап по ссылке с `target="_blank"` — открывается новая вкладка в UT Browser,
   а не другое приложение.
4. Если вёрстка всё ещё «десктопная» — флаги движка не применились: проверьте,
   что запуск идёт через `utbrowser.sh` (в installed-каталоге
   `/opt/click.ubuntu.com/utbrowser/1.1.0/utbrowser.desktop` должно быть
   `Exec=./utbrowser.sh`), и логи: `journalctl -f | grep -i utbrowser`.

## Если нужно переустановить ту же версию

Click не ставит второй раз пакет с той же версией («already installed»),
поэтому перед повторной установкой удалите старую:

```bash
pkcon remove utbrowser        # или: click unregister utbrowser utbrowser
pkcon install-local --allow-untrusted ~/utb/utbrowser_1.1.0_all.click
```

## Обновление исходников на телефоне

`git` на устройстве нет, поэтому просто скачайте архив заново (он перезапишет
файлы поверх):

```bash
cd ~/utb
wget -O utb.tar.gz https://codeload.github.com/pagor9811-arch/UTBrowser/tar.gz/refs/heads/arena/01d4f8b9-utbrowser
tar xzf utb.tar.gz --strip-components=1 --overwrite
python3 build-click.py
```

## Откат

```bash
click unregister utbrowser utbrowser   # снять приложение
```
