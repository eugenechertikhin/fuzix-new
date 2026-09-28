;
;		765 Floppy Controller Support
;
;	This is based upon the Amstrad NC200 driver by David Given and 
;  this example https://cpctech.cpcwiki.de/source/fdcload.html from Kevin Thacker site
;
;	It differs on the CPC in the following ways
;
;	- The timings are tighter so we use in a,(c) jp p and other
;	  tricks to make the clocks. Even so it should be in uncontended RAM
;
;	- The CPC doesn't expose the tc line, so if the 765 decides to
;	  expect more data or feed us more data all we can do is dump it or
;	  feed it crap until it shuts up
;
;	- We do motor and head loading delays (possibly some of those should
;	  be backported - FIXME)
;
;	- We don't hang if the controller tells us no more data when we
;	  think we need to feed it command bytes (BACKPORT NEEDED)
;
;	TODO
;	Initialize drive step rate etc (we rely on the firmware for now)
;	Step rate
;	Head load/unload times
;	Write off time	af
;	(4ms step ~28ms head stabilize, 4ms head load, 16ms head unload)
;
		.module fdc765

		.include "kernel.def"
		.include "kernel-z80.def"

.if CONFIG_FDC765

;	.globl _fd765_do_init
	.globl _fd765_do_nudge_tc
	.globl _fd765_do_recalibrate
	.globl _fd765_do_seek
	.globl _fd765_do_read
	.globl _fd765_do_write
	.globl _fd765_do_read_id
	.globl _fd765_motor_on
	.globl _fd765_motor_off

	.globl _fd765_track
	.globl _fd765_head
	.globl _fd765_sector
	.globl _fd765_status
	.globl _fd765_buffer
	.globl _fd765_map
	.globl _fd765_sectors
	.globl _fd765_drive

	.globl _vtborder
	.globl _int_disabled
	.globl a_map_to_bc


	.globl diskmotor

	.area _CODE

; AMSDOS BIOS parameters for CPC 3" drive (Setted by firmware, but...):
;   SRT = 10: (16 - 10) * 2 ms = 12 ms per step
;   HUT = 1: 1 * 32 ms = 32 ms head unload
;   HLT = 1: 1 * 4 ms = 4 ms head load
;   ND  = 1: non-DMA / PIO mode

;_fd765_do_init:

;SRT	.equ 10
;HUT	.equ 1
;HLT	.equ 1
;ND	.equ 1

;SPECIFY_BYTE_1:	.db (SRT << 4) | HUT
;SPECIFY_BYTE_2:	.db (HLT << 1) | ND

;_fd765_do_init:
;	ld a,#0x03             ; SPECIFY
;	call fd765_tx
;
;	ld a,(SPECIFY_BYTE_1)             ; SRT=12 ms, HUT=16 ms
;	call fd765_tx
;
;	ld a,(SPECIFY_BYTE_2)             ; HLT=2 ms, ND=1
;	call fd765_tx
;Drain 765
;	ld e,#4
;drain_loop:
;	ld a,#0x08             ; SENSE INTERRUPT STATUS
;	call fd765_tx
;	call fd765_read_status ; ST0, PCN
;	dec e
;	jr nz,drain_loop
;	ret	


fd765_tx:
	ld bc,#0xfb7e				;; I/O address for FDC main status register
	push af						;;
fwc1:
	in a,(c)					;; 
	add a,a						;; 
	jr nc,fwc1					;; 
	add a,a						;; 
	jr nc,fwc2					;; 
	pop af						;; 
	ret							
fwc2:
	pop af						;; 
	inc c						;; 
	out (c),a					;; write command byte 
	dec c						;; 

	;; some FDC documents say there must be a delay between each
	;; command byte, but in practice it seems this isn't needed on CPC.
	;; Here for compatiblity.
	ld a,#5	
fwc3:
	dec a
	jr nz,fwc3

	; FIXME: is our delay quite long enough for spec ?
	; might need them to be ex (sp),ix ?
	ret
;
; Twiddle the Terminal Count line to the FDC. Not supported by the
; CPC
;
_fd765_do_nudge_tc:
	ret

; Read the next sector ID off the disk.
; (Only used for debugging.)

_fd765_do_read_id:
	ld a, #0x4a 				; READ MFM ID
	call fd765_tx
	call send_head				; specified head, drive 0

; Reads bytes from the FDC data register until the FDC tells us to stop (by
; lowering DIO in the status register).

fd765_read_status:
	ld hl, #_fd765_status
	ld bc, #0xfb7e

fr1:
	in a,(c)
	cp #0xc0 
	jr c,fr1
	
	inc c 
	ini
	inc b 
	dec c 

	ld a,#5 
fr2: 
	dec a 
	jr nz,fr2
	in a,(c) 
	and #0x10 
	jr nz,fr1

	ret

_fd765_status:
	.ds 8				; 8 bytes of status data

; Sends the head/drive byte of a command.

send_head:
	ld hl, (_fd765_head)		; l = head h = drive)
	ld a, l
	add a
	add a
	add h
	jp fd765_tx

; Performs a RECALIBRATE command.

_fd765_do_recalibrate:
	ld a, #0x07				; RECALIBRATE
	call fd765_tx
	ld a, (_fd765_drive)			; drive #
	call fd765_tx
	jr wait_for_seek_ending

; Performs a SEEK command.

_fd765_do_seek:
	ld a, #0x0f				; SEEK
	call fd765_tx
	call send_head				; specified head, drive #0
	ld a, (_fd765_track)			; specified track
	call fd765_tx
	jr wait_for_seek_ending
_fd765_track:
	.db 0
_fd765_sector:
	.db 0
;
;	These two must remain adjacent see send_head
;
_fd765_head:
	.db 0
_fd765_drive:
	.db 0

; Waits for a SEEK or RECALIBRATE command to finish by polling SENSE INTERRUPT STATUS.
wait_for_seek_ending:

	ld a, #0x08				; SENSE INTERRUPT STATUS
	call fd765_tx
	call fd765_read_status

	ld a, (#_fd765_status)
	bit 5, a				; SE, seek end
	jr z, wait_for_seek_ending

	bit 4,a
	
	; Head settle: ~14 ms (one external loop, AMSDOS BIOS = 15ms)
	ld e,#1
	jr wait2


_fd765_motor_off:
	push bc
	ld bc,#0xfa7e
	xor a
	ld (diskmotor),a
	out (c),a
	pop bc
	ret

_fd765_motor_on:
	ld a,(diskmotor)
	or a
	ret nz
	ld a,#0x01
	ld (diskmotor),a
	; Take effect
	ld bc,#0xfa7e
	out (c),a
	; Now wait for spin up

    ; CPC Z80 clock: 4 MHz.
    ; On CPC, this inner loop takes ~7 us per iteration because
    ; instruction timings are stretched to whole microseconds by the gate array.
    ; 2000 * 7 us * 9 ~= 252 ms.
    ld e,#18

wait2:
    ld bc,#2000
wait1:
	dec bc
	ld a,b
	or c
	jr nz, wait1
	dec e
	jr nz, wait2
	ret

;
;	We will get an error reported that the command did not complete
;	because the tc bit is not controllable. Spot that specific error
;	and ignore it.
;
tc_fix:
	ld hl,#_fd765_status
	ld a,(hl)
	and #0xC0
	cp #0x40
	ret nz
	inc hl
	bit 7,(hl)
	ret z
	res 7,(hl)
	dec hl
	res 6,(hl)
	ret

; Given an FDC opcode in A, sets up a read or write.

setup_read_or_write:
	push af
	call fd765_tx			; 0: send opcode (in A)
	call send_head			; 1: specified head, drive #0
	ld a, (_fd765_track)	; 2: specified track
	call fd765_tx
	ld a, (_fd765_head)		; 3: specified head
	call fd765_tx
	ld a, (_fd765_sector)	; 4: specified sector
	ld d, a
	call fd765_tx
	ld a, #2				; 5: bytes per sector: 512
	call fd765_tx
	ld a, (_fd765_sectors)		
	add d					; add first sector
	dec a					; 6: last sector (*inclusive*)
	call fd765_tx
	ld a, (_fd765_gap)   	; 7: Gap 3 length (2A is standard for 3" drives)
	call fd765_tx
	; We return with the final unused 0 value not written. We need all
	; the other stuff lined up before we write this.
	ld hl, (_fd765_buffer)
	pop af
	push af
	ld bc,#0x7f10
	out (c),c
	out (c),a				;use command # as color: read-0x46-cyan, write-0x45-purple
	ld bc, #0xfb7e
	ld a, (_fd765_map)
	or a
	jr z, cont_trans_nomap
	exx
	call a_map_to_bc
	exx
cont_trans_nomap:
	di				; performance critical, interrupting 765 transfer sequences is not a good idea
					; run with interrupts off
	ex	af,af'
	xor a
	call fd765_tx	; send the final unused byte
					; to fire off the command
	pop af
	ex	af,af'
	ret

_fd765_buffer:
	.dw 0
_fd765_map:
	.db 0
_fd765_sectors:
	.db 0
_fd765_gap:
	.db 0x2A

fdc_transfer_end:
	ld (_fd765_buffer), hl		
	ld a,(_int_disabled)
	jr nz, cont_no_int
	ei							
cont_no_int:
	call fd765_read_status
	call tc_fix

	ld bc,#0x7f10
	out (c),c
	ld a,(_vtborder)
	out (c),a
	ret

.area _COMMONMEM
;
; Reads a 512-byte sector, after having previously saught to the right track.
;
; We need to be doubly careful here as the 765A has a 'feature' whereby it
; won't report an overrun on the last byte so we must always make timing
;
_fd765_do_read:
	ld a, #0x46			; READ SECTOR MFM
	ld e, #1
	jr fd765_do_trans


_fd765_do_write:
	ld a, #0x45			; WRITE SECTOR MFM
	ld e, #0	

	; FIXME: need to return a last cmd byte here and write it
	; after this crap or we may miss if we write just the sector hits
	; the head (BACKPORT ME ??)

fd765_do_trans:
	call setup_read_or_write
	or a
	jr z, fdc_data_trans
	exx
	out (c),c
	exx
fdc_data_trans:	
	ld a, e
	or a
	jr z,fdc_data_write

fdc_data_read:
	in a,(c)				;; FDC has data and the direction is from FDC to CPU
	jp p,fdc_data_read
	and #0x20				;; "Execution phase" i.e. indicates reading of sector data
	jr z,fdc_trans_end 	
	inc c					;; BC = I/O address for FDC data register
	ini						;; read from FDC data register
	inc b
	dec c					;; BC = I/O address for FDC main status register
	jr fdc_data_read

fdc_data_write:
	in a,(c)				;; FDC has data and the direction is from FDC to CPU
	jp p,fdc_data_write
	and #0x20				;; "Execution phase" i.e. indicates reading of sector data
	jr z,fdc_trans_end 	
	inc b
	inc c					;; BC = I/O address for FDC data register
	outi					;; write to FDC data register
	dec c					;; BC = I/O address for FDC main status register
	jr fdc_data_write

fdc_trans_end:
	ld bc,#0x7fc2
	out (c),c
	jp fdc_transfer_end

diskmotor:
	.db 0
.endif