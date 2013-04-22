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

