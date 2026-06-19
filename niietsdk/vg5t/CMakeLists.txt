set(NIIETSDK_DIR ${CMAKE_CURRENT_LIST_DIR})

add_library(niietsdk INTERFACE)

# Expose linker script directory so projects can reference k1921vg5t_flash.ld by name
target_link_options(niietsdk INTERFACE
    -L ${NIIETSDK_DIR}/Device/K1921VG5T/ldscripts
)

target_include_directories(niietsdk
    INTERFACE
        ${NIIETSDK_DIR}/Device/K1921VG5T/include
        ${NIIETSDK_DIR}/plib5t/inc
)

target_sources(niietsdk
    INTERFACE
        # Device startup & system init
        ${NIIETSDK_DIR}/Device/K1921VG5T/source/startup_k1921vg5t.S
        ${NIIETSDK_DIR}/Device/K1921VG5T/source/system_k1921vg5t.c
        ${NIIETSDK_DIR}/Device/K1921VG5T/source/plic.c
        ${NIIETSDK_DIR}/Device/K1921VG5T/source/mtimer.c
        ${NIIETSDK_DIR}/Device/K1921VG5T/source/riscv-irq.c

        # Peripheral library sources
        ${NIIETSDK_DIR}/plib5t/src/plib5t_adc.c
        ${NIIETSDK_DIR}/plib5t/src/plib5t_can.c
        ${NIIETSDK_DIR}/plib5t/src/plib5t_dma.c
        ${NIIETSDK_DIR}/plib5t/src/plib5t_flash.c
        ${NIIETSDK_DIR}/plib5t/src/plib5t_gpio.c
        ${NIIETSDK_DIR}/plib5t/src/plib5t_i2c.c
        ${NIIETSDK_DIR}/plib5t/src/plib5t_rcu.c
        ${NIIETSDK_DIR}/plib5t/src/plib5t_spi.c
        ${NIIETSDK_DIR}/plib5t/src/plib5t_tmr.c
        ${NIIETSDK_DIR}/plib5t/src/plib5t_uart.c
        ${NIIETSDK_DIR}/plib5t/src/plib5t_wdt.c

        # Peripheral library headers (for IDE source navigation)
        ${NIIETSDK_DIR}/plib5t/inc/plib5t.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_adc.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_assert.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_can.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_cap.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_conf.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_dma.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_flash.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_gpio.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_i2c.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_pwm.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_qep.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_rcu.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_spi.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_tmr.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_uart.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_version.h
        ${NIIETSDK_DIR}/plib5t/inc/plib5t_wdt.h

        # Device headers
        ${NIIETSDK_DIR}/Device/K1921VG5T/include/K1921VG5T.h
        ${NIIETSDK_DIR}/Device/K1921VG5T/include/system_k1921vg5t.h
        ${NIIETSDK_DIR}/Device/K1921VG5T/include/plic.h
        ${NIIETSDK_DIR}/Device/K1921VG5T/include/mtimer.h
        ${NIIETSDK_DIR}/Device/K1921VG5T/include/riscv-irq.h
        ${NIIETSDK_DIR}/Device/K1921VG5T/include/riscv-csr.h
)