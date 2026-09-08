#!/bin/bash
# Re-sign docsdk.framework (+ nested dcrcore / DocumentReaderCore) for device install.
# Unsigned / ad-hoc Drive binaries fail install with 0xe800801c / 0xe8008014.
set -euo pipefail

if [ "${PLATFORM_NAME:-}" = "iphonesimulator" ]; then
  exit 0
fi

if [ -z "${EXPANDED_CODE_SIGN_IDENTITY:-}" ] || [ "${EXPANDED_CODE_SIGN_IDENTITY}" = "-" ]; then
  echo "error: EXPANDED_CODE_SIGN_IDENTITY unset; cannot sign docsdk.framework" >&2
  echo "error: In Xcode, select the App target → Signing & Capabilities → your Team." >&2
  exit 1
fi

DEST="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
FW="${DEST}/docsdk.framework"

if [ ! -d "${FW}" ]; then
  echo "error: missing ${FW}" >&2
  exit 1
fi

if [ ! -f "${FW}/Info.plist" ]; then
  cat > "${FW}/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>docsdk</string>
	<key>CFBundleIdentifier</key>
	<string>com.faceplugin.docsdk</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>docsdk</string>
	<key>CFBundlePackageType</key>
	<string>FMWK</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>MinimumOSVersion</key>
	<string>13.0</string>
</dict>
</plist>
PLIST
  echo "note: wrote missing Info.plist into ${FW}"
fi

sign_one() {
  local path="$1"
  if [ ! -d "${path}" ]; then
    return 0
  fi
  if [ -d "${path}/Frameworks" ]; then
    for nested in "${path}/Frameworks"/*.framework; do
      [ -d "${nested}" ] || continue
      sign_one "${nested}"
    done
  fi
  echo "Signing $(basename "${path}") (${TARGET_NAME:-App})"
  /usr/bin/codesign --remove-signature "${path}" 2>/dev/null || true
  /usr/bin/codesign --force --sign "${EXPANDED_CODE_SIGN_IDENTITY}" \
    --timestamp=none \
    "${path}"
}

sign_one "${FW}"
echo "sign_nested_docsdk: ok"
