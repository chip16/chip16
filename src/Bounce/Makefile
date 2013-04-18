AS=tchip16
ASFLAGS=
IMG=img16
IMGFLAGS=

.PHONY: all clean

all: Bounce.c16

Bounce.c16: Bounce.asm
	$(AS) $< $(ASFLAGS) -o $@

clean:
	rm -rf Bounce.c16
