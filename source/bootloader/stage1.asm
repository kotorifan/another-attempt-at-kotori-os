format binary
use16
org 0x7c00

jmp 0x0000:_boot_start	

include "print_realmode.asm"

_boot_start:
;; Setup the segment registers
	xor ax, ax
	mov ss, ax	
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

;; Adjust the stack
	mov sp, 0x9c00
	cld
	
;; Booting message to show that the 
;; bootloader is indeed booting
	mov si, msg_boot
	call _print_realmode

;; Load the 2nd stage from disk				
	mov si, DAP					; DAP is at cs:si
	mov ah, 0x42				; Extended read
	mov dl, 0x80				; Set drive number. For practical purposes 0x80
	int 0x13					; Read disk 
	jc _print_disk_err

	;;mov dl, [drive] ;; Save the disk number for later
	jmp 0x0000:0x7e00 ;; Jump to the 2nd stage


_print_disk_err:
	mov si, msg_disk_err

_halt:
	hlt
	jmp _halt

align 16
DAP:
.size: db 0x10			; DAP size
.zero: db 0
.num_sectors: dw 1			; sectors read
.offset: dw 0x7e00		; 2nd stage offset
.segment: dw 0x0000
.lba. dq 1
drive:  db 0
msg_disk_err: db "Disk error", 13, 10, 0
msg_boot:  db "Booting", 13, 10, 0
	
	
	
times 510 - ($ - $$) db 0
dw 0xaa55
