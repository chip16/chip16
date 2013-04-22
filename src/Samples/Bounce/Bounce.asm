; Small bouncing ball with gravity and sound effects
; Press START to relaunch ball

; You may reuse this code, credit preferred.
; (C) tykel, 2012

SCR_W	equ 320
SCR_H   equ 240
SCR_LX	equ 318
SCR_LY 	equ 238
GRAV	equ 1

init:
	spr 0x0201			; 2*2 sprite
	ldi r1, note		; note for bounce sound -- similar to tennis ball?
	ldi r2, 16			; max vspeed
	ldi ra, 160			; X
	ldi rb, 160			; Y
init_hs:
	rnd rc, 6			; Hspeed
	cmpi rc, 3
	jz init_hs
	muli rc, 4
	subi rc, 12
	rnd rd, 16			; Vspeed
	subi rd, 16	
	ldi re, GRAV		; Gravity
	ldi rf, 0			; Zero register
	sng 0x00, 0x4300	; Low volume, fast, noise type

update:
	cmpi r2, 0			; If stopped bouncing, stop horiz. movement too
	jz draw
update_x:
	add ra, rc
	cmpi ra, SCR_LX
	jle update_x1
	snp r1, 30
	ldi ra, SCR_LX
	sub rf, rc, rc		; Hspeed = -Hspeed
	jmp update_y
update_x1:
	cmpi ra, 0
	jge update_y
	snp r1, 30
	ldi ra, 0
	sub rf, rc, rc
update_y:
	add rb, rd
	cmpi rb, SCR_LY
	jle update_y1
	snp r1, 30
	ldi rb, SCR_LY
	sub rf, rd, rd		; Vspeed = -Vspeed
	shr r2, 1
	sar rc, 1
	jmp update_dy
update_y1:
	cmpi rb, 0
	jge update_dy
	snp r1, 30
	ldi rb, 0
	sub rf, rd, rd
	shr r2, 1
	sar rc, 1
update_dy:				; Add gravity to this mess
	cmp rd, r2
	jge draw
	add rd, re

draw:
	cls
	drw ra, rb, spr_ball
	vblnk
	
input:					; If START pressed, reset game
	ldm r0, 0xFFF0
	tsti r0, 32
	jz update
	jmp init
	
spr_ball:
	db 0xff, 0xff
note:
	dw 2000
