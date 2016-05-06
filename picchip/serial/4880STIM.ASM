;*******************************************************************
;                            4880stim.ASM
;                    Novalink diagnostics package
;*******************************************************************
;
;
;
;*******************************************************************

                LIST    p=16C84 ;PIC16C84 is the target processor


;CONSTANTS, RS-232, NLINK

_ckspd          equ     D'4000000'              ;crystal freq.


_baud           equ     D'9600'                 ;baudrate.
_insBit         equ     (_ckspd/4/_baud)        ;PIC inst/bit time e.g. 0x68 
                                                ;or 104 @ 9.6/4M

_fClock         equ     d'35000'                ;35KHz is our test frequency
_insClock       equ     (_ckspd/4/_fClock)      ;Novalink inst/clock.


_dFactr         equ     3                       ;Delay routine timing.


endOfMsg        equ     0x0D    ;[CR] = end of message. (in and out both!)


theRVector      equ     0x0000  ;This location will contain reset vector.
theProgram      equ     0x0005  ;This is where code/data starts.



        ;DELAY CALCULATIONS. ALL MUST EVALUATE TO >= 3!!!!
        ;(you can find the eval. values by looking at the *.lst file)

        ;RECIEVE UART CODE DELAY CALCULATIONS. ADJUST IF CODE CHANGES ONLY.
        ;These delays _must_ be accurate +/- 3 inst/bit @ 9600/4MHz, 
        ;errors will acumulate over the reception of a byte

rDelay1         equ     (((_insBit/2) -6)/_dFactr)  
        ;almost 1/2 bit delay..
        ;delay to center of start bit.

rDelay2         equ     ((_insBit -6)/_dFactr)
        ;almost 1 bit delay
        ;bit to bit delay

        ;SEND UART CODE DELAY CALCULATIONS. ADJUST IF CODE CHANGES ONLY.
        ;The first 2 delays can have errors of +/- 3 inst. cum. @9600/4MHz.
        ;The third is a minimum value, non critical. (stop bit)

sDelay1         equ     ((_insBit -7)/_dFactr) 
        ;Time from enable xmitter to 1st bit test


sDelay2         equ     ((_insBit -8)/_dFactr)
        ;bit-to-bit delay


sDelay3         equ     ((_insBit -8)/_dFactr)
        ;non critical delay, for stop bit, but must come out to >1.0 bittime.



        ;FILE REGISTER NAMES


count1          equ     0x0C    ;general purpose
count2          equ     0x0D    ;general purpose
count3          equ     0x0E    ;general purpose

uartReg         equ     0x0F    ;our soft UART.
lsb             equ     0x00    ;output from lsb

AscMSB          equ     0x10    ;ascii MSB, in and out.
AscLSB          equ     0x11    ;ascii LSB, in and out.
packByte        equ     0x12    ;ascii -> byte in, byte -> ascii out.

pack1           equ     0x14    ;inBuffSt,   inBuffSt+1 in packed BCD
pack2           equ     0x15    ;inBuffSt+2, inBuffSt+3 in packed BCD
pack3           equ     0x16    ;inBuffSt+4, inBuffSt+5 in packed BCD

intW            equ     0x17    ;storage for interrupt routine.
intS            equ     0x18

nlBuffSt        equ     0x19    ;input buffer for data from novalink port.

intUReg         equ     0x29    ;temp storage for uartReg during int.

inBuffSt        equ     0x2A    ;First input character goes here.
inBuffEnd       equ     0x2F    ;2F is end, 30 always reads as 0x00


        ; Hardware special regs.

PORTA           equ     0x05    ;I/O port A
PORTB           equ     0x06    ;I/O port B

#DEFINE inbit   PORTA,0x02    ;serial input
#DEFINE outbit  PORTA,0x01    ;serial output
#DEFINE cts     PORTA,0x00    ;clear to send (from PC) output
#DEFINE inlink  PORTA,0x03    ;novalink data from PI

#DEFINE outlink PORTB,0x01    ;novalink data TO PI
#DEFINE clock   PORTB,0x02    ;novalink clock
#DEFINE strobe  PORTB,0x03    ;novalink strobe


IND0            equ     0x00    ;Indirect file register
TMR0            equ     0x01    ;Timer/counter register
PCL             equ     0x02    ;Program Counter
STATUS          equ     0x03    ;Status register
FSR             equ     0x04    ;File Select Register
INITCON         equ     0x0B    ;Interrupt control 

        ;Status register bits of interest.

RP0             equ     0x05    ;Selects hi RAM page.
Z               equ     0x02    ;Zero result?
C               equ     0x00    ;Carry bit.

        ;Initcon bits of interest.

GIE             equ     0x07    ;Global Int Enable

        ;Result of some operations goes either to 'w' or 'f'

w               equ     0x00    
f               equ     0x01

        ;The following registers are accessed after setting STATUS,RP0 to 1.
        ;recent microchip policy is to NOT use the old TRIS and OPTION commands
        ;directly, thusly, we have defined new replacement equates.
        ;(the registers are 'just another register' now).


xOPTION         equ     0x01    ;Various mode control bits
xTRISA          equ     0x05    ;Port A control register, 1 = in
xTRISB          equ     0x06    ;Port B control register, 1 = in


;start of code area...

                org     0x04    ;intterupt code here.

;***************************************************************
; INT0 Code. This is triggered by the start bit of incoming data
;***************************************************************


;save status, and w    
                movwf   intW
                movf    STATUS, w
                movwf   intS            
                movf    uartReg, w     ;save uartReg
                movwf   intUReg         

                bcf     strobe         ;kill the I/O! In the middle!

                bcf     outbit         ;send a "stop bit" of sorts. 

        ; STORE INCOMING STRING INTO RAM.. 6 chars
        ; 
        ; We have at least 40 instructions to do a character, (@9600, 4MHz) 
        ; more and a uart overrun will happen, with messy results.

;discard the buffer character. (It can't be read correctly anyway)

                call    inUart

;read in 6 characters.

storeStr        movlw   inBuffSt        ;point to beginning..
                movwf   FSR             ;of ram buffer.
                
sSLoop          call    inUart          ;get one char..
                movf    uartReg, w      ; -> w
                movwf   IND0            ; -> RAM. 
                
                incf    FSR, f          ;++pointer

                movlw   inBuffSt +6     ;check for buffer overrun!
                xorwf   FSR, w          ;set Z if overrun..
                btfsc   STATUS, Z       ;Z set?
                goto    exitInt         ;Yes, abort

                goto    sSLoop          ;nope, get more.


        ;MESSAGE STORED, FSR POINTS TO END + 1

 
;exit interrupt


exitInt         movf    intUReg, w      ;restore uartReg
                movwf   uartReg         

                movlw   B'10010000'     ;int0 reset for serial stuff.
                movwf   INITCON         
                
                movf    intS, w         ;restore status    
                movwf   STATUS
                
                swapf   intW, f         ;swaps dont change STATUS
                swapf   intW, w         ;restore W

                retfie                  ;return



;***************************************************************
; BIN-ASCII CONVERSION LOOKUP TABLE (must reside in lower 256B)
; w = low nybble + 1 (0x01 ... 0x10)in. w= ascii out.
; note: this is a lookup, not a string.  
;***************************************************************


        ; LOOKUP: BIN (LOW NIBBLE) TO ASCII
dataB2A         addwf   PCL, f                                  ;w = nybble + 1
                data    "404142434445464748494A4B4C4D4E4F"      ;0123456789ABCDEF



;**************************************************************************
;**************************************************************************
;        ******************  MAIN CODE FOLLOWS ****************
;**************************************************************************
;**************************************************************************

start           bcf     STATUS, RP0     ;select page 0
                clrf    INITCON         ;no interrupts.           
                clrf    PORTA           ;clear ports.
                clrf    PORTB

        
        ;set up watchdog, timer, prescaler, etc.
        
                clrf    TMR0            ;clear timer
                bsf     STATUS, RP0     ;select page 1
                clrwdt                  ;Reset prescaler and wdt
                movlw   B'11001111'     ;prescale= 1:128-> wdt, wdt on, etc.
                movwf   xOPTION         ;set it.
                movlw   B'11111100'
                movwf   xTRISA          ;Port A = 2 outs.
                movlw   B'11110001'    
                movwf   xTRISB          ;Port B has 3 outputs enabled.
                bcf     STATUS, RP0     ;back to page 0 to stay.
                clrf    PORTA
                clrf    PORTB
                movlw   B'10010000'     ;int0 enabled for serial stuff.
                movwf   INITCON         

        ;preset the control bytes

                clrf    pack1
                clrf    pack2
                clrf    pack3


;***************************************************************
; MAIN LOOP. READ MESSAGE FROM PC, THEN DO A PHRASE.
; 1. Convert the 6 characters to 3 packed bytes.
; 2. Send/recieve data. recieved data is in nlBuffer
; 3. send reply to PC.
; 4. repeat.
;***************************************************************
        


getPC           clrwdt

; 1 Convert the 6 characters to 3 packed bytes.
                call    asc2Bin

                movf    inBuffSt, w     ;one ascii character..
                movwf   AscMSB
                movf    inBuffSt + 1, w ;two ascii characters..
                movwf   AscLSB         
                call    asc2Bin         ;convert it.
                movf    packByte, w     ;get the result..
                movwf   pack1           ;into the reg for xmission.

                movf    inBuffSt + 2, w ;three ascii characters..
                movwf   AscMSB
                movf    inBuffSt + 3, w ;four ascii characters..
                movwf   AscLSB         
                call    asc2Bin         ;convert it.
                movf    packByte, w     ;get the result..
                movwf   pack2           ;into the reg for xmission.
               
                movf    inBuffSt + 4, w ;five ascii characters..
                movwf   AscMSB
                movf    inBuffSt + 5, w ;six ascii characters..
                movwf   AscLSB          ;ahhh hahahaha! *crack* *boom*
                call    asc2Bin         ;convert it.
                movf    packByte, w     ;get the result..
                movwf   pack3           ;into the reg for xmission.

; 2. Send/recieve data. recieved data is in nlBuf...
; note that I am always sending (in some cases) the same data to the
; external port due to memory limitations. This *could*
; be fixed, by using the EEPROM memory and some swapping.
; big time drain however..

shiftall        bcf     clock           ;preset the clock line high.
                bsf     outlink         ;preset the data line.
                bsf     strobe          ;notify unit of pending data.

                movlw   0xD0            ;header byte
                call    shift           ;send it.

                movlw   0x00            ;unused byte
                call    shift           ;send it

                movf    pack1, w        ;misc control byte
                call    shift           ;send it

                movlw   0x00            ;unused byte
                call    shift           ;send it

                movlw   0x00            ;unused byte
                call    shift           ;send it

                movlw   0x00            ;unused byte
                call    shift           ;send it

                movf    pack2, w        ;high pumps (not used normally)
                call    shift           ;send it

                movf    pack3, w        ;low pumps
                call    shift           ;send it

                movlw   0x77            ;aux byte 1
                call    shift           ;send it

                movlw   0x01            ;aux byte 2
                call    shift           ;send it

                movlw   0x02            ;aux byte 3
                call    shift           ;send it

                movlw   0x04            ;aux byte 4
                call    shift           ;send it

                movlw   0x08            ;aux byte 5
                call    shift           ;send it

                movlw   0x00            ;aux byte 6
                call    shift           ;send it

                movlw   0xFF            ;aux byte 7
                call    shift           ;send it

                movlw   0xF0            ;aux byte 8
                call    shift           ;send it

                movlw   0x06            ;then a small delay
                call    delay           ;just cause I can.
                bcf     strobe          ;kill the strobe

        ;AT THIS POINT DATA HAS BEEN SHIFTED TO/FROM UUT (maybe)

; 3. send reply to PC.
; due to the shortage of file registers we convert on the fly - 
; this will cause a small delay between characters, but nothing
; that should cause any problems, after all we are async.
; Im not looping here cause cut and paste is faster eh?
; Don't think any less of me for doing this, eh? beauty.

                movlw   endOfMsg        ;send a [CR]
                call    outUart

                movf    nlBuffSt, w     ;get a byte
                call    bin2Asc         ;convert
                movf    AscMSB, w       ;send one
                call    outUart         
                movf    AscLSB, w       ;then the other.
                call    outUart 
                movlw   d'32'           ;print a space inbetween
                call    outUart 

                movf    nlBuffSt+0x01,w ;get a byte
                call    bin2Asc         ;convert
                movf    AscMSB, w       ;send one
                call    outUart         
                movf    AscLSB, w       ;then the other.
                call    outUart 
                movlw   d'32'           ;print a space inbetween
                call    outUart 

                movf    nlBuffSt+0x02,w ;get a byte
                call    bin2Asc         ;convert
                movf    AscMSB, w       ;send one
                call    outUart         
                movf    AscLSB, w       ;then the other.
                call    outUart 
                movlw   d'32'           ;print a space inbetween
                call    outUart 

                movf    nlBuffSt+0x03,w ;get a byte
                call    bin2Asc         ;convert
                movf    AscMSB, w       ;send one
                call    outUart         
                movf    AscLSB, w       ;then the other.
                call    outUart 
                movlw   d'32'           ;print a space inbetween
                call    outUart 

                movf    nlBuffSt+0x04,w ;get a byte
                call    bin2Asc         ;convert
                movf    AscMSB, w       ;send one
                call    outUart         
                movf    AscLSB, w       ;then the other.
                call    outUart 
                movlw   d'32'           ;print a space inbetween
                call    outUart 

                movf    nlBuffSt+0x05,w ;get a byte
                call    bin2Asc         ;convert
                movf    AscMSB, w       ;send one
                call    outUart         
                movf    AscLSB, w       ;then the other.
                call    outUart 
                movlw   d'32'           ;print a space inbetween
                call    outUart 

                movf    nlBuffSt+0x06,w ;get a byte
                call    bin2Asc         ;convert
                movf    AscMSB, w       ;send one
                call    outUart         
                movf    AscLSB, w       ;then the other.
                call    outUart 
                movlw   d'32'           ;print a space inbetween
                call    outUart 

                movf    nlBuffSt+0x07,w ;get a byte
                call    bin2Asc         ;convert
                movf    AscMSB, w       ;send one
                call    outUart         
                movf    AscLSB, w       ;then the other.
                call    outUart 
                movlw   d'32'           ;print a space inbetween
                call    outUart 

                movf    nlBuffSt+0x08,w ;get a byte
                call    bin2Asc         ;convert
                movf    AscMSB, w       ;send one
                call    outUart         
                movf    AscLSB, w       ;then the other.
                call    outUart 
                movlw   d'32'           ;print a space inbetween
                call    outUart 

                movf    nlBuffSt+0x09,w ;get a byte
                call    bin2Asc         ;convert
                movf    AscMSB, w       ;send one
                call    outUart         
                movf    AscLSB, w       ;then the other.
                call    outUart 
                movlw   d'32'           ;print a space inbetween
                call    outUart 

                movf    nlBuffSt+0x0A,w ;get a byte
                call    bin2Asc         ;convert
                movf    AscMSB, w       ;send one
                call    outUart         
                movf    AscLSB, w       ;then the other.
                call    outUart 
                movlw   d'32'           ;print a space inbetween
                call    outUart 

                movf    nlBuffSt+0x0B,w ;get a byte
                call    bin2Asc         ;convert
                movf    AscMSB, w       ;send one
                call    outUart         
                movf    AscLSB, w       ;then the other.
                call    outUart 
                movlw   d'32'           ;print a space inbetween
                call    outUart 

                movf    nlBuffSt+0x0C,w ;get a byte
                call    bin2Asc         ;convert
                movf    AscMSB, w       ;send one
                call    outUart         
                movf    AscLSB, w       ;then the other.
                call    outUart 
                movlw   d'32'           ;print a space inbetween
                call    outUart 

                movf    nlBuffSt+0x0D,w ;get a byte
                call    bin2Asc         ;convert
                movf    AscMSB, w       ;send one
                call    outUart         
                movf    AscLSB, w       ;then the other.
                call    outUart 
                movlw   d'32'           ;print a space inbetween
                call    outUart 

                movf    nlBuffSt+0x0E,w ;get a byte
                call    bin2Asc         ;convert
                movf    AscMSB, w       ;send one
                call    outUart         
                movf    AscLSB, w       ;then the other.
                call    outUart 
                movlw   d'32'           ;print a space inbetween
                call    outUart 

                movf    nlBuffSt+0x0F,w ;get a byte
                call    bin2Asc         ;convert
                movf    AscMSB, w       ;send one
                call    outUart         
                movf    AscLSB, w       ;then the other.
                call    outUart 
                movlw   endOfMsg        ;a [CR]
                call    outUart 


; 7. repeat.
; but first, a delay.

                movlw   0xff
                call    delay

                goto    getPC

;***************************************************************************
;***************************************************************************
;                       ** SUBROUTINES FOLLOW **
;***************************************************************************
;***************************************************************************


;***************************************************************
;
; shift subroutine. sends data to the device under test
; and retrieves it as well. shift the data out one byte
; at a time. MSD/MSB first. uses carry bit to move bit
; between the registers. this acts like a real shift register.
; the strobe is controlled by the caller.
;
; w contains the data to be shifted to the external device
; (one byte) we copy it to the (trashable) uartReg to operate.
;
; nlBuffSt...nlBuffEnd contain the shifting input data.
; the extra byte is there to handle any changes to the code.
;
; the 4MHz clock gives us JUST enough time. Lucky here I guess.
;
;***************************************************************

shift           movwf   uartReg         ;copy output byte to uartReg           
                movlw   0x08            ;8 bits in a byte, eh?
                movwf   count3          ;put the '8' here.


sLoop           ;output a bit.  there is 2uS jitter here.

                rlf     uartReg,f       ;put MSB first into C
                btfsc   STATUS, C       ;Is C set?
                bsf     outlink         ;send a 1.
                btfss   STATUS, C       ;Is C clear?
                bcf     outlink         ;send a 0.

                nop                     ;this should qualify as
                                        ;worst case setup time: 1uS

                ;drop the clock. (input bit should be here now!)

                
                bsf     clock           ;sample edge

                ;sample the bit on the input.

                bsf     STATUS, C       ;Preset carry bit.
                btfsc   inlink          ;is it clear?
                bcf     STATUS, C       ;clear carry bit.

                ;bit in C, now rotate the shift register.
                ;note that the carry bit holds the data moved
                ;between registers.

                rlf     nlBuffSt+0x0F,f
                rlf     nlBuffSt+0x0E,f
                rlf     nlBuffSt+0x0D,f
                rlf     nlBuffSt+0x0C,f
                rlf     nlBuffSt+0x0B,f
                rlf     nlBuffSt+0x0A,f
                rlf     nlBuffSt+0x09,f
                rlf     nlBuffSt+0x08,f
                rlf     nlBuffSt+0x07,f
                rlf     nlBuffSt+0x06,f
                rlf     nlBuffSt+0x05,f

                bcf     clock           ;tell external device to shift.

                rlf     nlBuffSt+0x04,f
                rlf     nlBuffSt+0x03,f
                rlf     nlBuffSt+0x02,f
                rlf     nlBuffSt+0x01,f
                rlf     nlBuffSt,f


                ;Test for completion.

                decfsz  count3, f      ;finished?
                goto    sLoop          ;no, loop. 
                
                retlw   0x00           ;yes, exit.





;***************************************************************
; UART STUFF; INPUT, OUTPUT, DELAY SUBROUTINE. CHAR IN uartReg.
; uses count2, count3
;***************************************************************
        
        ;RECIEVE A BYTE

inUart          btfsc   inbit           ;Start bit?
                goto    inUart          ;No, try again.
                movlw   0x09            ;Yes, we want 8(+start) bits
                movwf   count2          
                movlw   rDelay1         ;set delay value
                call    delay           ;wait (almost) 1/2 bit time
                btfsc   inbit           ;Still there?
                goto    getPC           ;nope, (it's noise?), back to idle.
                
iNext           bsf     STATUS, C       ;set carry     
                btfss   inbit           ;Is input clear?
                bcf     STATUS, C       ;Clear carry in that case.
                rrf     uartReg, f      ;shift right, MSB->LSB from C bit.
                movlw   rDelay2         ;set delay value
                call    delay           ;wait (almost) 1 bit time

                decfsz  count2, f       ;done?
                goto    iNext           ;No, get next bit
                
                retlw   0x00            ;Exit 
                                       

        ;SEND A BYTE

outUart         movwf   uartReg         ;copy w to working reg.

                bcf     outbit          ;send start bit
                
                movlw   sDelay1         ;wait almost one bit time.
                call    delay    
                movlw   0x08            ;8 bits
                movwf   count2          

oNext           btfss   uartReg, lsb    ;bit to be sent next = 0?
                bcf     outbit          ;turn output on in that case
                btfsc   uartReg, lsb    ;bit to be sent next = 1?
                bsf     outbit          ;turn output off in that case
                movlw   sDelay2         ;set delay value
                call    delay           ;wait    
                rrf     uartReg,f       ;shift right MSB->LSB
                decfsz  count2,f        ;Done?         
                goto    oNext           ;No, output another bit
                bsf     outbit          ;Yes, send stop bit.


                movlw   sDelay3         ;set delay value
                call    delay           ;wait  
                retlw   0x00            ;done.
        
        ;DELAY LOOP
        ;time of execution: (w * 3)
        ;MINIMUM DELAY VALUE ALLOWABLE = 3!!!

delay           movwf   count3          ;delay factor into 'count3'
                decf    count3, f       ;adjust for overhead.
                decf    count3, f       ;adjust for overhead.
dLoop           decfsz  count3, f       ;decrement, put back in count3.
                goto    dLoop           ;Not zero? loop
                retlw   0x00            ;Zero? finished.


;***************************************************************
; CONVERT 1 BYTE PACKED HEX -> 2 BYTE ASCII HEX
; w in,          AscMSB, AscLSB out.  
; calls data table 'dataB2A'
;***************************************************************

bin2Asc         
                movwf   packByte        ;save the byte
                andlw   B'00001111'     ;chop high byte
                call    dataB2A         ;convert to ASCII
                movwf   AscLSB          ;store it.

                swapf   packByte, w     ;grab byte with swap nybble
                andlw   B'00001111'     ;chop high byte
                call    dataB2A         ;convert to ASCII
                movwf   AscMSB          ;store it.

                retlw   0x00            ;return.



;***************************************************************
; CONVERT 2 BYTE ASCII HEX -> 1 BYTE PACKED HEX
; AscMSB, AscLSB in,          packByte out.
;
; This code isn't nearly as easy to follow as the other convert
; routine above, but a simple lookup would be too expensive 
; memory wise.
;***************************************************************

asc2Bin         clrf    packByte
                movlw   (A'A'-A'9'-1)   ;this is gap, '9' to 'A'.
                btfsc   AscLSB, 0x06    ;If set? > 9.
                subwf   AscLSB, f       ;Yes, set. Adjust down.
                movlw   (A'0')          ;Value of ASCII '0'
                subwf   AscLSB, w       ;Adjust, answer in w.
                movwf   packByte        ;Store Low nybble.

                movlw   (A'A'-A'9'-1)   ;this is gap, '9' to 'A'.
                btfsc   AscMSB, 0x06    ;If set? > 9.
                subwf   AscMSB, f       ;Yes, set. Adjust down.
                movlw   (A'0')          ;Value of ASCII '0'
                subwf   AscMSB, f       ;Adjust, answer in f.
                swapf   AscMSB, w       ;Get it back in w,nybbles swapped.
                addwf   packByte, f     ;Add to Low Nybble.

                retlw   0x00            ;return.

;***************************************************************
; RESET VECTOR
;***************************************************************
                
                org     theRVector      ;last word of ROM? first?
                goto    start
                
                end
