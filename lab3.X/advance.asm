List p=18f4520
    #include<p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00

    setup:
        ;a (16 bit)
        MOVLW 0x9A
        MOVWF 0x00
        MOVLW 0xBC
        MOVWF 0x01

        ;b (16 bit)
        MOVLW 0x12
        MOVWF 0x10
        MOVLW 0x34
        MOVWF 0x11

    main:
        MOVF 0x11, W
        SUBWF 0x01, W
        MOVWF 0x21

        MOVLW 0x01
        ANDWF STATUS, W
        MOVWF 0x03
        
        MOVF 0x10, W
        TSTFSZ 0x03
            GOTO step2
        INCF WREG, W
        step2:
            SUBWF 0x00, W
            MOVWF 0x20
    end