#include "kernel-8086.def"

/*
 *	8086 real-mode context switch for the ibmpc platform.
 *
 *	Rewritten from the unfinished upstream sketch (which used the
 *	non-existent register %ei, the typo `calloutstring', an invalid
 *	`.bss 256' data section and referenced never-defined symbols).
 *
 *	Contract (CPU independent, see kernel/core/process.c):
 *	    void     plt_switchout(void)   - give up the CPU, never returns
 *	    void     switchin(ptptr p)     - resume process p
 *	    int16_t  dofork(ptptr child)   - returns child pid in the parent,
 *	                                     0 in the child
 *
 *	This follows the FUZIX banked-switch idiom used by the working
 *	rcbus-8085 port: save the callee-saved state + the kernel SP into
 *	udata.u_sp, pick the next task with getproc(), then switchin()
 *	restores that task's SP and register frame and returns into it.
 *
 *	ia16-elf-gcc ABI: ax/bx/cx/dx/es are call-clobbered (the C caller has
 *	already spilled what it needs); si, di, bp are call-saved, so those
 *	plus the flags are the state we must preserve across the switch.
 *
 *	>>> KNOWN INCOMPLETE (needs an 8086 emulator to finish/verify) <<<
 *	Unlike the 8085 - where the udata and the per-task kernel stack live
 *	in the banked window and a single bank select swaps them in - this
 *	board is CONFIG_SPLIT_UDATA with ONE udata and ONE kstack in the
 *	common kernel_ds.  Switching user segments does NOT swap them, so a
 *	multi-resident switch must explicitly save/restore both the 512-byte
 *	udata and the kernel stack per task.  The store for those saved copies
 *	was never designed on the C side (the sketch's phantom `udata_ds'),
 *	and bank8086.c:fork_copy() does not yet compile.  Until that MM work
 *	is done switchin() below only supports resuming the task that already
 *	owns the live udata (the nready==1 fast path that switchout() itself
 *	special-cases); a switch to any other task deliberately traps via
 *	switchfail rather than silently running with the wrong udata/stack.
 *	The hook where restore_udata()/stash_udata() must go is marked below.
 */

	.arch i8086,jumps
	.code16
	.att_syntax prefix

	.text

	.globl switchin
	.globl plt_switchout
	.globl dofork

/*
 *	plt_switchout() - save our context and run someone else.
 */
plt_switchout:
	cli
	pushw	%bp		/* call-saved registers ... */
	pushw	%di
	pushw	%si
	pushf			/* ... and the flags */
	movw	%sp,udata + U_DATA__U_SP

	call	getproc		/* ptptr of next task -> ax */
	pushw	%ax		/* switchin(p) */
	call	switchin
	/* switchin() returns into some *other* task, never back to here */
	jmp	plt_monitor

/*
 *	switchin(ptptr p) - resume process p.
 *	p is on the stack just above our return address.
 */
switchin:
	movw	%sp,%bx
	movw	2(%bx),%bx	/* bx = p */
	cli

	/*
	 * >>> banked multi-task hook <<<
	 * Here the finished port must bring p's saved udata (and its kernel
	 * stack) into the common kernel_ds before the u_ptab check below,
	 * e.g.  pushw %bx ; call restore_udata ; popw %bx  (restore_udata
	 * copying UDATA_SIZE bytes from p's save slot into `udata').  Until
	 * that store exists we can only resume the task that already owns the
	 * live udata.
	 */

	cmpw	udata + U_DATA__U_PTAB,%bx
	jne	switchfail

	movb	$P_RUNNING,P_TAB__P_STATUS_OFFSET(%bx)
	xorw	%ax,%ax
	movw	%ax,runticks
	movw	udata + U_DATA__U_SP,%sp
	popf
	popw	%si
	popw	%di
	popw	%bp
	ret

switchfail:
	call	outaxhex
	movw	$badswitchmsg,%ax
	call	outstring
	jmp	plt_monitor

/*
 *	dofork(ptptr child) - fork the current process.
 *	Returns the child pid in the parent; the child later resumes here
 *	via switchin() and returns 0.
 */
dofork:
	movw	%sp,%bx
	movw	2(%bx),%bx	/* bx = child ptptr */
	movw	%bx,fork_proc_ptr

	cli
	/* Save the same frame switchin() expects to pop, so the child - which
	   gets a copy of this stack - resumes cleanly. */
	pushw	%bp
	pushw	%di
	pushw	%si
	pushf
	movw	%sp,udata + U_DATA__U_SP

	/* Copy the parent image (and, once implemented, the udata) into the
	   child's bank.  fork_copy() lives in mm/bank8086.c. */
	pushw	fork_proc_ptr
	call	fork_copy
	addw	$2,%sp

	/* Build the child's process table entry: makeproc(child, &udata) */
	movw	$udata,%ax
	pushw	%ax
	pushw	fork_proc_ptr
	call	makeproc
	addw	$4,%sp

	xorw	%ax,%ax
	movw	%ax,runticks

	/* Parent path: recover our frame and return the child pid. */
	popf
	popw	%si
	popw	%di
	popw	%bp
	movw	fork_proc_ptr,%bx
	movw	P_TAB__P_PID_OFFSET(%bx),%ax	/* return child pid */
	ret

/*
 *	Minimal debug helpers for the switchfail panic path, via the BIOS
 *	teletype call (int $0x10, ah=0x0E) - the same primitive biosvid.S uses.
 */

/* outaxhex: print AX as four hex digits. */
outaxhex:
	pushw	%ax
	pushw	%bx
	pushw	%cx
	pushw	%dx
	movw	%ax,%dx
	movw	$4,%cx
oah_loop:
	rolw	$1,%dx		/* 8086 has no rotate-by-immediate; by 1 x4 */
	rolw	$1,%dx
	rolw	$1,%dx
	rolw	$1,%dx
	movb	%dl,%al
	andb	$0x0F,%al
	addb	$'0',%al
	cmpb	$'9',%al
	jbe	oah_emit
	addb	$7,%al		/* 'A'..'F' */
oah_emit:
	movb	$0x0E,%ah
	xorw	%bx,%bx
	int	$0x10
	loop	oah_loop
	popw	%dx
	popw	%cx
	popw	%bx
	popw	%ax
	ret

/* outstring: print the NUL-terminated string at AX. */
outstring:
	pushw	%ax
	pushw	%bx
	pushw	%si
	movw	%ax,%si
os_loop:
	movb	(%si),%al
	testb	%al,%al
	jz	os_done
	incw	%si
	movb	$0x0E,%ah
	xorw	%bx,%bx
	int	$0x10
	jmp	os_loop
os_done:
	popw	%si
	popw	%bx
	popw	%ax
	ret

	.data
badswitchmsg:
	.ascii	"switchin: FAIL"
	.byte	13,10,0
fork_proc_ptr:
	.word	0
