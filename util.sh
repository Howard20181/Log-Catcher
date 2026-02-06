# shellcheck shell=busybox
check_logpath() {
    if [ -d /cache ]; then
        LOG_PATH=/cache/bootlog
    else
        LOG_PATH=/data/local/bootlog
    fi
}
check_unlock() {
    local TEST_DIR=/sdcard/Android
    while [ ! -d "$TEST_DIR" ]; do
        sleep 1
    done
    local TEST_FILE="$TEST_DIR/.PERMISSION_TEST"
    touch "$TEST_FILE"
    while [ ! -f "$TEST_FILE" ]; do
        touch "$TEST_FILE"
        sleep 1
    done
    rm "${TEST_FILE:?}"
}
check_write() {
    local TEST_DIR=/sdcard/Download
    [ -d "$TEST_DIR" ] || mkdir -p "$TEST_DIR"
    local TEST_FILE="$TEST_DIR/.PERMISSION_TEST"
    touch "$TEST_FILE"
    while [ ! -f "$TEST_FILE" ]; do
        touch "$TEST_FILE"
        sleep 1
    done
    rm "${TEST_FILE:?}"
}
gettime() {
    if [ -z "$1" ] || [ ! -f "$1" ]; then
        date "+%Y%m%d-%H%M%S"
        return
    fi
    local ts
    ts=$(stat -c %Y "$1" 2>/dev/null)
    date -d "@$ts" "+%Y%m%d-%H%M%S" 2>/dev/null || date -r "$1" "+%Y%m%d-%H%M%S"
}
