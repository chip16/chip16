#ifdef C_PLUS_PLUS
extern "C" {
#endif

#define CH16_HEADER_SIZE 0x10

#include <stdint.h>

#pragma pack(push,1)
typedef struct ch16_header
{
    uint32_t magic;
    uint8_t  reserved;
    uint8_t  spec_ver;
    uint32_t rom_size;
    uint16_t start_addr;
    uint32_t crc32_sum;

} ch16_header;

typedef struct ch16_rom
{
    ch16_header header;
    uint8_t*    data;

} ch16_rom;
#pragma pack(pop)

#ifdef C_PLUS_PLUS
}
#endif
