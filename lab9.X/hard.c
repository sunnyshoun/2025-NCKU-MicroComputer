#include <xc.h>
#include <pic18f4520.h>

#pragma config OSC = INTIO67
#pragma config PWRT = OFF
#pragma config BOREN = ON
#pragma config WDT = OFF
#pragma config PBADEN = OFF
#pragma config LVP = OFF
#pragma config CPD = OFF

void __interrupt(high_priority) H_ISR() {
    
    // 讀取 ADC 結果 (10-bit)
    int adc_val = (ADRESH << 8) + ADRESL;
    
    // 設定 PWM Duty Cycle
    // CCPR1L 存高 8 位，CCP1CON<5:4> 存低 2 位
    CCPR1L = adc_val >> 2;        // 取高 8 位
    CCP1CONbits.DC1B = adc_val & 0x03; // 取低 2 位
    
    PIR1bits.ADIF = 0;
    ADCON0bits.GO = 1;
    
    return;
}

void main(void) 
{
    OSCCONbits.IRCF = 0b100; // 1MHz
    TRISAbits.RA0 = 1;       // RA0 為 ADC 輸入
    TRISCbits.RC2 = 0;       // RC2 為 PWM 輸出 (CCP1)
    
    // ADC 設定
    ADCON1bits.VCFG0 = 0;    // Vref+ = 5V
    ADCON1bits.VCFG1 = 0;    // Vref- = GND
    ADCON1bits.PCFG = 0b1110;// AN0 為類比，其他數位
    ADCON0bits.CHS = 0b0000; // Channel 0
    
    ADCON2bits.ADCS = 0b000; // Fosc/2 (Tad = 2us > 0.7us) [cite: 22]
    ADCON2bits.ACQT = 0b001; // 2 Tad (4us > 2.4us) [cite: 23]
    ADCON2bits.ADFM = 1;     // Right Justified (為了得到 0-1023 的精確值)
    ADCON0bits.ADON = 1;     // 開啟 ADC
    
    // --- PWM 設定 (Lab 8) --- [cite: 22]
    // 設定 Timer2 週期 (決定 PWM 頻率)
    // PR2 = 255, Fosc = 1MHz, Prescaler = 4
    // F_PWM = 1M / (4 * 4 * 256) = 244 Hz
    PR2 = 0xFF;
    
    // 設定 CCP1 模組為 PWM 模式
    CCP1CONbits.CCP1M = 0b1100; 
    
    // 設定 Timer2 Prescaler 並開啟
    T2CONbits.T2CKPS = 0b01; // Prescaler = 4
    T2CONbits.TMR2ON = 1;    // 開啟 Timer2

    // --- 中斷設定 ---
    PIE1bits.ADIE = 1;       // 開啟 ADC 中斷
    PIR1bits.ADIF = 0;
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;

    // 啟動第一次轉換
    ADCON0bits.GO = 1;
    
    while(1);
    return;
}