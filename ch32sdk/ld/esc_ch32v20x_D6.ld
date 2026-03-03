/* ESC - CH32V20x_D6 (CH32V203F8/G8/K8/C8)
 *
 */

INCLUDE ch32v20x_D6.ld

SECTIONS
{
    /*.calibration     0x0000F000 : { KEEP(*(.calibration))     }
    .mcu_uid         0x0000F400 : { KEEP(*(.mcu_uid))         }
    .bootloader_info 0x0000F810 : { KEEP(*(.bootloader_info)) }*/
    .firmware_start          0x00001000 :   { KEEP(*(.firmware_start))        }
    .app_start               0x00001000 :   { KEEP(*(.app_start))             }
    .eeprom                  0x0000F000 :   { KEEP(*(.eeprom))                }
    .flash_rw_offset         0x08000000 :   { KEEP(*(.flash_rw_offset))                }
    .device_type ADDR(.eeprom) - 32 :       { __device_info_start = .;  KEEP(*(.device_type));   }
    .firmware_info ADDR(.device_type) - 32 : { __firmware_info_start = .; KEEP(*(.firmware_info)); }
}

_flash_start_addr    = ORIGIN(FLASH);
_flash_size          = LENGTH(FLASH);
_firmware_start_addr = ADDR(.firmware_start);
_flash_rw_offset     = ADDR(.flash_rw_offset);
_app_start_addr      = ADDR(.app_start);
_eeprom_start_addr   = ADDR(.eeprom);

/* Bootloader must fit entirely before firmware_start (0x1000 = 4KB) */
ASSERT(_etext <= _firmware_start_addr, "ERROR: Bootloader exceeds 4KB - overflows into firmware area (firmware_start = 0x1000)")
