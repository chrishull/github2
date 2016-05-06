;----------------------------------------------------------
; Shift Register LED Driver Routines
;
; NOTE: These routines make no CALLS, so they can be the
; second call on a 2 element stack (12c509a)
;
; (c) Christopher Hull, Spillikin Aerospace
;----------------------------------------------------------
	
	#include "w:\picchip\lib\xp.inc"
	
	; Data values to send out to shift registers
	global		SHIFT_G2, SHIFT_G1
	global		SHIFT_Y2, SHIFT_Y1
	global		SHIFT_R2, SHIFT_R1
	
	; Methods used to send out data
	global		SHIFT_COLOR
	
	; Initialized by the XP code and exported
	extern		XP_SHADOW_PORTA
	
	; We use Bit 7 of XP_STATUS
	extern		XP_STATUS
	
	
;----------------------------------------------------------
; Interrupt handler file registers
;----------------------------------------------------------

	UDATA
	
; ------------------------------
; Shift register memory allocation
; ------------------------------


SRDriver	udata
; 24 bit color matched shift, not preserved by shift routines
SHIFTG1		res	1
SHIFTY1		res	1
SHIFTR1		res	1

ShiftColors	udata
; 48 bit color matched shift, are preserved by shift routines
SHIFT_G1	res	1
SHIFT_G2	res	1
SHIFT_Y1	res	1
SHIFT_Y2	res	1
SHIFT_R1	res	1
SHIFT_R2	res	1
		
; Loop var used by SHIFT8
SHIFT_LOOP	res	1	

; ------------------------------
; Constants
; ------------------------------

; PORTB Pin assignments for shift registers
SHIFT1_PORT			equ	XP_OUTPORT
SHIFT1_CLK			equ	XP_OUTPUT1
SHIFT1_DAT1			equ	XP_OUTPUT2

; We use this to save a byte of stack space when shifting out a full
; set of colors (48 LEDs)
FIRST_HALF			equ	8

;-------------------------------------------------------------------------
; PROG segment
;-------------------------------------------------------------------------
PROG	CODE

;---------------------------------------------------------------------
;	Color shift routine
;	Shift out 6 sets of GYR color bits.  
;	(in) SHIFT_G1, SHIFT_Y1, and SHIFT_R1 to 3.  Values are preserved.
;
;	(Stack Note) This routine makes no calls.
;---------------------------------------------------------------------
SHIFT_COLOR

	MOVFW	SHIFT_G2
	MOVWF	SHIFTG1
	MOVFW	SHIFT_Y2
	MOVWF	SHIFTY1
	MOVFW	SHIFT_R2
	MOVWF	SHIFTR1
	bsf	XP_STATUS, FIRST_HALF
	goto	SHIFTOUT_GYR

SHIFT_COLOR2

	MOVFW	SHIFT_G1
	MOVWF	SHIFTG1
	MOVFW	SHIFT_Y1
	MOVWF	SHIFTY1
	MOVFW	SHIFT_R1
	MOVWF	SHIFTR1
		
;-------------------------------------------------------------------------
; Shift 8 bits out of the SHIFTR1 SHIFTY1 and SHIFTG1 registers into the 
; first 24 bits of the shift register, matching the LED colors.  \
; This is the base shift method
; (out) SHIFTR1, SHIFTY1, and SHIFTG1 is shifted out.  Values are lost.
;-------------------------------------------------------------------------

SHIFTOUT_GYR
	MOVLW	8
	MOVWF	SHIFT_LOOP	

SGYR8_LOOP

	BTFSC	SHIFTR1, 7
	GOTO	SGYR8_SKIP_R
	BUF_BCF	XP_SHADOW_PORTA, SHIFT1_PORT, SHIFT1_DAT1
	GOTO	SGYR8_CLOCK_R
SGYR8_SKIP_R
	BUF_BSF	XP_SHADOW_PORTA, SHIFT1_PORT, SHIFT1_DAT1

SGYR8_CLOCK_R
	BUF_BSF	XP_SHADOW_PORTA, SHIFT1_PORT, SHIFT1_CLK	;Clock GND
	BUF_BCF	XP_SHADOW_PORTA, SHIFT1_PORT, SHIFT1_CLK	;Clock PULLUP

	BTFSC	SHIFTY1, 7
	GOTO	SGYR8_SKIP_Y
	BUF_BCF	XP_SHADOW_PORTA, SHIFT1_PORT, SHIFT1_DAT1
	GOTO	SGYR8_CLOCK_Y
SGYR8_SKIP_Y
	BUF_BSF	XP_SHADOW_PORTA, SHIFT1_PORT, SHIFT1_DAT1

SGYR8_CLOCK_Y
	BUF_BSF	XP_SHADOW_PORTA, SHIFT1_PORT, SHIFT1_CLK	;Clock GND
	BUF_BCF	XP_SHADOW_PORTA, SHIFT1_PORT, SHIFT1_CLK	;Clock PULLUP

	BTFSC	SHIFTG1, 7
	GOTO	SGYR8_SKIP_G
	BUF_BCF	XP_SHADOW_PORTA, SHIFT1_PORT, SHIFT1_DAT1
	GOTO	SGYR8_CLOCK_G
SGYR8_SKIP_G
	BUF_BSF	XP_SHADOW_PORTA, SHIFT1_PORT, SHIFT1_DAT1

SGYR8_CLOCK_G
	BUF_BSF	XP_SHADOW_PORTA, SHIFT1_PORT, SHIFT1_CLK	;Clock GND
	BUF_BCF	XP_SHADOW_PORTA, SHIFT1_PORT, SHIFT1_CLK	;Clock PULLUP
	
	RLF	SHIFTG1, F
	RLF	SHIFTY1, F
	RLF	SHIFTR1, F

	decfsz  SHIFT_LOOP, F
	goto    SGYR8_LOOP

	; if SHIFT_COLOR called us with FIRST_HALF set, then
	; jump back to SHIFT_COLOR2, else just return
	btfss	XP_STATUS, FIRST_HALF
	retlw	0x00
	
	bcf	XP_STATUS, FIRST_HALF
	goto	SHIFT_COLOR2

	END		
