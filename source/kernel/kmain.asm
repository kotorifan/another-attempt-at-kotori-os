;; does all the good stuff
include "./interrupts/int_handler.asm"
include "./interrupts/int.asm"
include "./interrupts/pic.asm"
_kmain:
	cli ;; cli; ret
	;; call an assembly routine to remap the PIC
	call _pic_remap
	call _idt_load
	sti ;; sti; ret
	
	mov ah, 7
	mov bl, 0
	div bl
	