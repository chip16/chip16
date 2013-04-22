/*
 *  ch16_rom.c
 *  
 *  Builds a Chip16 rom file given a bin file, and some options
 *  Possible options: -o [filename], -v [version], -s [start], -c
 *
 *  tykel (C) 2011-2012
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <math.h>
#include "structs.h"
#include "crc.h"

void build_header(ch16_header* header, uint8_t spec_ver, uint32_t rom_size, uint16_t start_addr, uint8_t* data)
{
    if(header == NULL)
    {
        fprintf(stderr,"Null pointer exception ***(build_header)");
        exit(1);
    }
    // Magic number 'CH16'
    header->magic = 0x36314843;
    // Reserved, always 0
    header->reserved = 0x00;
    // Spec version
    header->spec_ver = spec_ver;
    // Rom size
    header->rom_size = rom_size;
    // Start address
    header->start_addr = start_addr;
    // Calculate CRC
    crc_t crc = crc_init();
    crc = crc_update(crc,data,rom_size);
    crc = crc_finalize(crc);
    header->crc32_sum = crc;
}

void build_rom(ch16_rom* rom, ch16_header* header, uint8_t* data)
{
    // Check for bad memory
    if(header == NULL || data == NULL)
    {
        fprintf(stderr,"Null pointer exception ***(build_rom)");
        exit(1);
    }
    memcpy((uint8_t*)&(rom->header),(uint8_t*)header,CH16_HEADER_SIZE);
    memcpy((uint8_t*)&(rom->data),(uint8_t*)data,rom->header.rom_size);
}

int read_header(ch16_header* header, uint32_t size, uint8_t* data)
{
    if(header->magic != 0x36314843)
    {
        fprintf(stderr,"Invalid magic number\n");
        fprintf(stderr,"Found: 0x%x, Expected: 0x%x\n",
                header->magic, 0x36314843);
        return 0;
    }
    if(header->reserved != 0)
    {
        fprintf(stderr,"Reserved not 0\n");
        return 0;
    }
    if(header->rom_size != size - sizeof(ch16_header))
    {
        fprintf(stderr,"Incorrect size reported\n");
        fprintf(stderr,"Found: 0x%x, Expected: 0x%x\n",
                header->rom_size, (uint32_t)(size - sizeof(ch16_header)));
        return 0;
    }
    crc_t crc = crc_init();
    crc = crc_update(crc,data,size-sizeof(ch16_header));
    crc = crc_finalize(crc);
    if(header->crc32_sum != crc)
    {
        fprintf(stderr,"Incorrect CRC32 checksum\n");
        fprintf(stderr,"Found: 0x%x, Expected: 0x%x\n",
                header->crc32_sum, crc);
        return 0;
    }
    return 1;
}

int main(int argc, char** argv)
{
    if(argc == 1)
    {
        printf("No filename given, exiting\n");
        exit(0);
    }
    char binf_name[255];
    char romf_name[255];
    double verf = 1.0;
    uint16_t start = 0x0000;
    int check = 0;
    int raw = 0;
    if(argc >= 2)
    {
        for(int i=0; i<argc; ++i)
        {
            if(!strcmp(argv[i],"-o"))
            {
                if(i == argc-1 || argv[i+1][0] == '-')
                {
                    fprintf(stderr,"No output filename specified ***(main)\n");
                    exit(1);
                }
                strcpy(romf_name,argv[++i]);
            }
            else if(!strcmp(argv[i], "-v") || !strcmp(argv[i], "--version"))
            {
                if(i == argc-1 || argv[i+1][0] == '-')
                {
                    fprintf(stderr,"No version specified ***(main)\n");
                    exit(1);
                } 
                sscanf(argv[++i],"%lf",&verf);
            }
            else if(!strcmp(argv[i], "-s") || !strcmp(argv[i], "--start"))
            {
                if(i == argc-1 || argv[i+1][0] == '-')
                {
                    fprintf(stderr,"No start address specified ***(main)\n");
                    exit(1);
                } 
                sscanf(argv[++i],"%hu",&start);
            }
            else if(!strcmp(argv[i], "-c") || !strcmp(argv[i], "--check"))
            {
                check = 1;
            }
            else if(!strcmp(argv[i], "-r") || !strcmp(argv[i], "--raw"))
            {
                raw = 1;
            }
            else if(!strcmp(argv[i], "-h") || !strcmp(argv[i], "--help"))
            {
                printf("chip16 rom patch/check utility\nSee readme.txt for options and help.\n");
                exit(0);
            }
            else
                strcpy(binf_name,argv[i]);
        }
        if(binf_name == NULL)
        {
            fprintf(stderr,"No input filename specified ***(main)");
            exit(1);
        }

        FILE* binf = fopen(binf_name,"rb");
        if(binf == NULL)
        {
            fprintf(stderr,"Input file access denied ***(main)");
            exit(1);
        }
        // Get size of rom
        fseek(binf,0,SEEK_END);
        uint32_t len = ftell(binf);
        fseek(binf,0,SEEK_SET);
        // Read from disk
        uint8_t* bin = (uint8_t*) malloc(len);
        fread(bin,sizeof(uint8_t),len,binf);
        fclose(binf);
        if(check)
        {
            ch16_header* header = (ch16_header*)bin;
            uint8_t* data = (uint8_t*)(bin + sizeof(ch16_header));
            if(read_header(header,len,data))
            {
                printf("Header valid.\n");
                printf("Spec version: %d.%d\n",(header->spec_ver & 0xF0) >> 4,
                                               (header->spec_ver & 0x0F));
                printf("ROM size: %d (0x%x) B\n",header->rom_size, header->rom_size);
                printf("Start address: 0x%x\n", header->start_addr);
                printf("CRC32 checksum: (0x%x)\n", header->crc32_sum);
            }
            else
                printf("Header invalid.\n");
        }
        if(raw)
        {
            ch16_header* header = (ch16_header*)bin;
            uint8_t* data = (uint8_t*)(bin + sizeof(ch16_header));
            if(read_header(header,len,data))
            {
                binf = fopen(binf_name,"wb");
                if(binf == NULL)
                {
                    fprintf(stderr,"Output file access denied ***(main)");
                    exit(1);
                }
                fwrite(data,sizeof(uint8_t),len-sizeof(ch16_header),binf);
                fclose(binf);
            }
        }
        if(!check)
        {
            // Allocate, build header
            double frac = modf(verf,&verf);
            uint8_t ver = (uint8_t)(frac*10) | ((uint8_t)(verf) << 4);
            uint8_t* head = (uint8_t*) malloc(CH16_HEADER_SIZE);
            build_header((ch16_header*)head,ver,len,start,bin);
            // Allocate, build rom
            uint8_t* rom = (uint8_t*) malloc(CH16_HEADER_SIZE+len);
            build_rom((ch16_rom*)rom,(ch16_header*)head,bin);
            // Get the output filename
            if(romf_name == NULL)
            {
                char* suf = strstr(argv[1],".bin");
                if(suf != NULL) {
                    char* dot = strrchr(romf_name,'.');
                    dot[1] = 'c';
                    dot[2] = '1';
                    dot[3] = '6';
                }
                else
                {
                    suf = strstr(argv[1],".c16");
                    if(suf == NULL)
                        strcat(romf_name,".c16");
                }
            }
            // Write to disk
            FILE* romf = fopen(romf_name,"wb");
            if(romf == NULL)
            {
                fprintf(stderr,"Output file access denied ***(main)");
                exit(1);
            }
            fwrite(rom,sizeof(uint8_t),CH16_HEADER_SIZE+len,romf);
            fclose(romf);
            // Free memory up
            free(rom);
            free(head);
        }
        free(bin);
        }
        else
            fprintf(stderr,"More than one arg! Welp!");
    
        return 0;
}
