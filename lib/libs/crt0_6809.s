;
;	Initial 6309/6809 crt0.
;

	.code

	.export _environ
	.export head

head:
	.word 0x80A8
	.byte 0x04			; 6809
	.byte 0x00			; 6309 not needed
	.byte 1				; page to load at
	.byte 0				; no hints
	.word __data-0x0100		; gives us header + all text segments
	.word __data_size		; gives us data size info
	.word __bss_size		; bss size info
	.byte <start			; entry relative to start
	.byte 0				; no chmem hint
	.byte 0				; no stack hint
	.byte __zp_size			; ZP size

	; TODO signal handler, relocations

start:
	; we don't clear BSS since the kernel already did
	jsr ___stdio_init_vars

	; pass environ, argc and argv to main
	; pointers and data stuffed above stack by execve()
	leax 4,s
	stx _environ
	ldx 2,s
	stx ___argv
	jsr _main		; go
	pshs d
	jsr _exit

	.data

_environ:
	.word 0
