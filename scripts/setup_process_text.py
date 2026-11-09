#!/usr/bin/env python3
"""Wires the Android text-selection and file-sharing features into the
freshly generated android/ folder.

The repo does not commit android/; CI regenerates it with
`flutter create --platforms=android --project-name=oncard .` and then
runs this script. It does three things:

1. Adds a PROCESS_TEXT intent filter to the launch activity so that
   Oncard shows up in Android's text-selection menu.
2. Registers a FileProvider so decks can be shared as CSV files
   through the Android share sheet.
3. Installs the custom MainActivity that implements both features
   over the 'oncard/share' method channel.
"""
import glob
import io
import os

MANIFEST = 'android/app/src/main/AndroidManifest.xml'
OVERRIDE = 'android_override/MainActivity.kt'
FILE_PATHS = 'android/app/src/main/res/xml/file_paths.xml'

# CI regenerates android/ with `flutter create --org dev.josh`, so the
# Kotlin package folder follows the org. Locate the generated activity
# instead of hardcoding a path.
KOTLIN_ROOT = 'android/app/src/main/kotlin'
_candidates = glob.glob(KOTLIN_ROOT + '/**/MainActivity.kt', recursive=True)
if not _candidates:
    raise SystemExit('MainActivity.kt not found under ' + KOTLIN_ROOT)
ACTIVITY = _candidates[0]
PACKAGE = os.path.dirname(ACTIVITY)[len(KOTLIN_ROOT) + 1:].replace('/', '.')

manifest = io.open(MANIFEST, encoding='utf-8').read()
if 'android.permission.INTERNET' not in manifest:
    permission = ('<uses-permission '
                  'android:name="android.permission.INTERNET" />\n    ')
    patched = manifest.replace('<application', permission + '<application', 1)
    io.open(MANIFEST, 'w', encoding='utf-8').write(patched)
    print('manifest: INTERNET permission added')
else:
    print('manifest: INTERNET permission already present')

manifest = io.open(MANIFEST, encoding='utf-8').read()
if 'PROCESS_TEXT' not in manifest:
    intent_filter = (
        '<intent-filter>\n'
        '                <action android:name="android.intent.action.PROCESS_TEXT" />\n'
        '                <category android:name="android.intent.category.DEFAULT" />\n'
        '                <data android:mimeType="text/plain" />\n'
        '            </intent-filter>\n            '
    )
    # The first </activity> in the manifest is the launch activity.
    patched = manifest.replace('</activity>', intent_filter + '</activity>', 1)
    io.open(MANIFEST, 'w', encoding='utf-8').write(patched)
    print('manifest: PROCESS_TEXT intent filter added')
else:
    print('manifest: already patched')

manifest = io.open(MANIFEST, encoding='utf-8').read()
if 'FileProvider' not in manifest:
    provider = (
        '        <provider\n'
        '            android:name="androidx.core.content.FileProvider"\n'
        '            android:authorities="${applicationId}.fileprovider"\n'
        '            android:exported="false"\n'
        '            android:grantUriPermissions="true">\n'
        '            <meta-data\n'
        '                android:name="android.support.FILE_PROVIDER_PATHS"\n'
        '                android:resource="@xml/file_paths" />\n'
        '        </provider>\n'
    )
    patched = manifest.replace('</application>', provider + '</application>', 1)
    io.open(MANIFEST, 'w', encoding='utf-8').write(patched)
    print('manifest: FileProvider added')
else:
    print('manifest: FileProvider already present')

with io.open(OVERRIDE, encoding='utf-8') as f:
    source = f.read()
if 'package com.example.oncard' in source:
    source = source.replace('package com.example.oncard',
                            'package ' + PACKAGE)
io.open(ACTIVITY, 'w', encoding='utf-8').write(source)
print('MainActivity.kt: installed (' + PACKAGE + ')')

os.makedirs(os.path.dirname(FILE_PATHS), exist_ok=True)
with io.open(FILE_PATHS, 'w', encoding='utf-8') as f:
    f.write('<?xml version="1.0" encoding="utf-8"?>\n'
            '<paths>\n'
            '    <cache-path name="shared" path="." />\n'
            '</paths>\n')
print('file_paths.xml: written')
