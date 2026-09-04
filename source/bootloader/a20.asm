;; Enables the A20 line.
;; Also taken from old kotori-os source code.
;; It should work though.
use16

_enable_a20:    
	cli                     ; Disable interrupts

;; Disable keyboard
	call .wait_io1
	mov al, 0xad
	out 0x64, al

;; Read from keyboard controller
	call .wait_io1
	mov al, 0xd0
	out 0x64, al

	call .wait_io2
	in al, 0x60
	push eax ; Save current value


;; Write back with the A20 bit set
	call .wait_io1
	mov al, 0xd1
	out 0x64, al

	call .wait_io1
	pop eax
	or al, 2 ; Set A20 bit

;; Enable keyboard
	call .wait_io1
	mov al, 0xae
	out 0x64, al

	call .wait_io1
			
.wait_io1:
	in al, 0x64
	test al, 2
	jnz .wait_io1
	ret

.wait_io2:
	in al, 0x64
	test al, 1
	jz .wait_io2
	ret
