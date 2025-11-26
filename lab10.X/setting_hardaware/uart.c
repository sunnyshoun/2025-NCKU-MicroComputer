#include <xc.h>
//setting TX/RX

char mystring[20];
int lenStr = 0;

void UART_Initialize() {
           
    /* TODObasic   
           Serial Setting      
        1.   Setting Baud rate
        2.   choose sync/async mode 
        3.   enable Serial port (configures RX/DT and TX/CK pins as serial port pins)
        3.5  enable Tx, Rx Interrupt(optional)
        4.   Enable Tx & RX
    */
           
    TRISCbits.TRISC6 = 0; // RC6 為 TX 輸出
    TRISCbits.TRISC7 = 1; // RC7 為 RX 輸入
    
    //  Setting baud rate
    //  Fosc = 4MHz (根據 setting.c 設定), Desired Baud = 9600
    //  Formula (BRGH=1): Baud = Fosc / (16 * (SPBRG + 1))
    //  9600 = 4000000 / (16 * (25 + 1))
    TXSTAbits.SYNC = 0;      // 非同步模式     
    BAUDCONbits.BRG16 = 0;   // 8-bit 生成器       
    TXSTAbits.BRGH = 1;      // 高速鮑率
    SPBRG = 25;              // 設定數值 25
    
   //   Serial enable
    RCSTAbits.SPEN = 1;      // 啟用序列埠 (Serial Port Enable)        
    PIR1bits.TXIF = 0;
    PIR1bits.RCIF = 0;
    TXSTAbits.TXEN = 1;      // 啟用發送 (Transmit Enable)     
    RCSTAbits.CREN = 1;      // 啟用接收 (Continuous Receive Enable)       
    PIE1bits.TXIE = 0;       // 通常不需啟用 TX 中斷，除非用 Buffer
    IPR1bits.TXIP = 0;             
    PIE1bits.RCIE = 1;       // 啟用接收中斷       
    IPR1bits.RCIP = 0;       // 設定為低優先級 (配合 interrupt_manager)
}

void UART_Write(unsigned char data)  // Output on Terminal
{
    while(!TXSTAbits.TRMT);
    TXREG = data;              //write to TXREG will send data 
}


void UART_Write_Text(char* text) { // Output on Terminal, limit:10 chars
    for(int i=0;text[i]!='\0';i++)
        UART_Write(text[i]);
}

void ClearBuffer(){
    for(int i = 0; i < 20 ; i++)
        mystring[i] = '\0';
    lenStr = 0;
}

void MyusartRead()
{
    /* TODObasic: try to use UART_Write to finish this function */
    char data = RCREG; // 從暫存器讀取資料
    
    // 將讀到的資料存入 mystring
    if(lenStr < 19) {
        mystring[lenStr] = data;
        lenStr++;
        mystring[lenStr] = '\0'; // 補上字串結束符號
    }
    
    // 選用：將輸入的字元回傳顯示在 Terminal 上 (Echo)，方便使用者看到自己打了什麼
    UART_Write(data);
    
    return ;
}

char *GetString(){
    return mystring;
}


// void interrupt low_priority Lo_ISR(void)
void __interrupt(low_priority)  Lo_ISR(void)
{
    if(RCIF)
    {
        if(RCSTAbits.OERR)
        {
            CREN = 0;
            Nop();
            CREN = 1;
        }
        
        MyusartRead();
    }
    
   // process other interrupt sources here, if required
    return;
}