;; The GDT for long mode
GDT64:
	.null: dq 0x0000000000000000
	.code: dq 0x00209A0000000000
	.data: dq 0x0000920000000000
GDT64_end:

GDT64_ptr:
	.limit: dw GDT64_end - GDT64 - 1
	.base:  dq GDT64

CODE_SEG64 equ 0x08
DATA_SEG64 equ 0x10
