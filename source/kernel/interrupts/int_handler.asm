use64

include "../common/macros.asm"

_idt_load:
	lidt [IDT_ptr]
	ret


