@echo off
adb push utils.sh /data/local/tmp
adb push service.sh /data/local/tmp
adb shell su -c sh /data/local/tmp/service.sh
pause
