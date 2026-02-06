# shellcheck shell=busybox
LOG_PATH=/cache/bootlog
[ -d /cache ] || LOG_PATH=/data/local/bootlog
get_prop() {
    grep -m 1 "^$2=" "$1" | cut -d= -f2
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
get_time() {
    local fmt
    fmt="%Y%m%d-%H%M%S"
    if [ -z "$1" ] || [ ! -f "$1" ]; then
        date "+$fmt"
        return
    fi
    local ts
    ts=$(stat -c %Y "$1" 2>/dev/null)
    date -d "@$ts" "+$fmt" 2>/dev/null || date -r "$1" "+$fmt"
}
get_model() {
    local model marketname
    model=$(getprop ro.product.model)
    marketname=$(getprop ro.product.marketname)
    [ -z "$marketname" ] && marketname="$(getprop ro.vivo.market.name)"
    [ -n "$marketname" ] && model="$model ($marketname)"
    echo "$model"
}
