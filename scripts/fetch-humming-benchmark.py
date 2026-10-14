#!/usr/bin/env python3
"""Download a fixed, tiny evaluation subset, never bundled into the application.
HumTrans is CC-BY-NC-4.0; these researcher-provided recordings stay in ignored test resources.
"""
import hashlib,io,json,sys,urllib.request,zipfile
from pathlib import Path
from remotezip import RemoteZip
output=Path(sys.argv[1]);output.mkdir(parents=True,exist_ok=True)
base='https://raw.githubusercontent.com/shansongliu/HumTrans/main/'
keys=urllib.request.urlopen(base+'valid_keys.txt').read().decode().splitlines()
references=zipfile.ZipFile(io.BytesIO(urllib.request.urlopen(base+'midis/GroundTruth.zip').read()))
selected=[next(k for k in keys if k.startswith(prefix+'_')) for prefix in ['F01','F02','M01','M02']]
cases=[]
with RemoteZip('https://huggingface.co/datasets/dadinghh2/HumTrans/resolve/main/all_wav.zip') as audio:
    for i,key in enumerate(selected):
        wav=audio.read('wav_data_sync_with_midi/'+key+'.wav')
        midi=references.read('GroundTruth/valid/'+key+'.mid')
        name='humtrans-'+str(i)
        (output/(name+'.wav')).write_bytes(wav);(output/(name+'.mid')).write_bytes(midi)
        cases.append({'key':key,'audio':name+'.wav','midi':name+'.mid','audioSHA256':hashlib.sha256(wav).hexdigest(),'midiSHA256':hashlib.sha256(midi).hexdigest()})
(output/'humtrans-cases.json').write_text(json.dumps({'source':'https://github.com/shansongliu/HumTrans','license':'CC-BY-NC-4.0','split':'validation','excerptSeconds':6,'cases':cases},indent=2))
print('Prepared four real humming evaluation recordings and reference MIDI; not app resources.')
