# Optional real-humming test data

This folder is referenced by the committed Xcode test target, not the app target.
Run `bash scripts/prepare-tests.sh` before the full suite. It downloads the fixed
four HumTrans validation cases into ignored files and configures test resources.
The recordings are CC-BY-NC-4.0 and must not be bundled into a distributed app.
A fresh offline clone can run the other tests; the data-dependent benchmark
reports an explicit skip with preparation instructions, never a fictitious pass.
CI always prepares data and sets REQUIRE_HUMMING_BENCHMARK=1 to fail if missing.
