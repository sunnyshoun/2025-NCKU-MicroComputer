; ===============================================
; ws2812_driver.asm
; WS2812 8x8 LED 驅動程式（ASM 部分）
; 提供底層函式給 C 語言呼叫
; XC8 編譯器版本
; ===============================================

#include <xc.inc>

; ===============================================
; 匯出函式（供 C 語言呼叫）
; ===============================================
    GLOBAL _WS2812_Init
    GLOBAL _WS2812_SendBuffer
    GLOBAL _WS2812_Reset

; ===============================================
; 外部變數（來自 C 語言）
; ===============================================
    EXTERN _led_buffer      ; unsigned char led_buffer[64]

; ===============================================
; 常數定義
; ===============================================
RED_VALUE   EQU 50
NUM_LEDS    EQU 64

; ===============================================
; 本地變數（使用 Access Bank）
; ===============================================
PSECT udata_acs
color_g:     DS 1
color_r:     DS 1
color_b:     DS 1
bit_count:   DS 1
byte_count:  DS 1
temp:        DS 1
delay_count: DS 1

; ===============================================
; 程式碼區段
; ===============================================
PSECT code

; ===============================================
; WS2812_Init - 初始化 I/O
; void WS2812_Init(void);
; ===============================================
_WS2812_Init:
    bcf TRISB, 0, BANKED    ; RB0 設為輸出
    bcf LATB, 0, BANKED     ; 輸出低電平
    return

; ===============================================
; WS2812_SendBuffer - 發送緩衝區到 WS2812
; void WS2812_SendBuffer(void);
; 
; 從 led_buffer[64] 讀取資料並發送
; 0 = 黑色, 非0 = 紅色 (亮度 50)
; ===============================================
_WS2812_SendBuffer:
    ; 設置 FSR0 指向 led_buffer
    lfsr 0, _led_buffer
    
    ; 發送 64 個 LED
    movlw NUM_LEDS
    movwf byte_count, ACCESS
    
SendBuffer_Loop:
    ; 讀取像素值
    movf POSTINC0, W, ACCESS
    
    ; 判斷顏色
    xorlw 0x00
    bz SendBuffer_Black
    
SendBuffer_Red:
    ; 發送紅色 (G=0, R=50, B=0)
    clrf color_g, ACCESS
    movlw RED_VALUE
    movwf color_r, ACCESS
    clrf color_b, ACCESS
    call Send_LED_Color
    bra SendBuffer_Next
    
SendBuffer_Black:
    ; 發送黑色 (G=0, R=0, B=0)
    clrf color_g, ACCESS
    clrf color_r, ACCESS
    clrf color_b, ACCESS
    call Send_LED_Color
    
SendBuffer_Next:
    decfsz byte_count, F, ACCESS
    bra SendBuffer_Loop
    
    ; 發送 Reset 訊號
    call _WS2812_Reset
    return

; ===============================================
; Send_LED_Color - 發送單一 LED 的顏色
; 內部函式：發送 24 bits (G8R8B8)
; ===============================================
Send_LED_Color:
    ; 發送綠色
    movf color_g, W, ACCESS
    call Send_Byte
    
    ; 發送紅色
    movf color_r, W, ACCESS
    call Send_Byte
    
    ; 發送藍色
    movf color_b, W, ACCESS
    call Send_Byte
    
    return

; ===============================================
; Send_Byte - 發送一個位元組 (8 bits)
; 輸入：W = 要發送的位元組
; ===============================================
Send_Byte:
    movwf temp, ACCESS
    movlw 8
    movwf bit_count, ACCESS
    
SendByte_Loop:
    btfsc temp, 7, ACCESS   ; 測試最高位元
    bra Send_1
    bra Send_0

Send_1:
    ; 發送 '1': 高電平 0.8μs (8 cycles), 低電平 0.45μs (4.5 cycles)
    ; 40MHz: 1 cycle = 0.1μs
    bsf LATB, 0, BANKED     ; 1 cycle
    nop                     ; 1 cycle
    nop                     ; 1 cycle
    nop                     ; 1 cycle
    nop                     ; 1 cycle
    nop                     ; 1 cycle
    nop                     ; 1 cycle
    bcf LATB, 0, BANKED     ; 1 cycle (total: 8 cycles = 0.8μs)
    nop                     ; 1 cycle
    nop                     ; 1 cycle
    nop                     ; 1 cycle
    bra SendByte_Next       ; 2 cycles (total: ~4.5 cycles = 0.45μs)

Send_0:
    ; 發送 '0': 高電平 0.4μs (4 cycles), 低電平 0.85μs (8.5 cycles)
    bsf LATB, 0, BANKED     ; 1 cycle
    nop                     ; 1 cycle
    nop                     ; 1 cycle
    bcf LATB, 0, BANKED     ; 1 cycle (total: 4 cycles = 0.4μs)
    nop                     ; 1 cycle
    nop                     ; 1 cycle
    nop                     ; 1 cycle
    nop                     ; 1 cycle
    nop                     ; 1 cycle
    nop                     ; 1 cycle
    nop                     ; 1 cycle
    nop                     ; 1 cycle (total: 8 cycles = 0.8μs)

SendByte_Next:
    rlncf temp, F, ACCESS   ; 左移準備下一位元
    decfsz bit_count, F, ACCESS
    bra SendByte_Loop
    
    return

; ===============================================
; WS2812_Reset - 發送 Reset 訊號
; void WS2812_Reset(void);
; 
; 低電平持續 > 50μs
; ===============================================
_WS2812_Reset:
    bcf LATB, 0, BANKED     ; 設為低電平
    
    ; 延遲約 80μs (200 個指令週期 @ 40MHz = 20μs)
    ; 我們多跑幾次確保 > 50μs
    movlw 4                 ; 跑 4 次 = 80μs
    movwf temp, ACCESS
    
Reset_Loop:
    movlw 200
    movwf delay_count, ACCESS
Reset_Inner:
    nop
    nop
    decfsz delay_count, F, ACCESS
    bra Reset_Inner
    
    decfsz temp, F, ACCESS
    bra Reset_Loop
    
    return

    END