"""Wires release signing into the generated Android build.

Patches android/app/build.gradle to load android/key.properties and
sign release builds with the upload keystore. Safe to run without a
key.properties: it then leaves the generated project untouched.
"""
import os

GRADLE = 'android/app/build.gradle'


def main():
    if not os.path.exists('android/key.properties'):
        print('No key.properties, keeping default signing.')
        return
    with open(GRADLE) as f:
        src = f.read()

    props = '''def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
'''
    if 'keystoreProperties' not in src:
        src = src.replace('android {', props, 1)

    signing = '''    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile file(keystoreProperties['storeFile'])
                storePassword keystoreProperties['storePassword']
            }
        }
    }

    buildTypes {
'''
    if 'signingConfigs {' not in src:
        src = src.replace('    buildTypes {', signing, 1)

    src = src.replace(
        'signingConfig = signingConfigs.debug',
        'signingConfig = signingConfigs.release')

    with open(GRADLE, 'w') as f:
        f.write(src)
    print('Release signing wired into build.gradle.')


if __name__ == '__main__':
    main()
