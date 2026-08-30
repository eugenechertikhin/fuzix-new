/*
 * No STARTUP(crt0.o): the CMake build passes every object explicitly on the ld
 * command line with crt0.o FIRST (see platform-rcbus-80c188.cmake), so crt0's
 * .text is already at the start of .text.  STARTUP() would instead look for a
 * file literally named crt0.o on the search path (absent here -> "cannot find
 * crt0.o") and, if found, link crt0 twice.
 */
OUTPUT_ARCH(i8086)


SEARCH_DIR(.)

MEMORY
{
  ram (rwx) : ORIGIN = 0x0200, LENGTH = 0xED00
}

/*
 * stick everything in ram (of course)
 */
SECTIONS
{
  .data :
  {
    *(.got.plt) *(.got)
    *(.shdata)
    *(.data .data.*)
    _edata = .;
  } > ram
  .text :
  {
    CREATE_OBJECT_SYMBOLS
    *(.text .text.*)

    . = ALIGN(0x4);
    /* These are for running static constructors and destructors under ELF.  */

    *(.rodata .rodata.*)

    . = ALIGN(0x4);
    *(.gcc_except_table)

    . = ALIGN(0x4);
    *(.eh_frame)

    . = ALIGN(0x4);
    _etext = .;
    *(.lit)
  } > ram


  .bss :
  {
    . = ALIGN(0x4);
    __bss_start = . ;
    *(.shbss)
    *(.bss .bss.*)
    *(COMMON)
    _end =  ALIGN (0x8);
    __end = _end;
  } > ram

  .stab 0 (NOLOAD) :
  {
    *(.stab)
  }

  .stabstr 0 (NOLOAD) :
  {
    *(.stabstr)
  }
}
