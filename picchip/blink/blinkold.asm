;Toggle the GP0 pin at a rate
;determined by DELAY.

        LIST    p=16F84 ; PIC16F84 is the target processor
	#include "P16F84.INC" ; Include header file

; Master delay loop
TEMP1		EQU	0x0C
TEMP2		EQU	0x0D
TEMP3		EQU	0x0E

LOOP1		EQU	0x0F

; 8 bit shift out to shift registers, not preserved
SHIFT1		EQU	0x10

; 16 bit shift out to registers
SHIFTL		EQU	0x11
SHIFTH		EQU	0x12

; 48 bit shift out to registers
SHIFT_1		EQU	0X13
SHIFT_2		EQU	0X14
SHIFT_3		EQU	0X15
SHIFT_4		EQU	0X16
SHIFT_5		EQU	0X17
SHIFT_6		EQU	0X18


LOOP_RY	EQU	0x20

LOOP_2	EQU	0x21
LOOP_3	EQU	0x22


; Constants
; PORTB Pin assignments for shift registers
SHIFT1_CLK	EQU	2
SHIFT1_DAT	EQU	3

; When wired with 2 colored LEDs
FIRST_2		EQU	0X55
SECOND_2	EQU	0XAA

; When wired with 3 colored LEDs
GREEN		EQU	0X49
YELLOW  	EQU	0X92
RED		EQU	0X24

 

; Set Start and Interrupt vectors from 16F84.lkr script
	ORG	0x00

	goto	Start			;0002 = Interrupt Vector
	nop				; Pad out so interrupt
	nop				;  service routine gets
	nop				;    put at address 0x0004.
	goto	IntSvc	 		; Points to interrupt service routine


; Set the start of code from 16F84.lkr script
	ORG	0x10		

; Interrupt service routine
; For now, we just exit
;
IntSvc
	retfie


; Start of main program
;
Start
	BCF	STATUS, RP0		; Select bank 0
	CLRF	PORTB			; Initialize PortB
					; by setting output
					; data latches

	BSF	STATUS, RP0		; Select bank 1
	MOVLW	0x00			; Set PORTB data direction to
	MOVWF	TRISB			; all pins as output

	BCF	STATUS, RP0		; Select bank 0

	BCF	INTCON, T0IE		; Kill timer interrupt
	BCF	INTCON, RBIE		; Kill port change interrupt


LOOP

	MOVLW	0x8
	MOVWF	LOOP_2
	MOVLW	1
	MOVWF	SHIFTL

FILL_LOOP
	MOVFW	SHIFTL
	MOVWF	SHIFT1
	CALL	SHIFT_8
	CALL	DELAY

	BSF	STATUS, C
	RLF	SHIFTL

	decfsz  LOOP_2, F
	GOTO	FILL_LOOP

	MOVLW	0x8
	MOVWF	LOOP_2

EMPTY_LOOP
	MOVFW	SHIFTL
	MOVWF	SHIFT1
	CALL	SHIFT_8
	CALL	DELAY

	BCF	STATUS, C
	RLF	SHIFTL

	decfsz  LOOP_2, F
	GOTO	EMPTY_LOOP

	GOTO	LOOP








	; Shift Red Yellow
	MOVLW	0xFF
	MOVWF	LOOP_2
	MOVLW	0
	MOVWF	SHIFTL
	MOVLW	0
	MOVWF	SHIFTH
	CALL	SHIFT_16
	CALL	DELAY
	MOVLW	1
	MOVWF	SHIFTL
	MOVLW	1
	MOVWF	SHIFTH

LOOP2

	CALL	SHIFT_16
	CALL	DELAY

	MOVLW	1
	ADDWF	SHIFTH, F
	MOVLW	1
	ADDWF	SHIFTL, F

	decfsz  LOOP_2, F
	GOTO	LOOP2

	; Flash Yellow and Red
	MOVLW	16
	MOVWF	LOOP_3

LOOP3
	; Light all the Reds
	MOVLW	FIRST_3
	MOVWF	SHIFTH
	MOVLW	SECOND_3
	MOVWF	SHIFTL
	CALL	SHIFT_16
	CALL	DELAY
	MOVLW	0
	MOVWF	SHIFTL
	MOVWF	SHIFTH
	CALL	SHIFT_16
	CALL	DELAY

	; Light all the Yellows
	MOVLW	SECOND_3
	MOVWF	SHIFTH
	MOVLW	THIRD_3
	MOVWF	SHIFTL
	CALL	SHIFT_16
	CALL	DELAY
	MOVLW	0
	MOVWF	SHIFTL
	MOVWF	SHIFTH
	CALL	SHIFT_16
	CALL	DELAY

	; Light all the Greens
	MOVLW	THIRD_3
	MOVWF	SHIFTH
	MOVLW	FIRST_3
	MOVWF	SHIFTL
	CALL	SHIFT_16
	CALL	DELAY
	MOVLW	0
	MOVWF	SHIFTL
	MOVWF	SHIFTH
	CALL	SHIFT_16
	CALL	DELAY

	decfsz  LOOP_2, F
	GOTO	LOOP3

	GOTO	LOOP			;Repeat

; Shift thru the register by 3s, keeping the color the same.

RY_SHIFT
	MOVLW	8
	MOVWF	LOOP_RY			;Loop 4 times
RY_LOOP
	CALL	SHIFT_16
	CALL	DELAY

	CALL	ROTL
	CALL	ROTL

	decfsz  LOOP_RY, F
	GOTO	RY_LOOP
	retlw	0x00

; Rotate SHIFTL and SHIFTH Left

ROTL
	RLF	SHIFTH, F
	RLF	SHIFTL, F
	BTFSC	SHIFTL, 7
	GOTO	ROTL_1
	MOVLW	1
	IORWF	SHIFTH, F
ROTL_1	retlw	0x00


; Shift 8 bits out of the SHIFT1 register into the first 8 bits of
; the shift register

SHIFT_8
	MOVLW	8
	MOVWF	LOOP1	

S8_LOOP
	; Set PORTB according to the high bit
	BTFSC	SHIFT1, 7
	GOTO	S8_SKIP
	BCF	PORTB, SHIFT1_DAT
	GOTO	S8_CLOCK
S8_SKIP
	BSF	PORTB, SHIFT1_DAT

S8_CLOCK
	BSF	PORTB, SHIFT1_CLK	;Clock up
	BCF	PORTB, SHIFT1_CLK	;Clock down

	RLF	SHIFT1, F

	decfsz  LOOP1, F
	goto    S8_LOOP

	retlw	0x00


; Shift out 16 bits.  The highest bit will fall off of the 15 bit registers
;	(in) SHIFTH and SHIFTL

SHIFT_16
	MOVFW	SHIFTH
	MOVWF	SHIFT1
	CALL	SHIFT_8

	MOVFW	SHIFTL
	MOVWF	SHIFT1
	CALL	SHIFT_8

	retlw	0x00
		

;***************************************
;*  This routine is a software delay.  *
;*  Fosc = 1/Tosc; Tcycle = 4 x Tosc   *
;*  Delay = TEMP1xTEMP2xTEMP3xTcycle   *
;***************************************

DELAY

	MOVLW	0xFF 
	MOVWF	TEMP1			;TEMP1 = 255
	MOVWF	TEMP2			;TEMP2 = 255

DLOOP
	decfsz  TEMP1, F
	goto    DLOOP

	decfsz  TEMP2, F
	goto    DLOOP

	retlw	0x00

	END		
