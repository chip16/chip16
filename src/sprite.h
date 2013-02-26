/*
 *  Sprite functions for use with the img16
 *  image converter.
 */

#ifndef SPRITE_H
#define SPRITE_H

#include <stdint.h>

//int extract_chip16_buf(uint8_t *, uint8_t *, uint32_t, uint32_t, uint32_t *, int, int);

int palettize(uint8_t *, uint8_t *, uint32_t, uint32_t, uint32_t *, int, int, int);

int match_rgb(uint32_t, uint32_t *);

void dump_image(uint8_t *, uint32_t, uint32_t);

#endif
