use64
include "../common/macros.asm"
include "../drivers/vga/kwrite.asm"
include "idt.asm"

struc cpu_state {
	.rax dq ?
	.rbx dq ?
	.rcx dq ?
	.rdx dq ?
	.rsi dq ?
	.rdi dq ?
	.rbp dq ?
	.r8 dq ?
	.r9 dq ?
	.r10 dq ?
	.r11 dq ?
	.r12 dq ?
	.r13 dq ?
	.r14 dq ?
	.r15 dq ?
	.interrupt dq ?
	.error dq ?
	.rip dq ?
	.cs dq ?
	.eflags dq ?
	.rsp dq ?
	.ss dq ?
}

_isr_handler_common:
	pushaq
	mov ax, ds
	push rax
	load_segments 0x10
	lea rdi, [rsp + 8]
	call _exception_handler
	
	pop rax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	popaq
	add rsp, 16 ;; mind you, it's 64-bit mode
	iretq
	
_irq_handler_common:
	pushaq
	
	mov ax, ds
	push rax
	load_segments 0x10
	lea rdi, [rsp + 8]
	call _irq_handler
	
	pop rax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	popaq
	add rsp, 16 ;; same as above
	iretq 
	
_irq_handler:
	mov rax, [rdi + cpu_state.interrupt]
	cmp qword [irq_handlers + rax * 8], 0
	je .eoi
	call qword [irq_handlers + rax * 8]
.eoi:
	mov al, 0x20
	out 0x20, al
	
	cmp qword [rdi + cpu_state.interrupt], 40
	jb .master
	
	out 0x0a0, al
.master:
	out 0x20, al
	ret
	
_exception_handler:
	mov rax, [rdi + cpu_state.interrupt]
	mov rdi, messages.exception
	call _kwrite
	
	cmp rax, 31
	ja .unknown
	
	mov rdi, [exceptions + rax * 8]
	call _kwrite
	
	cli
.hang:
	hlt
	jmp .hang

.unknown:
	mov rdi, messages.unknown_exception
	call _kwrite
	
	cli
	jmp .hang

;; Multiply by 8 to get the particular string for the
;; exception.
exceptions:
	.exc0: db "Division by Zero (0x00)", 0
	.exc1: db "Debug (0x01)", 0
	.exc2: db "Non-maskable interrupt (0x02)", 0
	.exc3: db "Breakpoint (0x03)", 0
	.exc4: db "Into detected overflow (0x04)", 0
	.exc5: db "Out of bounds (0x05)", 0
	.exc6: db "Invalid opcode (0x06)", 0
	.exc7: db "No coprocessor (0x07)", 0
	.exc8: db "Double fault (0x08)", 0
	.exc9: db "Coprocessor segment overrun (0x09)", 0
	.exc10: db "Bad TSS 0x0a", 0
	.exc11: db "Segment not present (0x0b)", 0
	.exc12: db "Stack Fault (0x0c)	", 0
	.exc13: db "General Protection Fault (0x0d)", 0
	.exc14: db "Page Fault (0x0e)", 0
	.exc15: db "Unknown Interrupt (0x0f)", 0
	.exc16: db "Coprocessor Fault (0x10)", 0
	.exc17: db "Alignment check (0x11)", 0
	.exc18: db "Machine check (0x12)", 0
	.exc19: db "SIMD Floating Exception (0x13)", 0
	.exc20: db "Virtual Exception (0x14)", 0
	.exc21: db "Control Protection Exception (0x15)", 0
	.exc22: db "Reserved (0x16)", 0
	.exc23: db "Reserved (0x17)", 0
	.exc24: db "Reserved (0x18)", 0
	.exc25: db "Reserved (0x19)", 0
	.exc26: db "Reserved (0x1a)", 0
	.exc27: db "Reserved (0x1b)", 0
	.exc28: db "Hypervisor Intrusion Exception (0x1c)", 0
	.exc29: db "VMM Communications Exception (0x1d)", 0
	.exc31: db "Security Excpetion (0x1e)", 0
	.exc32: db "Reserved (0x1f)", 0
	
messages:
	.exception: db "An exception occurred. You screwed up.", 0
	.unknown_exception: db "The exception number does not correspond with any exception in the table", 0