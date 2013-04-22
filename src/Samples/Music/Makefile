AS=tchip16
ASFLAGS=
IMG=img16
IMGFLAGS=

.PHONY: all clean

all: Music.c16

Music.c16: Music.asm
	$(AS) $< $(ASFLAGS) -o $@

clean:
	rm -rf Music.c16
