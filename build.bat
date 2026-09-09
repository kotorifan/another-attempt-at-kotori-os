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
if not exist "%BUILD%" mkdir "%BUILD%"
if exist "%BUILD%\stage2.bin" del /f /q "%BUILD%\stage2.bin"
if exist "%SRC%\bootloader\scripted\stage2_size.asm" del /f /q "%SRC%\bootloader\scripted\stage2_size.asm"
%AS% "%SRC%\bootloader\stage2.asm" "%BUILD%\stage2.bin"
if errorlevel 1 exit /b 1

for %%F in ("%BUILD%\stage2.bin") do (
	set /a STAGE2_SIZE=%%~zF
)
set /a SECTOR_SIZE=512
set /a STAGE2_SECTORS=(STAGE2_SIZE + SECTOR_SIZE - 1) / SECTOR_SIZE

echo define STAGE2_SECTORS %STAGE2_SECTORS% > "%SRC%\bootloader\scripted\stage2_size.asm"

for /r "%SRC%" %%F in (*.asm) do (
	if /i not "%%~nxF"=="stage2.asm" (
		echo Assembling... %%F
		%AS% "%%F" "%BUILD%\%%~nF.bin"

		if errorlevel 1 exit /b 1
	)
)

copy /b "%BUILD%\stage1.bin"+"%BUILD%\stage2.bin" "%DISK%" >nul

echo Build complete.
exit /b 0

:debug
qemu-system-x86_64 -drive format=raw,file=disk.img -S -s -serial mon:stdio -d int -no-shutdown -no-reboot
exit /b 0

:run 
qemu-system-x86_64 -drive format=raw,file=disk.img
exit /b 0

:clean 
if exist build rmdir /s /q build
if exist disk.img del disk.img
exit /b 0