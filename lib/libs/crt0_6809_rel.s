		.export _environ
		.export head

		.code
head:
		.word 0x80A8
		.byte 0x04			; 6809
		.byte 0x00			; 6309 not needed
		.byte 0				; page to load at
		.byte 0				; no hints
		.word __data			; gives us header + all text segments
		.word __data_size		; gives us data size info
		.word __bss_size		; bss size info
		.byte <start			; entry relative to start
		.byte 0				; no chmem hint
		.byte 0				; no stack hint
		.byte 0				; ZP not supported

		.word 0				; Signals (unused)
		.word 0				; Patched for reloc ptr

		; We can be at any page aligned address but our base
		; is passed in Y
start:
		tfr y,x				; Base into both
		ldd 18,x			; Relocation offset from
						; our header
		leay d,y			; To relocation base

		tfr x,d				; Base into D so we can get
						; the high byte for
						; relocating into A

		;
		; A is the relocation amount in pages
		; B is scratch
		; U is not used
		; X is the binary as we walk it relocating
		; Y is the relocation table pointer
		;
relocnext:
		ldb ,y				; Relocation byte
		clr ,y+				; Turn into BSS
		tstb				; 0 is end marker
		beq  relocdone
		cmpb #255			; 255 is a long skip
		beq reloc254
		abx				; 1-254 is that many
						; bytes on and relocate
		tfr a,b				; Shuffle to keep the
		addb ,x				; A value unchanged
		stb ,x				; Relocate the byte
		bra relocnext

reloc254:	; 255 means move on 254 but do not relocate
		decb				; We know B is 255
		abx
		bra relocnext

		;
		; Correct the brk base of the binary as we can now discard
		; the relocation table from memory if it grew the binary
		; size
		;

relocdone:
		; Fix up the BSS base
		; This will be relocated before it is run
		ldd #__bss
		addd #__bss_size
		std ,--s
		std ,--s
		ldd #30				; brk(x)
		swi				; and syscall
		leas 4,s
		;
		;  This jmp was relocated by the relocation loop above
		;
		; we don't clear BSS since the kernel already did
		lbsr ___stdio_init_vars

		; pass environ, argc and argv to main
		; pointers and data stuffed above stack by execve()
		leax 4,s
		stx _environ,pc
		ldx 2,s
		stx ___argv,pc
		lbsr _main		; go
		pshs d
		lbsr _exit

		.data
_environ:	.word 0
