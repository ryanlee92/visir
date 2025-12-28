# Release

## macos

Xcode > Archive. Then distribute with `Direct Distribution` After Apple finish
Notorize app, export app to Download folder. Compress downloaded file and rename
to `taskey.zip`. Move `taskey.zip` to `web/release`
`dart run auto_updater:sign_update web/release/taskey.zip`

this will return appcast.xml `sparkle:edSigniture` value. So update appcast.xml
move dmg file to `./web/release` with name `taskey.dmg`

`flutter build web` then `firebase deploy --only hosting` to update appcast.xml

## windows

`dart run inno_bundle:build --release`
`smctl sign --keypair-alias key_1503288680 --input .\branding\release\visir-beta.exe`
`dart run auto_updater:sign_update .\branding\release\visir-beta.exe`

this will return appcast.xml `sparkle:dsaSigniture` value. So update appcast.xml
move exe file to `./web/release` with name `taskey.exe`

`flutter build web` then `firebase deploy --only hosting` to update appcast.xml

## Improve performance

### SkSL warmup

Run the app with --cache-sksl turned on to capture shaders in SkSL:

`flutter run --profile --cache-sksl` If the same app has been previously run
without --cache-sksl, then the --purge-persistent-cache flag may be needed:

`flutter run --profile --cache-sksl --purge-persistent-cache` This flag removes
older non-SkSL shader caches that could interfere with SkSL shader capturing. It
also purges the SkSL shaders so use it only on the first --cache-sksl run.

Play with the app to trigger as many animations as needed; particularly those
with compilation jank.

Press M at the command line of flutter run to write the captured SkSL shaders
into a file named something like flutter_01.sksl.json. For best results, capture
SkSL shaders on an actual iOS device. A shader captured on a simulator isn’t
likely to work correctly on actual hardware.

Build the app with SkSL warm-up using the following, as appropriate:

`flutter build ios --bundle-sksl-path flutter_01.sksl.json`

Test the newly built app.
