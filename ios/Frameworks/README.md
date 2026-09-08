# ios/Frameworks — Document Reader native runtimes

Drop from the FacePlugin Drive **iOS** pack (same as `DocumentReader-iOS-App`):

1. `docsdk.framework` (includes `dcr.fpk` + nested engine under `Frameworks/dcrcore.framework` or `Frameworks/DocumentReaderCore.framework`)

The framework should include `Info.plist` (`CFBundleExecutable` = `docsdk`). Drive binaries are often **unsigned**; the example app’s **Embed FacePlugin DocSDK** phase re-signs `docsdk` + nested `dcrcore` with your Xcode Team identity (see `example/ios/App/scripts/sign_nested_docsdk.sh`).

Then from `example/ios` run `pod install` (or `npx cap sync ios`).

Header stubs alone are not enough to run on device.

For **customer apps**, copy the same folder to `node_modules/document-reader-capacitor/ios/Frameworks/docsdk.framework` after install.
