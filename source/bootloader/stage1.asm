format binary
use16
org 0x7c00

jmp 0x0000:_boot_start

_boot_start:
	xor ax, ax
	mov ss, ax	
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	mov sp, _boot_start
	cld
	
times 510 - ($ - $$) db 0
dw 0xaa55
