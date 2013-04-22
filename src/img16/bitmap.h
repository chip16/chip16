/*
 *  Bitmap (DIB) definitions and declarations, for use with the img16
 *  image converter.
 */

#ifndef BITMAP_H
#define BITMAP_H

#include <stdint.h>

#pragma pack(push,1)

/* Bitmap file header. */
typedef struct _bmp_file_hdr
{
    unsigned char magic[2];
    uint32_t file_size;
    uint32_t reserved;
    uint32_t offset;

} bmp_file_hdr;

/* Bitmap info header. */
typedef struct _bmp_info_hdr
{
    uint32_t ih_size;
    int32_t width;
    int32_t height;
    uint16_t col_planes;
    uint16_t bpp;
    uint32_t compression;
    uint32_t img_size;
    uint32_t hres;
    uint32_t vres;
    uint32_t cols;
    uint32_t imp_cols;

} bmp_info_hdr;

#pragma pack(pop)

/* Bitmap compression methods. */
typedef enum
{
    BI_RGB = 0,
    BI_RLE8,
    BI_RLE4,
    BI_BITFIELDS, //Also Huffman 1D compression for BITMAPCOREHEADER2
    BI_JPEG,      //Also RLE-24 compression for BITMAPCOREHEADER2
    BI_PNG
} bmp_compression_method_t;

int supported_header(bmp_file_hdr *, bmp_info_hdr *);

void dump_header(bmp_file_hdr *, bmp_info_hdr *);

#endif
