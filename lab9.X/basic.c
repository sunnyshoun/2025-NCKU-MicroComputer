#include <xc.h>
#include <pic18f4520.h>

#pragma config OSC = INTIO67
#pragma config PWRT = OFF
#pragma config BOREN = ON
#pragma config WDT = OFF
#pragma config PBADEN = OFF
#pragma config LVP = OFF
#pragma config CPD = OFF

int date[8] = {2, 0, 2, 5, 1, 1, 2, 0};

void __interrupt(high_priority) H_ISR() {
    
    // 讀取 ADC 高 8 位 (範圍 0-255)
    int value = ADRESH;
    
    // 0-255 分成 8 等份
    int index = value / 32;
    if(index > 7) index = 7;
    
    // 輸出至 LED (RD7~RD4)
    LATD = (LATD & 0x0F) | (date[index] << 4);
    
    PIR1bits.ADIF = 0;
    ADCON0bits.GO = 1;
    
    return;
}

void main(void) 
{
    OSCCONbits.IRCF = 0b100; // 1MHz
    TRISAbits.RA0 = 1;       // RA0 輸入
    TRISD = 0x0F;            // RD7~RD4 輸出
    
    // ADC 設定
    ADCON1bits.VCFG0 = 0;    // Vref+ = 5V
    ADCON1bits.VCFG1 = 0;    // Vref- = GND
    ADCON1bits.PCFG = 0b1110;// AN0 類比，其餘數位
    ADCON0bits.CHS = 0b0000; // 通道 AN0
    
    ADCON2bits.ADCS = 0b000; // Fosc/2
    ADCON2bits.ACQT = 0b001; // 2 Tad
    ADCON2bits.ADFM = 0;     // Left Justified (方便讀取 ADRESH)
    ADCON0bits.ADON = 1;     // 開啟模組
    
    // 中斷設定
    PIE1bits.ADIE = 1;
    PIR1bits.ADIF = 0;
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;

    ADCON0bits.GO = 1;
    
    while(1);
    
    return;
}