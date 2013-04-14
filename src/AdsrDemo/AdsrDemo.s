;-------------------------------------------------------------------------------            
; ADSR sound system demo for Chip16
; Inspired by the Pascal Win32 application by paul_nicholls
; Copyright (c) tykel 2012. Licensed under GPL.
;
; Spec version: 1.1
; Spec instr. used: SNG, SNP, FLIP
;
; Registers R0-R9 are not preserved in these subroutines.

; RA: focus             RD:
; RB: max               RE: pause counter for cycling
; RC: step              RF: pad status
;
;-------------------------------------------------------------------------------
; How does it work? We save values for the ADSR envelope in main memory, and
; dynamically generate SNP and SNG instructions with the right parameters.
; See the "play" subroutine for more.
;
;-------------------------------------------------------------------------------            
; Graphics imports
importbin gfx/font.bin 0 3072 spr_font
importbin gfx/arrow.bin 0 32 spr_arrow

;-------------------------------------------------------------------------------            
; Constant definitions
FOCUS_DUR   equ 0                   ; Menu focus enumeration
FOCUS_NOTE  equ 1
FOCUS_ATK   equ 2
FOCUS_DEC   equ 3
FOCUS_STN   equ 4
FOCUS_RLS   equ 5
FOCUS_VOL   equ 6
FOCUS_TYPE  equ 7

PAD_IO      equ 0xFFF0              ; Controller I/O port
PAD_UP      equ 1                   ; Gamepad button mappings
PAD_DOWN    equ 2
PAD_LEFT    equ 4
PAD_RIGHT   equ 8
PAD_SELECT  equ 16
PAD_START   equ 32
PAD_A       equ 64
PAD_B       equ 128

DUR_Y       equ 18                  ; Height of different menu items
NOTE_Y      equ 34
ATK_Y       equ 50
DEC_Y       equ 66
STN_Y       equ 82
RLS_Y       equ 98
VOL_Y       equ 114
TYPE_Y      equ 130

ADSR_STEP   equ 1
BIG_STEP    equ 20

WAIT_FRAMES equ 5                   ; Delay between button presses (in frames)

;-------------------------------------------------------------------------------            
; Main routine, includes initialisation code
init:               ldi ra, FOCUS_DUR
                    ldi re, WAIT_FRAMES
draw_screen:        cls                         ; Redraw the screen:
                    ldi r0, str_title           ; First the title
                    ldi r1, 104
                    ldi r2, 2
                    call print
                    ldi r0, str_authors         ; Then the credits
                    ldi r1, 56
                    ldi r2, 232
                    call print
                    ldi r0, str_dpad
                    ldi r1, 0
                    ldi r2, 180
                    call print
                    ldi r0, str_start
                    ldi r1, 0
                    ldi r2, 196
                    call print
                    call menu_upd_entry         ; Finally the menu
handle_input:       vblnk
                    push rf                     ; Keep the old pad status
                    ldm rf, PAD_IO              ; Get the new status
                    andi rf, 0xFF
                    jz handle_input_none        
                    pop r0                      ; Junk the old pad status
                    jmp handle_input_cont
handle_input_none:  pop r0                      ; Restore the old status
handle_input_cont:  subi re, 1                  ; Check if the wait is over
                    jnz handle_loop
                    ldi re, WAIT_FRAMES         ; Waiting done, reset the count
                    tsti rf, PAD_UP
                    cnz menu_up                 ; UP pressed, previous menu elem
                    tsti rf, PAD_DOWN
                    cnz menu_down               ; DOWN pressed, next menu elem
                    tsti rf, PAD_LEFT
                    cnz val_dec                 ; LEFT pressed, decrement val
                    tsti rf, PAD_RIGHT
                    cnz val_inc                 ; RIGHT pressed, increment val
                    tsti rf, PAD_START
                    cnz play                    ; START pressed, play sound
                    tsti rf, PAD_SELECT
                    cnz secret
                    ldi rf, 0
handle_loop:        jmp draw_screen
;-------------------------------------------------------------------------------                
secret:             sng 0x63, 0x9385
                    ldi r0, secret_note
                    snp r0, 600
                    vblnk
                    vblnk
                    ret
secret_note:        db 0xe8, 0x00

;-------------------------------------------------------------------------------            
; Handle UP key press, cycle through menu items
menu_up:            cmpi ra, FOCUS_DUR
                    jz menu_up_wrap
                    subi ra, 1
                    jmp menu_up_disp 
menu_up_wrap:       ldi ra, FOCUS_TYPE
menu_up_disp:       ret     
; Handle DOWN key press, cycle through menu items
menu_down:          cmpi ra, FOCUS_TYPE
                    jz menu_down_wrap
                    addi ra, 1
                    jmp menu_down_disp 
menu_down_wrap:     ldi ra, FOCUS_DUR
menu_down_disp:     ret
                    
;-------------------------------------------------------------------------------            
; Menu update routine
menu_upd_entry:     
; Duration entry
menu_upd_dur:       ldi rb, 0xFFFF
                    ldi r0, str_duration
                    ldi r1, 0
                    ldi r2, DUR_Y
                    call print
                    cmpi ra, FOCUS_DUR
                    jnz menu_upd_dur_body
                    ldm r0, var_duration
                    cmpi r0, 0
                    jz menu_upd_dur_body
                    drw r1, r2, spr_arrow
                    addi r1, 8
menu_upd_dur_body:  ldm r0, var_duration
                    call print_num
                    ldi r0, str_ms
                    call print
                    cmpi ra, FOCUS_DUR
                    jnz menu_upd_note
                    ldm r0, var_duration
                    cmp r0, rb
                    jz menu_upd_note
                    flip 1, 0
                    drw r1, r2, spr_arrow
                    flip 0, 0
; Note entry
menu_upd_note:      ldi rb, 0xFFFF
                    ldi r0, str_note
                    ldi r1, 0
                    ldi r2, NOTE_Y
                    call print
                    cmpi ra, FOCUS_NOTE
                    jnz menu_upd_note_body
                    ldm r0, var_note
                    cmpi r0, 0
                    jz menu_upd_note_body
                    drw r1, r2, spr_arrow
                    addi r1, 8
menu_upd_note_body: ldm r0, var_note
                    call print_num
                    ldi r0, str_hz
                    call print
                    cmpi ra, FOCUS_NOTE
                    jnz menu_upd_atk
                    ldm r0, var_note
                    cmp r0, rb
                    jz menu_upd_atk
                    flip 1, 0
                    drw r1, r2, spr_arrow
                    flip 0, 0
; Attack entry
menu_upd_atk:       ldi rb, 15
                    ldi r0, str_attack
                    ldi r1, 0
                    ldi r2, ATK_Y
                    call print
                    cmpi ra, FOCUS_ATK
                    jnz menu_upd_atk_body
                    ldm r0, var_attack
                    cmpi r0, 0
                    jz menu_upd_atk_body
                    drw r1, r2, spr_arrow
                    addi r1, 8
menu_upd_atk_body:  ldm r0, var_attack
                    call print_num
                    addi r1, 8
                    ldi r0, str_lparen
                    call print
                    ldm r0, var_attack
                    muli r0, 2
                    addi r0, lkp_attack
                    ldm r0, r0
                    call print_num
                    ldi r0, str_ms
                    call print
                    ldi r0, str_rparen
                    call print
                    cmpi ra, FOCUS_ATK
                    jnz menu_upd_dec
                    ldm r0, var_attack
                    cmp r0, rb
                    jz menu_upd_dec
                    flip 1, 0
                    drw r1, r2, spr_arrow
                    flip 0, 0
; Decay entry
menu_upd_dec:       ldi rb, 15
                    ldi r0, str_decay
                    ldi r1, 0
                    ldi r2, DEC_Y
                    call print
                    cmpi ra, FOCUS_DEC
                    jnz menu_upd_dec_body
                    ldm r0, var_decay
                    cmpi r0, 0
                    jz menu_upd_dec_body
                    drw r1, r2, spr_arrow
                    addi r1, 8
menu_upd_dec_body:  ldm r0, var_decay
                    call print_num
                    addi r1, 8
                    ldi r0, str_lparen
                    call print
                    ldm r0, var_decay
                    muli r0, 2
                    addi r0, lkp_rd
                    ldm r0, r0
                    call print_num
                    ldi r0, str_ms
                    call print
                    ldi r0, str_rparen
                    call print
                    cmpi ra, FOCUS_DEC
                    jnz menu_upd_stn
                    ldm r0, var_decay
                    cmp r0, rb
                    jz menu_upd_stn
                    flip 1, 0
                    drw r1, r2, spr_arrow
                    flip 0, 0
; Sustain entry
menu_upd_stn:       ldi rb, 15
                    ldi r0, str_sustain
                    ldi r1, 0
                    ldi r2, STN_Y
                    call print
                    cmpi ra, FOCUS_STN
                    jnz menu_upd_stn_body
                    ldm r0, var_sustain
                    cmpi r0, 0
                    jz menu_upd_stn_body
                    drw r1, r2, spr_arrow
                    addi r1, 8
menu_upd_stn_body:  ldm r0, var_sustain
                    call print_num
                    cmpi ra, FOCUS_STN
                    jnz menu_upd_rls
                    ldm r0, var_sustain
                    cmp r0, rb
                    jz menu_upd_rls
                    flip 1, 0
                    drw r1, r2, spr_arrow
                    flip 0, 0
; Release entry
menu_upd_rls:       ldi rb, 15
                    ldi r0, str_release
                    ldi r1, 0
                    ldi r2, RLS_Y
                    call print
                    cmpi ra, FOCUS_RLS
                    jnz menu_upd_rls_body
                    ldm r0, var_release
                    cmpi r0, 0
                    jz menu_upd_rls_body
                    drw r1, r2, spr_arrow
                    addi r1, 8
menu_upd_rls_body:  ldm r0, var_release
                    call print_num
                    addi r1, 8
                    ldi r0, str_lparen
                    call print
                    ldm r0, var_release
                    muli r0, 2
                    addi r0, lkp_rd
                    ldm r0, r0
                    call print_num
                    ldi r0, str_ms
                    call print
                    ldi r0, str_rparen
                    call print
                    cmpi ra, FOCUS_RLS
                    jnz menu_upd_vol
                    ldm r0, var_release
                    cmp r0, rb
                    jz menu_upd_vol
                    flip 1, 0
                    drw r1, r2, spr_arrow
                    flip 0, 0
; Volume entry
menu_upd_vol:       ldi rb, 15
                    ldi r0, str_volume
                    ldi r1, 0
                    ldi r2, VOL_Y
                    call print
                    cmpi ra, FOCUS_VOL
                    jnz menu_upd_vol_body
                    ldm r0, var_volume
                    cmpi r0, 0
                    jz menu_upd_vol_body
                    drw r1, r2, spr_arrow
                    addi r1, 8
menu_upd_vol_body:  ldm r0, var_volume
                    call print_num
                    cmpi ra, FOCUS_VOL
                    jnz menu_upd_type
                    ldm r0, var_volume
                    cmp r0, rb
                    jz menu_upd_type
                    flip 1, 0
                    drw r1, r2, spr_arrow
                    flip 0, 0
; Type entry
menu_upd_type:      ldi rb, 3
                    ldi r0, str_type
                    ldi r1, 0
                    ldi r2, TYPE_Y
                    call print
                    cmpi ra, FOCUS_TYPE
                    jnz menu_upd_type_body
                    ldm r0, var_type
                    cmpi r0, 0
                    jz menu_upd_type_body
                    drw r1, r2, spr_arrow
                    addi r1, 8
menu_upd_type_body: ldm r0, var_type
                    cmpi r0, 0
                    jnz menu_upd_type1
                    ldi r0, str_triangle
                    call print
                    jmp menu_upd_type_cont
menu_upd_type1:     cmpi r0, 1
                    jnz menu_upd_type2
                    ldi r0, str_sawtooth
                    call print
                    jmp menu_upd_type_cont
menu_upd_type2:     cmpi r0, 2
                    jnz menu_upd_type3
                    ldi r0, str_pulse
                    call print
                    jmp menu_upd_type_cont
menu_upd_type3:     ldi r0, str_noise
                    call print
menu_upd_type_cont: cmpi ra, FOCUS_TYPE
                    jnz menu_upd_end
                    ldm r0, var_type
                    cmp r0, rb
                    jz menu_upd_end
                    flip 1, 0
                    drw r1, r2, spr_arrow
                    flip 0, 0
menu_upd_end:       ret
;-------------------------------------------------------------------------------
; Handle incrementing and decrementing of the variables
val_inc:            cmpi ra, FOCUS_DUR
                    jz val_inc_dur
                    cmpi ra, FOCUS_NOTE
                    jz val_inc_note
                    cmpi ra, FOCUS_ATK
                    jz val_inc_atk
                    cmpi ra, FOCUS_DEC
                    jz val_inc_dec
                    cmpi ra, FOCUS_STN
                    jz val_inc_stn
                    cmpi ra, FOCUS_RLS
                    jz val_inc_rls
                    cmpi ra, FOCUS_VOL
                    jz val_inc_vol
                    jmp val_inc_type
val_inc_dur:        ldi r0, var_duration
                    ldi rb, 0xFFFF
                    ldi rc, BIG_STEP
                    jmp val_inc_upd
val_inc_note:       ldi r0, var_note
                    ldi rb, 0xFFFF
                    ldi rc, BIG_STEP
                    jmp val_inc_upd
val_inc_atk:        ldi r0, var_attack
                    ldi rb, 15
                    ldi rc, ADSR_STEP
                    jmp val_inc_upd
val_inc_dec:        ldi r0, var_decay
                    ldi rb, 15
                    ldi rc, ADSR_STEP
                    jmp val_inc_upd
val_inc_stn:        ldi r0, var_sustain
                    ldi rb, 15
                    ldi rc, ADSR_STEP
                    jmp val_inc_upd
val_inc_rls:        ldi r0, var_release
                    ldi rb, 15
                    ldi rc, ADSR_STEP
                    jmp val_inc_upd
val_inc_vol:        ldi r0, var_volume
                    ldi rb, 15
                    ldi rc, ADSR_STEP
                    jmp val_inc_upd
val_inc_type:       ldi r0, var_type
                    ldi rb, 3
                    ldi rc, ADSR_STEP
val_inc_upd:        ldm r1, r0
                    cmp r1, rb
                    jz val_inc_end
                    add r1, rc
                    stm r1, r0
val_inc_end:        ret
; Decrementing now
val_dec:            cmpi ra, FOCUS_DUR
                    jz val_dec_dur
                    cmpi ra, FOCUS_NOTE
                    jz val_dec_note
                    cmpi ra, FOCUS_ATK
                    jz val_dec_atk
                    cmpi ra, FOCUS_DEC
                    jz val_dec_dec
                    cmpi ra, FOCUS_STN
                    jz val_dec_stn
                    cmpi ra, FOCUS_RLS
                    jz val_dec_rls
                    cmpi ra, FOCUS_VOL
                    jz val_dec_vol
                    jmp val_dec_type
val_dec_dur:        ldi r0, var_duration
                    ldi rc, BIG_STEP
                    jmp val_dec_upd
val_dec_note:       ldi r0, var_note
                    ldi rc, BIG_STEP
                    jmp val_dec_upd
val_dec_atk:        ldi r0, var_attack
                    ldi rc, ADSR_STEP
                    jmp val_dec_upd
val_dec_dec:        ldi r0, var_decay
                    ldi rc, ADSR_STEP
                    jmp val_dec_upd
val_dec_stn:        ldi r0, var_sustain
                    ldi rc, ADSR_STEP
                    jmp val_dec_upd
val_dec_rls:        ldi r0, var_release
                    ldi rc, ADSR_STEP
                    jmp val_dec_upd
val_dec_vol:        ldi r0, var_volume
                    ldi rc, ADSR_STEP
                    jmp val_dec_upd
val_dec_type:       ldi r0, var_type
                    ldi rc, ADSR_STEP
val_dec_upd:        ldm r1, r0
                    cmpi r1, 0
                    jz val_dec_end
                    sub r1, rc
                    stm r1, r0
val_dec_end:        ret
;-------------------------------------------------------------------------------
; Generate and play the sound with our parameters.
play:               snd0                        ; Stop all sounds
                    ldi r2, sound_gen           ; First we make our SNG instr.
                    ldi r0, 0x000E
                    ldm r1, var_attack          ; Fetch the attack
                    shl r1, 12
                    or r0, r1
                    ldm r1, var_decay           ; Fetch the decay
                    shl r1, 8
                    or r0, r1
                    stm r0, r2
                    addi r2, 2                  ; Fetch second part of instr.
                    ldi r0, 0
                    ldm r1, var_volume
                    shl r1, 12
                    or r0, r1
                    ldm r1, var_type            ; Fetch the type
                    shl r1, 8
                    or r0, r1
                    ldm r1, var_sustain         ; Fetch the sustain
                    shl r1, 4
                    or r0, r1
                    ldm r1, var_release         ; Fetch the release
                    or r0, r1
                    stm r0, r2
                    call sound_gen              ; Now call our custom SNG!
                    ldm r0, var_duration        ; Fetch the duration
                    ldi r1, sound_play
                    addi r1, 2
                    stm r0, r1                  ; Insert it in our SNP instr.
                    ldi r0, var_note
                    call sound_play             ; And play it!
                    ret
; Modifiable code for changing ADSR settings
sound_gen:          sng 0x00, 0x0000            ; 0E 00 00 00
                    ret
; Modifiable code for playing ADSR sounds
sound_play:         snp r0, 0x0000              ; 0D 00 00 00
                    ret

;-------------------------------------------------------------------------------            
; Print text routine (wraps)
; R0: String ptr | R1: X | R2: Y
print:              spr 0x0804
print_wrap:         cmpi r1, 320            ; Check if screen edge is reached
                    jl print_read
                    ldi r1, 0               ; Back to start of line
                    addi r2, 8              ; New line
print_read:         ldm r3, r0
                    andi r3, 0xFF           ; Read char byte from word
                    jz print_end
                    subi r3, 32             ; Characters below ' ' not displayed
                    muli r3, 32             ; Convert to sprite offset
                    addi r3, spr_font       ; Convert to sprite address
                    drw r1, r2, r3
                    addi r0, 1              ; Point to next character
                    addi r1, 8              ; Move x along
                    jmp print_wrap
print_end:          ret

;-------------------------------------------------------------------------------            
; Print number routine (no wrap)
; R0: Number | R1: X | R2: Y
print_num:          spr 0x0804
                    ldi r4, 10000           ; Initial divider
                    ldi r5, 1               ; Only zeroes so far (boolean)
print_num_loop:     cmpi r4, 0
                    jz print_num_end
                    div r0, r4, r3          ; Obtain the digit
                    jnz print_num_nz
                    cmpi r5, 1              ; Test if this 0 prefixes the num
                    jz print_num_add
print_num_nz:       addi r3, 16             ; Convert to ASCII
                    muli r3, 32             ; Convert to sprite offset
                    addi r3, spr_font       ; Convert to sprite address
                    drw r1, r2, r3
                    ldi r5, 0               ; Printed -> no more prefix zeroes
print_num_addx:     addi r1, 8              ; Move x along
print_num_add:      div r0, r4, r6          ; Eliminate the printed digit
                    mul r6, r4
                    sub r0, r6
                    divi r4, 10             ; Move the divider along
                    jmp print_num_loop
print_num_end:      cmpi r5, 1              ; Draw a zero if nothing was printed
                    jnz print_num_ret
                    ldi r3, 512             ; Offset to '0'
                    addi r3, spr_font       ; Address of '0' in font sprite
                    drw r1, r2, r3
                    addi r1, 8              ; Move x along
print_num_ret:      ret

;-------------------------------------------------------------------------------            
; Lookup tables - 16-bit values stored in little-endian, 8-bit format
lkp_attack:         db 2,0, 8,0, 16,0, 24,0, 38,0, 56,0, 68,0, 80,0, 100,0, 
                    db 250,0, 0xF4,1, 0x20,3, 0xE8,3, 0xB8,0xB, 0x88,0x13, 
                    db 0x40, 0x1F
lkp_rd:             db 6,0, 14,0, 48,0, 72,0, 114,0, 168,0, 204,0, 240,0,
                    db 0x2C,0x1, 0xEE,0x2, 0xDC,0x5, 0x60,0x9, 0xB8,0xB,
                    db 0x28,0x23, 0x98,0x3A, 0xC0,0x5D
                    
;-------------------------------------------------------------------------------            
; Variables
var_duration:       db 0xc8, 0x00
var_note:           db 0xe8, 0x03
var_attack:         db 0x08, 0x00
var_decay:          db 0x08, 0x00
var_sustain:        db 0x08, 0x00
var_release:        db 0x08, 0x00
var_volume:         db 0x00, 0x00
var_type:           db 0x00, 0x00

;-------------------------------------------------------------------------------            
; String contants - mustn't forget those sring terminators!
str_title:          db "ADSR testing"
                    db 0x0
str_attack:         db "Attack: "
                    db 0x0
str_decay:          db "Decay: "
                    db 0x0
str_sustain:        db "Sustain: "
                    db 0x0
str_release:        db "Release: "
                    db 0x0
str_volume:         db "Volume: "
                    db 0x0
str_type:           db "Type: "
                    db 0x0
str_triangle:       db "Triangle"
                    db 0x0
str_sawtooth:       db "Sawtooth"
                    db 0x0
str_pulse:          db "Pulse"
                    db 0x0
str_noise:          db "Noise"
                    db 0x0
str_duration:       db "Duration: "
                    db 0x0
str_ms:             db " ms"
                    db 0x0
str_note:           db "Note: "
                    db 0x0
str_hz:             db " Hz"
                    db 0x0
str_lparen:         db "("
                    db 0x0
str_rparen:         db ")"
                    db 0x0
str_start:          db "Hold START to play"
                    db 0x0
str_dpad:           db "Use D-PAD to navigate / change values"
                    db 0x0
str_authors:        db "Copyright (C) tykel, 2012"
                    db 0x0
