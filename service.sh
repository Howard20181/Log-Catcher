# shellcheck shell=busybox
MODDIR=${0%/*}
. "$MODDIR/utils.sh"
resetprop -w sys.boot_completed 0
ANDROID_DIR=/sdcard/Android
LOGCAT_PID_FILE=$LOG_PATH/logcat.pid
LOG_FILE=$LOG_PATH/boot.log
while [ ! -d "$ANDROID_DIR" ]; do
  if [ -f "$LOGCAT_PID_FILE" ]; then
    LOGCAT_PID=$(cat "$LOGCAT_PID_FILE")
    if ! kill -0 "$LOGCAT_PID" 2>/dev/null; then
      logger -t LogCatcher -p warn "logd restarted, restarting logcat"
      logcat -b main,system,crash -f "$LOG_FILE" &
      echo $! >"$LOGCAT_PID_FILE"
    fi
  fi
  sleep 1
done
ANDROID_DIR_PERMISSION_TEST_FILE="$ANDROID_DIR/.PERMISSION_TEST"
touch "$ANDROID_DIR_PERMISSION_TEST_FILE"
while [ ! -f "$ANDROID_DIR_PERMISSION_TEST_FILE" ]; do
  touch "$ANDROID_DIR_PERMISSION_TEST_FILE"
  sleep 1
done
rm "${ANDROID_DIR_PERMISSION_TEST_FILE:?}"
check_write
FILE=/data/local/logcatcher/boot.lcs
if [ ! -f "$FILE" ]; then
  if [ -f "$LOGCAT_PID_FILE" ]; then
    kill "$(cat "$LOGCAT_PID_FILE")" 2>/dev/null
    rm -f "$LOGCAT_PID_FILE"
  fi
  KMSG_PID_FILE=$LOG_PATH/kmsg.pid
  if [ -f "$KMSG_PID_FILE" ]; then
    kill "$(cat "$KMSG_PID_FILE")" 2>/dev/null
    rm -f "$KMSG_PID_FILE"
  fi
  BOOT_LOG_TIME=$(get_time "$LOG_PATH/boot.log")
  mv "$LOG_FILE" "$LOG_PATH/boot-$BOOT_LOG_TIME.log"
  mv "$LOG_PATH/kernel.log" "$LOG_PATH/kernel-$(get_time "$LOG_PATH/kernel.log").log"
  tar -czf "/sdcard/Download/bootlog-$BOOT_LOG_TIME.tar.gz" -C "$LOG_PATH" . && rm -rf "${LOG_PATH:?}"
elif [ -d "$LOG_PATH/old" ]; then
  for f in "$LOG_PATH"/old/boot-*.log; do
    [ -f "$f" ] || continue
    [ -z "$BOOT_LOG_TIME" ] && BOOT_LOG_TIME=$(get_time "$f") && break
  done
  [ -n "$BOOT_LOG_TIME" ] && tar -czf "/sdcard/Download/bootlog-$BOOT_LOG_TIME.tar.gz" -C "$LOG_PATH/old" . && rm -rf "${LOG_PATH:?}/old"
fi
