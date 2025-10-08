List p=18f4520
    #include<p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00

    setup:
        MOVLW 0xFE
        MOVWF 0x00

        MOVLW 0xFC
        MOVWF 0x01

        CLRF 0x02
    main:
        MOVLW 0x08
        MOVWF 0x03

        loop:
            MOVLW 0x01
            ANDWF 0x01, W
            TSTFSZ WREG
                GOTO add
            GOTO skip
            add:
                MOVF 0x00, W
                ADDWF 0x02, W
                MOVWF 0x02
            skip:
                RLNCF 0x00
                MOVLW b'11111110'
                ANDWF 0x00

                RRNCF 0x01
                MOVLW b'01111111'
                ANDWF 0x01

                DECF 0x03
                TSTFSZ 0x03
                    GOTO loop
    end