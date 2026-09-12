;; also reused code from old kotori-os projects

io_wait:    
	xor al, al
	out 0x80, al
	ret

_pic_remap:
	mov al, (0x10 | 0x01)       ; starts the initialization
	out 0x20, al
	call io_wait

	mov al, (0x10 | 0x01)
	out 0xa0, al
	call io_wait

	mov al, 0x20            ; first offset
	out (0xa0 + 1), al
	call io_wait

	mov al, 0x28                ; second offset
	out (0xa0 + 1), al
	call io_wait

	mov al, (1 << 2)
	out (0xa0 + 1), al
	call io_wait

	mov al, 0x01
	out (0x20 + 1), al
	call io_wait

	mov al, 0x01
	out  (0x0a + 1), al

	ret