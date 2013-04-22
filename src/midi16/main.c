/*
 * This file is part of midi16.
 *
 * midi16 is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * midi16 is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with midi16. If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>

#include "midi.h"

int main(int argc, char **argv)
{
    FILE *fmid = NULL;
    int size = 0;
    uint8_t *bufmid = NULL;
    midi_header_t *h = NULL;

    if(argc <= 1)
    {
        fprintf(stderr,"error: no MIDI file specified\n");
        exit(1);
    }
    fmid = fopen(argv[1],"rb");
    if(fmid == NULL)
    {
        fprintf(stderr,"error: MIDI file %s could not be opened\n",argv[1]);
        exit(1);
    }
    fseek(fmid,0,SEEK_END);
    size = ftell(fmid);
    fseek(fmid,0,SEEK_SET);
    printf("debug: file = %d B\n",size);

    bufmid = malloc(size);
    fread(bufmid,1,size,fmid);
    fclose(fmid);

    h = (midi_header_t*) bufmid;
    printf("debug: id='%s' size=%d type=%x tracks=%x time_div=%x\n",
            h->id,
            h->size[3] | (h->size[2] << 8) | (h->size[1] << 16) | (h->size[0] << 24),
            h->type[1] | (h->type[0] << 8),
            h->tracks[1] | (h->tracks[0] << 8),
            h->time_div[1] | (h->time_div[0] << 8));

    return 0;
}
