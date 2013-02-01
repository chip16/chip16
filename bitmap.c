/*
 * Bitmap (DIB) implementations
 *
 */

#include "bitmap.h"
#include <stdio.h>

/* Returns 1 if the header is handled by this program, 0 otherwise. */
int supported_header (bmp_file_hdr *fh, bmp_info_hdr *ih)
{
    if(fh->magic[0] != 'B' || fh->magic[1] != 'M')
    {
        printf("BAD MAGIC\n");
        return 0;
    }
    if(ih->bpp != 24)
    {
        printf("BAD BPP (%u)\n", ih->bpp);
        return 0;
    }

    return 1;
}

/* Returns 1 if a chip16 image representation could be extracted,
 * 0 otherwise. */
int extract_chip16_buf(uint8_t *bmp, uint8_t *c16, uint32_t width, uint32_t height,
                       uint32_t *pal, int pal_type, int key)
{
    int pad = (width*3) % 4 == 0 ? 0 : 4 - (width*3)%4;
    int rowsize = width*3 + pad;
    int x, y;
    for(y=0; y<height; ++y)
    {
        for(x=0; x<width; ++x)
        {
            int lo = rowsize*y + (x++)*3;
            uint32_t rgb_lo = (bmp[lo] | (bmp[lo+1] << 8) | (bmp[lo+2] << 16));
            uint8_t c16_lo = match_rgb(rgb_lo,pal);
            int hi = rowsize*y + x*3;
            uint32_t rgb_hi = (bmp[hi] | (bmp[hi+1] << 8) | (bmp[hi+2] << 16));
            uint8_t c16_hi = match_rgb(rgb_hi,pal);
            uint8_t out = ((c16_lo == key ? 0 : c16_lo) << 4) |
                           (c16_hi == key ? 0 : c16_hi);
            c16[((height-y-1)*width + x)/2] = out;
        }
    }
    return 1;
}

/* Match a 24-bit RGB pixel to its nearest chip16 palette index. */
int match_rgb(uint32_t rgb, uint32_t *pal)
{
    uint32_t nearest = 1, i;
    for(i=1; i<16; ++i)
    {
        if((pal[i]-rgb)*(pal[i]-rgb) < (pal[nearest]-rgb)*(pal[nearest]-rgb))
            nearest = i;
    }
    return nearest;
}

/* Prints relevant parts of the headers for debugging. */
void dump_header(bmp_file_hdr *fh, bmp_info_hdr *ih)
{
    if(fh == NULL || ih == NULL)
        return;
    printf("File header:\nmagic: 0x%x%x (`%c%c')\nfilesize: %u\noffset: %u\n\n",
            fh->magic[0], fh->magic[1], fh->magic[0], fh->magic[1], fh->file_size,
            fh->offset);
    printf("Info header:\nih_size: %u\nw: %u\nh: %u\nbpp: %hu\nimg_size: %u\n",
            ih->ih_size, ih->width, ih->height, ih->bpp, ih->img_size);
}

/* Prints the chip16 indexed representation of the image for debugging. */
void dump_image(uint8_t *buffer, uint32_t w, uint32_t h)
{
    int x, y;
    for(y=0; y<h; ++y)
    {
        for(x=0; x<w/2; ++x)
            printf("%02x ", buffer[(y*w)/2+x]);
        printf("\n");
    }
}
