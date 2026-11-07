#!/bin/sh
# UT Browser launcher.
#
# Флаги Chromium, которые нужны для мобильной вёрстки, нельзя включить из QML:
# QtWebEngine читает QTWEBENGINE_CHROMIUM_FLAGS только при инициализации
# (до создания первого WebEngineProfile). Кроме того, если эта переменная
# задана, Qt 5.9 полностью заменяет ею аргументы командной строки приложения,
# поэтому флаги передаём именно через окружение, а не аргументами qmlscene.
#
#   --enable-viewport
#       Включает поддержку <meta name="viewport">. Без него Chromium игнорирует
#       мета-тег и верстает страницу под ширину окна в физических пикселях —
#       именно из-за этого сайты открывались в «десктопном» виде.
#   --main-frame-resizes-are-orientation-changes
#       Правильный пересчёт layout при повороте экрана.
#   --enable-pinch / --enable-overlay-scrollbar
#       Жесты масштабирования и мобильные полосы прокрутки.

set -u

APP_DIR=$(dirname "$0")
cd "$APP_DIR" || exit 1

UTB_FLAGS="--enable-viewport --main-frame-resizes-are-orientation-changes --enable-pinch --enable-overlay-scrollbar"

# Сохраняем флаги, которые мог задать пользователь или система.
CURRENT_FLAGS="${QTWEBENGINE_CHROMIUM_FLAGS:-}"
for flag in $UTB_FLAGS; do
    case " $CURRENT_FLAGS " in
        *" $flag "*) ;;
        *) CURRENT_FLAGS="$CURRENT_FLAGS $flag" ;;
    esac
done
QTWEBENGINE_CHROMIUM_FLAGS="$CURRENT_FLAGS"
export QTWEBENGINE_CHROMIUM_FLAGS

# На части устройств (hybris/GLES) аппаратное ускорение видео роняет вкладку;
# QtWebEngine и так запускается в режиме, где это не критично.
QTWEBENGINE_DISABLE_GPU_THREAD="${QTWEBENGINE_DISABLE_GPU_THREAD:-1}"
export QTWEBENGINE_DISABLE_GPU_THREAD

exec qmlscene utbrowser.qml "$@"
