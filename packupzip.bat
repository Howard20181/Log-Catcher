@echo off
title Magisk Module Quick Packing (by Howard)
For /f "tokens=1-2 delims==" %%i in (module.prop) do (
If /i "%%i"=="id" set id=%%j
)
set filename=%id%.zip
IF EXIST "%filename%" DEL /Q /S "%filename%"
7z a "%filename%" META-INF/** system/** common/** mods/** *.prop *.sh README.md *.apk *.rule ksu/** *.rc
echo %filename%

