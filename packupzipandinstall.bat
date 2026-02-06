@echo off
echo running packupzip
for /f %%a in ('packupzip.bat') do set "filename=%%a"
title Magisk Module Quick Install (by Howard)
installmodule "%filename%"
pause
