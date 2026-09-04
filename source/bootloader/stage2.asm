;; performs all the necessary steps to get into
;; Long Mode
use16
org 0x7e00

jmp 0x0000:_stage2_start

include "a20.asm"
include "print_realmode.asm"
include "gdt32.asm"

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
	mov si, msg_enabled_a20
	call _print_realmode
	
	;; Load GDT for protected mode
	lgdt [GDT32_ptr]
	mov si, msg_loaded_gdt32
	call _print_realmode
	
	;; Enable protected mode
	mov eax, cr0
	or eax, 1
	mov cr0, eax

    jmp far CODE_SEG32:_protmode
	
use32
include "gdt64.asm"
include "print_protmode.asm"

_protmode:
	load_segments DATA_SEG32
	
	;; Set up the stack for protected mode
	mov esp, 0x90000
	
	mov ebx, msg_reached_protmode
	call _print_protmode
	
halt:
	hlt
	jmp halt

msg_reached_stage2: 
	db "Reached Stage 2", 13, 10, 0
msg_reached_protmode:
	db "Reached protected mode", 13, 10, 0
msg_enabled_a20:
	db "Enabled the A20 line", 13, 10, 0
msg_loaded_gdt32:
	db "Loaded the 32-bit GDT", 13, 10, 0