;
;	    nano-z80 support
;
;

	; exported symbols
	.export init_hardware
	.export _program_vectors
	.export map_buffers
	.export map_kernel
	.export map_kernel_di
	.export map_kernel_restore
    .export map_proc
	.export map_proc_a
	.export map_proc_always
	.export map_proc_always_di
	.export map_save_kernel
	.export map_restore
    .export map_for_swap
    .export plt_interrupt_all
	.export _kernel_flag
	.export _int_disabled
    .export _disk_map
    .export _sd_sector0
    .export _sd_sector1
    .export _sd_sector2
    .export _sd_sector3
    .export _sd_set_sector_regs
    .export _sd_read_block
    .export _sd_write_block
    .export _sd_ptr
	; exported debugging tools
	.export _plt_monitor
	.export _plt_reboot
	.export outchar



#include "kernelu.def"
#include "kernel-z80.def"

;
; Buffers (we use asm to set this up as we need them in a special segment
; so we can recover the discard memory into the buffer pool
;

	.export _bufpool
	.buffers

_bufpool:
	.ds BUFSIZE * NBUFS

; -----------------------------------------------------------------------------
; COMMON MEMORY BANK (kept even when we task switch)
; -----------------------------------------------------------------------------
	.common
;
;	Interrupt flag. This needs to be in common memory for most memory
;	models. It starts as 1 as interrupts start off.
;
_int_disabled:
	.byte 1
;
;	This method is invoked early in interrupt handling before any
;	complex handling is done. It's useful on a few platforms but
;	generally a ret is all that is needed
;
plt_interrupt_all:
	ret

; -----------------------------------------------------------------------------
; KERNEL MEMORY BANK (may be below 0x8000, only accessible when the kernel is
; mapped)
; -----------------------------------------------------------------------------
	.code
;
;	If you have a ROM monitor you can get back to then do so, if not
;	fall into reboot.
;
_plt_monitor:
;
;	Reboot the system if possible, halt if not. On a system where the
;	ROM promptly wipes the display you may want to delay or wait for
;	a keypress here (just remember you may be interrupts off, no kernel
;	mapped so hit the hardware).
;
_plt_reboot:
	di
    halt
 
; -----------------------------------------------------------------------------
; DISCARD is memory that will be recycled when we exec init
; -----------------------------------------------------------------------------
	.discard
;
;	After the kernel has shuffled things into place this code is run.
;	It's the best place to breakpoint or trace if you are not sure your
;	kernel is loading and putting itself into place properly.
;
;	It's required jobs are to set up the vectors, ramsize (total RAM),
;	and procmem (total memory free to processs), as well as setting the
;	interrupt mode but *not* enabling interrupts. Many platforms also
;	program up support hardware like PIO and CTC devices here.
;
init_hardware:
    ; set system RAM size
    ld hl, 8192
    ld(_ramsize), hl
    ld hl, 4032
    ld(_procmem), hl

    ; Enable fixed region from 0xf000 in MMU
    ld a,1
    out (MFIXED_TOP), a

    ; Enable hardware TTY
    ld a, IO_SEL_TTY
    out (IO_SEL_REG), a
    ld a, 0x01
    out (TTY_ENABLED), a
    ;And disable autoscroll
    ld a, 0x00
    out (TTY_AUTOSCR), a
    ;Set video mode to text with color
    ld a, 0x04
    out (TTY_VIDMODE), a

    ; Configure keyboard arrow keys for VT52
    ld a,IO_SEL_USB
    out (IO_SEL_REG), a
    ld a,0x03
    out (USB_ARROWKEY), a

    call _vtinit

    ld hl, 0
	push hl
	call _program_vectors
	pop hl
	
    ; Start timer and enable interrupt output
    ld a, IO_SEL_PIC      ; Select interrupt controler
    out (IO_SEL_REG), a
    ld a, 0x0F      ; Enable channels 1,2,3,4 (timer, keyboard, uarts)
    out (PIC_IRQ_EN), a

    ld a, IO_SEL_TMR      ; Select timer
    out (IO_SEL_REG), a
    ld a, 0x01      ; Start timer, default setting is 100 Hz
    out (TMR_ENABLE), a
    
    im 1
	
    ret

;
;	Bank switching unsurprisingly must be in common memory space so it's
;	always available.
;
	.common

_kernel_flag:
	.byte 1	; We start in kernel mode
mapreg:
	.byte 0	; Our map register is write only so keep a copy
mapsave:
	.byte 0	; Saved copy of the previous map (see map_save)
;
;	This is invoked with a NULL argument at boot to set the kernel
;	vectors and then elsewhere in the kernel when the kernel knows
;	a bank may need vectors writing to it.
;
_program_vectors:
    di
    pop de                          ; temporarily store return address
    pop hl                          ; function argument -- base page number    
    push hl                         ; put stack back as it was
    push de

    ; At this point the common block has already been copied
    call map_proc

    ; now install the interrupt vector at 0x0038 (shouldn't be used)

    ld a, 0xC3                      ; JP instruction
    ld (0x0038), a
    ld hl, interrupt_handler
    ld (0x0039),hl    
    
    ; set restart vector for FUZIX system calls
    ld (0x0030), a   ;  (rst 30h is unix function call vector)
    ld hl, unix_syscall_entry
    ld (0x0031), hl

    ld (0x0000), a
    ld hl, null_handler   ;   to Our Trap Handler
    ld (0x0001), hl

;
;	Mapping set up for the SBCv2
;
;	The top 32K bank holds kernel code and pieces of common memory
;	The lower 32K is switched between the various user banks.
;
;	We know the ROM mapping is already off
;
;	The _di versions of the functions are called when we know interrupts
;	are definitely off. In our case it's not useful information so both
;	symbols end up at the same code.
;
map_buffers:
	; for us no difference. We could potentially use a low 32K bank
	; for buffers but it's not clear it would gain us much value
map_kernel_di:
map_kernel:
map_kernel_restore:
	push af
	ld a,0x00
	ld (mapreg),a
	out (0x60), a
    inc a
    out (0x62), a
	inc a
    out (0x64), a
    inc a
    out (0x66), a
    pop af
	ret
	
    ; map_proc is called with HL either NULL or pointing to the
	; page mapping. Unlike the other calls it's allowed to trash AF
map_proc:
	ld a, h
	or l
	jr z, map_kernel
map_proc_hl:
	ld a, (hl)			; and fall through
	;
	; With a simple bank switching system you need to provide a
	; method to switch to the bank in A without corrupting any
	; other registers. The stack is safe in common memory.
	; For swap you need to provide what for simple banking is an
	; identical routine.
map_for_swap:
map_proc_a:			; used by bankfork
    or a
    jr z, map_kernel ; page 0 is kernel
    push af
    ld (mapreg), a	; bank
	; Calculate physical page (a * 4)
    add a,a
    add a,a
    ; Set page register
    out (0x60), a
    inc a
    out (0x62), a
    inc a
    out (0x64), a
    inc a
    out (0x66), a
	pop af
    ret

	;
	; Map the current process into memory. We do this by extracting
	; the bank value from u_page.
	;
map_proc_always_di:
map_proc_always:
	push af
	push hl
	ld hl, _udata + U_DATA__U_PAGE
	call map_proc_hl
	pop hl
	pop af
	ret

	;
	; Save the existing mapping and switch to the kernel.
	; The place you save it to needs to be in common memory as you
	; have no idea what bank is live. Alternatively defer the save
	; until you switch to the kernel mapping
	;
map_save_kernel:
	push af
    ld a, (mapreg)
	ld (mapsave), a
    call map_kernel
	pop af
	ret
	;
	; Restore the saved bank. Note that you don't need to deal with
	; stacking of banks (we never recursively use save/restore), and
	; that we may well call save and decide not to call restore.
	;
map_restore:
	push af
	ld a, (mapsave)
	ld (mapreg), a
    call map_proc_a
	pop af
	ret

;
; SD-card low level code
;
_sd_set_sector_regs:
    push af
    ld a, IO_SEL_SD
    out (IO_SEL_REG), a
    ld a, (_sd_sector0)
    out (SD_SEC_0), a
    ld a, (_sd_sector1)
    out (SD_SEC_1), a
    ld a, (_sd_sector2)
    out (SD_SEC_2), a
    ld a, (_sd_sector3)
    out (SD_SEC_3), a

    pop af
    ret

sd_map:
    ld a, (_td_raw)
    or a
    jp z, map_buffers
    dec a
    jp z, map_proc_always
    ld a, (_td_page)
    jp map_for_swap

_sd_read_block:
    push af
    push bc
    push de
    push hl

    call sd_map

    call sd_init

    ld a, 1
    out (SD_RD_STR), a   ; Perform read

    call sd_init

    ; Copy data to correct address
    ld hl, (_sd_ptr)
    ld b, 0
    ld c, SD_DATA

    inir
    inir

    call map_kernel
 
    pop hl
    pop de
    pop bc
    pop af
    ret

_sd_write_block:
    push af
    push bc
    push de
    push hl

    call sd_map

    call sd_init

    ; Copy data from buffer to FPGA SD-buffer
    ld hl, (_sd_ptr)
    ld b, 0
    ld c, SD_DATA

    otir
    otir
   
    ; Perform write
    ld a, 1
    out (SD_WR_STR), a

    call sd_wait

    call map_kernel
    
    pop hl
    pop de
    pop bc
    pop af
 
    ret

sd_init:
    ld a, IO_SEL_SD
    out (IO_SEL_REG), a
    ; Fall through
sd_wait:
    in a, (SD_BUSY)
    cp 0
    jr nz, sd_wait
    ret

_sd_sector0: .byte 0
_sd_sector1: .byte 0
_sd_sector2: .byte 0
_sd_sector3: .byte 0
_sd_ptr: .ds 2
_disk_map: .byte 0
	;
	; Used for low level debug. Output the character in A without
	; corrupting other registers. May block. Interrupts and memory
	; state are undefined
	;
outchar:
	push af
twait:	
    in a,(TTY_BUSY)
	or a
	jr nz, twait
	pop af
	out (TTY_OUT),a
	ret



;
;	Stub helpers for code compactness: TODO

	.discard
;
;	The first two use an rst as a jump. In the reload sp case we don't
;	have to care. In the pop ix case for the function end we need to
;	drop the spare frame first, but we know that af contents don't
;	matter
;

rstblock:
