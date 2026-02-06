# shellcheck shell=busybox
# shellcheck disable=SC2117
MODDIR=${0%/*}
getprop2() {
    grep -m 1 "^$2=" "$1" | cut -d= -f2
}
. "$MODDIR/util.sh"
check_logpath
if [ -d "$LOG_PATH" ]; then
    [ -d "$LOG_PATH/old" ] || mkdir -p "$LOG_PATH/old"
    for f in "$LOG_PATH"/*.log; do
        [ -f "$f" ] || continue
        base=$(basename "$f")
        name=${base%.log}
        mv "$f" "$LOG_PATH/old/$name-$(gettime "$f").log"
    done
else
    mkdir -p "$LOG_PATH"
fi

KMSG_PID_FILE=$LOG_PATH/kmsg.pid
rm -f "$KMSG_PID_FILE"
KERNEL_LOG_FILE=$LOG_PATH/kernel.log
cat /proc/kmsg >"$KERNEL_LOG_FILE" &
echo $! >"$KMSG_PID_FILE"
LOG_FILE=$LOG_PATH/boot.log
SU_VERSION=$(su -v)
{
    echo "Log Catcher version: $(getprop2 "$MODDIR/module.prop" version) ($(getprop2 "$MODDIR/module.prop" versionCode))"
    echo "--------- beginning of information"
    echo "Manufacturer: $(getprop ro.product.manufacturer)"
    echo "Product: $(getprop ro.build.product)"
    echo "Model: $(getprop ro.product.model)"
    echo "Fingerprint: $(getprop ro.build.fingerprint)"
    echo "ROM build description: $(getprop ro.build.description)"
    echo "Architecture: $(getprop ro.product.cpu.abi)"
    echo "Android sdk: $(getprop ro.build.version.sdk)"
    echo "${SU_VERSION#*:}: ${SU_VERSION%:*} ($(su -V))"
    echo "SELinux: $(getenforce)"
} >>"$LOG_FILE"
logcat -b main,system,crash -f "$LOG_FILE" logcatcher-bootlog:S &
