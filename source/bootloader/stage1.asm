;; boot.stage1.asm 
use16
org 0x7c00

include "scripted/stage2_size.asm"

_entry:
;; this is necessary so the very first code is the _start
	jmp 0x0000:_start

include "print_realmode.asm"

_start: 
;; setup segment registers
	xor ax, ax
	mov ds, ax
	mov es, ax  
	mov ss, ax
	mov sp, 0x9c00              ; adjust stack

	cld

	mov [drive], dl             ; get boot drive number

	;; show boot message
	mov si, boot_msg
	call _print16

;; load stage 2
	mov word [DAP.lba], 1
	mov word [DAP.num_sectors], STAGE2_SECTORS
	mov dl, [drive]
	mov si, DAP
	mov ah, 0x42
	int 0x13
	
	jmp far 0x0000:0x7e00 ;; jump to stage 2
	
;;_disk_read_err: 
;;	mov si, disk_read_err_msg
;;	call _print16

.halt: 
	hlt
	jmp .halt

align 16
DAP:
.size:	db 0x10
.zero:	db 0
.num_sectors: dw STAGE2_SECTORS
.buf_offset: dw 0x7e00
.segment: dw 0x0000
.lba:	dq 1
drive:  db 0
disk_read_err_msg: db "disk error", 13, 10, 0
boot_msg:  db "booting", 13, 10, 0

times 510-($-$$) db 0
dw 0xaa55
