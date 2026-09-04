format binary
use16
org 0x7c00

jmp 0x0000:_boot_start	

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
	xor ax, ax		
	mov ah, 0x42				; Extended read
	mov dl, [drive]				; Set drive number
	int 0x13					; Read disk 
	jc _print_disk_err

	mov dl, [drive]
	;;jmp 0x0000:STAGE2_ADDR

_print_realmode: 
	.loop:
	lodsb
	or al, al   
	jz .done
	mov ah, 0x0e
	int 0x10
	jmp .loop
.done:
	ret

_print_disk_err:
	mov si, msg_disk_err

_halt:
	hlt
	jmp _halt
			
align 16
DAP:
	db 0x10
	db 0
	dw 16 ;; Number of read sectors
	dw 0x7e00 ;; Address for stage 2
	dw 0x0000
	dq 1
drive:  db 0
msg_disk_err: db "Disk error", 13, 10, 0
msg_boot:  db "Booting", 13, 10, 0
	
	
	
times 510 - ($ - $$) db 0
dw 0xaa55
