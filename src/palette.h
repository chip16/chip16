/*
 *  Palette loading and manipulation.
 *
 */

#ifndef PALETTE_H
#define PALETTE_H

#include <stdint.h>

#define PALETTE_ENTRIES 16

/* Palette file types. */
typedef enum _pal_t
{
    PAL_DEFAULT,
    PAL_TEXT,
    PAL_BINARY
} pal_t;

int load_palette(const char *, uint32_t *, int);

#endif

