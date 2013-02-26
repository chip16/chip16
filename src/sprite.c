#include "sprite.h"
#include <stdio.h>

/* Returns 1 if a chip16 image representation could be extracted,
 * 0 otherwise. */
/*
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
            uint32_t rgb_lo = ((bmp[lo] << 16) | (bmp[lo+1] << 8) | bmp[lo+2]);
            uint8_t c16_lo = match_rgb(rgb_lo,pal);
            int hi = rowsize*y + x*3;
            uint32_t rgb_hi = ((bmp[hi] << 16) | (bmp[hi+1] << 8) | bmp[hi+2]);
            uint8_t c16_hi = match_rgb(rgb_hi,pal);
            uint8_t out = ((c16_lo == key ? 0 : c16_lo) << 4) |
                           (c16_hi == key ? 0 : c16_hi);
            c16[((height-y-1)*width + x)/2] = out;
        }
    }
    return 1;
}*/

/* Returns 1 if a chip16 image representation could be extracted,
 * 0 otherwise. */
int palettize(uint8_t *bmp, uint8_t *c16, uint32_t width, uint32_t height,
                       uint32_t *pal, int pal_type, int key, int dither)
{
    int pad = (width*3) % 4 == 0 ? 0 : 4 - (width*3)%4;
    int rs = width*3 + pad;
    int x, y;
    for(y=0; y<height; ++y)
    {
        for(x=0; x<width; ++x)
        {
            uint32_t rgb = ((bmp[y*rs + x] << 16) | (bmp[y*rs + x+1] << 8) | bmp[y*rs + x+2]);
            uint8_t i = match_rgb(rgb,pal);
            c16[(height-y-1)*width + x] = i;
            if(dither)
            {
                
            }
        }
    }
    return 1;
}

/* Apply dithering to the 24-bit RGB pixel array. */
int dither_rgb(uint8_t* bmp, uint8_t* c16, uint32_t width, uint32_t height)
{
    int pad = (width*3) % 4 == 0 ? 0 : 4 - (width*3)%4;
    int rs = width*3 + pad;
    int x, y, c;
    for(y=0; y<height-1; ++y)
    {
        for(x=0; x<width; ++x)
        {
            /* Treat each color channel independently. */
            for(c=0; c<3; ++c)
            {
                uint8_t np, p = bmp[rs*y + x*3 + c];
                np = (p > 128) ? 255 : 0;
                int quant_err = p - np;
                
                bmp[rs*y + (x+1)*3 + c] += 7*quant_err/16;
                bmp[rs*(y+1) + (x-1)*3 + c] += 3*quant_err/16;
                bmp[rs*(y+1) + x*3 + c] += 5*quant_err/16;
                bmp[rs*(y+1) + (x+1)*3 + c] += 1*quant_err/16;
            }
        }
    }
    return 1;
}

/* Match a 24-bit RGB pixel to its nearest chip16 palette index. */
int match_rgb(uint32_t rgb, uint32_t *pal)
{
    int r = (rgb >> 16) & 0xff, br = 1000;
    int g = (rgb >> 8) & 0xff, bg = 1000;
    int b = rgb & 0xff, bb = 1000; 

    uint32_t nearest = 1, i;
    for(i=1; i<16; ++i)
    {
        int ir = (pal[i] >> 16) & 0xff;
        int ig = (pal[i] >> 8) & 0xff;
        int ib = pal[i] & 0xff;
        
        if(((ir - r)*(ir - r) + (ig - g)*(ig - g) + (ib - b)*(ib - b)) 
                < ((br - r)*(br - r) + (bg - g)*(bg - g) + (bb - b)*(bb - b)))
        {
            nearest = i;
            br = ir, bg = ig, bb = ib;
        }
    }
    return nearest;
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
