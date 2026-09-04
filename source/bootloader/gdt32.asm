;; The GDT for protected mode
;; It will only be needed to
;; transition to long mode.

GDT32:  
	.null: dq 0x0000000000000000
	.code: dq 0x00CF9A000000FFFF
	.data: dq 0x00CF92000000FFFF
GDT32_end:
  
GDT32_ptr:  
	.limit: dw GDT32_end - GDT32 - 1
	.base: dd GDT32

CODE_SEG32 equ 0x08
DATA_SEG32 equ 0x10

