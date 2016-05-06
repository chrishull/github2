;----------------------------------------------------------
; Drive a 48 mast consisting of Red, Yellow, and Blue LEDs.
; Displays many bright colors.  Used for bicycle flag light
; and our Burning Man becon.  Visible at great distances.
;
; (c) Christopher Hull, Spillikin Aerospace
;----------------------------------------------------------
	
	#include "w:\picchip\lib\xp.inc"
	
	; Release number
	#define		VERSION_MAJOR			0x01
	#define		VERSION_MINOR			0x00
	
;----------------------------------------------------------
; External links
;----------------------------------------------------------

	extern	XP_Init, XP_SHADOW_PORTA
	
	; Data values to send out to shift registers
	extern		SHIFT_G1, SHIFT_Y1, SHIFT_R1
	extern		SHIFT_G2, SHIFT_Y2, SHIFT_R2
	
	; Methods used to send out data
	extern		SHIFT_COLOR
	
	; Callback for XP
	global		Main, Interrupt
	
	; Callback for XPEvent
	global		XPHandler_ButtonPushed
	
	; Links for the jump table
	global		Jump_XP_Delay
	extern		XP_Delay
	global		Jump_XP_WaitNextEvent
	extern		XP_WaitNextEvent
	global		Jump_XP_WNE_NoHandler
	extern		XP_WNE_NoHandler
	
	; XP_Random from XP
	extern		XP_RANDOM
	
	
;----------------------------------------------------------
; Interrupt handler file registers
;----------------------------------------------------------

; ------------------------------
; Pattern Subroutines
; ------------------------------

Patterns	udata

; Loops used by all pattern generating routines
LOOP1		res	1
LOOP2		res	1
TEMP1		res	1
TEMP2		res	1

; Color fill's current fill color
NEXT_PATTERN	res	1
NEXT_COLOR	res	1

;-------------------------------------------------------------------------
; IDLOCS segment
; Set Version number for this software
;-------------------------------------------------------------------------

IDLOCS CODE
	dw VERSION_MINOR
	dw VERSION_MAJOR

;-------------------------------------------------------------------------
; PROG segment
;-------------------------------------------------------------------------
PROG	CODE

;-------------------------------------------------------------------------
; Interrupt Service Routine.
; 
; This controls the value of BRT_LOW and BRT_HIGH, which drives the
; LED in the main loop.
; It would have been nice to put the LED driver here, but this executes
; too infrequently, creating much flucker.
;-------------------------------------------------------------------------

	IFNDEF	__12C509A
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

	; Handle Interrupt Button press
	; --------------------------------------------------------
IntPortB
	bcf	INTCON, INTF		; Clear detect flag	
	retfie
	
	ENDIF
	
;-------------------------------------------------------
; Interrupt for 12c509a will never be called.
;-------------------------------------------------------

	IFDEF	__12C509A
Interrupt
	nop
	ENDIF
	
;-------------------------------------------------------------------------
; Main
; Initialize using XP_Init.
; Display version information.
; Clear all LEDs, sleep and wait for user to hit the button.
;-------------------------------------------------------------------------
Main

	movfw	STATUS			; Save STATUS,  12cxxx needs to
	movwf	TEMP1			; check for wake from sleep
	call	Jump_XP_Init		; Init IO for 16x or 12x
		
	; Possible Wake from Sleep for 12cxxx
	IFDEF	__12C509A
	
	btfss	TEMP1, GPWUF		; If set, we are waking from sleep
	goto	PowerUp
	call	Mast_Wake		; Checks to see if button is really down
	goto	Main_Loop
	
	ENDIF

PowerUp	
	call	Jump_ZERO_ALL		; Display version number
	movlw	VERSION_MAJOR
	MOVWF	SHIFT_G1
	movlw	VERSION_MINOR
	MOVWF	SHIFT_G2
	call	Jump_SHIFT_COLOR
		
	MOVLW	0x40			; Pause
	CALL	Jump_XP_Delay

	call	Jump_ZERO_ALL		; Clear all LEDs
	call	Jump_SHIFT_COLOR
	
	call	Mast_Sleep		; Sleep, user will activate
	
;-------------------------------------------------------
; Main loop
; Loop forever displaying different patterns.
;-------------------------------------------------------

Main_Loop
	movlw	0x01
	movwf	NEXT_PATTERN		

; All pattern routines jump back to this point
Dispatch
;	btfsc	TMR0, 0
;	goto	Disp1
;	bcf	STATUS, C
;	rrf	NEXT_PATTERN, f		; Move to next pattern
;Disp1
	bcf	STATUS, C
	rlf	NEXT_PATTERN, f		; Move to next pattern
Select_Pattern
	btfsc	NEXT_PATTERN, 0
	goto	COLOR_ZOOM
	btfsc	NEXT_PATTERN, 1
	goto	COLOR_FILL
	btfsc	NEXT_PATTERN, 2
	goto	COLOR_FLASH
	btfsc	NEXT_PATTERN, 3
	goto	COLOR_POLICE
	
; If we got this far, we have run thru all the patterns and must
; reset NEXT_PATTERN
	movlw	0x01			; Move to first pattern
	movwf	NEXT_PATTERN
	goto	Select_Pattern

; ----------------------------------------------------------------------	
; Jump Table for 12 bit Instruction set chips
; ----------------------------------------------------------------------

Jump_SHIFT_COLOR
	goto	SHIFT_COLOR
Jump_XP_Init
	goto	XP_Init
Jump_XP_WaitNextEvent
	goto	XP_WaitNextEvent
Jump_XP_Delay
	goto	XP_Delay
Jump_XP_WNE_NoHandler
	goto	XP_WNE_NoHandler
Jump_ZERO_ALL
	goto	ZERO_ALL
Jump_SET_ALL
	goto	SET_ALL
Jump_RRF_COLOR
	goto	RRF_COLOR
Jump_RLF_COLOR
	goto	RLF_COLOR
	
;-------------------------------------------------------
; XPHandler Routines
; Note, we are 1 level deep in the stack.  Only 1 
; level calls allowed.
;-------------------------------------------------------
	
XPHandler_ButtonPushed

Mast_Sleep

	; Display the turn off sequence, then sleep
	call	Jump_SET_ALL
	call	Jump_SHIFT_COLOR
	movlw	0x10
	call	Jump_XP_Delay
	clrf	SHIFT_R1
	clrf	SHIFT_R2
	call	Jump_SHIFT_COLOR
	movlw	0x10
	call	Jump_XP_Delay
	clrf	SHIFT_Y1
	clrf	SHIFT_Y2
	call	Jump_SHIFT_COLOR
	movlw	0x10
	call	Jump_XP_Delay
	clrf	SHIFT_G1
	clrf	SHIFT_G2
	call	Jump_SHIFT_COLOR
	movlw	0x10
	call	Jump_XP_Delay	

XPH_SleepMore	
	sleep

Mast_Wake	; Entry point from Reset if we are waking from sleep (12cxxx)
		; If we are a 16fxxx, sleep simply resumes execution here.
		
	; Wake on button push has occurred.  Go back to sleep if
	; the click was too short
	movlw	0xf0
	call	Jump_XP_WNE_NoHandler	; Call NO HANDLER so we are not recalled
	movwf	TEMP1			; If we returned XP_WNE_LONG_EVENT
	movlw	XP_WNE_LONG_EVENT	; then wake
	cmpwfse	TEMP1
	goto	XPH_SleepMore
	
	call	Jump_ZERO_ALL
	call	Jump_SHIFT_COLOR
	movlw	0x10
	call	Jump_XP_Delay
	movlw	0xff
	movwf	SHIFT_R1
	movwf	SHIFT_R2
	call	Jump_SHIFT_COLOR
	movlw	0x10
	call	Jump_XP_Delay
	movlw	0xff
	movwf	SHIFT_Y1
	movwf	SHIFT_Y2
	call	Jump_SHIFT_COLOR
	movlw	0x10
	call	Jump_XP_Delay
	movlw	0xff
	movwf	SHIFT_G1
	movwf	SHIFT_G2
	call	Jump_SHIFT_COLOR
	movlw	0x10
	call	Jump_XP_Delay		
	
	retlw	0x00


;-------------------------------------------------------
; Pattern Routines
;-------------------------------------------------------

;-------------------------------------------------------
; Pattern Utility Routines
;-------------------------------------------------------

;----------------------------------------------------------------------
; Color fill
; Slowly fill in with the given color for the given number of cycles.
; (in) FILL_COLOR the color to fill
; (in) W = The number of places to fill
; LOOP1 is used.
;----------------------------------------------------------------------

COLOR_FILL
	call	Jump_ZERO_ALL

	movfw	TMR0			; number of times to run thru this 
	movwf	LOOP2			; pattern
	movlw	0x1f
	andwf	LOOP2, f
	incf	LOOP2, f

CF_LOOP2
	movfw	TMR0			; Number of places to fill with this color
	movwf	LOOP1			; no more than 7
	movlw	0x0f
	andwf	LOOP1, f
	incf	LOOP1, f
	incf	NEXT_COLOR		; Advance to next color

CF_LOOP
	btfsc	NEXT_COLOR, 0		; Set the LSB on one color plane
	goto	CF_N1			; based on NEXT_COLOR
	bsf	SHIFT_R1, 0
	goto	CF_BITSET
CF_N1	btfsc	NEXT_COLOR, 1
	goto	CF_F2
	bsf	SHIFT_Y1, 0
	goto	CF_BITSET
CF_F2	bsf	SHIFT_G1, 0

CF_BITSET
	CALL	Jump_SHIFT_COLOR		; Send to LEDs
	call	Jump_RLF_COLOR		; Rotate to next position
	MOVLW	0x05			; Wait 8 ticks
	; pagesel	XP_WaitNextEvent
	CALL	Jump_XP_WaitNextEvent

	decfsz  LOOP1, F		; Shift out more of this color
	GOTO	CF_LOOP

	decfsz  LOOP2, F		; Set up for the next color
	GOTO	CF_LOOP2

	goto	Dispatch		; 12c509a stack to shallow for call

	
;----------------------------------------------------------------------
; Color zoom
; Quickly stripe one color while strobing another color
; (uses) LOOP1 The number of places to fill, and LOOP2 the number of times to loop
;----------------------------------------------------------------------

COLOR_ZOOM

	MOVFW	TMR0
	MOVWF	LOOP2
	movlw	0x07
	andwf	LOOP2, f
	incf	LOOP2, f

CZ_LOOP3
	; Select a random fill color
	call	Jump_ZERO_ALL
	
	MOVLW	0x03				; Load a 0x03
	BTFSC	TMR0, 0				; into one of R, Y, or B
	goto	CZ_S1
	movwf	SHIFT_R1
	goto	CZ_COLOR
CZ_S1	BTFSC	TMR0, 1
	goto	CZ_S2
	movwf	SHIFT_Y1
	goto	CZ_COLOR
CZ_S2	BTFSC	TMR0, 1
	goto	CZ_S2
	movwf	SHIFT_G1

CZ_COLOR
	MOVLW	0x07				; Move total of 8 x up pole
	MOVWF	LOOP1
CZ_LOOP1
	call	Jump_SHIFT_COLOR
	call	Jump_RLF_COLOR			; Rotate 2 positions
	call	Jump_RLF_COLOR
	movlw	0x04
	call	Jump_XP_WaitNextEvent

	decfsz  LOOP1, F			; loop
	GOTO	CZ_LOOP1

	movlw	0x07				; move back down
	movwf	LOOP1
CZ_LOOP2
	call	Jump_SHIFT_COLOR
	call	Jump_RRF_COLOR			; Rotate x3 for next color
	call	Jump_RRF_COLOR
	movlw	0x04
	call	Jump_XP_WaitNextEvent

	decfsz  LOOP1, F		; loop
	GOTO	CZ_LOOP2

	decfsz  LOOP2, F		; do another random color
	GOTO	CZ_LOOP3

	goto	Dispatch		; 12c509a stack to shallow for call


;----------------------------------------------------------------------
; Color flash
; Flash a random color on and off a random number of times
;----------------------------------------------------------------------

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
	call	Jump_ZERO_ALL		; clear and wait
	call	Jump_SHIFT_COLOR
	MOVLW	0x08
	CALL	Jump_XP_WaitNextEvent
	
	call	Jump_ZERO_ALL		; Set the yellow LEDs
	movlw	0xff			
	movwf	SHIFT_Y1
	movwf	SHIFT_Y2

	btfsc	NEXT_COLOR, 0		; If bit set, Set the red LEDs
	goto	CFL_GREEN
	call	Jump_ZERO_ALL
	movlw	0xff
	movwf	SHIFT_R1
	movwf	SHIFT_R2

CFL_GREEN
	btfsc	NEXT_COLOR, 1		; If bit set, Set the green LEDs
	goto	CFL_YELLOW
	call	Jump_ZERO_ALL
	movlw	0xff
	movwf	SHIFT_G1
	movwf	SHIFT_G2

CFL_YELLOW
	call	Jump_SHIFT_COLOR
	MOVLW	0x03
	CALL	Jump_XP_WaitNextEvent

	decfsz  LOOP1, F		; flash this color again
	GOTO	CFL_LOOP1

	decfsz  LOOP2, F		; do another random color
	GOTO	CFL_LOOP2

	call	Jump_ZERO_ALL		; clear and exit
	call	Jump_SHIFT_COLOR
	goto	Dispatch		; 12c509a stack to shallow for call
	
;----------------------------------------------------------------------
; Color Police
; Flash alternating colors in a back and forth pattern, like a police
; car.
;----------------------------------------------------------------------

COLOR_POLICE

	MOVFW	TMR0			; Number of different colors to flash
	MOVWF	LOOP2
	movlw	0x03
	andwf	LOOP2, f
	incf	LOOP2, f

CPL_LOOP2
	; - First half of mast, show color

	movfw	TMR0			; Number of times to flash this color
	movwf	LOOP1			;
	movlw	0x1f
	andwf	LOOP1, f
	incf	LOOP1, f
	movfw	TMR0			; Use a pair of random colors
	movwf	NEXT_COLOR

CPL_LOOP1	
	call	Jump_ZERO_ALL		; Set first half of Y, R, or B
	movlw	0xff			
	movwf	SHIFT_Y1		; Set yellow
	btfsc	NEXT_COLOR, 0
	goto	CPL_GREEN1
	call	Jump_ZERO_ALL		; or clear and set Red
	movlw	0xff
	movwf	SHIFT_R1
CPL_GREEN1
	btfsc	NEXT_COLOR, 1
	goto	CPL_YELLOW1
	call	Jump_ZERO_ALL		; or clear and set Green
	movlw	0xff
	movwf	SHIFT_G1
CPL_YELLOW1
	call	Jump_SHIFT_COLOR		; Display and wait
	MOVLW	0x08
	CALL	Jump_XP_WaitNextEvent

	; - Second half of mast, show color
	
	call	Jump_ZERO_ALL		; Set first half of Y, R, or B
	movlw	0xff			
	movwf	SHIFT_Y2		; Set yellow
	btfsc	NEXT_COLOR, 2
	goto	CPL_GREEN2
	call	Jump_ZERO_ALL		; or clear and set Red
	movlw	0xff
	movwf	SHIFT_R2
CPL_GREEN2
	btfsc	NEXT_COLOR, 3
	goto	CPL_YELLOW2
	call	Jump_ZERO_ALL		; or clear and set Green
	movlw	0xff
	movwf	SHIFT_G2
CPL_YELLOW2
	call	Jump_SHIFT_COLOR		; Display and wait
	MOVLW	0x08
	CALL	Jump_XP_WaitNextEvent
	
	decfsz  LOOP1, F		; flash this color again
	GOTO	CPL_LOOP1

	decfsz  LOOP2, F		; do another random color
	GOTO	CPL_LOOP2

	call	Jump_ZERO_ALL		; clear and exit
	call	Jump_SHIFT_COLOR
	goto	Dispatch		; 12c509a stack to shallow for call
	

;---------------------------------------------------------------------
;	Utility routines
;	(Stack Note) These routines make no other calls, so they can be the
;	second call in a chain.
;---------------------------------------------------------------------

; General purpose rotate for SHIFT_1 thru SHIFT_6
; (out) SHIFT_1 thru SHIFT_6 rotated 1 position left

RLF_COLOR
	BCF	STATUS, C
	RLF	SHIFT_R1, F
	RLF	SHIFT_R2, F
	BCF	STATUS, C
	RLF	SHIFT_Y1, F
	RLF	SHIFT_Y2, F
	BCF	STATUS, C
	RLF	SHIFT_G1, F
	RLF	SHIFT_G2, F	
	retlw	0x00

; General purpose rotate for SHIFT_1 thru SHIFT_6
; (out) SHIFT_1 thru SHIFT_6 rotated 1 position right

RRF_COLOR
	BCF	STATUS, C
	rrf	SHIFT_R1, F
	rrf	SHIFT_R2, F
	BCF	STATUS, C
	rrf	SHIFT_Y1, F
	rrf	SHIFT_Y2, F
	BCF	STATUS, C
	rrf	SHIFT_G1, F
	rrf	SHIFT_G2, F	
	retlw	0x00

; Zero out all the Shift register memory regs

ZERO_ALL
	clrf	SHIFT_R1
	clrf	SHIFT_R2
	clrf	SHIFT_Y1
	clrf	SHIFT_Y2
	clrf	SHIFT_G1
	clrf	SHIFT_G2
	retlw	0x00

; Set all the Shift register memory regs

SET_ALL
	MOVLW	0xFF
	movwf	SHIFT_R1
	movwf	SHIFT_R2
	movwf	SHIFT_Y1
	movwf	SHIFT_Y2
	movwf	SHIFT_G1
	movwf	SHIFT_G2
	retlw	0x00
	

	END		
