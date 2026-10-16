#!/usr/bin/env python3
"""Capture genuine Release app screenshots and launch video, with bounded simulator recovery."""
import os,signal,subprocess,time
from pathlib import Path
sim=os.environ['SIMULATOR_ID'];out=Path('artifacts');out.mkdir(exist_ok=True)
files=[out/n for n in ['StarMusic-Home.png','StarMusic-Home-Light.png','StarMusic-Entrance.mp4']]
def run(*args,timeout=60,check=True):
    print('simctl:',args[0],flush=True)
    return subprocess.run(['xcrun','simctl',*args],check=check,timeout=timeout)
def stop_video(video):
    video.send_signal(signal.SIGINT)
    try:video.wait(timeout=20)
    except subprocess.TimeoutExpired:
        video.terminate()
        try:video.wait(timeout=5)
        except subprocess.TimeoutExpired:video.kill();video.wait(timeout=5)
def capture():
    # Warm CoreSimulator/its app services before starting the GPU-backed video recorder.
    # The actual video still records a subsequent process launch and real system transition.
    run('shutdown',sim,timeout=30,check=False)
    run('boot',sim,timeout=30)
    developer=Path(subprocess.check_output(['xcode-select','-p'],text=True).strip())
    subprocess.run(['open','-a',str(developer/'Applications/Simulator.app'),'--args','-CurrentDeviceUDID',sim],check=True,timeout=30)
    run('bootstatus',sim,'-b',timeout=120)
    run('io',sim,'screenshot',str(out/'Simulator-Ready.png'),timeout=45)
    run('install',sim,'build/simulator/Build/Products/Release-iphonesimulator/StarMusic.app',timeout=90)
    run('status_bar',sim,'override','--time','9:41','--dataNetwork','wifi','--wifiMode','active','--wifiBars','3','--batteryState','charged','--batteryLevel','100',timeout=30)
    run('launch',sim,'music.star.starmusic','-appearance','dark',timeout=90)
    time.sleep(3)
    run('terminate',sim,'music.star.starmusic',timeout=30)
    video=subprocess.Popen(['xcrun','simctl','io',sim,'recordVideo','--codec=h264',str(files[2])])
    try:
        time.sleep(1)
        run('launch',sim,'music.star.starmusic','-appearance','dark',timeout=60)
        time.sleep(3)
        run('io',sim,'screenshot',str(files[0]),timeout=45)
    finally:stop_video(video)
    if not files[2].is_file() or files[2].stat().st_size<10000:
        raise RuntimeError('Native launch video was not captured')
    run('terminate',sim,'music.star.starmusic',timeout=30)
    run('launch',sim,'music.star.starmusic','-appearance','light',timeout=60)
    time.sleep(2)
    run('io',sim,'screenshot',str(files[1]),timeout=45)
for attempt in range(2):
    for file in files:file.unlink(missing_ok=True)
    try:
        capture();break
    except (subprocess.SubprocessError,RuntimeError) as error:
        print('Native capture attempt failed:',attempt+1,str(error),flush=True)
        try:run('io',sim,'screenshot',str(out/f'StarMusic-Capture-Failure-{attempt+1}.png'),timeout=30)
        except subprocess.SubprocessError as diagnostic:print('Failure screenshot unavailable:',str(diagnostic),flush=True)
        if attempt==1:raise
        run('shutdown',sim,timeout=30,check=False)
print('Actual native dark/light and process-launch captures completed.',flush=True)
