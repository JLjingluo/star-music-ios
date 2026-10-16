#!/usr/bin/env python3
"""Capture the real Release app through XCTest's device/launch manager and recording support."""
import json,os,shutil,subprocess,xml.etree.ElementTree as XML
from pathlib import Path

out=Path('artifacts');out.mkdir(exist_ok=True)
source=Path('StarMusic.xcodeproj/xcshareddata/xcschemes/StarMusic.xcscheme')
tree=XML.parse(source);root=tree.getroot()
# Use a temporary capture-only scheme; no app, model, test source or project setting changes.
for parent_path,child_tag in [('BuildAction/BuildActionEntries','BuildActionEntry'),('TestAction/Testables','TestableReference')]:
    parent=root.find(parent_path);assert parent is not None
    for child in list(parent):
        reference=child.find('BuildableReference')
        if reference is not None and reference.get('BlueprintName')=='StarMusicTests':parent.remove(child)
action=root.find('TestAction');assert action is not None
for key,value in {'buildConfiguration':'Release','preferredScreenCaptureFormat':'screenRecording','systemAttachmentLifetime':'keepAlways','userAttachmentLifetime':'keepAlways'}.items():action.set(key,value)
launch=root.find('LaunchAction')
if launch is not None:launch.set('buildConfiguration','Release')
tree.write(source.with_name('StarMusicPreview.xcscheme'),encoding='UTF-8',xml_declaration=True)
command=['xcodebuild','test','-project','StarMusic.xcodeproj','-scheme','StarMusicPreview','-configuration','Release','-destination','platform=iOS Simulator,id='+os.environ['SIMULATOR_ID'],'-derivedDataPath','build/simulator','-resultBundlePath','build/ReleasePreview.xcresult','-only-testing:StarMusicUITests/InteractionTests/testCreationSheetOpensEditorAndHidesNavigation','-only-testing:StarMusicUITests/InteractionTests/testLightAppearanceAndNativeSettingsToggle','CODE_SIGNING_ALLOWED=YES','CODE_SIGN_IDENTITY=-','-parallel-testing-enabled','NO']
# XCTest manages boot/install/launch; avoid the standalone simctl service failures on this image.
subprocess.run(command,check=True,timeout=1200)
captures=out/'release-ui'
subprocess.run(['xcrun','xcresulttool','export','attachments','--path','build/ReleasePreview.xcresult','--output-path',str(captures)],check=True,timeout=90)
manifest=json.loads((captures/'manifest.json').read_text())
found=set();video=None
for group in manifest:
    creation='testCreationSheetOpensEditorAndHidesNavigation' in group.get('testIdentifier','')
    for attachment in group['attachments']:
        filename=attachment['exportedFileName'];friendly=attachment.get('suggestedHumanReadableName','')
        original=captures/filename
        if friendly.startswith('Home-Dark_') and filename.endswith('.png'):
            shutil.copy2(original,out/'StarMusic-Home.png');found.add('dark')
        if friendly.startswith('Home-Light_') and filename.endswith('.png'):
            shutil.copy2(original,out/'StarMusic-Home-Light.png');found.add('light')
        if creation and filename.endswith('.mp4'):video=original
assert found=={'dark','light'},'Actual Release appearance captures missing'
assert video is not None and video.stat().st_size>10000,'XCTest did not preserve an actual native screen recording'
# The unmodified recording includes the process launch and native creation/navigation flow.
shutil.copy2(video,out/'StarMusic-Entrance.mp4')
for file in captures.iterdir():
    if file.is_file() and file.suffix in ('.png','.json'):
        target=out/'ui';target.mkdir(exist_ok=True);shutil.copy2(file,target/('Release-'+file.name))
print('Actual Release UI smoke tests, dark/light screenshots and native launch/creation recording verified.',flush=True)
