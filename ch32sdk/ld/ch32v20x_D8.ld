/* CH32V20x_D8 - CH32V203RB
 * Flash: 128K, RAM: 64K (default config)
 * Other supported configs:
 *   FLASH-144K + RAM-48K
 *   FLASH-160K + RAM-32K
 */

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 128K
    RAM   (xrw) : ORIGIN = 0x20000000, LENGTH = 64K
}

INCLUDE ch32v20x.ld
