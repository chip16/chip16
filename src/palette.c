#include "palette.h"
#include <stdio.h>

int load_palette(const char *fn, uint32_t *pal, int type)
{
    FILE *file;
    uint8_t buffer[PALETTE_ENTRIES*3];
    int i;
    switch(type)
    {
    case PAL_TEXT:
        file = fopen(fn,"r");
        if(file == NULL)
            return 0;
        for(i=0; i<PALETTE_ENTRIES; ++i)
        {
            if(fscanf(file,"%x",&pal[i]) == EOF)
                return 0;
        }
        fclose(file);
        break;
    case PAL_BINARY:
        file = fopen(fn,"rb");
        if(file == NULL)
            return 0;
        if(fread(buffer,sizeof(uint8_t),PALETTE_ENTRIES*3,file) != 48)
            return 0;
        fclose(file);
        for(i=0; i<PALETTE_ENTRIES; ++i)
            pal[i] = (buffer[3*i] << 16) | (buffer[3*i +1] << 8) | buffer[3*i + 2];
        break;
    default:
        return 0;
    }
    return 1; 
}

