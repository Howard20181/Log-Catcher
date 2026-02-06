@echo off
adb push utils.sh /data/local/tmp
adb push service.sh /data/local/tmp
adb shell su -c '/data/adb/magisk/busybox sh /data/local/tmp/service.sh'
pause
