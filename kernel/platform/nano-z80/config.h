/* Enable to make ^Z dump the inode table for debug */
#undef CONFIG_IDUMP
/* Enable to make ^A drop back into the monitor */
#undef CONFIG_MONITOR
/* Profil syscall support (not yet complete) */
#undef CONFIG_PROFIL
/* Multiple processes in memory at once */
/* CONFIG_MULTI: supplied by CMake (-DFUZIX_MULTIPROCESS) */

/* Select a banked memory set up */
/* CONFIG_BANK_FIXED: supplied by CMake (-DFUZIX_MM) */
/* This is the number of banks of user memory available (maximum) */
#define MAX_MAPS	60		/* 64 x 64K pages - 4 for kernel? */
/* How many banks do we have in our address space */
#define CONFIG_BANKS	1	/* 1 x 60K */
#define MAP_SIZE 0xF000

/* Video terminal support */
#define CONFIG_VT
#define CONFIG_VT_MULTI
#define VT_WIDTH    80
#define VT_HEIGHT   30
#define VT_RIGHT    79
#define VT_BOTTOM   29

/* Tinydisk */
#define CONFIG_TD_NUM 2

/*
 *	Define the program loading area (needs to match kernel.def)
 */
#define PROGBASE    0x0000  /* Base of user  */
#define PROGLOAD    0x0100  /* Load and run here */
#define PROGTOP     0xEE00  /* Top of program, base of U_DATA stash */
#define PROC_SIZE   60 	    /* Memory needed per process including stash */

/* Define number of processes */
#define PTABSIZE    32

/* Networking */
#define CONFIG_NET
#define CONFIG_NET_NATIVE

/* No swap */
#undef SWAPDEV

#define BOOTDEVICENAMES "hd#"

/* We will resize the buffers available after boot. This is the normal setting */
#define CONFIG_DYNAMIC_BUFPOOL

/* Larger transfers (including process execution) should go directly not via
   the buffer cache. For all small (eg bit) systems this is the right setting
   as it avoids polluting the small cache with data when it needs to be full
   of directory and inode information */
#define CONFIG_LARGE_IO_DIRECT(x)	1

#define CONFIG_RTC
#define CONFIG_RTC_INTERVAL	100

/*
 * How fast does the clock tick (if present), or how many times a second do
 * we simulate if not. For a machine without video 10 is a good number. If
 * you have video you probably want whatever vertical sync/blank interrupt
 * rate the machine has. For many systems it's whatever the hardware gives
 * you.
 *
 * Note that this needs to be divisible by 10 and at least 10. If your clock
 * is a bit slower you may need to fudge things somewhat so that the kernel
 * gets 10 timer interrupt calls per second. 
 */
#define TICKSPERSEC 100	    /* Ticks per second */

/*
 *	The device (major/minor) for the console and boot up tty attached to
 *	init at start up. 512 is the major 2, so all the tty devices are
 *	512 + n where n is the tty.
 */
#define BOOT_TTY (512 + 1)      

#define CMDLINE	0x81	  /* CP/M commandline */

/* Device parameters */
#define NUM_DEV_TTY 6	  /* How many tty devices does the platform support */
#define TTYDEV   BOOT_TTY /* Device used by kernel for messages, panics */
#define NBUFS    5        /* Number of block buffers. Must be 4+ and must match
                             kernel.def */
#define NMOUNTS	 2	  /* Number of mounts at a time */

#define CONFIG_SMALL

#define plt_copyright()
