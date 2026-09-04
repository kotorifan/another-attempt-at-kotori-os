;; performs all the necessary steps to get into
;; Long Mode
use16
org 0x7e00

jmp 0x0000:_stage2_start

include "a20.asm"
include "print_realmode.asm"

macro load_segments seg {
	mov ax, seg
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
}

_stage2_start:
	cli				; disable interrupts for now
	load_segments 0
	
	mov si, msg_reached_stage2
	call _print_realmode

	;; Enable A20 line
	call _enable_a20

halt:
	hlt
	jmp halt

msg_reached_stage2: 
	db "Reached Stage 2", 13, 10, 0