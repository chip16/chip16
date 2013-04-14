AS=tchip16
ASFLAGS=
IMG=img16
IMGFLAGS=--key 0

.PHONY: all clean

all: text.c16

text.c16: text.s font.bin
	$(AS) text.s $(ASFLAGS) -o text.c16

font.bin: font.bmp
	$(IMG) font.bmp $(IMGFLAGS) -o font.bin

clean:
	rm -rf font.bin text.c16
