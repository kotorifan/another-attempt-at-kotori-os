use32

define VGA_WHITE_ON_BLACK 0x0f
define VGA_BUFFER 0xb8000

_print_protmode: 
	pusha
	mov edx, VGA_BUFFER

.loop:
	mov al, [ebx]
	test al, al
	je .done
			
	mov ah, VGA_WHITE_ON_BLACK
	mov [edx], ax
			
	inc ebx					; Move on the next character
	add edx, 2				; Next VGA buffer cell
	jmp .loop

.done:
	popa
	ret
