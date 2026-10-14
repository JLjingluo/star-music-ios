#!/usr/bin/env python3
"""Static verification only; this is not a replacement for xcodebuild."""
from pathlib import Path
import plistlib,json,yaml,xml.etree.ElementTree as XML,re
from tree_sitter import Language,Parser
import tree_sitter_swift
from openstep_parser import OpenStepDecoder
from PIL import Image
root=Path(__file__).resolve().parent.parent
parser=Parser(Language(tree_sitter_swift.language()))
source=list((root/'StarMusic').glob('*.swift'))+list((root/'StarMusicTests').glob('*.swift'))
for p in source:
    assert not parser.parse(p.read_bytes()).root_node.has_error, f'Swift grammar error: {p}'
for p in root.rglob('*.json'):json.loads(p.read_text())
for p in [root/'StarMusic/Info.plist',root/'StarMusic/PrivacyInfo.xcprivacy']:plistlib.loads(p.read_bytes())
assert 'NSMicrophoneUsageDescription' in plistlib.loads((root/'StarMusic/Info.plist').read_bytes())
project=yaml.safe_load((root/'project.yml').read_text());assert set(project['targets'])=={'StarMusic','StarMusicTests'}
for p in (root/'.github/workflows').glob('*.yml'):
    workflow=yaml.load(p.read_text(),Loader=yaml.BaseLoader)
    expected_permissions={'contents':'write','actions':'read'} if p.name=='ipa-download.yml' else {'contents':'read'}
    assert 'on' in workflow and workflow['permissions']==expected_permissions
    assert all(job['runs-on'].startswith(('macos-','ubuntu-')) for job in workflow['jobs'].values())
image=Image.open(root/'StarMusic/Assets.xcassets/AppIcon.appiconset/AppIcon.png')
assert image.size==(1024,1024)
if image.mode=='RGBA':assert image.getchannel('A').getextrema()==(255,255)
with (root/'StarMusic.xcodeproj/project.pbxproj').open() as f:pbx=OpenStepDecoder.ParseFromFile(f)
objects=pbx['objects'];assert pbx['rootObject'] in objects
assert len([o for o in objects.values() if o['isa']=='PBXNativeTarget'])==2
swift_files=[o['path'] for o in objects.values() if o['isa']=='PBXFileReference' and o.get('path','').endswith('.swift')]
assert sorted(swift_files)==sorted(p.name for p in source)
XML.parse(root/'StarMusic.xcodeproj/xcshareddata/xcschemes/StarMusic.xcscheme')
# Prevent accidental packaging of credentials.
assert not list(root.rglob('*.p12')) and not list(root.rglob('*.mobileprovision'))
for p in root.rglob('*'):
    if '.git' not in p.relative_to(root).parts and p.is_file() and p.suffix not in {'.png','.zip'}:
        assert not re.search(r'gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}',p.read_text()),f'Credential-like value in {p}'
print(f'PASS: {len(source)} Swift syntax trees; parsed Xcode project and shared scheme; XcodeGen targets; GitHub workflows; Info/privacy plists; opaque 1024px app icon; no signing/token files.')
print('Xcode compilation, XCTest execution and device behavior are NOT verified by this check.')
