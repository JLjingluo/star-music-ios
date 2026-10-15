#!/bin/bash
set -euo pipefail
PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)
BENCHMARK_ENV="$PROJECT_ROOT/build/benchmark-env"
python3 -m venv "$BENCHMARK_ENV"
"$BENCHMARK_ENV/bin/python" -m pip install remotezip==0.12.3
"$BENCHMARK_ENV/bin/python" "$PROJECT_ROOT/scripts/fetch-humming-benchmark.py" "$PROJECT_ROOT/StarMusicTests/BenchmarkSamples"
python3 "$PROJECT_ROOT/scripts/generate-project.py"
printf 'Prepared committed Xcode test target. Open StarMusic.xcodeproj and run tests.\n'
