/* ESC sectors
 *
 */

SECTIONS
{
    /*.calibration     0x0000F000 : { KEEP(*(.calibration))     }
    .mcu_uid         0x0000F400 : { KEEP(*(.mcu_uid))         }
    .bootloader_info 0x0000F810 : { KEEP(*(.bootloader_info)) }*/
    .app_start               0x00001000 :   { KEEP(*(.app_start))             }
    .eeprom                  0x0000F000 :   { KEEP(*(.eeprom))                }
    .flash_rw_offset         0x08000000 :   { KEEP(*(.flash_rw_offset))                }
    .device_type             ADDR(.eeprom) - 32 :   { __device_info_start = .;  KEEP(*(.device_type)); }
}

_flash_size          = LENGTH(FLASH);
_flash_rw_offset     = ADDR(.flash_rw_offset);
_app_start_addr      = ADDR(.app_start);
_eeprom_start_addr   = ADDR(.eeprom);

