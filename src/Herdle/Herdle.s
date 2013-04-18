; Herding game for Chip16
; Coding: (C) tykel, 2012
; Art: (C) Chris2balls, 2012
;-------------------------------------------------------------------------------
; Outline:
; 	You are a sheep dog, you get round the sheep, and reach the exit, 
;	at the top of the screen, without colliding into sheep or fencing. 
;	A path counter decrements every step; if runs out, lose life.
;	Collision with either removes life; when out of lives, game over.
;-------------------------------------------------------------------------------
; Memory layout:
;	r0-4: scratch registers
;	r5: time
;	r6: nb lives
;	r7: box count
;	r8: box.x = prevdog.x
;	r9: box.y = prevdog.y
;	ra: dog.x (grid)
;	rb: dog.y (grid)
;	rc: dog.dir (1=U,2=D,4=L,8=R)
;	rd: firstRun? boolean
;	re: move counter (decrements every step)
;	rf: dog.spr_address (animation)
;	0xF000 - 0xF257: collision array (16-bit)
;		-> hi byte = 0xFF if sheep, 0x00 otherwise
;		-> lo byte = 0xFF if box, 0x00 otherwise
;	0xF258:	exit x-coord
;	0xF300: timer constant
;	0xF302: move counter reset value (decrease every screen)
;-------------------------------------------------------------------------------
; GFX imports:
	importbin title.bin 0 15680 spr_title
	importbin dog.bin 0 128 spr_dog1
	importbin dog.bin 128 128 spr_dog2
	importbin sheep.bin 0 128 spr_sheep1
	importbin sheep.bin 128 128 spr_sheep2
	importbin box.bin 0 128 spr_box
	importbin exit.bin 0 128 spr_exit
	importbin steps.bin 0 128 spr_steps
	importbin empty.bin 0 128 spr_empty
	importbin font.bin 0 7125 spr_font
;-------------------------------------------------------------------------------
; CODE:
;-----------
; Initialisation code run only once during game
pre_init:
	ldi r6, 3							; reset score
	ldi r0, 0xFF13
	stm r0, ascii_score_val				; and in memory too!
	ldi r0, 40
	stm r0, 0xF300						; timer mult. const. = 40
	ldi r0, 0x15
	stm r0, 0xF302						; move cnt reset value = 0x15
;-----------
;Title screen
title:
	cls
	spr 0x8C70
	ldi r1, 48
	ldi r2, 20
	drw r1, r2, spr_title
	ldi r0, ascii_press_start
	ldi r1, 110
	ldi r2, 170
	call text_disp
	ldi r0, ascii_credits
	ldi r1, 70
	ldi r2, 220
	call text_disp
	vblnk
; Test for START until pressed
title_loop:
	ldm r0, 0xFFF0
	andi r0, 0x20
	jmz title_loop
;-----------
; Initialization code
init:
	cls
	bgc 0x1								; black bg
	spr 0x1008							; sprites are 16x16 (0x10 * 0x08 bytes)
	ldm r5, 0xF300						; reset timer
	ldi r0, 20							; if 20 or less, game is won!
	sub r0, r5
	jmc init_cont
	jmp game_win
init_cont:
	ldi r7, 0							; no boxes initially
	ldi r8, 0xFFFF						; initialize box.x
	ldi r9, 0xFFFF						; initialize box.y
	ldi rd, 1							; this is the first run
	ldm re, 0xF302						; initialize mvt counter
	subi re, 1							; decrease it for next screen
	stm re, 0xF302						; TODO: ADD BOUNDS CHECK
	ldi rf, spr_dog1					; current animation frame
; Make the array empty
zero_array:
	ldi r0, 0xF000
	ldi r1, 0x258
zero_array_cont:
	subi r1, 2
	jmc place_exit
	add r0, r1, r2
	ldi r3, 0x0000
	stm r3, r2
	jmp zero_array_cont
; Place the exit at a random x-coord
place_exit:
	rnd r0, 19
	stm r0, 0xF258
; Place the sheep at random initial positions
place_sheep:
	ldi r0, 24							; counter to 24
	ldi r3, 0xF000						; coll. array base address
place_sheep_loop:
	subi r0, 1
	jmc place_dog
	rnd r1, 15							; random sheep.x
	addi r1, 2
	rnd r2, 7							; random sheep.y
	addi r2, 3
	muli r2, 20							; .
	add r1, r2, r4						; ..
	shl r4, 1							; ...
	add r4, r3							; ...(y*20 + x)*2 + 0xF000
	ldi r1, 0xFF00
	stm r1, r4
	jmp place_sheep_loop
; Place the dog middle-bottom, facing up
place_dog:
	ldi ra, 9
	ldi rb, 13
	ldi rc, 1
;-----------
; Main game loop, as described in outline
game_loop:
	;jmp draw
wander_sheep:
	; TODO
;-----------
; Get input from player, change direction accordingly
get_input:
	ldm r0, 0xFFF0						; get P1 ctlr status
	andi r0, 0x0D
	jmz move
	mov rc, r0
;-----------
; Move player according to direction
move:
	subi re, 1
	jmz move_cont
	jmp draw							; [modify this to improve speed]
move_cont:
	ldm re, 0xF302						; first, reset counter
	subi r5, 1							; then, decrement the timer
	jmz game_over						; time's up!
move_update_timer:
	ldi r1, 100							; update path ctr in memory...
	div r5, r1, r2						; r2 = X00
	mul r1, r2, r3
	sub r5, r3, r0
	ldi r1, 10
	div r0, r1, r4						; r4 = 0X0
	mul r1, r4, r3
	sub r0, r3							; r0 = 00X
	addi r2, 0x10
	addi r4, 0x10
	addi r0, 0x10
	mov r1, r4
	shl r1, 8	
	or r1, r2
	ldi r2, 0xFF00						; ensure ended by '\0'
	or r2, r0
	ldi r0, ascii_path_val
	stm r1, r0
	addi r0, 2
	stm r2, r0							; ... .
move_cont2:
	snd1 20								; play a sound
	ldi r0, spr_dog1					; swap animation frame
	sub rf, r0, r0
	jmz move_dog2
	ldi rf, spr_dog1
	jmp move_updatebox
move_dog2:
	ldi rf, spr_dog2
move_updatebox:
	mov r8, ra							; update box.x...
	mov r9, rb							; ...and box.y
move_test_up:
	ldi r1, 1
	and r1, rc
	jmz move_test_left
	subi rb, 1
	jmz move_test_up_check
	jmp check_collision
move_test_up_check:
	ldm r0, 0xF258
	jme ra, r0, end_screen
	jmp game_over
move_test_left:
	ldi r1, 4
	and r1, rc
	jmz move_test_right
	subi ra, 1
	jmc game_over
	jmp check_collision
move_test_right:
	ldi r1, 8
	and r1, rc
	jmz check_collision
	addi ra, 1
	mov r0, ra
	subi r0, 20
	jmc check_collision
	jmp game_over
;-----------
; Check for collision at new position
check_collision:
; Check for collision with box/fencing
	ldi r0, 0xF000
	mov r1, rb
	muli r1, 20
	add r1, ra
	shl r1, 1							; mult. by 2 for 16-bit words
	add r1, r0
	ldm r2, r1
	andi r2, 0xFFFF
	jmz lay_box							; 0: no box nor sheep
	jmp game_over
;-----------
; Lay a box/fence at position
lay_box:
	addi r7, 1							; increment box count
	ldi r0, 0xF000						; calculate this box's address
	mov r1, r9
	muli r1, 20
	add r1, r8
	shl r1, 1
	add r1, r0
	ldm r2, r1
	ori r2, 0x00FF						; add the box to the mask
	stm r2, r1
;-----------
; Draw it all on screen
draw:
; draw dog
	mov r0, ra
	shl r0, 4
	mov r1, rb
	shl r1, 4
	drw r0, r1, rf
; draw box
	mov r0, r8
	shl r0, 4
	mov r1, r9
	shl r1, 4
	drw r0, r1, spr_empty
	drw r0, r1, spr_steps
; draw path
	ldi r0, ascii_path_val
	ldi r1, 290
	ldi r2, 227
	call text_disp
	addi rd, 0							; only draw sheep...
	jmz draw_finish						; ...if this is the first run
; draw sheep
draw_sheep:
	ldi rd, 0							; the first run is over.
	ldi r0, 0xF000
	ldi r1, 0x258
draw_sheep_cont:
	subi r1, 2
	jmc draw_hud
	add r0, r1, r2
	ldm r3, r2
	mov r2, r1
	divi r2, 2
	andi r3, 0xFF00						; check for sheep
	jmz draw_sheep_cont
	mov r3, r2
	divi r3, 20
	mov r4, r3
	muli r4, 20
	sub r2, r4, r4
	shl r3, 4							; sheep.y
	shl r4, 4							; sheep.x
	drw r4, r3, spr_sheep1
	jmp draw_sheep_cont
draw_hud:
	ldi r0, ascii_score
	ldi r1, 0
	ldi r2, 227
	call text_disp
	ldi r0, ascii_score_val
	ldi r1, 60
	call text_disp
	ldi r0, ascii_path
	ldi r1, 240
	call text_disp
draw_top_fence:
	ldi r0, 320
	ldi r1, 0
draw_top_fence_loop:
	subi r0, 16
	jmc draw_exit
	drw r0, r1, spr_box
	jmp draw_top_fence_loop
draw_exit:
	ldm r0, 0xF258
	muli r0, 16
	ldi r1, 0
	drw r0, r1, spr_exit
draw_finish:
	vblnk
	jmp game_loop
;-----------
; Inter-screen
end_screen:
	ldm r0, 0xF300						; take 2 from move counter
	subi r0, 2
	stm r0, 0xF300
	snd2 300							; play a sound!
	bgc 0xA								; flash the screen
	vblnk
	ldi r0, 6
	call pause
	bgc 0x1
	vblnk
	ldi r0, 45							; pause for 750ms...
	call pause
	jmp init							; then next screen
;-----------
; GAME OVER
game_over:
	snd3 300							; play a sound!
	ldm r0, 0xF302						; ensure the speed doesn't increase
	addi r0, 1
	stm r0, 0xF302
	bgc 0x3
	vblnk
	ldi r0, 2
	call pause
	bgc 0x1
	vblnk
	ldi r0, 100						; pause...
	call pause
game_over_cont:
	subi r6, 1
	jmc game_over_def
	mov r0, r6
	addi r0, 0x10
	ori r0, 0xFF00
	stm r0, ascii_score_val
	jmp init
game_over_def:							; then it's game over >:D
	cls
	ldi r0, ascii_game_over
	ldi r1, 120
	ldi r2, 110
	call text_disp
	vblnk
	ldi r0, 240
	call pause
	jmp pre_init
;-----------
; GAME WIN
game_win:
	snd1 200
	ldi r0, 9
	call pause
	snd2 200
	ldi r0, 9
	call pause
	snd3 200
	ldi r0, 9
	call pause
	cls
	ldi r0, ascii_congrats
	ldi r1, 85
	ldi r2, 100
	call text_disp
	ldi r0, ascii_beat_game
	ldi r1, 75
	ldi r2, 170
	call text_disp
	ldi r1, 10
game_win_pause:
	subi r1, 1
	jmc pre_init
	ldi r0, 240
	call pause
	jmp game_win_pause
;-----------
; TEXT DISPLAYING ROUTINE
; r0: char ptr, r1-2: pos
; Non-standard: uses 0xFF as string terminator
text_disp:
	spr 0x0F05							; chars are 10x15 px
	ldi r4, 0x00FF
text_disp_cont:
	ldm r3, r0							; read value...
	andi r3, 0x00FF						; ...but keep only low byte
	jme r3, r4, text_disp_end			; hit end-of-string, exit
	muli r3, 75							; convert char offs to byte offs (thx S)
	addi r3, spr_font					; offset to ascii data
	drw r1, r2, r3
	addi r0, 1							; increment char ptr
	addi r1, 10							; next char 10px right
	jmp text_disp_cont
text_disp_end:
	spr 0x1008
	ret
;----------
; PAUSING ROUTINE
; r0: delay in vblnks (16.66ms)
pause:
	subi r0, 1
	jmc pause_end
	vblnk
	jmp pause
pause_end:
	ret
;-------------------------------------------------------------------------------
; String data -- cannot use string literals, since the data is not ASCII!
ascii_press_start:
	db 0x30		; P
	db 0x52		; r
	db 0x45 	; e
	db 0x53		; s
	db 0x53		; s
	db 0x00		; 
	db 0x33		; S
	db 0x34		; T
	db 0x21		; A
	db 0x32		; R
	db 0x34		; T
	db 0xFF		; \0
ascii_credits:
	db 0x12		; 2
	db 0x10		; 0
	db 0x11		; 1
	db 0x11		; 1
	db 0x0C		; ,
	db 0x00		; 
	db 0x2B		; K
	db 0x45 	; e
	db 0x4C		; l
	db 0x53		; s
	db 0x41		; a
	db 0x4C		; l
	db 0x4C		; l
	db 0x00		; 
	db 0x22		; B
	db 0x52		; r
	db 0x4F		; o
	db 0x53		; s
	db 0x0E		; .
	db 0xFF		; \0
ascii_score:
	db 0x2C		; L
	db 0x49		; i
	db 0x56		; v
	db 0x45		; e
	db 0x53		; s
	db 0x1A		; :
	db 0xFF		; \0
ascii_score_val:
	db 0x10		; 0
	db 0xFF		; \0
ascii_path:
	db 0x30		; P
	db 0x41		; a
	db 0x54		; t
	db 0x48		; h
	db 0x1A		; :
	db 0xFF		; \0
ascii_path_val:
	db 0x10		; 0
	db 0x10		; 0
	db 0x10		; 0
	db 0xFF		; \0
ascii_game_over:
	db 0x27		; G
	db 0x41		; a
	db 0x4D		; m
	db 0x45		; e
	db 0x00		;
	db 0x2F		; O
	db 0x56		; v
	db 0x45		; e
	db 0x52		; r
	db 0xFF		; \0
ascii_congrats:
	db 0x23		; C
	db 0x2F		; O
	db 0x2E		; N
	db 0x27		; G
	db 0x32		; R
	db 0x21		; A
	db 0x34		; T
	db 0x35		; U
	db 0x2C		; L
	db 0x21		; A
	db 0x34		; T
	db 0x29		; I
	db 0x2F		; O
	db 0x2E		; N
	db 0x33		; S
	db 0xFF		; \0
ascii_beat_game:
	db 0x39		; Y
	db 0x4F		; o
	db 0x55		; u
	db 0x00		; 
	db 0x42		; b
	db 0x45		; e
	db 0x41		; a
	db 0x54		; t
	db 0x00		; 
	db 0x54		; t
	db 0x48		; h
	db 0x45		; e
	db 0x00		; 
	db 0x47		; g
	db 0x41		; a
	db 0x4D		; m
	db 0x45		; e
	db 0xFF		; \0
