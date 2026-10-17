#!/usr/bin/env python3
"""Run the same dense-score regression on an actual iPad simulator, not a mockup."""
import json,os,subprocess
from pathlib import Path

devices=json.loads(subprocess.check_output(['xcrun','simctl','list','devices','available','--json']))['devices']
device=next(d['udid'] for runtime,items in devices.items() if runtime.endswith('iOS-26-2') for d in items if d.get('isAvailable') and d['name'].startswith('iPad Pro 11-inch'))
result=Path('build/TabletLayout.xcresult')
try:
    subprocess.run(['xcodebuild','test','-project','StarMusic.xcodeproj','-scheme','StarMusic','-destination','platform=iOS Simulator,id='+device,'-derivedDataPath','build/test','-resultBundlePath',str(result),'-only-testing:StarMusicUITests/InteractionTests/testDenseScoreFontPaginationAndBottomControlsRemainSeparate','CODE_SIGNING_ALLOWED=YES','CODE_SIGN_IDENTITY=-','-parallel-testing-enabled','NO'],check=True,timeout=900)
finally:
    if result.exists():
        output=Path('artifacts/tablet-ui')
        subprocess.run(['xcrun','xcresulttool','export','attachments','--path',str(result),'--output-path',str(output)],check=True,timeout=90)
        target=Path('artifacts/ui');target.mkdir(parents=True,exist_ok=True)
        for file in output.iterdir():
            if file.suffix in ('.png','.json'):(target/('Tablet-'+file.name)).write_bytes(file.read_bytes())
    subprocess.run(['xcrun','simctl','shutdown',device],check=False,timeout=45)
