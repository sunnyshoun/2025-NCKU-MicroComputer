List p=18f4520
    #include<p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
    setup:
        MOVLW 0xA6
        MOVWF 0x00
        MOVLW 0x01
        MOVWF 0x01
        CLRF TRISA
    main:
        MOVF 0x00, W
        ANDWF 0x01, W
        ADDWF TRISA, 1
        RRNCF 0x00
        RLNCF TRISA
        MOVF 0x00, W
        ANDWF 0x01, W
        ADDWF TRISA, 1
        RRNCF 0x00
        RLNCF TRISA
        MOVF 0x00, W
        ANDWF 0x01, W
        ADDWF TRISA, 1
        RRNCF 0x00
        RLNCF TRISA
        MOVF 0x00, W
        ANDWF 0x01, W
        ADDWF TRISA, 1
        RRNCF 0x00
        RLNCF TRISA
        MOVF 0x00, W
        ANDWF 0x01, W
        ADDWF TRISA, 1
        RRNCF 0x00
        RLNCF TRISA
        MOVF 0x00, W
        ANDWF 0x01, W
        ADDWF TRISA, 1
        RRNCF 0x00
        RLNCF TRISA
        MOVF 0x00, W
        ANDWF 0x01, W
        ADDWF TRISA, 1
        RRNCF 0x00
        RLNCF TRISA
        MOVF 0x00, W
        ANDWF 0x01, W
        ADDWF TRISA, 1
    end