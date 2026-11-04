#!/usr/bin/env python3
"""Wires the Android text-selection quick-add flow into the freshly
generated android/ folder.

The repo does not commit android/; CI regenerates it with
`flutter create --platforms=android --project-name=oncard .` and then
runs this script. It does two things:

1. Adds a PROCESS_TEXT intent filter to the launch activity so that
   Oncard shows up in Android's text-selection menu.
2. Installs the custom MainActivity that hands the selected text to
   Flutter over the 'oncard/share' method channel.
"""
import io

MANIFEST = 'android/app/src/main/AndroidManifest.xml'
ACTIVITY = ('android/app/src/main/kotlin/com/example/oncard/'
            'MainActivity.kt')
OVERRIDE = 'android_override/MainActivity.kt'

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

with io.open(OVERRIDE, encoding='utf-8') as f:
    source = f.read()
io.open(ACTIVITY, 'w', encoding='utf-8').write(source)
print('MainActivity.kt: installed')
