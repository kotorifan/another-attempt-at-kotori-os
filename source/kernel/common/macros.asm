;; The same macros exist in the bootloader
;; source code, however I like to make the
;; bootloader and the kernel two separate
;; things, and thus I don't want them to
;; rely on each other's code

use64
macro pushaq {
	push rax
	push rbx
	push rcx
	push rdx
	push rbp
	push rsi
	push rdi
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
}

macro popaq {
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop rdi
	pop rsi
	pop rbp
	pop rdx
	pop rcx
	pop rbx
	pop rax
}

macro load_segments selector {
	mov ax, selector
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
}