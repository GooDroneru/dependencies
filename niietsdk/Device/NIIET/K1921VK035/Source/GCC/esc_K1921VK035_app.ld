/* ESC firmware application — K1921VK035 (Cortex-M4F, 64K Flash, 16K RAM)
 *
 * Firmware runs after the bootloader. MFLASH starts at 0x00001000 (4 KB
 * bootloader reserved at 0x00000000–0x00000FFF).
 *
 * ESC-specific fixed sections (same addresses as esc_K1921VK035.ld):
 *   .eeprom            0x0000F000  — ESC EEPROM emulation
 *   .device_type       ADDR(.eeprom) - 32
 *   .calibration_value 0x0000F800  — calibration data
 *   .mcu_uid           0x0000FC00  — MCU unique ID
 *
 * Exported symbols:
 *   _flash_start_addr        = ORIGIN(MFLASH)                    = 0x00001000
 *   _flash_size              = LENGTH(MFLASH)                    = 0x00010000
 *   _eeprom_start_addr       = ADDR(.eeprom)                     = 0x0000F000
 *   _calibration_value_addr  = ADDR(.calibration_value)          = 0x0000F800
 *   _mcu_uid_addr            = ADDR(.mcu_uid)                    = 0x0000FC00
 */

MEMORY
{
  MFLASH (rx) : ORIGIN = 0x00001000, LENGTH = 64K
  RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 16K
}

REGION_ALIAS("CODE_FLASH", MFLASH);
REGION_ALIAS("DATA_RAM",   RAM);
REGION_ALIAS("HEAP_RAM",   RAM);
REGION_ALIAS("STACK_RAM",  RAM);
REGION_ALIAS("BSS_RAM",    RAM);

ENTRY(Reset_Handler)

SECTIONS
{
    .text :
    {
        KEEP(*(.isr_vector))
        *(.text*)

        KEEP(*(.init))
        KEEP(*(.fini))

        /* .ctors */
        *crtbegin.o(.ctors)
        *crtbegin?.o(.ctors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
        *(SORT(.ctors.*))
        *(.ctors)

        /* .dtors */
        *crtbegin.o(.dtors)
        *crtbegin?.o(.dtors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
        *(SORT(.dtors.*))
        *(.dtors)

        *(.rodata*)

        KEEP(*(.eh_frame*))
    } > CODE_FLASH

    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } > CODE_FLASH

    __exidx_start = .;
    .ARM.exidx :
    {
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > CODE_FLASH
    __exidx_end = .;

    .copy.table :
    {
        . = ALIGN(4);
        __textdata_start__ = LOADADDR(.data);
        __copy_table_start__ = .;
        LONG (__textdata_start__)
        LONG (__data_start__)
        LONG (__data_end__ - __data_start__)
        __copy_table_end__ = .;
    } > CODE_FLASH

    .zero.table :
    {
        . = ALIGN(4);
        __zero_table_start__ = .;
        LONG (__bss_start__)
        LONG (__bss_end__ - __bss_start__)
        __zero_table_end__ = .;
    } > CODE_FLASH

    .data :
    {
        __data_start__ = .;
        *(vtable)
        *(.data*)
        *(.ramfunc*)

        . = ALIGN(4);
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP(*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);

        . = ALIGN(4);
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE_HIDDEN (__init_array_end = .);

        . = ALIGN(4);
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE_HIDDEN (__fini_array_end = .);

        KEEP(*(.jcr*))
        . = ALIGN(4);
        __data_end__ = .;
    } > DATA_RAM AT > CODE_FLASH

    .bss :
    {
        . = ALIGN(4);
        __bss_start__ = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
    } > BSS_RAM

    .heap (COPY):
    {
        __end__ = .;
        PROVIDE(end = .);
        *(.heap*)
        __HeapLimit = .;
    } > HEAP_RAM

    .stack_dummy (COPY):
    {
        *(.stack*)
    } > STACK_RAM

    __StackTop   = ORIGIN(STACK_RAM) + LENGTH(STACK_RAM);
    __StackLimit = __StackTop - SIZEOF(.stack_dummy);
    PROVIDE(__stack = __StackTop);

    ASSERT(__StackLimit >= __HeapLimit, "region STACK_RAM overflowed with stack")

    /* ESC fixed-address sections */
    .eeprom                         0x0000F000 : { KEEP(*(.eeprom))            }
    .device_type ADDR(.eeprom) - 32            : { KEEP(*(.device_type))       }
    .calibration_value              0x0000F800 : { KEEP(*(.calibration_value)) }
    .mcu_uid                        0x0000FC00 : { KEEP(*(.mcu_uid))           }
}

_flash_start_addr       = ORIGIN(MFLASH);
_flash_size             = LENGTH(MFLASH);
_eeprom_start_addr      = ADDR(.eeprom);
_calibration_value_addr = ADDR(.calibration_value);
_mcu_uid_addr           = ADDR(.mcu_uid);
