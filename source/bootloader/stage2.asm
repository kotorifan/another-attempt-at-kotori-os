;; performs all the necessary steps to get into
;; Long Mode
use16
org 0x7e00

jmp 0x0000:_stage2_start

include "a20.asm"
include "gdt32.asm"
include "print_realmode.asm"

;; Constants related to paging
PAGE_PRESENT = (1 shl 0) 
PAGE_WRITE = ( 1 shl 1) 
PAGE_LARGE_SIZE = (1 shl 7)
PML4_ADDR  = 0x1000
PDPT_ADDR  = 0x2000
PD_ADDR    = 0x3000

macro load_segments seg {
	mov ax, seg
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
}

macro map_table src, dst {
	mov dword [src], dst or PAGE_PRESENT or PAGE_WRITE
	mov dword [src + 4], 0
}

macro enable_crbit cr, val {
	mov eax, cr
	or  eax, val
	mov cr, eax
}

macro load_pml4_address addr {
	mov eax, addr
	mov cr3, eax
}

macro enable_msr msr, bit {
	mov ecx, msr
	rdmsr
	or eax, bit
	wrmsr	
}

_stage2_start:
	cli				; disable interrupts for now
	load_segments 0
	
	mov si, msg_reached_stage2
	call _print16

	;; Enable A20 line
	call _enable_a20
	mov si, msg_enabled_a20
	call _print16
	
	;; Load GDT for protected mode
	lgdt [GDT32_ptr]
	mov si, msg_loaded_gdt32
	call _print16
	
	;; Enable protected mode
	mov eax, cr0
	or eax, 1
	mov cr0, eax

    jmp far CODE_SEG32:_protmode
	
use32
include "print_protmode.asm"
include "gdt64.asm"

_protmode:
	load_segments DATA_SEG32
	
	;; Set up the stack for protected mode
	mov esp, 0x90000
	
	mov ebx, msg_reached_protmode
	call _print32
	
	;; Set up paging
	;; Zero out all page tables
	;; 0x1000 is the page tab size here
	;; See here:
	;; https://thasso.xyz/setting-up-an-x86-cpu.html
	mov ecx, 0x1000
	mov edi, 0x1000
	xor eax, eax
	rep stosd ; Repeat until it is all zero'd out
	
	mov edi, ebx
	lea eax, [edi + (0x1000 or 11b)]
	mov dword [edi], eax
		
	;; Create Page tables
	;; PML4 -> PDPT
	map_table 0x1000, 0x2000

	;; PDPT -> PD
	map_table 0x2000, 0x3000
	
	;; Identity map the first 1GiB using 2MiB pages
	mov edi, 0x3000
	mov ebx, 0
	mov ecx, 512
.map:
	mov eax, ebx
	or eax, PAGE_PRESENT or PAGE_WRITE or PAGE_LARGE_SIZE
			
	mov dword [edi], eax
	mov dword [edi + 4], 0

	add ebx, 0x200000
	add edi, 8
	loop .map

	enable_crbit cr4, 1 shl 5 ; Enable PAE
	enable_msr 0x0C0000080, 1 shl 8 ; Enable LME
	load_pml4_address PML4_ADDR
	enable_crbit cr0, 1 shl 31      ; Enable Paging

	lgdt [GDT64_ptr]
			
	jmp far CODE_SEG64:_longmode

use64
include "print.asm"
include "macros.asm"
_longmode:
	mov rsp, 0x90000
	
;;	call _clear_screen
	mov rdi, msg_boot_longmode
	call _print64
	 
halt:
	hlt
	jmp halt

msg_reached_stage2: 
	db "Reached Stage 2", 13, 10, 0
msg_reached_protmode:
	db "Reached protected mode", 13, 10, 0
msg_enabled_a20:
	db "Enabled the A20 line", 13, 10, 0
msg_loaded_gdt32:
	db "Loaded the 32-bit GDT", 0
msg_boot_longmode:
	db "Booted into long mode", 0