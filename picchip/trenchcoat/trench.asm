;----------------------------------------------------------
; A special version of the Mast code that drivees LEDs
; on my trenchcoat.
;
; (c) Christopher Hull, Spillikin Aerospace
;----------------------------------------------------------
	
	#include "w:\picchip\lib\xp.inc"
	
;----------------------------------------------------------
; External links
;----------------------------------------------------------

	extern	XP_Init, XP_SHADOW_PORTA
	extern	Waitx, Tick
	
	; Data values to send out to shift registers
	extern		SHIFT1, SHIFTG1, SHIFTY1, SHIFTR1
	
	; Methods used to send out data
	extern		SHIFTOUT_GYR, SHIFTOUT_8
	
	extern		SLOW_TEST
	
;----------------------------------------------------------
; Interrupt handler file registers
;----------------------------------------------------------

	UDATA

; ------------------------------
; Color and Linear shadow registers
; ------------------------------

Shifters	udata_ovr	; 6 bytes overlap
; 48 bit shift , are preserved by shift routines
SHIFT_1		res	1
SHIFT_2		res	1
SHIFT_3		res	1
SHIFT_4		res	1
SHIFT_5		res	1
SHIFT_6		res	1

Shifters	udata_ovr
; 48 bit color matched shift, are preserved by shift routines
SHIFT_G1	res	1
SHIFT_G2	res	1
SHIFT_Y1	res	1
SHIFT_Y2	res	1
SHIFT_R1	res	1
SHIFT_R2	res	1

; ------------------------------
; Pattern Subroutines
; ------------------------------

; Loops used by all pattern generating routines
LOOP1		res	1
LOOP2		res	1
TEMP1		res	1
TEMP2		res	1

; Color fill's current fill color
FILL_COLOR	res	1
NEXT_COLOR	res	1

; ------------------------------
; Utility Subroutines 3A - 3F
; ------------------------------

MASK_COLOR	res	1

Int_Loop	res	1
int_timer_lo	res	1
int_timer_hi	res	1
int_timer	res	1

; ------------------------------
; Constants
; ------------------------------

; PORTB Pin assignments for shift registers
SHIFT1_CLK	EQU	1
SHIFT1_DAT1	EQU	2
SHIFT1_DAT2	EQU	3
SHIFT1_DAT3	EQU	5

; When wired with 3 colored LEDs (full bytes)
GREEN_BYTE	EQU	0X49
YELLOW_BYTE  	EQU	0X92
RED_BYTE	EQU	0X24

; When wired with 3 colored LEDs (least sig bits)
GREEN		EQU	0X01
YELLOW  	EQU	0X02
RED		EQU	0X04



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

	; Check for Timer 0 overflow
	btfsc	INTCON, T0IF
	goto	IntT0IF
	
	; Check for PORTB Interrups
	btfsc	INTCON, INTF
	goto	IntPortB
	
	retfie
	
	; Handle TMR0 Overflow
	; --------------------------------------------------------
IntT0IF
	bcf	INTCON, T0IF		; Clear detect flag
	bsf	INTCON, T0IE		; ReEnable timer interrupt ?
	retfie

IntPortB

	bcf	INTCON, INTF		; Clear detect flag
	bsf	INTCON, INTE		; ReEnable timer interrupt ?
	
	;movlw	0xff
	;movwf	PORTB			; Clear the reg

	;movlw	0x0a
	;movwf	Int_Loop

Int_Loop3	
	call	SET_ALL
	call	SHIFT_48
	movlw	0x03
	call	Int_Delay
	call	ZERO_ALL
	call	SHIFT_48
	movlw	0x03
	call	Int_Delay
	
	btfss	PORTB, 0
	goto	Int_Loop3
	
	retfie
	


; Delay for use at interrupt time
Int_Delay
	movwf	int_timer
Int_Delay_Loop
	decfsz  int_timer_lo, F
	goto    Int_Delay_Loop
	decfsz  int_timer_hi, F
	goto    Int_Delay_Loop
	movlw	0x10			; tic value
	movwf	int_timer_hi
	decfsz  int_timer, F
	goto    Int_Delay_Loop

	retlw	0x00
	
;-------------------------------------------------------------------------
; Main
; Set PORTA to be output, init other stuff.
;-------------------------------------------------------------------------
Main

	call	XP_Init			; Init IO for 16x or 12x

	;movlw	0x30
	;call	Waitx
	;BUF_BCF	XP_SHADOW_PORTA, XP_PORTA, 1
	
	;movlw	0x30
	;call	Waitx
	;BUF_BSF	XP_SHADOW_PORTA, XP_PORTA, 1
	
;-------------------------------------------------------
; Main loop
;-------------------------------------------------------

LOOP	
	CALL	COLOR_FILL
	btfsc	TMR0, 0
	call	COLOR_ZOOM
	btfsc	TMR0, 1
	CALL	COLOR_FILL
	btfsc	TMR0, 2
	call	COLOR_FLASH
	btfsc	TMR0, 3
	CALL	COLOR_FILL
		
	goto	LOOP

;-------------------------------------------------------
; Subroutines for all occasions
;-------------------------------------------------------


;-------------------------------------------------------
; Pattern Routines
;-------------------------------------------------------

;-------------------------------------------------------
; Pattern Utility Routines
;-------------------------------------------------------

; Color fill
; Slowly fill in with the given color for the given number of cycles.
; (in) FILL_COLOR the color to fill
; (in) W = The number of places to fill
; LOOP1 is used.

COLOR_FILL
	call	ZERO_ALL

	MOVFW	TMR0			; number of different colors to fill
	MOVWF	LOOP2
	movlw	0xff
	andwf	LOOP2, f
	clrf	NEXT_COLOR

CF_LOOP2
	movfw	TMR0			; Number of places to fill with this color
	MOVWF	LOOP1			; no more than 7
	movlw	0x0f
	andwf	LOOP1, f
	incf	LOOP1, f

	movlw	RED			; set fill color based on lower bits of next color
	btfsc	NEXT_COLOR, 0
	movlw	GREEN
	btfsc	NEXT_COLOR, 1
	movlw	YELLOW
	movwf	FILL_COLOR
	incf	NEXT_COLOR, f		; rotate to the next color we want to use

	call	RLF_48
	call	RLF_48
	call	RLF_48

CF_LOOP
	movfw	FILL_COLOR
	addwf	SHIFT_1, f
	CALL	SHIFT_48		; Send to LEDs
	MOVLW	0x08
	CALL	Waitx

	CALL	RLF_48			; Rotate x3 for next color
	CALL	RLF_48
	CALL	RLF_48

	decfsz  LOOP1, F		; loop for this color
	GOTO	CF_LOOP

	decfsz  LOOP2, F		; loop for next color
	GOTO	CF_LOOP2

	retlw	0x00

; Color zoom
; Quickly stripe one color while strobing another color
; (uses) LOOP1 The number of places to fill, and LOOP2 the number of times to loop

COLOR_ZOOM

	MOVFW	TMR0
	MOVWF	LOOP2
	movlw	0x0f
	andwf	LOOP2, f
	incf	LOOP2, f

CZ_LOOP3
	; Select a random fill color
	MOVLW	GREEN
	BTFSC	TMR0, 0
	MOVLW	RED
	BTFSC	TMR0, 1
	MOVLW	YELLOW
	MOVWF	FILL_COLOR

	; Zoom up 10 positions
	MOVLW	0x10
	MOVWF	LOOP1
	CALL	ZERO_ALL
	MOVFW	FILL_COLOR
	MOVWF	SHIFT_1
CZ_LOOP1
	CALL	SHIFT_48
	CALL	RLF_48			; Rotate x3 for next color
	CALL	RLF_48
	CALL	RLF_48
	MOVLW	3
	CALL	Waitx

	decfsz  LOOP1, F		; loop
	GOTO	CZ_LOOP1

	; Zoom down 10 positions
	MOVLW	0x10
	MOVWF	LOOP1
	CALL	ZERO_ALL
	MOVFW	FILL_COLOR
	MOVWF	SHIFT_6
CZ_LOOP2
	CALL	SHIFT_48
	CALL	RRF_48			; Rotate x3 for next color
	CALL	RRF_48
	CALL	RRF_48
	MOVLW	3
	CALL	Waitx

	decfsz  LOOP1, F		; loop
	GOTO	CZ_LOOP2

	decfsz  LOOP2, F		; do another random color
	GOTO	CZ_LOOP3

	retlw	0x00



; Color flash
; Flash a random color on and off a random number of times

COLOR_FLASH

	MOVFW	TMR0			; Number of different colors to flash
	MOVWF	LOOP2
	movlw	0x0f
	andwf	LOOP2, f
	incf	LOOP2, f

CFL_LOOP2
	movfw	TMR0			; Number of times to flash this color
	MOVWF	LOOP1			;
	movlw	0x0f
	andwf	LOOP1, f
	incf	LOOP1, f
	incf	NEXT_COLOR, f		; next color

CFL_LOOP1
	call	ZERO_ALL		; clear and wait
	call	SHIFT_GYR3
	CALL	Tick
	
	call	ZERO_ALL		; Set the yellow LEDs
	movlw	0xff			
	movwf	SHIFT_Y1
	movwf	SHIFT_Y2

	btfsc	NEXT_COLOR, 0		; If bit set, Set the red LEDs
	goto	CFL_GREEN
	call	ZERO_ALL
	movlw	0xff
	movwf	SHIFT_R1
	movwf	SHIFT_R2

CFL_GREEN
	btfsc	NEXT_COLOR, 1		; If bit set, Set the green LEDs
	goto	CFL_YELLOW
	call	ZERO_ALL
	movlw	0xff
	movwf	SHIFT_G1
	movwf	SHIFT_G2

CFL_YELLOW
	call	SHIFT_GYR3

	MOVLW	4
	CALL	Waitx

	decfsz  LOOP1, F		; flash this color again
	GOTO	CFL_LOOP1

	decfsz  LOOP2, F		; do another random color
	GOTO	CFL_LOOP2

	call	ZERO_ALL		; clear and exit
	call	SHIFT_GYR3
	retlw	0x00

;---------------------------------------------------------------------
;	Color and Monochrome shift routines
;---------------------------------------------------------------------

; Shift out 48 bits.  
;	(in) SHIFT_1 to SHIFT_6.  Values are preserved.

SHIFT_48
	MOVFW	SHIFT_6
	MOVWF	SHIFT1
	CALL	SHIFTOUT_8
	MOVFW	SHIFT_5
	MOVWF	SHIFT1
	CALL	SHIFTOUT_8
	MOVFW	SHIFT_4
	MOVWF	SHIFT1
	CALL	SHIFTOUT_8
	MOVFW	SHIFT_3
	MOVWF	SHIFT1
	CALL	SHIFTOUT_8
	MOVFW	SHIFT_2
	MOVWF	SHIFT1
	CALL	SHIFTOUT_8
	MOVFW	SHIFT_1
	MOVWF	SHIFT1
	CALL	SHIFTOUT_8

	retlw	0x00

; Shift out 6 sets of GYR color bits.  
;	(in) SHIFT_G1, SHIFT_Y1, and SHIFT_R1 to 3.  Values are preserved.

SHIFT_GYR3

	MOVFW	SHIFT_G2
	MOVWF	SHIFTG1
	MOVFW	SHIFT_Y2
	MOVWF	SHIFTY1
	MOVFW	SHIFT_R2
	MOVWF	SHIFTR1
	CALL	SHIFTOUT_GYR

	MOVFW	SHIFT_G1
	MOVWF	SHIFTG1
	MOVFW	SHIFT_Y1
	MOVWF	SHIFTY1
	MOVFW	SHIFT_R1
	MOVWF	SHIFTR1
	CALL	SHIFTOUT_GYR

	retlw	0x00


;---------------------------------------------------------------------
;	Utility routines
;---------------------------------------------------------------------

; General purpose rotate for SHIFT_1 thru SHIFT_6
; (out) SHIFT_1 thru SHIFT_6 rotated 1 position left

RLF_48
	BCF	STATUS, C
	RLF	SHIFT_1, F
	RLF	SHIFT_2, F
	RLF	SHIFT_3, F
	RLF	SHIFT_4, F
	RLF	SHIFT_5, F
	RLF	SHIFT_6, F
	retlw	0x00

; General purpose rotate for SHIFT_1 thru SHIFT_6
; (out) SHIFT_1 thru SHIFT_6 rotated 1 position right

RRF_48
	BCF	STATUS, C
	RRF	SHIFT_6, F
	RRF	SHIFT_5, F
	RRF	SHIFT_4, F
	RRF	SHIFT_3, F
	RRF	SHIFT_2, F
	RRF	SHIFT_1, F
	retlw	0x00

; Zero out all the Shift register memory regs

ZERO_ALL
	CLRF	SHIFT_1
	CLRF	SHIFT_2
	CLRF	SHIFT_3
	CLRF	SHIFT_4
	CLRF	SHIFT_5
	CLRF	SHIFT_6
	retlw	0x00

; Set all the Shift register memory regs

SET_ALL
	MOVLW	0xFF
	MOVWF	SHIFT_1
	MOVWF	SHIFT_2
	MOVWF	SHIFT_3
	MOVWF	SHIFT_4
	MOVWF	SHIFT_5
	MOVWF	SHIFT_6
	retlw	0x00

	

	END		
