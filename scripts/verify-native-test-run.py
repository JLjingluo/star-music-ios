#!/usr/bin/env python3
"""Reuse existing XCTest evidence only for identical app, model, tests and project sources."""
import json,os,re,subprocess
from pathlib import Path

def run(*args):
    return subprocess.check_output(args,text=True).strip()
def api(path):
    return json.loads(run('gh','api',path))
repo=os.environ['GITHUB_REPOSITORY']
run_id=os.environ['VERIFIED_TEST_RUN_ID']
assert re.fullmatch(r'[0-9]+',run_id), 'Expected a numeric native test run ID'
evidence=api(f'repos/{repo}/actions/runs/{run_id}')
assert evidence['repository']['full_name']==repo
assert evidence['path']=='.github/workflows/ios-simulator.yml' and evidence['head_branch']=='main'
assert evidence['status']=='completed', 'Native test run must have finished'
sha=evidence['head_sha'];assert re.fullmatch(r'[a-f0-9]{40}',sha)
jobs=api(f'repos/{repo}/actions/runs/{run_id}/attempts/{evidence["run_attempt"]}/jobs?per_page=100')['jobs']
required={'Select Xcode','Prepare real humming evaluation samples','Generate Xcode project','Run music, storage and interface tests'}
assert any(required <= {s['name'] for s in job['steps'] if s['conclusion']=='success'} for job in jobs), 'No completed passing full native XCTest step'
protected=('StarMusic/','StarMusicTests/','StarMusicUITests/')
allowed={'.github/workflows/ios-simulator.yml','scripts/capture-native-preview.py','scripts/verify-native-test-run.py','scripts/check-source.py'}
changed=run('git','diff','--name-only',sha,'HEAD').splitlines()
for path in changed:
    assert not path.startswith(protected) and path!='project.yml', f'Application/test/project changed: {path}'
    assert path in allowed or path.endswith('.md'), f'Unverified build input changed: {path}'
# Independently guard every application, model, resource, test and project-generation input.
subprocess.run(['git','diff','--exit-code',sha,'HEAD','--','StarMusic','StarMusicTests','StarMusicUITests','project.yml','scripts/generate-project.py','scripts/fetch-humming-benchmark.py'],check=True)
url=evidence['html_url']
Path('artifacts').mkdir(exist_ok=True)
Path('artifacts/Native-Test-Provenance.json').write_text(json.dumps({'testRunID':run_id,'testSourceSHA':sha,'buildSourceSHA':run('git','rev-parse','HEAD'),'testRunURL':url,'appModelTestsAndProjectUnchanged':True},indent=2))
with open(os.environ['GITHUB_STEP_SUMMARY'],'a') as f:
    f.write(f'Native tests reuse [{run_id}]({url}) at `{sha}`. All app/model/test/project inputs are identical; only capture/build recovery and documentation changed.\n')
print('Verified completed passing native XCTest evidence for unchanged app/model/tests/project:',run_id,sha)
