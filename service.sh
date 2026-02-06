# shellcheck shell=busybox
MODDIR=${0%/*}
. "$MODDIR/utils.sh"
resetprop -w sys.boot_completed 0
check_unlock
check_write
FILE=/data/local/logcatcher/boot.lcs
if [ ! -f "$FILE" ]; then
  pkill -f logcatcher-bootlog:S
  KMSG_PID_FILE=$LOG_PATH/kmsg.pid
  if [ -f "$KMSG_PID_FILE" ]; then
    kill "$(cat "$KMSG_PID_FILE")" 2>/dev/null
    rm -f "$KMSG_PID_FILE"
  fi
  BOOT_LOG_TIME=$(get_time "$LOG_PATH/boot.log")
  mv "$LOG_PATH/boot.log" "$LOG_PATH/boot-$BOOT_LOG_TIME.log"
  mv "$LOG_PATH/kernel.log" "$LOG_PATH/kernel-$(get_time "$LOG_PATH/kernel.log").log"
  tar -czf "/sdcard/Download/bootlog-$BOOT_LOG_TIME.tar.gz" -C "$LOG_PATH" ./* && rm -rf "${LOG_PATH:?}"
elif [ -d "$LOG_PATH/old" ]; then
  for f in "$LOG_PATH"/old/boot-*.log; do
    [ -f "$f" ] || continue
    [ -z "$BOOT_LOG_TIME" ] && BOOT_LOG_TIME=$(get_time "$f") && break
  done
  [ -n "$BOOT_LOG_TIME" ] && tar -czf "$LOG_PATH/bootlog-$BOOT_LOG_TIME.tar.gz" -C "$LOG_PATH/old" ./* && rm -rf "${LOG_PATH:?}/old"
fi
