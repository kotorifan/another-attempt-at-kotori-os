include "macros.asm"

define VGA_GREEN_ON_BLACK 0x0a
define VGA_BUFFER 0xb8000
define VGA_SCREEN_X 80
define VGA_SCREEN_Y 25
define VGA_SCREEN (VGA_SCREEN_X * VGA_SCREEN_Y)

_print64: 
	pushaq
			
	mov rsi, rdi    
	mov rdi, VGA_BUFFER
.loop:
			
	lodsb
	test al, al	; Check if the null term. has been reached
	jz .done
	mov ah, VGA_GREEN_ON_BLACK
	stosw	; Store AX to rdi, then increment by 2
	jmp .loop
.done:
	popaq
	ret

_clear_screen:  
	pushaq
			
	mov rdi, VGA_BUFFER
	xor rcx, rcx
.loop:
	cmp rcx, 2000
	jge .done
			
	mov ax, 0x20	; 0x20 -> ' ' 
	stosw
	inc rcx
	jmp .loop
.done:
	popaq
	ret
			
