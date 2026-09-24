#!/usr/bin/env python3
"""Apply Dive app icon from tool/scripts/icon_data/*.b64"""
import base64
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DATA = Path(__file__).resolve().parent / 'icon_data'

MAP = {
    'launcher.b64': [
        'android/app/src/main/res/mipmap-mdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-hdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
    ],
    'brand.b64': [
        'assets/brand/app-icon.png',
        'assets/brand/app-icon-tight.png',
        'assets/brand/mark.png',
        'assets/brand/master-mark.png',
    ],
}

def main() -> None:
    for fname, dests in MAP.items():
        raw = base64.b64decode((DATA / fname).read_text().strip())
        for rel in dests:
            path = ROOT / rel
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(raw)
            print(f'wrote {rel} ({len(raw)} bytes)')

if __name__ == '__main__':
    main()
