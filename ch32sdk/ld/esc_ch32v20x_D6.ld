/* ESC - CH32V20x_D6 (CH32V203F8/G8/K8/C8)
 *
 */

INCLUDE ch32v20x_D6.ld

SECTIONS
{
    /*.calibration     0x0000F000 : { KEEP(*(.calibration))     }
    .mcu_uid         0x0000F400 : { KEEP(*(.mcu_uid))         }
    .bootloader_info 0x0000F810 : { KEEP(*(.bootloader_info)) }*/
    .firmware_start          0x08001000 :   { KEEP(*(.firmware_start))        }
    .eeprom                  0x0800F000 :   { KEEP(*(.eeprom))                }
    .device_type ADDR(.eeprom) - 32 :       { KEEP(*(.device_type))           }
}

_flash_start_addr    = ORIGIN(FLASH);
_flash_size          = LENGTH(FLASH);
_firmware_start_addr = ADDR(.firmware_start);
_eeprom_start_addr   = ADDR(.eeprom);

/* Bootloader must fit entirely before firmware_start (0x1000 = 4KB) */
ASSERT(_etext <= _firmware_start_addr, "ERROR: Bootloader exceeds 4KB - overflows into firmware area (firmware_start = 0x1000)")
