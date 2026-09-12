use64

macro isr num {
isr_stub_#num:
	push 0
	push num
	jmp _isr_handler_common
}

macro isr_err num {
isr_stub_err_#num:
	push num
	jmp _isr_handler_common
}

macro irq num {
irq_stub_#num:
	push 0
	push num
	jmp _irq_handler_common
}


isr 0
isr 1
isr 2
isr 3
isr 4
isr 5
isr 6
isr 7
isr_err 8
isr 9
isr_err 10
isr_err 11
isr_err 12
isr_err 13
isr_err 14
isr 15
isr 16
isr_err 17
isr 18
isr 19
isr 20
isr 21
isr 22
isr 23
isr 24
isr 25
isr 26
isr 27
isr 28
isr 29
isr_err 30
isr 31

irq 32
irq 33
irq 34
irq 35
irq 36
irq 37
irq 38
irq 39
irq 40
irq 41
irq 42
irq 43
irq 44
irq 45
irq 46
irq 47

macro IDT_entry handler {
	dw handler
	dw 8
	db 0,0x8e
	dw handler shr 16
	dd handler shr 32
	dd 0
}

align 16
IDT:
rept 32 i:0 {
	IDT_entry isr_stub_#i
}

rept 16 i:32 {
	IDT_entry irq_stub_#i
}

rept 208 {
	IDT_entry isr_stub_default
}
IDT_end:

IDT_ptr:
	.limit: dw IDT_end - IDT - 1
	.base: dq IDT