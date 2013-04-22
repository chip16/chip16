/*
 *  Sprite functions for use with the img16
 *  image converter.
 */

#ifndef SPRITE_H
#define SPRITE_H

#include <stdint.h>

#pragma pack(push,1)

typedef struct
{
    uint8_t r, g, b;

} rgb_t;

/* Useful for mapping palette entries. */
typedef struct
{
    uint8_t r, g, b, u;

} rgbu_t;

/* Useful for mapping bitmap data. */
typedef struct
{
    uint8_t b, g, r;

} bgr_t;

#pragma pack(pop)

//int extract_chip16_buf(uint8_t *, uint8_t *, uint32_t, uint32_t, uint32_t *, int, int);

int palettize(uint8_t *, uint8_t *, uint32_t, uint32_t, uint32_t *, int, int, int);

int match_rgb(uint32_t, uint32_t *);

void dump_image(uint8_t *, uint32_t, uint32_t);

#endif
