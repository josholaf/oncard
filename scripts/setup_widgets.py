#!/usr/bin/env python3
"""Wires the Android home-screen widget into the freshly generated
android/ folder: installs the Kotlin provider into the app package,
copies the layout, background and provider metadata into res/, and
registers the receiver in the manifest. The repo does not commit
android/; CI regenerates it with flutter create."""
import glob
import io
import os

KOTLIN_ROOT = 'android/app/src/main/kotlin'
RES = 'android/app/src/main/res'
MANIFEST = 'android/app/src/main/AndroidManifest.xml'
OVERRIDE = 'android_override/OncardWidgetProvider.kt'
WIDGET_RES = 'android_override/widget'

candidates = glob.glob(KOTLIN_ROOT + '/**/MainActivity.kt', recursive=True)
if not candidates:
    raise SystemExit('MainActivity.kt not found under ' + KOTLIN_ROOT +
                     '; run flutter create first')
package_dir = os.path.dirname(candidates[0])

with io.open(OVERRIDE, encoding='utf-8') as f:
    source = f.read()
if 'package com.example.oncard' in source:
    package = package_dir[len(KOTLIN_ROOT) + 1:].replace(os.sep, '.')
    source = source.replace('package com.example.oncard', 'package ' + package)
os.makedirs(package_dir, exist_ok=True)
io.open(package_dir + os.sep + 'OncardWidgetProvider.kt',
        'w', encoding='utf-8').write(source)
print('OncardWidgetProvider.kt installed in ' + package_dir)

for sub, name in [('layout', 'oncard_widget.xml'),
                  ('drawable', 'oncard_widget_bg.xml')]:
    os.makedirs(RES + '/' + sub, exist_ok=True)
    with io.open(WIDGET_RES + '/' + name, encoding='utf-8') as f:
        body = f.read()
    io.open(RES + '/' + sub + '/' + name, 'w', encoding='utf-8').write(body)
    print('res/' + sub + '/' + name + ' written')

os.makedirs(RES + '/xml', exist_ok=True)
with io.open(WIDGET_RES + '/oncard_widget_info.xml', encoding='utf-8') as f:
    info = f.read()
io.open(RES + '/xml/oncard_widget_info.xml', 'w', encoding='utf-8').write(info)
print('res/xml/oncard_widget_info.xml written')

# Ensure @string/app_name exists (widget description references it)
strings_path = RES + '/values/strings.xml'
os.makedirs(os.path.dirname(strings_path), exist_ok=True)
if os.path.exists(strings_path):
    with io.open(strings_path, encoding='utf-8') as f:
        strings = f.read()
    if 'name="app_name"' not in strings:
        strings = strings.replace('</resources>', '    <string name="app_name">Oncard</string>\n</resources>')
        with io.open(strings_path, 'w', encoding='utf-8') as f:
            f.write(strings)
        print('added app_name to existing strings.xml')
    else:
        print('app_name already present in strings.xml')
else:
    with io.open(strings_path, 'w', encoding='utf-8') as f:
        f.write('<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <string name="app_name">Oncard</string>\n</resources>\n')
    print('created strings.xml with app_name')

manifest = io.open(MANIFEST, encoding='utf-8').read()
if 'OncardWidgetProvider' not in manifest:
    receiver = (
        '        <receiver\n'
        '            android:name=".OncardWidgetProvider"\n'
        '            android:exported="false">\n'
        '            <intent-filter>\n'
        '                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />\n'
        '            </intent-filter>\n'
        '            <meta-data\n'
        '                android:name="android.appwidget.provider"\n'
        '                android:resource="@xml/oncard_widget_info" />\n'
        '        </receiver>\n'
    )
    patched = manifest.replace('</application>', receiver + '</application>', 1)
    io.open(MANIFEST, 'w', encoding='utf-8').write(patched)
    print('manifest: widget receiver added')
else:
    print('manifest: widget receiver already present')
