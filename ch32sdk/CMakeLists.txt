set(PROJECT_NAME ch32sdk)
add_library(${PROJECT_NAME} INTERFACE )

target_link_options(${PROJECT_NAME} INTERFACE 
    -L ${CMAKE_CURRENT_LIST_DIR}/ld
)

target_include_directories(${PROJECT_NAME}
    INTERFACE
        ${CMAKE_CURRENT_SOURCE_DIR}
        "${CMAKE_CURRENT_SOURCE_DIR}/core"
        "${CMAKE_CURRENT_SOURCE_DIR}/debug"
        "${CMAKE_CURRENT_SOURCE_DIR}/ld"
        "${CMAKE_CURRENT_SOURCE_DIR}/peripheral"
        "${CMAKE_CURRENT_SOURCE_DIR}/peripheral/inc"
        "${CMAKE_CURRENT_SOURCE_DIR}/startup"
)

if(NOT DEFINED CH32_DEVICE)
    message(FATAL_ERROR "CH32_DEVICE must be set to D6, D8, or D8W")
endif()

target_sources(${PROJECT_NAME}
    INTERFACE
        startup/startup_ch32v20x_${CH32_DEVICE}.S
)

target_sources(${PROJECT_NAME}
    INTERFACE
        core/core_riscv.c
        core/core_riscv.h
        core/system_ch32v20x.c
        core/system_ch32v20x.h
        debug/debug.c
        debug/debug.h
        peripheral/inc/ch32v20x.h
        peripheral/inc/ch32v20x_adc.h
        peripheral/inc/ch32v20x_bkp.h
        peripheral/inc/ch32v20x_can.h
        peripheral/inc/ch32v20x_crc.h
        peripheral/inc/ch32v20x_dbgmcu.h
        peripheral/inc/ch32v20x_dma.h
        peripheral/inc/ch32v20x_exti.h
        peripheral/inc/ch32v20x_flash.h
        peripheral/inc/ch32v20x_gpio.h
        peripheral/inc/ch32v20x_i2c.h
        peripheral/inc/ch32v20x_iwdg.h
        peripheral/inc/ch32v20x_misc.h
        peripheral/inc/ch32v20x_opa.h
        peripheral/inc/ch32v20x_pwr.h
        peripheral/inc/ch32v20x_rcc.h
        peripheral/inc/ch32v20x_rtc.h
        peripheral/inc/ch32v20x_spi.h
        peripheral/inc/ch32v20x_tim.h
        peripheral/inc/ch32v20x_usart.h
        peripheral/inc/ch32v20x_wwdg.h
        peripheral/src/ch32v20x_adc.c
        peripheral/src/ch32v20x_bkp.c
        peripheral/src/ch32v20x_can.c
        peripheral/src/ch32v20x_crc.c
        peripheral/src/ch32v20x_dbgmcu.c
        peripheral/src/ch32v20x_dma.c
        peripheral/src/ch32v20x_exti.c
        peripheral/src/ch32v20x_flash.c
        peripheral/src/ch32v20x_gpio.c
        peripheral/src/ch32v20x_i2c.c
        peripheral/src/ch32v20x_iwdg.c
        peripheral/src/ch32v20x_misc.c
        peripheral/src/ch32v20x_opa.c
        peripheral/src/ch32v20x_pwr.c
        peripheral/src/ch32v20x_rcc.c
        peripheral/src/ch32v20x_rtc.c
        peripheral/src/ch32v20x_spi.c
        peripheral/src/ch32v20x_tim.c
        peripheral/src/ch32v20x_usart.c
        peripheral/src/ch32v20x_wwdg.c
)