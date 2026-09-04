@echo off

set DISK=disk.img
set AS=fasm
set SRC=source
set BUILD=build

if /i "%1"=="clean" goto clean
if /i "%1"=="run" goto run
if /i "%1"=="debug" goto debug
if "%1"=="" goto build
if /i "%1"=="build" goto build

:build
if not exist build mkdir build

for /r "%SRC%" %%F in (*.asm) do (
	echo Assembling... %%F
	fasm "%%F" "%BUILD%\%%~nF.bin"
)
rem Maybe useful for later
rem fsutil file createnew "%DISK%" 1474560
rem copy /b "%BUILD%\stage1.bin"+"%BUILD%\stage2.bin" "%DISK%" 
rem copy "%BUILD%\stage1.bin"+"%BUILD%\stage2.bin" "%DISK%"
rem copy /b "%BUILD%\stage1.bin" "%DISK%" >nul

for %%F in ("%BUILD%\stage1.bin") do set SIZE=%%~zF
if not "%SIZE%"=="512" (
	echo "Stage1 is not exactly one sector big. Dumbass"
	exit /b 1
)
copy /b "%BUILD%\stage1.bin"+"%BUILD%\stage2.bin" "%DISK%"
echo Build complete. stage1.bin=%SIZE% bytes
exit /b 0

:debug
qemu-system-x86_64 -drive format=raw,file=disk.img -S -s -serial mon:stdio -d int -no-shutdown -no-reboot
exit /b 0

:run 
qemu-system-x86_64 -drive format=raw,file=disk.img
exit /b 0

:clean 
if exist build rmdir /s /q build
exit /b 0