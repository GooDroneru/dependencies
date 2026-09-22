/// @file
/// @brief platform init funcs

#include <sys/errno.h>
#include <string.h>
#include <unistd.h>

#include "memasm.h"

extern char _tdata_start[], _tdata_end[], _tbss_start[], _tbss_end[];

extern const uint8_t __data_source_start;
extern uint8_t __data_target_start;
extern uint8_t __data_target_end;

extern const uint8_t __sdata_source_start;
extern uint8_t __sdata_target_start;
extern uint8_t __sdata_target_end;

extern void plf_init_relocate(void) __attribute__((weak));

extern char __bss_start[], __bss_end[];
extern char _ramfunc_start[], _ramfunc_end[];
extern char _tcmcode_start[], _tcmcode_end[];
extern char _tcmconst_start[], _tcmconst_end[];
extern char __etext[];
extern char __tcmcode_pos[];
extern char __tcmconst_pos[];
extern char __tcmvar_pos[];

void __init plf_init_noreloc(void)
{
    // do nothing
}

void CopyToRAM(void* dest, void* src, uint32_t cnt)
{
    uint32_t *sp;
    uint32_t *dp;
    uint32_t i;
    uint32_t size=cnt>>2;
    sp=(uint32_t *)src;
    dp=(uint32_t *)dest;

    for (i=0; i<size; i++)
    {
        *dp=*sp;
        dp++;
        sp++;
    }
}
void __init plf_init_generic(void)
{
    // init BSS
    memset(__bss_start, 0, (size_t)(__bss_end - __bss_start));
    memcpy((void*)&__data_target_start,
           (const void*)&__data_source_start,
           (&__data_target_end - &__data_target_start));

    memcpy((void*)&__sdata_target_start,
              (const void*)&__sdata_source_start,
              (&__sdata_target_end - &__sdata_target_start));
    //memcpy(_ramfunc_start, __etext, (size_t)(_ramfunc_end - _ramfunc_start));
    CopyToRAM(_ramfunc_start, __etext, (size_t)(_ramfunc_end - _ramfunc_start));
    CopyToRAM(_tcmcode_start, __tcmcode_pos, (size_t)(_tcmcode_end - _tcmcode_start));
    CopyToRAM(_tcmconst_start, __tcmconst_pos, (size_t)(_tcmconst_end - _tcmconst_start));
}

void plf_init(void) __attribute__((weak, alias("plf_init_generic")));

