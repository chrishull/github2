;----------------------------------------------------------
; Demonstrate brightness change with an LED attached to RA2
; on a 16x84.  Ramping is 16 levels and very smooth, 
; using DVB algorithm.
;
; The LED will get brighter, then dimmer, and repeat til the
; power fails.
; RA1 gives a heartbeat showing that the interrupt routine
; is running.
;
; (c) Christopher Hull, Spillikin Aerospace
;----------------------------------------------------------

        LIST    p=16F84 ; PIC16F84 is the target processor
			; This will override the UI
        #include "P16F84.INC" ; Include header file
	

CLK_LOW		EQU	0x08
CLK_MED		EQU	0x09
CLK_HIGH	EQU	0x10

LED_LOW		EQU	0x11
LED_HIGH	EQU	0x12

BRT_LOW		EQU	0x13
BRT_HIGH	EQU	0x14

RND_LOW		EQU	0x15
RND_HIGH	EQU	0x16

HB_TOGGLE	EQU	0x17

DIRECTION	EQU	0X18


; ------------------------------
; Constants
; ------------------------------

MAKE_DIMMER	EQU	1
MAKE_BRIGHTER	EQU	0


;-------------------------------------------------------------------------
; IDLOCS segment
; Set Version number for this software
;-------------------------------------------------------------------------

IDLOCS CODE
	dw 0x0000
	dw 0x0002

;-------------------------------------------------------------------------
; CONFIG segment
; Set Configuration bits
;-------------------------------------------------------------------------

; External oscellator, timers off, no code protect
; This will override the UI
CONFIG CODE	
	dw _XT_OSC & _PWRTE_OFF & _WDT_OFF & _CP_OFF  
	

;-------------------------------------------------------------------------
; STARTUP segment
; Set Start and Interrupt vectors
;-------------------------------------------------------------------------

STARTUP	CODE

	goto	Main			
	nop				; Pad out so interrupt
	nop				;  service routine gets
	nop				;    put at address 0x0004.
	goto	Interrupt	 	; Points to interrupt service routine	

;-------------------------------------------------------------------------
; PROG segment
;-------------------------------------------------------------------------

;-------------------------------------------------------------------------
; Interrupt Service Routine.
; 
; This controls the value of BRT_LOW and BRT_HIGH, which drives the
; LED in the main loop.
; It would have been nice to put the LED driver here, but this executes
; too infrequently, creating much flucker.
;-------------------------------------------------------------------------

PROG	CODE
Interrupt
	
	; Check to see which interrupt happened	
	btfsc	INTCON, T0IF
	goto	IntT0IF
	retfie
	
	; Handle TMR0 Overflow
IntT0IF
	incfsz	CLK_LOW, F
	goto	Int_Exit
	; incfsz	CLK_HIGH, F
	; goto	ISkip
	
	; Perform control tasks every 65536 iterrations
	; No timer loops here else the fast Main will break

	call	Heartbeat

	btfsc	DIRECTION, 0
	goto	Dimmer
	
Brighter	
	btfsc	BRT_HIGH, 7
	goto	Chg_Dimmer
	bcf	STATUS,C
	rlf	BRT_LOW, F
	rlf	BRT_HIGH, F
	goto	Int_Exit
	
Chg_Dimmer
	movlw	MAKE_DIMMER
	movwf	DIRECTION
	goto	Int_Exit
	
Dimmer	
	btfsc	BRT_LOW, 0
	goto	Chg_Brighter
	bcf	STATUS,C
	rrf	BRT_HIGH, F
	rrf	BRT_LOW, F
	goto	Int_Exit

Chg_Brighter
	movlw	MAKE_BRIGHTER
	movwf	DIRECTION	
	
	
	; Exit from TRM0 Overflow interrupt
Int_Exit
	bcf	INTCON, T0IF		; Clear detect flag
	bsf	INTCON, T0IE		; ReEnable timer interrupt ?
	retfie



;-------------------------------------------------------------------------
; Main
; Set PORTA to be output, init other stuff.
;-------------------------------------------------------------------------
Main
	BCF	STATUS, RP0		; Select bank 0
	CLRF	PORTA			; Initialize PortA
					; by setting output
					; data latches

	BSF	STATUS, RP0		; Select bank 1
	MOVLW	0x00			; Set PORTA data direction to
	MOVWF	TRISA			; all pins as output
	
	BCF	OPTION_REG, T0CS	; TMR0 is to get it's signal from the instr cycle

	BCF	STATUS, RP0		; Select bank 0

	bcf	INTCON, T0IF		; Clear timer interrupt detect
	BSF	INTCON, T0IE		; Enable timer interrupt

	BSF	INTCON, GIE		; Enable timer interrupt


	clrf	DIRECTION		; start by making brighter
	clrf	BRT_HIGH		
	movlw	1			; set dimmest setting
	movwf	BRT_LOW
	
;-------------------------------------------------------
; Main loop
; Drive the LED as fast as you can.
;-------------------------------------------------------

LOOP
	movfw	TMR0
	movwf	RND_LOW

	movfw	BRT_LOW
	addwf	LED_LOW
	movfw	BRT_HIGH
	addwf	LED_HIGH
	btfsc	STATUS, C
	GOTO	Brt2
	BCF	PORTA, 2
	GOTO	Brt1
Brt2	BSF	PORTA, 2	
Brt1	

	movfw	TMR0
	movwf	RND_HIGH
	
	goto	LOOP


;-------------------------------------------------------
; Heartbeat routine to tell that interrupt is being processed
; Toggle RA1 everytime this is called
;-------------------------------------------------------

Heartbeat

	btfss	HB_TOGGLE, 0
	goto	MB_SET
	bcf	PORTA, 1
	bcf	HB_TOGGLE, 0
	retlw	0x00
MB_SET	bsf	PORTA, 1
	bsf	HB_TOGGLE, 0
	retlw	0x00


	END		
