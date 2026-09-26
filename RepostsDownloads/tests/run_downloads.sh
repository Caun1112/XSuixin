#!/bin/sh
set -eu
cd "$(dirname "$0")"
BHRD_TEST_DIR="$(mktemp -d -t bhrd-download-tests)"
BHRD_SERVER_PID=''
BHRD_PYTHON_BIN=""
if [ -x /usr/bin/python3 ]; then
  BHRD_PYTHON_BIN=/usr/bin/python3
else
  BHRD_PYTHON_BIN="$(command -v python3 || true)"
fi
cleanup() {
  BHRD_TEST_STATUS=$?
  trap - EXIT INT TERM
  if [ -n "$BHRD_SERVER_PID" ]; then
    kill "$BHRD_SERVER_PID" 2>/dev/null || true
    wait "$BHRD_SERVER_PID" 2>/dev/null || true
  fi
  rm -rf "$BHRD_TEST_DIR"
  exit "$BHRD_TEST_STATUS"
}
trap cleanup EXIT
if [ ! -x "$BHRD_PYTHON_BIN" ]; then
  echo "python3 was not found; PATH=$PATH" >&2
  exit 1
fi
xcrun clang -fobjc-arc -Wall -Wextra -Werror -framework Foundation \
  ../BHRDTaskState.m ../BHRDDownload.m DownloadLifecycleTests.m -o "$BHRD_TEST_DIR/tests"
"$BHRD_PYTHON_BIN" -u download_server.py "$BHRD_TEST_DIR/port" > "$BHRD_TEST_DIR/server.log" 2>&1 &
BHRD_SERVER_PID=$!
BHRD_RETRIES=0
while [ ! -s "$BHRD_TEST_DIR/port" ]; do
  BHRD_RETRIES=$((BHRD_RETRIES + 1))
  if [ "$BHRD_RETRIES" -gt 50 ]; then
    echo "download test server did not start (pid=$BHRD_SERVER_PID)" >&2
    cat "$BHRD_TEST_DIR/server.log" >&2 || true
    kill "$BHRD_SERVER_PID" 2>/dev/null || true
    wait "$BHRD_SERVER_PID" 2>/dev/null || true
    exit 1
  fi
  sleep 0.1
done
"$BHRD_TEST_DIR/tests" "http://127.0.0.1:$(cat "$BHRD_TEST_DIR/port")"
