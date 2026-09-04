use16

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