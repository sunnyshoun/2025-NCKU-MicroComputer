#include <xc.h>
#include <pic18f4520.h>

#pragma config OSC = INTIO67
#pragma config PWRT = OFF
#pragma config BOREN = ON
#pragma config WDT = OFF
#pragma config PBADEN = OFF
#pragma config LVP = OFF
#pragma config CPD = OFF

int prev_val = 0;

void __interrupt(high_priority) H_ISR() {
    
    // 讀取 ADC 數值 (0-255) 並映射到 0-15
    int value = ADRESH;
    int current_val = value / 16; 
    if(current_val > 15) current_val = 15;
    
    if (value - prev_val > 3) { // 電壓上升
        if (current_val % 2 == 0) {
            LATD = (LATD & 0x0F) | (current_val << 4);
        }
        prev_val = value;
    } 
    else if (prev_val - value > 3) { // 電壓下降
        if (current_val % 2 != 0) {
            LATD = (LATD & 0x0F) | (current_val << 4);
        }
        prev_val = value;
    }

    PIR1bits.ADIF = 0;
    ADCON0bits.GO = 1;
    
    return;
}

void main(void) 
{
    // 系統與腳位設定
    OSCCONbits.IRCF = 0b100; // 1MHz
    TRISAbits.RA0 = 1;       // RA0 Input
    TRISD = 0x0F;            // RD7-RD4 Output (LED)
    
    // ADC 設定
    ADCON1bits.VCFG0 = 0;    // Vref+ = 5V
    ADCON1bits.VCFG1 = 0;    // Vref- = GND
    ADCON1bits.PCFG = 0b1110;// AN0 Analog
    ADCON0bits.CHS = 0b0000; // AN0 Channel
    
    ADCON2bits.ADCS = 0b000; // Fosc/2
    ADCON2bits.ACQT = 0b001; // 2 Tad
    ADCON2bits.ADFM = 0;     // Left Justified
    ADCON0bits.ADON = 1;     // Enable ADC
    
    // 中斷設定
    PIE1bits.ADIE = 1;
    PIR1bits.ADIF = 0;
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;

    // 啟動轉換
    ADCON0bits.GO = 1;
    
    while(1);
    return;
}