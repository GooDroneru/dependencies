/* ESC firmware application — CH32V203x_D6 (RISC-V, 64K Flash, 20K RAM)
 *
 * Firmware runs after the bootloader. FLASH starts at 0x08001000 (4 KB
 * bootloader reserved at 0x08000000–0x08000FFF).
 *
 * ESC-specific fixed sections (same addresses as esc_ch32v20x_D6.ld):
 *   .eeprom            0x0800F000  — ESC EEPROM emulation
 *   .device_type       ADDR(.eeprom) - 32
 *   .firmware_info     ADDR(.device_type) - 32
 *
 * Exported symbols:
 *   _flash_start_addr   = ORIGIN(FLASH)   = 0x08001000
 *   _flash_size         = LENGTH(FLASH)   = 0x0000F000 (60K)
 *   _eeprom_start_addr  = ADDR(.eeprom)   = 0x0800F000
 *   _firmware_start_addr = ADDR(.firmware_start) = 0x08001000
 */
MEMORY
{
    FLASH (rx)  : ORIGIN = 0x00001000, LENGTH = 60K
    RAM   (xrw) : ORIGIN = 0x20000000, LENGTH = 20K
}

ENTRY( _start )

__stack_size = DEFINED(__stack_size) ? __stack_size : 2048;
PROVIDE( _stack_size = __stack_size );

SECTIONS
{
    .init :
    {
        _sinit = .;
        . = ALIGN(4);
        KEEP(*(SORT_NONE(.init)))
        . = ALIGN(4);
        _einit = .;
    } >FLASH AT>FLASH

    .vector :
    {
        *(.vector);
        . = ALIGN(64);
    } >FLASH AT>FLASH

    .text :
    {
        . = ALIGN(4);
        *(.text)
        *(.text.*)
        *(.rodata)
        *(.rodata*)
        *(.gnu.linkonce.t.*)
        . = ALIGN(4);
    } >FLASH AT>FLASH

    .fini :
    {
        KEEP(*(SORT_NONE(.fini)))
        . = ALIGN(4);
    } >FLASH AT>FLASH

    PROVIDE( _etext = . );
    PROVIDE( _eitcm = . );

    .preinit_array :
    {
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP (*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);
    } >FLASH AT>FLASH

    .init_array :
    {
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
        KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
        PROVIDE_HIDDEN (__init_array_end = .);
    } >FLASH AT>FLASH

    .fini_array :
    {
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
        KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
        PROVIDE_HIDDEN (__fini_array_end = .);
    } >FLASH AT>FLASH

    .ctors :
    {
        KEEP (*crtbegin.o(.ctors))
        KEEP (*crtbegin?.o(.ctors))
        KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
        KEEP (*(SORT(.ctors.*)))
        KEEP (*(.ctors))
    } >FLASH AT>FLASH

    .dtors :
    {
        KEEP (*crtbegin.o(.dtors))
        KEEP (*crtbegin?.o(.dtors))
        KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
        KEEP (*(SORT(.dtors.*)))
        KEEP (*(.dtors))
    } >FLASH AT>FLASH

    .dalign :
    {
        . = ALIGN(4);
        PROVIDE(_data_vma = .);
    } >RAM AT>FLASH

    .dlalign :
    {
        . = ALIGN(4);
        PROVIDE(_data_lma = .);
    } >FLASH AT>FLASH

    .data :
    {
        *(.gnu.linkonce.r.*)
        *(.data .data.*)
        *(.gnu.linkonce.d.*)
        . = ALIGN(8);
        PROVIDE( __global_pointer$ = . + 0x800 );
        *(.sdata .sdata.*)
        *(.sdata2.*)
        *(.gnu.linkonce.s.*)
        . = ALIGN(8);
        *(.srodata.cst16)
        *(.srodata.cst8)
        *(.srodata.cst4)
        *(.srodata.cst2)
        *(.srodata .srodata.*)
        . = ALIGN(4);
        PROVIDE( _edata = .);
    } >RAM AT>FLASH

    .bss :
    {
        . = ALIGN(4);
        PROVIDE( _sbss = .);
        *(.sbss*)
        *(.gnu.linkonce.sb.*)
        *(.bss*)
        *(.gnu.linkonce.b.*)
        *(COMMON*)
        . = ALIGN(4);
        PROVIDE( _ebss = .);
    } >RAM AT>FLASH

    PROVIDE( _end = _ebss);
    PROVIDE( end = . );

    PROVIDE( _heap_end  = _ebss );
    PROVIDE( _susrstack = ORIGIN(RAM) + LENGTH(RAM) - __stack_size );
    PROVIDE( _eusrstack = ORIGIN(RAM) + LENGTH(RAM) );
    ASSERT( _susrstack >= _ebss, "RAM overflow: .data + .bss + stack exceeds RAM!" )

    /* ESC fixed-address sections */
    .firmware_start          0x08001000 :               { KEEP(*(.firmware_start))  }
    .eeprom                  0x0000F000 :               { KEEP(*(.eeprom))           }
    .device_type  ADDR(.eeprom) - 32   :               { __device_info_start = .;   KEEP(*(.device_type));   }
    .firmware_info ADDR(.device_type) - 32 :           { __firmware_info_start = .; KEEP(*(.firmware_info)); }
}

_flash_start_addr    = ORIGIN(FLASH);
_flash_size          = LENGTH(FLASH);
_firmware_start_addr = ADDR(.firmware_start);
_eeprom_start_addr   = ADDR(.eeprom);

ASSERT(_etext <= _firmware_start_addr, "ERROR: Code exceeds firmware start boundary (0x08001000)")
