#!/usr/bin/env python3
"""Capture the actual Release app, with bounded CoreSimulator commands."""
import os,signal,subprocess,time
from pathlib import Path
sim=os.environ['SIMULATOR_ID'];out=Path('artifacts');out.mkdir(exist_ok=True)
def run(*args,timeout=60,check=True):
    print('simctl:',args[0],flush=True)
    return subprocess.run(['xcrun','simctl',*args],check=check,timeout=timeout)
# Release simulator resources left by the full-model benchmark and UI runner.
run('shutdown',sim,timeout=30,check=False)
run('boot',sim,timeout=30)
run('bootstatus',sim,'-b',timeout=120)
run('install',sim,'build/simulator/Build/Products/Release-iphonesimulator/StarMusic.app',timeout=90)
run('status_bar',sim,'override','--time','9:41','--dataNetwork','wifi','--wifiMode','active','--wifiBars','3','--batteryState','charged','--batteryLevel','100',timeout=30)
video=subprocess.Popen(['xcrun','simctl','io',sim,'recordVideo','--codec=h264',str(out/'StarMusic-Entrance.mp4')])
try:
    time.sleep(1)
    run('launch',sim,'music.star.starmusic','-appearance','dark',timeout=60)
    time.sleep(3)
    run('io',sim,'screenshot',str(out/'StarMusic-Home.png'),timeout=45)
finally:
    video.send_signal(signal.SIGINT)
    try:video.wait(timeout=20)
    except subprocess.TimeoutExpired:
        video.terminate()
        try:video.wait(timeout=5)
        except subprocess.TimeoutExpired:video.kill();video.wait(timeout=5)
if not (out/'StarMusic-Entrance.mp4').is_file() or (out/'StarMusic-Entrance.mp4').stat().st_size<10000:
    raise RuntimeError('Native launch video was not captured')
run('terminate',sim,'music.star.starmusic',timeout=30)
run('launch',sim,'music.star.starmusic','-appearance','light',timeout=60)
time.sleep(2)
run('io',sim,'screenshot',str(out/'StarMusic-Home-Light.png'),timeout=45)
print('Actual native dark/light and entrance captures completed.',flush=True)
