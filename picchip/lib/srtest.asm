;----------------------------------------------------------
; Shift Register Test Routines
;
; (c) Christopher Hull, Spillikin Aerospace
;----------------------------------------------------------
	
	#include "w:\picchip\lib\xp.inc"
	
	; Initialized by the main code and exported
	extern		XP_SHADOW_PORTA, XP_WaitNextEvent
	
	global		SLOW_TEST
	

; ------------------------------
; Shift register memory allocation
; ------------------------------

		UDATA
	
SHIFT1		res		1
SHIFT_LOOP	res		1


; ------------------------------
; Constants
; ------------------------------

; PORTB Pin assignments for shift registers
SHIFT1_CLK	EQU	1
SHIFT1_DAT1	EQU	2

PROG	CODE

;---------------------------------------------------------------------
;	Test routines
;---------------------------------------------------------------------

; Shift out a set of 1s, and then a set of 0s.  Each set is shifted
; out SHIFT1 times, very slowly.  A long delay is placed between
; each clock and data state change so that a logic probe can be
; used to track thigns.  SHIFTOUT_8 is not used.
;
; (in) W, The number of 1s and 0s to shift.
; (out) SHIFT1, SHIFT_LOOP are used.

SLOW_TEST
	MOVWF	SHIFT1
	MOVWF	SHIFT_LOOP	

	; Clear out the registers quickly
;	BUF_BCF	XP_SHADOW_PORTA, XP_PORTA, SHIFT1_DAT1	;Clear the bit
;ST_LOOP3
;	BUF_BSF	XP_SHADOW_PORTA, XP_PORTA, SHIFT1_CLK	;Clock GND
;	BUF_BCF	XP_SHADOW_PORTA, XP_PORTA, SHIFT1_CLK	;Clock PULLUP

;	decfsz  SHIFT_LOOP, F
;	goto    ST_LOOP3

	MOVFW	SHIFT1
	MOVWF	SHIFT_LOOP	
	
	; FIll slowly with 1s
	BUF_BSF	XP_SHADOW_PORTA, XP_PORTA, SHIFT1_DAT1	;Set the bit
ST_LOOP1
	BUF_BSF	XP_SHADOW_PORTA, XP_PORTA, SHIFT1_CLK	;Clock GND
	movlw	0x20
	CALL	XP_WaitNextEvent
	BUF_BCF	XP_SHADOW_PORTA, XP_PORTA, SHIFT1_CLK	;Clock PULLUP
	movlw	0x20
	CALL	XP_WaitNextEvent

	decfsz  SHIFT_LOOP, F
	goto    ST_LOOP1

	MOVFW	SHIFT1
	MOVWF	SHIFT_LOOP	

	; Fill slowly with 0s
	BUF_BCF	XP_SHADOW_PORTA, XP_PORTA, SHIFT1_DAT1	;Clear the bit
ST_LOOP2
	BUF_BSF	XP_SHADOW_PORTA, XP_PORTA, SHIFT1_CLK	;Clock GND
	movlw	0x20
	CALL	XP_WaitNextEvent
	BUF_BCF	XP_SHADOW_PORTA, XP_PORTA, SHIFT1_CLK	;Clock PULLUP
	movlw	0x20
	CALL	XP_WaitNextEvent

	decfsz  SHIFT_LOOP, F
	goto    ST_LOOP2

	retlw	0x00

	END		
