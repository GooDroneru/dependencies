#ifndef ESC_VERSION_H
#define ESC_VERSION_H

#pragma pack (push, 1)
typedef struct version_s {
    uint8_t major;
    uint8_t minor;
} version_t;

typedef struct hardwareVersion_s {
    char deviceId[16];
} hardwareVersion_t;
#pragma pack (pop)

#endif /* ESC_VERSION_H */
