set(VK035SDK_DIR ${CMAKE_CURRENT_LIST_DIR})

add_library(vk035sdk INTERFACE)

# Expose linker script directory so projects can reference K1921VK035.ld by name
target_link_options(vk035sdk INTERFACE
    -L ${VK035SDK_DIR}/Device/NIIET/K1921VK035/Source/GCC
)

target_include_directories(vk035sdk
    INTERFACE
        ${VK035SDK_DIR}/CMSIS/Core/Include
        ${VK035SDK_DIR}/Device/NIIET/K1921VK035/Include
        ${VK035SDK_DIR}/plib/inc
)

target_sources(vk035sdk
    INTERFACE
        # Device startup & system init
        ${VK035SDK_DIR}/Device/NIIET/K1921VK035/Source/system_K1921VK035.c
        ${VK035SDK_DIR}/Device/NIIET/K1921VK035/Source/GCC/startup_K1921VK035.S

        # Peripheral library sources
        ${VK035SDK_DIR}/plib/src/plib035_adc.c
        ${VK035SDK_DIR}/plib/src/plib035_can.c
        ${VK035SDK_DIR}/plib/src/plib035_dma.c
        ${VK035SDK_DIR}/plib/src/plib035_ecap.c
        ${VK035SDK_DIR}/plib/src/plib035_gpio.c
        ${VK035SDK_DIR}/plib/src/plib035_i2c.c
        ${VK035SDK_DIR}/plib/src/plib035_mflash.c
        ${VK035SDK_DIR}/plib/src/plib035_pmu.c
        ${VK035SDK_DIR}/plib/src/plib035_pwm.c
        ${VK035SDK_DIR}/plib/src/plib035_qep.c
        ${VK035SDK_DIR}/plib/src/plib035_rcu.c
        ${VK035SDK_DIR}/plib/src/plib035_spi.c
        ${VK035SDK_DIR}/plib/src/plib035_tmr.c
        ${VK035SDK_DIR}/plib/src/plib035_uart.c
        ${VK035SDK_DIR}/plib/src/plib035_wdt.c

        # Peripheral library headers (for IDE source navigation)
        ${VK035SDK_DIR}/plib/inc/plib035.h
        ${VK035SDK_DIR}/plib/inc/plib035_adc.h
        ${VK035SDK_DIR}/plib/inc/plib035_assert.h
        ${VK035SDK_DIR}/plib/inc/plib035_can.h
        ${VK035SDK_DIR}/plib/inc/plib035_conf.h
        ${VK035SDK_DIR}/plib/inc/plib035_dma.h
        ${VK035SDK_DIR}/plib/inc/plib035_ecap.h
        ${VK035SDK_DIR}/plib/inc/plib035_gpio.h
        ${VK035SDK_DIR}/plib/inc/plib035_i2c.h
        ${VK035SDK_DIR}/plib/inc/plib035_mflash.h
        ${VK035SDK_DIR}/plib/inc/plib035_pmu.h
        ${VK035SDK_DIR}/plib/inc/plib035_pwm.h
        ${VK035SDK_DIR}/plib/inc/plib035_qep.h
        ${VK035SDK_DIR}/plib/inc/plib035_rcu.h
        ${VK035SDK_DIR}/plib/inc/plib035_spi.h
        ${VK035SDK_DIR}/plib/inc/plib035_tmr.h
        ${VK035SDK_DIR}/plib/inc/plib035_uart.h
        ${VK035SDK_DIR}/plib/inc/plib035_version.h
        ${VK035SDK_DIR}/plib/inc/plib035_wdt.h

        # Device headers
        ${VK035SDK_DIR}/Device/NIIET/K1921VK035/Include/K1921VK035.h
        ${VK035SDK_DIR}/Device/NIIET/K1921VK035/Include/system_K1921VK035.h
)
