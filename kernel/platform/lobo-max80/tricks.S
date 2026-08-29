;
;	For simple banked systems there is a standard implementation. The
;	only reason to do otherwise is for speed. A custom bank logic aware
;	bank to bank copier will give vastly better fork() performance.
;
#include "kernelu.def"
#include "kernel-z80.def"

#include "z80ufixedbank.S"
#include "z80uuser1.s"
