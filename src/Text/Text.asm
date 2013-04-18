; Example text-displaying program for chip16
; Hold A to display text

; You may reuse this code, credit preferred.
; (C) tykel, 2011

;-------------------------------------------------------------------------------
; Preprocessor
;-------------------------------------------------------------------------------
importbin font.bin 0 3072 spr_font          ; Import our bitmap font

CHAR_MASK       equ 0x00FF                  ; Keep lo-byte
CHAR_SPR_SIZE   equ 0x0804                  ; Chars are 8*8 px
CHAR_SPR_WIDTH  equ 8                       ; Char width
CHAR_ASCII_OFFS equ 0x20                    ; Ignore first 32 ASCII codes
CHAR_SPR_LEN    equ 32                      ; Char sprites are 32 B long
SCR_WIDTH       equ 320                     ; Screen width in pixels, avoid overrun
SCR_HEIGHT      equ 240                     ; Screen height in pixels, same
PAD1_IO         equ 0xFFF0                  ; Memory address of Pad 1 input port
PAD_ABTN        equ 0x40                    ; A-button mask
MAX_STR_IND     equ 3                       ; Index of last string

;-------------------------------------------------------------------------------
; Code 
;-------------------------------------------------------------------------------
; Program entry point
_start:         
                call store_ptrs
                bgc 0x0                     ; Black bg
                ldi rb, 0                   ; X = 0
                ldi rc, 0                   ; Y = 0
print_str:      
                rnd ra, MAX_STR_IND         ; Get a random string
                muli ra, 2                  ; Each address is 2 B
                addi ra, strptrs            ; Add offset to the ptrs
                ldm ra, ra                  ; Dereference to our string
                call text_disp              ; Print it!
                ldi rb, 0                   ; Set cursor back to left
                addi rc, 8                  ; New line!
                cmpi rc, SCR_HEIGHT         ; If bottom of screen is reached...
                jl get_input                ; If y >= 240...
                ldi rc, 0                   ; ...go back to the top...
                cls                         ; ...and clear the screen too
get_input:      
                ldi ra, 15                  ; 15 VBLNKs = 0.25s
                call pause_prog             ; Wait 0.25s
                ldm r0, PAD1_IO             ; Get Pad 1 status
                andi r0, PAD_ABTN           ; If A is pressed...
                jz get_input                
                jmp print_str               ; ...print again

; Text displaying routine
; [RA:         Char ptr]
; [RB, C:     X, Y]
text_disp:
                spr CHAR_SPR_SIZE           ; Set sprite size
                push r0                     ; Preserve R0
text_disp_loop: 
                ldm r0, ra                  ; Load 2 bytes from memory
                andi r0, CHAR_MASK          ; Isolate lo-byte                
                jz text_disp_end            ; '\0' terminator, exit
                subi r0, CHAR_ASCII_OFFS    ; Remove ASCII offset
                jc text_disp_next           ; Skip unprintable chars
                muli r0, CHAR_SPR_LEN       ; Multiply by indiv. size
                addi r0, spr_font           ; Add sprite addr.
                drw rb, rc, r0              ; Output to screen
text_disp_next:
                addi rb, CHAR_SPR_WIDTH     ; Move X coordinate along
                cmpi rb, SCR_WIDTH            
                jl text_disp_itp            ; If x >= 320...
                ldi rb, 0                   ; ...wrap back to 0...
                addi rc, 8                  ; ...and go to new line
text_disp_itp: 
                addi ra, 1                  ; Increment text pointer
                jmp text_disp_loop          ; Repeat...
text_disp_end:
                pop r0                      ; Restore R0
                ret

; Pauses the program
; [RA:    number of VBLNKs to wait]
pause_prog:
                cmpi ra, 0                  ; Check number of VBLNKs left
                jle pause_prog_end          ; If 0, exit
                vblnk                       ; Pause for 16 ms
                subi ra, 1                  ; Decrement counter
                jmp pause_prog              ; Repeat...
pause_prog_end:
                ret    

; Saves the string pointers in storage area                
store_ptrs:
                push r0                     ; Save R0, R1
                push r1
                ldi r0, strptrs             ; Load first string ptr address
                ldi r1, string1             ; Load first string address
                stm r1, r0                  ; Store it in ptr
                addi r0, 2                  ; Next ptr, and repeat...
                ldi r1, string2
                stm r1, r0
                addi r0, 2
                ldi r1, string3
                stm r1, r0
                addi r0, 2
                ldi r1, string4
                stm r1, r0
                pop r1                      ; Restore R1, R0
                pop r0
                ret

;-------------------------------------------------------------------------------
; Data
;-------------------------------------------------------------------------------
; Our test strings
string1:    
                db "Hello, this is a string printing test. Text should wrap..."
                db 0
string2:   
                db "So, here is another string... Making these long so they wrap!"
                db 0
string3:   
                db "Can you guess what font this is? It's from an 80's computer..."
                db 0
string4:
                db "It's the eeey-eeey-eeeey-eeey-eeeey-eeye... of the tiger"
                db 0
; Pointers to these strings
strptrs:
            db 0x00, 0x00
            db 0x00, 0x00
            db 0x00, 0x00
            db 0x00, 0x00

