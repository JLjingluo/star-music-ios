"""Build the complete pretrained CREPE network as an offline iOS Core ML program.
Run with Python 3.11, tensorflow-cpu 2.15.1, coremltools 8.3.0 and scipy 1.12.0.
The original architecture/weights remain MIT-licensed: github.com/marl/crepe.
"""
from pathlib import Path
import argparse,bz2,importlib.util,json,hashlib,os,urllib.request
root=Path(__file__).resolve().parent.parent
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument("--cache-dir",type=Path,default=root/"build/crepe-source",help="Reusable source/weights cache; no workspace-specific paths")
args=parser.parse_args()
os.environ['TF_CPP_MIN_LOG_LEVEL']='2'
os.environ['OMP_NUM_THREADS']='4'
os.environ['TF_NUM_INTRAOP_THREADS']='4'
os.environ['TF_NUM_INTEROP_THREADS']='2'
import tensorflow as tf
import coremltools as ct
import numpy as np
cache=args.cache_dir.resolve();cache.mkdir(parents=True,exist_ok=True)
source=cache/'core.py';weights=cache/'model-full.h5'
source_commit='c9b71ce61491454125a0693f584f7244f29d9884'
if not source.exists():
    source.write_bytes(urllib.request.urlopen(f'https://raw.githubusercontent.com/marl/crepe/{source_commit}/crepe/core.py',timeout=30).read())
if not weights.exists():
    compressed=urllib.request.urlopen('https://raw.githubusercontent.com/marl/crepe/models/model-full.h5.bz2',timeout=120).read()
    weights.write_bytes(bz2.decompress(compressed))
expected='b6fd2758b03a8625a16fe86cd474ff0d8f30ad9a05e4bee2244e13e98664f860'
if hashlib.sha256(weights.read_bytes()).hexdigest()!=expected:
    raise RuntimeError('CREPE full weights hash mismatch; refusing conversion')
spec=importlib.util.spec_from_file_location('crepe_core',source)
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
model=module.build_and_load_model('full')
@tf.function(input_signature=[tf.TensorSpec([1,1024],tf.float32,name='audio')])
def infer(audio):return model(audio,training=False)
print('Loaded complete pretrained CREPE:',model.count_params(),'parameters',flush=True)
converted=ct.convert([infer.get_concrete_function()],source='tensorflow',convert_to='mlprogram',inputs=[ct.TensorType(name='audio',shape=(1,1024),dtype=np.float32)],outputs=[ct.TensorType(dtype=np.float32)],minimum_deployment_target=ct.target.iOS17,compute_precision=ct.precision.FLOAT16,skip_model_load=True)
converted.author='Jong Wook Kim / CREPE contributors; Core ML conversion by Star Music'
converted.license='MIT'
converted.short_description='Full-capacity pretrained CREPE monophonic pitch estimation. 16 kHz, 1024 normalized audio samples -> 360 pitch salience bins.'
converted.input_description['audio']='Zero-mean/unit-standard-deviation 1024-sample frame at 16000 Hz.'
converted.output_description[converted.get_spec().description.output[0].name]='360 sigmoid pitch salience bins, 20 cents apart, original CREPE cents mapping.'
path=root/'StarMusic/Resources/PitchCREPE.mlpackage';converted.save(str(path))
manifest={'source':'https://github.com/marl/crepe','weightsURL':'https://raw.githubusercontent.com/marl/crepe/models/model-full.h5.bz2','capacity':'full','parameters':model.count_params(),'weightsSHA256':hashlib.sha256(weights.read_bytes()).hexdigest(),'tensorflow':tf.__version__,'coremltools':ct.__version__,'coremlPrecision':'FLOAT16','samplingRate':16000,'frameSize':1024,'outputBins':360,'license':'MIT','notice':'CREPE-LICENSE.txt'}
(root/'StarMusic/Resources/MODEL-MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('Saved:',path,'bytes:',sum(p.stat().st_size for p in path.rglob('*') if p.is_file()),flush=True)
# Original TensorFlow smoke check; Core ML equivalence is verified by native tests.
wave=np.sin(2*np.pi*440*np.arange(1024)/16000).astype('float32');wave=(wave-wave.mean())/wave.std()
pred=model(wave[None],training=False).numpy()[0]
cents=module.to_local_average_cents(pred);hz=10*2**(cents/1200)
print('Source model A4 smoke check:',hz,'Hz, confidence',float(pred.max()),flush=True)
