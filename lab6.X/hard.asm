LIST p=18f4520
#include<p18f4520.inc>

    CONFIG OSC = INTIO67 ; Set internal oscillator to 1 MHz
    CONFIG WDT = OFF     ; Disable Watchdog Timer
    CONFIG LVP = OFF     ; Disable Low Voltage Programming

    L1 EQU 0x14         ; Define L1 memory location
    L2 EQU 0x15         ; Define L2 memory location
    org 0x00            ; Set program start address to 0x00

; instruction frequency = 1 MHz / 4 = 0.25 MHz
; instruction time = 1/0.25 = 4 ?s
; Total_cycles = 2 + (2 + 8 * num1 + 3) * num2 cycles
; num1 = 111, num2 = 70, Total_cycles = 62512 cycles
; Total_delay ~= Total_cycles * instruction time = 0.25 s
DELAY macro num1, num2
    local LOOP1         ; Inner loop
    local LOOP2         ; Outer loop
    
    ; 2 cycles
    MOVLW num2          ; Load num2 into WREG
    MOVWF L2            ; Store WREG value into L2
    
    ; Total_cycles for LOOP2 = 2 cycles
    LOOP2:
    MOVLW num1          
    MOVWF L1  
    
    ; Total_cycles for LOOP1 = 8 cycles
    LOOP1:
    NOP                 ; busy waiting
    NOP
    NOP
    NOP
    NOP
    DECFSZ L1, 1        
    BRA LOOP1           ; BRA instruction spends 2 cycles
    
    ; 3 cycles
    DECFSZ L2, 1        ; Decrement L2, skip if zero
    BRA LOOP2           
endm

setup:
    MOVLW   0x0f            ; Set ADCON1 register for digital mode
    MOVWF   ADCON1          ; Store WREG value into ADCON1 register
    CLRF    PORTB           ; Clear PORTB
    BSF     TRISB, 0        ; Set RB0 as input (TRISB = 0000 0001)
    CLRF    LATA            ; Initialize LATA to 0x00 (turn off all LEDs)
    CLRF    TRISA           ; Set PORTA as output (TRISA = 0000 0000)
    CLRF    0x00            ; button_state
    CLRF    0x01            ; 0.1s counter
    MOVLW   0x01
    MOVWF   0x02            ; current_state
    CLRF    0x03            ; led_cycle_state

loop:
    DELAY   d'60', d'70'
    TSTFSZ  0x00   
        BRA     check_release
    BTFSC   PORTB, 0        ; Check if PORTB bit 0 is low (button pressed)
        BRA     state_cycle     ; If button is not pressed, branch back to state_cycle
    MOVLW   0x01
    MOVWF   0x00
    BRA     state_cycle
    check_release:
        BTFSS   PORTB, 0        ; Check if PORTB bit 0 is high (button released)
        RCALL   state_cycle
        RCALL   button_release
    state_cycle:
        BTFSC   0x02, 0
            RCALL   state_0
        BTFSC   0x02, 1
            RCALL   state_1
        BTFSC   0x02, 2
            RCALL   state_2
        INCF    0x01
        BRA     loop

button_release:
    CLRF    0x00
    change_state:
        CLRF    0x01
        MOVLW   0x01
        MOVWF   0x03
        RLNCF   0x02
        MOVF    0x02, W
        SUBLW   0x08
        TSTFSZ  WREG
        RETURN  
        MOVLW   0x01
        MOVWF   0x02
        RETURN  

state_0:
    CLRF    LATA
    BRA     loop
    RETURN  

state_1:
    BTFSC   0x03, 0
        BRA     state_1_0
    BTFSC   0x03, 1
        BRA     state_1_1
    BTFSC   0x03, 2
        BRA     state_1_2
    BTFSC   0x03, 3
        BRA     state_1_3
    state_1_0:
        RLNCF   0x03
        MOVLW   0x01
        MOVWF   LATA
        RETURN
    state_1_1:
        MOVF    0x01, W
        SUBLW   0x05
        TSTFSZ  WREG
            RETURN
        RLNCF   0x03
        RLNCF   LATA
        RETURN
    state_1_2:
        MOVF    0x01, W
        SUBLW   0x0A
        TSTFSZ  WREG
            RETURN
        RLNCF   0x03
        RLNCF   LATA
        RETURN
    state_1_3:
        MOVF    0x01, W
        SUBLW   0x0F
        TSTFSZ  WREG
            RETURN
        MOVLW   0x01
        MOVWF   0x03
        CLRF    0x01
        MOVLW   0x01
        MOVWF   LATA
        RETURN

state_2:
    BTFSC   0x03, 0
        BRA     state_2_0
    BTFSC   0x03, 1
        BRA     state_2_1
    BTFSC   0x03, 2
        BRA     state_2_2
    BTFSC   0x03, 3
        BRA     state_2_3
    BTFSC   0x03, 4
        BRA     state_2_4
    BTFSC   0x03, 5
        BRA     state_2_5
    BTFSC   0x03, 6
        BRA     state_2_6
    BTFSC   0x03, 7
        BRA     state_2_7
    state_2_0:
        RLNCF   0x03
        MOVLW   0x01
        MOVWF   LATA
        RETURN
    state_2_1:
        MOVF    0x01, W
        SUBLW   d'10'
        TSTFSZ  WREG
            RETURN
        RLNCF   0x03
        RLNCF   LATA
        INCF    LATA
        RETURN
    state_2_2:
        MOVF    0x01, W
        SUBLW   d'20'
        TSTFSZ  WREG
            RETURN
        RLNCF   0x03
        MOVLW   0x04
        MOVWF   LATA
        RETURN
    state_2_3:
        MOVF    0x01, W
        SUBLW   d'25'
        TSTFSZ  WREG
            RETURN
        RLNCF   0x03
        CLRF    LATA
        RETURN
    state_2_4:
        MOVF    0x01, W
        SUBLW   d'35'
        TSTFSZ  WREG
            RETURN
        RLNCF   0x03
        MOVLW   0x04
        MOVWF   LATA
        RETURN
    state_2_5:
        MOVF    0x01, W
        SUBLW   d'40'
        TSTFSZ  WREG
            RETURN
        RLNCF   0x03
        CLRF    LATA
        RETURN
    state_2_6:
        MOVF    0x01, W
        SUBLW   d'50'
        TSTFSZ  WREG
            RETURN
        RLNCF   0x03
        MOVLW   0x04
        MOVWF   LATA
        RETURN
    state_2_7:
        MOVF    0x01, W
        SUBLW   d'55'
        TSTFSZ  WREG
            RETURN
        MOVLW   0x01
        MOVWF   0x03
        CLRF    0x01
        MOVLW   0x01
        MOVWF   LATA
        RETURN
end
