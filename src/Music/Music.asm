; Example music-playing program for chip16
; Plays a list of sounds sequentially.

; You may reuse this code, credit preferred.
; (C) tykel, 2012

; Note frequencies
REST    equ 0
C1      equ 32
C3      equ 131
D3      equ 146
E3      equ 164
F3      equ 174
G3      equ 195
A4      equ 220
B4      equ 247
C4      equ 261
D4      equ 293
E4      equ 329
F4      equ 349
G4      equ 391
A5      equ 440
B5      equ 493
C5      equ 523
D5      equ 587
E5      equ 659
F5      equ 698
G5      equ 783
D6      equ 1174
E6      equ 1318

; Note lengths
; 150bpm
d_sxt_150       equ 100         ; 1/16
d_eht_150       equ 200         ; 1/8
d_qtr_150       equ 400         ; 1/4
d_hlf_150       equ 800         ; 1/2
d_whl_150       equ 1600        ; 1/1, probably not used
d_3sxt_150      equ 300         ; 3/16 = 1/8 .
d_3eht_150      equ 600         ; 3/8 = 1/4 .
d_3qtr_150      equ 1200        ; 3/4 = 1/2 .
; 120bpm
d_sxt_120       equ 125         ; 1/16
d_eht_120       equ 250         ; 1/8
d_qtr_120       equ 500         ; 1/4
d_hlf_120       equ 1000        ; 1/2
d_whl_120       equ 2000        ; 1/1, probably not used
d_3sxt_120      equ 375         ; 3/16 = 1/8 .
d_3eht_120      equ 750         ; 3/8 = 1/4 .
d_3qtr_120      equ 1500        ; 3/4 = 1/2 .

init:
    ; sng AD, VTSR
    sng 0x14, 0xf1d7
    ldi r0, 88
    ldi r2, note
    ldi r3, dur
; Traverse a series of notes and play them
play_note:
    mov r4, r0
    addi r4, notes_sonic_ghz
    ldm r1, r4
    cmpi r1, 0xFFFF
    jz init
    stm r1, r2
    mov r5, r1
    mov r4, r0
    addi r4, dur_sonic_ghz
    ldm r1, r4
    stm r1, r3
    cmpi r5, 0
    jz play_note_wait
    call play
play_note_wait:
    mov ra, r1
    call wait
    addi r0, 2
    jmp play_note
    
; wait -- Pause the CPU for given number of ms
; ra: number of milliseconds
wait:
    divi ra, 16             ; convert from ms to frames
wait_loop:
    cmpi ra, 0
    jz wait_end
    vblnk
    subi ra, 1
    jmp wait_loop
wait_end:
    ret
end:
    vblnk
    jmp end

; Temp note buffer
note:
    dw 0
play:
    db 0x0d, 0x02
dur:
    dw 0
    ret

; Sonic Green Hill Zone melody
; _CCACBCBGACA_AEDCBCBGACE_CCACBCBGACA_AAFAGAGC
notes_sonic_ghz:
    dw REST, C5,A5, C5,B5, C5,B5, G4,A5,C5,A5
    dw REST, A5,E6,D6, C5,B5, C5,B5, G4,A5,C5,E6
    dw REST, C5,A5, C5,B5, C5,B5, G4,A5,C5,A5
    dw REST, A5,A5,F4, A5,G4, A5,G4,C4
    
    dw REST, C5,A5, C5,B5, C5,B5, G4,A5,C5,A5
    dw REST, A5,E6,D6, C5,B5, C5,B5, G4,A5,C5,E6
    dw REST, C5,A5, C5,B5, C5,B5, G4,A5,C5,A5
    dw REST, A5,A5,F4, A5,G4, A5,G4,C4
    dw REST, REST
; TLoZ:OoT Song Of Storms melody
notes_oot_sos:
    dw D3,F3,D4, D3,F3,D4, E4,F4,E4,F4, E4,C4,A4
    dw A4,D3,F3,G3, A4, A4,D3,F3,G3, E3
    dw D3,F3,D4, D3,F3,D4, E4,F4,E4,F4, E4,C4,A4
    dw A4,D3,F3,G3, A4,A4, D3,REST
    dw 0xFFFF
    
dur_sonic_ghz:
    dw d_qtr_150, d_eht_150,d_qtr_150, d_eht_150,d_qtr_150, d_eht_150,d_qtr_150, d_sxt_150,d_sxt_150,d_eht_150,d_eht_150
    dw d_qtr_150, d_eht_150,d_eht_150,d_qtr_150, d_eht_150,d_qtr_150, d_eht_150,d_qtr_150, d_sxt_150,d_sxt_150,d_eht_150,d_eht_150
    dw d_qtr_150, d_eht_150,d_qtr_150, d_eht_150,d_qtr_150, d_eht_150,d_qtr_150, d_sxt_150,d_sxt_150,d_eht_150,d_eht_150
    dw d_qtr_150, d_eht_150,d_eht_150,d_qtr_150, d_eht_150,d_qtr_150, d_eht_150,d_qtr_150,d_qtr_150
    
    dw d_qtr_150, d_eht_150,d_qtr_150, d_eht_150,d_qtr_150, d_eht_150,d_qtr_150, d_sxt_150,d_sxt_150,d_eht_150,d_eht_150
    dw d_qtr_150, d_eht_150,d_eht_150,d_qtr_150, d_eht_150,d_qtr_150, d_eht_150,d_qtr_150, d_sxt_150,d_sxt_150,d_eht_150,d_eht_150
    dw d_qtr_150, d_eht_150,d_qtr_150, d_eht_150,d_qtr_150, d_eht_150,d_qtr_150, d_sxt_150,d_sxt_150,d_eht_150,d_eht_150
    dw d_qtr_150, d_eht_150,d_eht_150,d_qtr_150, d_eht_150,d_qtr_150, d_eht_150,d_qtr_150,d_qtr_150
    dw d_qtr_150, d_qtr_150
    
dur_oot_sos:
    dw d_eht_150,d_eht_150,d_hlf_150, d_eht_150,d_eht_150,d_hlf_150, d_3eht_150,d_eht_150,d_eht_150,d_eht_150, d_eht_150,d_eht_150,d_hlf_150
    dw d_qtr_150,d_qtr_150,d_eht_150,d_eht_150, d_3qtr_150, d_qtr_150,d_qtr_150,d_eht_150,d_eht_150, d_3qtr_150
    dw d_eht_150,d_eht_150,d_hlf_150, d_eht_150,d_eht_150,d_hlf_150, d_3eht_150,d_eht_150,d_eht_150,d_eht_150, d_eht_150,d_eht_150,d_hlf_150
    dw d_qtr_150,d_qtr_150,d_eht_150,d_eht_150, d_hlf_150,d_qtr_150, d_hlf_150,d_qtr_150
