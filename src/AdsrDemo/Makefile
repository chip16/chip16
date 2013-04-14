AS=tchip16
ASFLAGS=
IMG=img16
IMGFLAGS=--key 0
GFXDIR=gfx

.PHONY: all clean

all: AdsrDemo.c16

AdsrDemo.c16: AdsrDemo.s $(GFXDIR)/font.bin $(GFXDIR)/arrow.bin
	$(AS) $< $(ASFLAGS) -o $@

$(GFXDIR)/%.bin: $(GFXDIR)/%.bmp
	$(IMG) $< $(IMGFLAGS) -o $@

clean:
	rm -rf $(GFXDIR)/*.bin AdsrDemo.c16
