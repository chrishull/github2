;----------------------------------------------------------
; Test code to make pushbuttons work
;
; (c) Christopher Hull, Spillikin Aerospace
;----------------------------------------------------------
	
	#include "w:\picchip\lib\xp.inc"
	
;----------------------------------------------------------
; External links
;----------------------------------------------------------

	extern	XP_Init, XP_SHADOW_PORTA
	extern	Waitx, Tick
	
	; Methods used to send out data
	extern		SHIFTOUT_8
	extern		SHIFT1
	
	extern		SLOW_TEST
	
;----------------------------------------------------------
; Interrupt handler file registers
;----------------------------------------------------------

	UDATA
	
counter		res	1

; ------------------------------
; Constants
; ------------------------------

; PORTB Pin assignments for shift registers
SHIFT1_CLK	EQU	1
SHIFT1_DAT1	EQU	2

; ------------------------------
; I/O Pin Use
; ------------------------------

	IFDEF __16F84

	
	
	ENDIF

	IFDEF __12C671

	
	
	ENDIF

	IFDEF __12C672

	
	
	ENDIF



;-------------------------------------------------------------------------
; IDLOCS segment
; Set Version number for this software
;-------------------------------------------------------------------------

IDLOCS CODE
	dw 0x0000
	dw 0x0002
	
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
	; --------------------------------------------------------
IntT0IF
	bcf	INTCON, T0IF		; Clear detect flag
	bsf	INTCON, T0IE		; ReEnable timer interrupt ?
	retfie

;-------------------------------------------------------------------------
; Main
; Set PORTA to be output, init other stuff.
;-------------------------------------------------------------------------
Main

	call	XP_Init			; Init IO for 16x or 12x

	movlw	0x30
	call	Waitx
	BUF_BCF	XP_SHADOW_PORTA, XP_PORTA, 1
	
	movlw	0x30
	call	Waitx
	BUF_BSF	XP_SHADOW_PORTA, XP_PORTA, 1
	
;-------------------------------------------------------
; Main loop
;-------------------------------------------------------

	
	; movlw	0x30
	; call	SLOW_TEST
	
	clrf	counter
	
loop
	
	movfw	counter
	movwf	SHIFT1
	call	SHIFTOUT_8
	
	movlw	0x20
	call	Waitx
	
	incf	counter
	
	goto	loop

	
;-------------------------------------------------------
; Subroutines for all occasions
;-------------------------------------------------------



	END		
