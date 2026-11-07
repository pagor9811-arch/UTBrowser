#!/usr/bin/env python3
"""Сборка click-пакета без Docker, без Clickable и без binutils.

Работает прямо на телефоне Ubuntu Touch: нужен только python3 из прошивки.
Пакет architecture-independent (all) — подходит и для armhf, и для arm64.

    python3 build-click.py            # → utbrowser_<version>_all.click
    ./build-click.sh                  # то же самое, если python3 в PATH
"""

import io
import json
import os
import shutil
import sys
import tarfile
import tempfile

ROOT = os.path.dirname(os.path.abspath(__file__))
APP_DIR = os.path.join(ROOT, "utbrowser")

# Файлы приложения, попадающие в корень click-пакета.
APP_FILES = [
    "manifest.json",
    "utbrowser.apparmor",
    "utbrowser.desktop",
    "utbrowser.png",
    "utbrowser.qml",
    "utbrowser.sh",
]
EXECUTABLE = {"utbrowser.sh"}


def add_file(tar, path, arcname):
    info = tar.gettarinfo(path, arcname=arcname)
    info.uid = info.gid = 0
    info.uname = info.gname = "root"
    info.mode = 0o755 if os.path.basename(arcname) in EXECUTABLE else 0o644
    info.mtime = 0
    with open(path, "rb") as handle:
        tar.addfile(info, handle)


def add_dir(tar, arcname):
    info = tarfile.TarInfo(arcname)
    info.type = tarfile.DIRTYPE
    info.mode = 0o755
    info.uid = info.gid = 0
    info.uname = info.gname = "root"
    info.mtime = 0
    tar.addfile(info)


def build_data_tar(manifest):
    """data.tar.gz — файлы приложения в корне."""
    buffer = io.BytesIO()
    with tarfile.open(fileobj=buffer, mode="w:gz", compresslevel=9) as tar:
        add_dir(tar, "./")
        add_dir(tar, "./qml")
        qml_dir = os.path.join(APP_DIR, "qml")
        for name in sorted(os.listdir(qml_dir)):
            full = os.path.join(qml_dir, name)
            if os.path.isfile(full):
                add_file(tar, full, "./qml/" + name)
        for name in APP_FILES:
            add_file(tar, os.path.join(APP_DIR, name), "./" + name)
    return buffer.getvalue()


def build_control_tar(manifest, manifest_raw, installed_size):
    """control.tar.gz — метаданные пакета."""
    control = "\n".join([
        "Package: {0}".format(manifest["name"]),
        "Version: {0}".format(manifest["version"]),
        "Architecture: {0}".format(manifest.get("architecture", "all")),
        "Click-Version: 0.4",
        "Maintainer: {0}".format(manifest.get("maintainer", "")),
        "Installed-Size: {0}".format(installed_size),
        'Description: {0}'.format(manifest.get("title", manifest["name"])),
        "",
    ])

    preinst = (
        "#! /bin/sh\n"
        'echo "Click packages may not be installed directly using dpkg."\n'
        'echo "Use \'click install\' instead."\n'
        "exit 1\n"
    )

    buffer = io.BytesIO()
    with tarfile.open(fileobj=buffer, mode="w:gz", compresslevel=9) as tar:
        for name, data in (
            ("./control", control.encode("utf-8")),
            ("./manifest", manifest_raw),
            ("./preinst", preinst.encode("utf-8")),
            ("./md5sums", b""),
        ):
            info = tarfile.TarInfo(name)
            info.size = len(data)
            info.mode = 0o644
            info.uid = info.gid = 0
            info.uname = info.gname = "root"
            info.mtime = 0
            tar.addfile(info, io.BytesIO(data))
    return buffer.getvalue()


def build_ar(members, target):
    """AR-архив (формат click/deb) вручную, binutils не нужен."""
    with open(target, "wb") as out:
        out.write(b"!<arch>\n")
        for name, payload in members:
            header = "{0:<16}{1:<12}{2:<6}{3:<6}{4:<8}{5:<10}`\n".format(
                name, 0, 0, 0, "100644", len(payload)
            )
            out.write(header.encode("ascii"))
            out.write(payload)
            if len(payload) % 2:
                out.write(b"\n")


def main():
    manifest_path = os.path.join(APP_DIR, "manifest.json")
    if not os.path.isfile(manifest_path):
        sys.exit("Не найден {0}".format(manifest_path))

    manifest_raw = open(manifest_path, "rb").read()
    manifest = json.loads(manifest_raw.decode("utf-8"))

    data_tar = build_data_tar(manifest)
    installed_size = max(1, int(len(data_tar) / 1024))
    control_tar = build_control_tar(manifest, manifest_raw, installed_size)

    out_name = "{0}_{1}_all.click".format(manifest["name"], manifest["version"])
    out_path = os.path.join(ROOT, out_name)

    build_ar(
        [
            ("debian-binary", b"2.0\n"),
            ("control.tar.gz", control_tar),
            ("data.tar.gz", data_tar),
        ],
        out_path,
    )

    print("Готово: {0} ({1} байт)".format(out_path, os.path.getsize(out_path)))
    print("Установка: pkcon install-local --allow-untrusted {0}".format(out_path))


if __name__ == "__main__":
    main()
