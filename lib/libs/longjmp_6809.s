
	.export _longjmp
	.code
; void longjmp(jmp_buf, int)
_longjmp:
	ldx 2,s
	; read back Y,U,S and return address
	ldd 4,s		; second argument
	bne nz		; must not be 0
	incb
nz:	ldy ,x++
	ldu ,x++
	lds ,x++	; points to clobbered return address
	ldx ,x
	stx ,s		; restore return address
	; return given argument to setjmp caller
	rts

