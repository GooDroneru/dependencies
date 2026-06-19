/* ESC - K1921VK035 (Cortex-M4F, 64K Flash, 16K RAM)
 *
 * Adds ESC-specific sections on top of the base K1921VK035.ld:
 *   .firmware_start    0x00001000  — marks start of application firmware area
 *   .eeprom            0x0000F000  — ESC EEPROM emulation
 *   .device_type       ADDR(.eeprom) - 32
 *   .calibration_value 0x0000F800  — calibration data
 *   .mcu_uid           0x0000FC00  — MCU unique ID
 *
 * Exported symbols (used by bootloader firmware):
 *   _flash_start_addr        = ORIGIN(MFLASH)             = 0x00000000
 *   _flash_size              = LENGTH(MFLASH)             = 0x00010000 (64K)
 *   _firmware_start_addr     = ADDR(.firmware_start)      = 0x00001000
 *   _eeprom_start_addr       = ADDR(.eeprom)              = 0x0000F000
 *   _calibration_value_addr  = ADDR(.calibration_value)   = 0x0000F800
 *   _mcu_uid_addr            = ADDR(.mcu_uid)             = 0x0000FC00
 */

INCLUDE K1921VK035.ld

SECTIONS
{
    .firmware_start                 0x00001000 : { KEEP(*(.firmware_start))     }
    .eeprom                         0x0000F000 : { KEEP(*(.eeprom))             }
    .device_type ADDR(.eeprom) - 32            : { __device_info_start = .; KEEP(*(.device_type))        }
    .flash_rw_offset                0x00000000 : { KEEP(*(.flash_rw_offset))    }
    .calibration_value              0x0000F800 : { KEEP(*(.calibration_value))  }
    .mcu_uid                        0x0000FC00 : { KEEP(*(.mcu_uid))            }
}

_flash_start_addr    = ORIGIN(MFLASH);
_flash_size          = LENGTH(MFLASH);
_firmware_start_addr = ADDR(.firmware_start);
_eeprom_start_addr   = ADDR(.eeprom);
_flash_rw_offset     = ADDR(.flash_rw_offset);
_calibration_value_addr = ADDR(.calibration_value);
_mcu_uid_addr = ADDR(.mcu_uid);

/* Bootloader must fit entirely before firmware_start (0x1000 = 4KB) */
ASSERT(__exidx_end <= _firmware_start_addr, "ERROR: Bootloader exceeds 4KB - overflows into firmware area (firmware_start = 0x1000)")
