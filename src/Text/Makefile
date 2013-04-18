AS=tchip16
ASFLAGS=
IMG=img16
IMGFLAGS=--key 0

.PHONY: all clean

all: Text.c16

Text.c16: Text.asm font.bin
	$(AS) $< $(ASFLAGS) -o $@

font.bin: font.bmp
	$(IMG) font.bmp $(IMGFLAGS) -o font.bin

clean:
	rm -rf font.bin Text.c16
