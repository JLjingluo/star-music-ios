#!/bin/bash
set -euo pipefail
# Run only on a macOS runner. Signing secrets are provided as environment values.
SIGNING_DIR=$(mktemp -d "$RUNNER_TEMP/star-signing.XXXXXX")
KEYCHAIN_PATH="$SIGNING_DIR/signing.keychain-db"
KEYCHAIN_PASSWORD=$(openssl rand -base64 32)
PROFILE_DEST=''
cleanup() {
  security delete-keychain "$KEYCHAIN_PATH" >/dev/null 2>&1 || true
  if [ -n "$PROFILE_DEST" ]; then rm -f "$PROFILE_DEST"; fi
  rm -rf "$SIGNING_DIR"
}
trap cleanup EXIT
python3 - "$SIGNING_DIR" <<'PY'
import os,sys,base64
from pathlib import Path
root=Path(sys.argv[1])
for variable,name in [('APPLE_CERTIFICATE_P12_BASE64','certificate.p12'),('APPLE_PROVISION_PROFILE_BASE64','profile.mobileprovision')]:
    raw=base64.b64decode(os.environ[variable],validate=True)
    (root/name).write_bytes(raw)
PY
security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security import "$SIGNING_DIR/certificate.p12" -P "$APPLE_CERTIFICATE_PASSWORD" -A -t cert -f pkcs12 -k "$KEYCHAIN_PATH"
security set-key-partition-list -S apple-tool:,apple: -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH" >/dev/null
security list-keychain -d user -s "$KEYCHAIN_PATH" login.keychain-db
security cms -D -i "$SIGNING_DIR/profile.mobileprovision" > "$SIGNING_DIR/profile.plist"
python3 - "$SIGNING_DIR" <<'PY'
import os,sys,plistlib,datetime
from pathlib import Path
root=Path(sys.argv[1]); p=plistlib.loads((root/'profile.plist').read_bytes())
team=os.environ['APPLE_TEAM_ID']; bundle=os.environ['APP_BUNDLE_ID']; method=os.environ['EXPORT_METHOD']
assert team in p.get('TeamIdentifier',[]), 'Profile Team ID mismatch'
identifier=p['Entitlements'].get('application-identifier','')
assert identifier == team+'.'+bundle, 'Provisioning profile must match the exact Bundle ID'
assert p['ExpirationDate'] > datetime.datetime.utcnow(), 'Provisioning profile has expired'
assert method in ('release-testing','debugging','app-store-connect'), 'Unsupported export method'
assert (method != 'release-testing' or (p.get('ProvisionedDevices') and not p['Entitlements'].get('get-task-allow',False))), 'Ad Hoc profile required'
assert (method != 'debugging' or p['Entitlements'].get('get-task-allow',False)), 'Development profile required'
assert (method != 'app-store-connect' or (not p.get('ProvisionedDevices') and not p['Entitlements'].get('get-task-allow',False))), 'App Store profile required'
(root/'uuid.txt').write_text(p['UUID']); (root/'name.txt').write_text(p['Name'])
identity='Apple Development' if method=='debugging' else 'Apple Distribution'
options={'method':method,'teamID':team,'signingStyle':'manual','signingCertificate':identity,'provisioningProfiles':{bundle:p['Name']},'manageAppVersionAndBuildNumber':False,'stripSwiftSymbols':True}
(root/'ExportOptions.plist').write_bytes(plistlib.dumps(options))
PY
PROFILE_UUID=$(cat "$SIGNING_DIR/uuid.txt")
PROFILE_NAME=$(cat "$SIGNING_DIR/name.txt")
PROFILE_DEST="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_UUID.mobileprovision"
mkdir -p "$(dirname "$PROFILE_DEST")"
cp "$SIGNING_DIR/profile.mobileprovision" "$PROFILE_DEST"
if [ "$EXPORT_METHOD" = debugging ]; then SIGN_IDENTITY='Apple Development'; else SIGN_IDENTITY='Apple Distribution'; fi
xcodebuild archive -project StarMusic.xcodeproj -scheme StarMusic -configuration Release -destination 'generic/platform=iOS' -archivePath build/StarMusic.xcarchive DEVELOPMENT_TEAM="$APPLE_TEAM_ID" PRODUCT_BUNDLE_IDENTIFIER="$APP_BUNDLE_ID" CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY="$SIGN_IDENTITY" PROVISIONING_PROFILE_SPECIFIER="$PROFILE_NAME" OTHER_CODE_SIGN_FLAGS="--keychain $KEYCHAIN_PATH"
mkdir -p artifacts
xcodebuild -exportArchive -archivePath build/StarMusic.xcarchive -exportPath artifacts -exportOptionsPlist "$SIGNING_DIR/ExportOptions.plist"
