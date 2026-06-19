set(NIIETSDK_DIR ${CMAKE_CURRENT_LIST_DIR})

add_library(niietsdk INTERFACE)

# Expose linker script directory so projects can reference K1921VK035.ld by name
target_link_options(niietsdk INTERFACE
    -L ${NIIETSDK_DIR}/Device/NIIET/K1921VK035/Source/GCC
)

target_include_directories(niietsdk
    INTERFACE
        ${NIIETSDK_DIR}/CMSIS/Core/Include
        ${NIIETSDK_DIR}/Device/NIIET/K1921VK035/Include
        ${NIIETSDK_DIR}/plib/inc
)

target_sources(niietsdk
    INTERFACE
        # Device startup & system init
        ${NIIETSDK_DIR}/Device/NIIET/K1921VK035/Source/system_K1921VK035.c
        ${NIIETSDK_DIR}/Device/NIIET/K1921VK035/Source/GCC/startup_K1921VK035.S

        # Peripheral library sources
        ${NIIETSDK_DIR}/plib/src/plib035_adc.c
        ${NIIETSDK_DIR}/plib/src/plib035_can.c
        ${NIIETSDK_DIR}/plib/src/plib035_dma.c
        ${NIIETSDK_DIR}/plib/src/plib035_ecap.c
        ${NIIETSDK_DIR}/plib/src/plib035_gpio.c
        ${NIIETSDK_DIR}/plib/src/plib035_i2c.c
        ${NIIETSDK_DIR}/plib/src/plib035_mflash.c
        ${NIIETSDK_DIR}/plib/src/plib035_pmu.c
        ${NIIETSDK_DIR}/plib/src/plib035_pwm.c
        ${NIIETSDK_DIR}/plib/src/plib035_qep.c
        ${NIIETSDK_DIR}/plib/src/plib035_rcu.c
        ${NIIETSDK_DIR}/plib/src/plib035_spi.c
        ${NIIETSDK_DIR}/plib/src/plib035_tmr.c
        ${NIIETSDK_DIR}/plib/src/plib035_uart.c
        ${NIIETSDK_DIR}/plib/src/plib035_wdt.c

        # Peripheral library headers (for IDE source navigation)
        ${NIIETSDK_DIR}/plib/inc/plib035.h
        ${NIIETSDK_DIR}/plib/inc/plib035_adc.h
        ${NIIETSDK_DIR}/plib/inc/plib035_assert.h
        ${NIIETSDK_DIR}/plib/inc/plib035_can.h
        ${NIIETSDK_DIR}/plib/inc/plib035_conf.h
        ${NIIETSDK_DIR}/plib/inc/plib035_dma.h
        ${NIIETSDK_DIR}/plib/inc/plib035_ecap.h
        ${NIIETSDK_DIR}/plib/inc/plib035_gpio.h
        ${NIIETSDK_DIR}/plib/inc/plib035_i2c.h
        ${NIIETSDK_DIR}/plib/inc/plib035_mflash.h
        ${NIIETSDK_DIR}/plib/inc/plib035_pmu.h
        ${NIIETSDK_DIR}/plib/inc/plib035_pwm.h
        ${NIIETSDK_DIR}/plib/inc/plib035_qep.h
        ${NIIETSDK_DIR}/plib/inc/plib035_rcu.h
        ${NIIETSDK_DIR}/plib/inc/plib035_spi.h
        ${NIIETSDK_DIR}/plib/inc/plib035_tmr.h
        ${NIIETSDK_DIR}/plib/inc/plib035_uart.h
        ${NIIETSDK_DIR}/plib/inc/plib035_version.h
        ${NIIETSDK_DIR}/plib/inc/plib035_wdt.h

        # Device headers
        ${NIIETSDK_DIR}/Device/NIIET/K1921VK035/Include/K1921VK035.h
        ${NIIETSDK_DIR}/Device/NIIET/K1921VK035/Include/system_K1921VK035.h
)
