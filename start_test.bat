@echo off
adb push module.prop /data/local/tmp
adb push post-fs-data.sh /data/local/tmp
adb push utils.sh /data/local/tmp
adb shell su -c sh /data/local/tmp/post-fs-data.sh
