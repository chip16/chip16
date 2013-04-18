AS=tchip16
ASFLAGS=
IMG=img16
IMGFLAGS=

.PHONY: all clean

all: Herdle.c16

Herdle.c16: Herdle.s
	$(AS) $< $(ASFLAGS) -o $@

clean:
	rm -rf Herdle.c16
