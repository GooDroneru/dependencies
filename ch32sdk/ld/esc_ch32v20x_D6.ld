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
    .eeprom                  0x0000F000 :   { KEEP(*(.eeprom))                }
    .device_type ADDR(.eeprom) - 32 :       { KEEP(*(.device_type))           }
}

_firmware_start_addr = ADDR(.firmware_start);
_eeprom_start_addr   = ADDR(.eeprom);
