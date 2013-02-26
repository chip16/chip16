/*
 * img16 -- an image converter targetting the chip16.
 * Copyright (C) tykel, 2012
 *
 * Licensed under the GPL, V3.
 */

#include "bitmap.h"
#include "palette.h"
#include "sprite.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const char *phelp = "-h";
static const char *phelpv = "--help";
static const char *pdump = "-d";
static const char *pdumpv = "--dump";
static const char *pout = "-o";
static const char *ppalt = "-pt";
static const char *ppaltv = "--palette-text";
static const char *ppalb = "-pb";
static const char *ppalbv = "--palette-bin";
static const char *pkey = "-k";
static const char *pkeyv = "--key";
static const char *pinfo = "-i";
static const char *pinfov = "--info";
static const char *pdither = "-d";
static const char *pditherv = "--dither";
static const char *pver = "-v";
static const char *pverv = "--version";

/* Default palette. */
static uint32_t palette[PALETTE_ENTRIES] =
{
    0x000000,0x000000,
    0x888888,0x3239BF,
    0xAE7ADE,0x213D4C,
    0x255F90,0x5294E4,
    0x79D9EA,0x3B7A53,
    0x4AD5AB,0x382E25,
    0x7F4600,0xCCAB68,
    0xE4DEBC,0xFFFFFF
};

/* Error codes for the program. */
typedef enum _err_t
{
    ERR_NO_FILE,
    ERR_ARGS,
    ERR_IO,
    ERR_INVALID_KEY,
    ERR_FEW_PAL,
    ERR_INVALID_BMP
} err_t;

int error(err_t);
int help(void);
int version(void);

/* Parses arguments, reads file, performs transformations. */
int main(int argc, char *argv[])
{
    if(argc < 2)
        return error(ERR_NO_FILE);
   
    /* Modifiers. */
    char *fn = argv[1], *out_fn = NULL, *pal_fn = NULL;
    out_fn = malloc(200);
    char *p = out_fn, *q = argv[1];
    while(*q != '\0')
        *p++ = *q++;
    *p++ = '.'; *p++ = 'b'; *p++ = 'i'; *p++ = 'n'; *p = '\0';
    int i, pal_type = PAL_DEFAULT, key = -1, dither = 0;
    int show_help = 0, show_ver = 0, show_info = 0, dump_img = 0;
    
    /* Parse arguments. */
    for (i=2; i<argc; ++i)
    {
        if(!strcmp(argv[i],pout))
        {
            if(i+1<argc)
                out_fn = argv[++i];
            else
                return error(ERR_ARGS);
        }
        else if(!strcmp(argv[i],pdump) || !strcmp(argv[i],pdumpv))
        {
            dump_img = 1;
        }
        else if(!strcmp(argv[i],ppalt) || !strcmp(argv[i],ppaltv))
        {
            if(i+1<argc)
                pal_fn = argv[++i], pal_type = PAL_TEXT;
            else
                return error(ERR_ARGS);
        }
        else if(!strcmp(argv[i],ppalb) || !strcmp(argv[i],ppalbv))
        {
            if(i+1<argc)
                pal_fn = argv[++i], pal_type = PAL_BINARY;
            else
                return error(ERR_ARGS);
        }
        else if(!strcmp(argv[i],pkey) || !strcmp(argv[i],pkeyv))
        {
            if(i+1<argc)
                key = atoi(argv[++i]);
            else
                return error(ERR_ARGS);
        }
        else if(!strcmp(argv[i],pinfo) || !strcmp(argv[i],pinfov))
            show_info = 1;
        else if(!strcmp(argv[i],pdither) || !strcmp(argv[i],pditherv))
            dither = 1;
        else if(!strcmp(argv[i],phelp) || !strcmp(argv[i],phelpv))
            show_help = 1;
        else if(!strcmp(argv[i],pver) || !strcmp(argv[i],pverv))
            show_ver = 1;
        else
            return error(ERR_ARGS);
    }
    
    /* If help flag was passed, display that and return. */
    if(!strcmp(fn,phelp) || !strcmp(fn,phelpv) || show_help)
        return help();

    /* If version flag was passed, display it and return. */
    if(!strcmp(fn,pver) || !strcmp(fn,pverv) || show_ver)
        return version();

    /* Open and read the source file. */
    FILE *file = fopen(fn,"rb");
    if(file == NULL)
        return error(ERR_IO);
    fseek(file,0,SEEK_END);
    int size = ftell(file);
    fseek(file,0,SEEK_SET);
    uint8_t *buffer = malloc(size);
    fread(buffer,sizeof(uint8_t),size,file);
    fclose(file);
    
    /* Map the regions of the bitmap file. */
    bmp_file_hdr *bfh = (bmp_file_hdr *)buffer;
    bmp_info_hdr *bih = (bmp_info_hdr *)(buffer + sizeof(bmp_file_hdr));
    uint8_t *pixels = (uint8_t *)((uint64_t)bfh + (uint64_t)bfh->offset);

    /* Ensure we can handle this BMP type. */
    if(!supported_header(bfh,bih))
    {
        dump_header(bfh, bih);
        return error(ERR_INVALID_BMP);
    }
    /* Dump the header if requested. */
    if(show_info)
        dump_header(bfh, bih);

    /* Use the correct palette. */
    if(pal_type != PAL_DEFAULT)
    {
        if(!load_palette(pal_fn,palette,pal_type))
            return error(ERR_FEW_PAL);
    }

    /* Allocate space for the sprite buffer. */
    uint8_t *spr_buffer = malloc(bih->width * bih->height);

    /* Convert the BGR data to chip16 palletized data. */
    palettize(pixels,spr_buffer,bih->width,bih->height,palette,pal_type,key,dither);
    
    /* Allocate space for the (packed) output sprite buffer. */
    uint8_t *ospr_buffer = malloc((bih->width * bih->height)/2);
   
    /* Pack the sprite data for output. */
    sprite_pack(spr_buffer,ospr_buffer,bih->width,bih->height);

    /* Extract a chip16 indexed image representation. */
    //if(!extract_chip16_buf(,cbuffer,
    //                       bih->width,bih->height,palette,pal_type,key))
    //    return error(-1);
    
    /* Output the chip16 image to file. */
    file = fopen(out_fn,"wb+");
    if(file == NULL)
        return error(ERR_IO);
    fwrite(ospr_buffer,sizeof(uint8_t),(bih->width*bih->height)/2,file);
    fclose(file);

    /* Print useful information for use with the assembler. */
    printf("importbin %s 0 %u spr_%s\n",
            out_fn,(bih->width*bih->height)/2,out_fn);

    /* Dump the image if requested. */
    if(dump_img)
    {
        printf("Dump:\n");
        dump_image(ospr_buffer, bih->width, bih->height);    
    }

    /* Clean up. */
    free(ospr_buffer);
    free(spr_buffer);
    free(buffer);
      
    return 0;
}

int error(err_t code)
{
    printf("error: ");
    switch(code)
    {
    case ERR_NO_FILE:
        printf("no filename supplied\n");
        break;
    case ERR_ARGS:
        printf("invalid/missing argument\n(run img16 --help for valid arguments)\n");
        break;
    case ERR_IO:
        printf("problem opening file\n");
        break;
    case ERR_INVALID_KEY:
        printf("invalid color key supplied (valid range: 0-15)\n");
        break;
    case ERR_FEW_PAL:
        printf("not enough palette entries in file\n");
        break;
    case ERR_INVALID_BMP:
        printf("BMP file invalid/not supported\n");
        break;
    default:
        printf("unknown\n");
        break;
    }
    return 1;
} 

int help(void)
{
    printf("Usage: img16 SOURCE [OPTION...]\n");
    printf("\n    Convert a BMP image to a chip16 binary sprite.\n\n");
    printf("Options: [-h|--help] [-o DEST] [-pt|--palette-text FILE]\n");
    printf("         [-pb|--palette-bin FILE] [-k|--key KEY] [-v|--version]\n\n");
    printf("\t-h, --help                    Display this help text.\n\n");
    printf("\t-v, --version                 Display program version information.\n\n");
    printf("\t-o DEST                       Output to DEST (default is image.bin).\n\n");
    printf("\t-pt, --palette-text FILE      Use the palette in FILE, stored as ASCII\n"
           "\t                              hex numbers.\n\n");
    printf("\t-pb, --palette-bin FILE       Use the palette in FILE, stored as 24-bit\n"
           "\t                              unsigned numbers.\n\n");
    printf("\t-k, --key KEY                 Make the chip16 color KEY transparent\n"
           "\t                              (set to 0)\n\n");
    printf("\t-d, --dither                  Apply dithering (Floyd-Steinberg)\n\n");
    printf("\t-i, --info                    Output BMP header information.\n\n");
    return 0;
}

int version(void)
{
    printf("img16 1.1 - a chip16 image converter\n");
    return 110;
}
