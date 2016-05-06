;----------------------------------------------------------
; Make an RGB LED fade from one color to the next via
; attenuation.  The LED package itself contains only
; three colors, r g and b.  Blinking them rqpidly at
; different rates produces any color you like.
;
; Strangely, the business logic runs at interrupt
; time, whereas the tight looping code that creates color
; is in "main".  This is due to the fact that interrupts do
; not take place fast enough for flicker free
; attenuation.
;
; (c) Christopher Hull, Spillikin Aerospace
;----------------------------------------------------------
	
	; work with 12 and 16 series PICs.
	#include "w:\picchip\lib\xp.inc"
	
	; Release number
	; DO NOT MAKE ANY PART ZERO
	; The part will flash the release number on power up.
	#define		VERSION_MAJOR			0x02
	#define		VERSION_MINOR			0x03

;----------------------------------------------------------
; History
; Version numbers flash at initial powerup
;----------------------------------------------------------

; Version 2.1		Initial release
; 2.2			Red now has twice the chance to go black
;			and Green has a chance of being opposite RED
; 2.3			Green never fades to black.  Still seem to
;           see way too much Red.  Must be brighter.

	
;----------------------------------------------------------
; External links
;----------------------------------------------------------

	; Initialized Output port
	extern	XP_SHADOW_PORTA, XP_STATUS
	
	; Set up vectors in XP.asm
	global	Main, Interrupt
	
	; Needed to set Get New Color
	; global no_get_new_colors
	
	; Called by XPEvent when a button is pushed
	global	XPHandler_ButtonPushed
	
	; Links for the jump table
	global		Jump_XP_Init		; XP.asm
	extern		XP_Init
	
	global		Jump_XP_Delay		; XPEvent.asm
	extern		XP_Delay
	global		Jump_XP_WaitNextEvent
	extern		XP_WaitNextEvent
	global		Jump_XP_WNE_NoHandler
	extern		XP_WNE_NoHandler

	;global		Jump_Ramp		; utils.asm
	;extern		Ramp			;   local to color
	;global		Jump_Square
	;extern		Square
	
	
	
;----------------------------------------------------------
; Interrupt handler file registers
;----------------------------------------------------------

Color			UDATA
	
clk_lo			RES	1
clk_hi			RES	1

new_red			RES	1	; Value to dim or brighten to
red			RES	1	; Current value used to calc log
red_value_lo		RES	1	; accumulation value for red
red_value_hi		RES	1
red_register_lo		RES	1	; modulator reg for red
red_register_hi		RES	1

new_green		RES	1
green			RES	1
green_value_lo		RES	1	; accumulation value for green
green_value_hi		RES	1
green_register_lo	RES	1	; modulator reg for green
green_register_hi	RES	1

new_blue		RES	1
blue			RES	1
blue_value_lo		RES	1	; accumulation value for blue
blue_value_hi		RES	1
blue_register_lo	RES	1	; modulator reg for blue
blue_register_hi	RES	1

temp_value_hi		RES	1	; Used by the driver code!
					; DO NOT use at interrupt time

; next_color		RES	1

blink_timer		RES	1

mode			RES	1	; Current pattern mode

; rand			res	1
no_get_new_colors		res	1

count			res	1

; TempStatus		RES	1	; Preserve status during init

; ------------------------------
; I/O Pin Use
; ------------------------------

RED_PIN			EQU	XP_OUTPUT3	; Pin 5
GREEN_PIN		EQU	XP_OUTPUT2	; Pin 4
BLUE_PIN		EQU	XP_OUTPUT1	; Pin 2

COLOR_MASK		EQU	0x7f	; We handle 4 bits per channel
COLOR_MAX		EQU	0x7f	; Tha's 16 levels per channel

; GET_NEW_COLOR		EQU	0x70	; XP_STATUS flag


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
; This vector is set up in XP.asm
;
; Set PORTA to be output, init other stuff.
;-------------------------------------------------------------------------
Main
	movfw	STATUS			; stuff STATUS in mode
	movwf	mode
	
	call	Jump_XP_Init			; Init IO for 16x or 12x

	clrf	red			; Clear all color registers
	clrf	green
	clrf	blue
	call	Jump_Update_Colors
	clrf	new_red			; Clear all color registers
	clrf	new_green
	clrf	new_blue
	
	; Sleep the chip 
	;  (...if we have not just woken from sleep  12c)
	
	; Possible Wake from Sleep for 12cxxx
	IFDEF	__12C509A
	
	btfss	mode, GPWUF	; If set, we are waking from sleep
	goto	PowerUp
	clrf	mode
	call	Jump_Color_Wake		; Perform wakeup seq.
	goto	Main_Loop
	
	ENDIF
	
	; If we get to here, the battery has just been put in.
	; Perform first time wake (show version number, etc).
	; Then go to sleep
PowerUp

	; Blink major and minor version number
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, RED_PIN
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, GREEN_PIN
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, BLUE_PIN
	movlw	0x10
	call	Jump_XP_Delay
	
	movlw	VERSION_MAJOR
	movwf	mode
VB_1	
	BUF_BCF	XP_SHADOW_PORTA, XP_OUTPORT, RED_PIN
	movlw	0x10
	call	Jump_XP_Delay
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, RED_PIN
	movlw	0x10
	call	Jump_XP_Delay
	decfsz	mode
	goto	VB_1

	movlw	VERSION_MINOR
	movwf	mode
VB_2	
	BUF_BCF	XP_SHADOW_PORTA, XP_OUTPORT, BLUE_PIN
	movlw	0x10
	call	Jump_XP_Delay
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, BLUE_PIN
	movlw	0x10
	call	Jump_XP_Delay
	decfsz	mode
	goto	VB_2
	
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, GREEN_PIN
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, GREEN_PIN
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, BLUE_PIN
	movlw	0x10
	call	Jump_XP_Delay	
	clrf	mode
	call	Jump_Color_Sleep
	
;-------------------------------------------------------
; Main loop
; Drive the LEDs as fast as you can, limited only by reg.
;-------------------------------------------------------

Main_Loop
	
	;incf	rand
	
	movfw	red_value_hi
	movwf	temp_value_hi
	movfw	red_value_lo		; Add red_value to red_reg as fast
	addwf	red_register_lo,f	; as possible.  When we overflow
	btfsc	STATUS, C		; prop the carry
	incf	temp_value_hi, f
	movfw	temp_value_hi		; turn the LED on, else off.
	addwf	red_register_hi,f
	btfss	STATUS, C
	GOTO	Red2
	BUF_BCF	XP_SHADOW_PORTA, XP_OUTPORT, RED_PIN		; Light the LED for every overflow
	GOTO	Red1
Red2	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, RED_PIN		; Do not light the LED
Red1	

	movfw	green_value_hi
	movwf	temp_value_hi
	movfw	green_value_lo		; Add green_value to green_reg as fast
	addwf	green_register_lo,f	; as possible.  When we overflow
	btfsc	STATUS, C		; prop the carry
	incf	temp_value_hi, f
	movfw	temp_value_hi		; turn the LED on, else off.
	addwf	green_register_hi,f
	btfss	STATUS, C
	GOTO	Green2
	BUF_BCF	XP_SHADOW_PORTA, XP_OUTPORT, GREEN_PIN	; Light the LED for every overflow
	GOTO	Green1
Green2	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, GREEN_PIN	; Do not light the LED
Green1	
	
	movfw	blue_value_hi
	movwf	temp_value_hi
	movfw	blue_value_lo		; Add blue_value to blue_reg as fast
	addwf	blue_register_lo,f	; as possible.  When we overflow
	btfsc	STATUS, C		; prop the carry
	incf	temp_value_hi, f
	movfw	temp_value_hi		; turn the LED on, else off.
	addwf	blue_register_hi,f
	btfss	STATUS, C
	GOTO	Blue2
	BUF_BCF	XP_SHADOW_PORTA, XP_OUTPORT, BLUE_PIN		; Light the LED for every overflow
	GOTO	Blue1
Blue2	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, BLUE_PIN		; Do not light the LED
Blue1	
	
	goto	Run_Color		; will jump back to Main_Loop
	
	goto	Main_Loop

;-----------------------------------------------------------------
; This section changes the values of [color]_hi and _lo by
; ramping them toward randomly chosen target colors.  If those 
; targest have been reached, now targest are chosen.
; This function should only be called occasionally.  The more 
; frequently it is called, the faster the colors change.
;
; NOTE NOT a Subroutine   For 12c509a, we must preserve stack space!
; This function ALWAYS jumps back to Main_Loop
;
; Business logic for color
;-----------------------------------------------------------------
	
Run_Color

	incfsz	clk_lo, F
	goto	Main_Loop
	incf	clk_hi, f
	btfsc	mode, 0			; If set run fast
	goto	M_Fast
	btfsc	mode, 1			; If set run slow flash / ramp
	goto	M_Slow_Flash
	
M_Slow_Fade	
	btfss	clk_hi, 4
	goto	Main_Loop
	goto	M_Run
	
M_Slow_Flash
	btfss	clk_hi, 2
	goto	Main_Loop
	goto	M_Run
M_Fast	
	btfss	clk_hi, 1		; Run fast
	goto	Main_Loop

M_Run	
	; Perform these functions every tenth of a second or so.
	; --------------------------------------------------------
	clrf	clk_hi
	clrf	clk_lo
	; call	Heartbeat
	
	
	; Check for Events
	; --------------------------------------------------------
	btfss	XP_INPORT, XP_INPUT1	; If not pushed, skip
	call	XPHandler_ButtonPushed
	
	;movlw	0x01			; XXX Too Slow, must 
	;call	Jump_XP_WaitNextEvent	; make "flow thru"
		
; Based on Mode, either Ramp or Blink
; --------------------------------------------------------
Run_Mode	
	btfsc	mode, 1			; Ramp or blink
	goto	Blink_Colors
	
; Ramp Colors from old to new
; --------------------------------------------------------
	
	; If we are still moving the colors, then jump to Move_Colors
	; Else pick new random colors	
	; btfsc	XP_STATUS, GET_NEW_COLOR
	; btfss	no_get_new_colors, 0
	
	; Cheat, cause I can't figure out what the deal with the 12c509a is
	incf	no_get_new_colors
	btfsc	no_get_new_colors, 6
	
	goto	New_Random_Colors
	
	; Move RGB values toward the NEW_RGB values
	;clrf	no_get_new_colors	; Assume we need new colors

	;movlw	new_red			; point to new_red, red
	;movwf	FSR
	;call	Jump_Ramp			; Ramp the color
	
	
	; --------  Ramp the long way so we don't cross page boundries
	
	movfw	red			; Get the moving value
	subwf	new_red, W		; w = red - new_red
	btfsc	STATUS,Z		; if Z is set then equal
	goto	ramp_equal_red
	btfsc	STATUS,C		; if C is set, then red too low
	goto	ramp_inc_red
	decf	red, F			; Decrease color
	goto	ramp_equal_red
ramp_inc_red	
	incf	red, F			; Increase color
ramp_equal_red	
	;iorwf	no_get_new_colors, f	; If nonzero then change took place

	;movlw	new_green		; point to new_green, grn
	;movwf	FSR
	;call	Jump_Ramp			; Ramp the color
	
	; --------  Ramp the long way so we don't cross page boundries
	movfw	green			; Get the moving value
	subwf	new_green, W		; w = red - new_red
	btfsc	STATUS,Z		; if Z is set then equal
	goto	ramp_equal_green
	btfsc	STATUS,C		; if C is set, then red too low
	goto	ramp_inc_green
	decf	green, F			; Decrease color
	goto	ramp_equal_green
ramp_inc_green
	incf	green, F		; Increase color
ramp_equal_green
	;iorwf	no_get_new_colors, f	; If nonzero then change took place

	;movlw	new_blue		; point to new_blue, blu
	;movwf	FSR
	;call	Jump_Ramp			; Ramp the color
	; --------  Ramp the long way so we don't cross page boundries
	movfw	blue			; Get the moving value
	subwf	new_blue, W		; w = red - new_red
	btfsc	STATUS,Z		; if Z is set then equal
	goto	ramp_equal_blue
	btfsc	STATUS,C		; if C is set, then red too low
	goto	ramp_inc_blue
	decf	blue, F			; Decrease color
	goto	ramp_equal_blue
ramp_inc_blue
	incf	blue, F		; Increase color
ramp_equal_blue
	;iorwf	no_get_new_colors, f	; If nonzero then change took place
	
	;btfss	temp_value_hi, 0	; If any change, do not set NEW_COLOR
	;bsf	XP_STATUS, GET_NEW_COLOR
	

	; Update the color registers with new values after ramping
	call	Jump_Update_Colors
	
	goto	Color_Exit

	; Select a new set of random colors to Ramp to
	; --------------------------------------------------------
New_Random_Colors
	;bsf	no_get_new_colors, 0
	;bcf	XP_STATUS, GET_NEW_COLOR
	clrf	no_get_new_colors
	call	Junp_New_RGB1
	
	movlw	0x00		; Some chance of dimming to black
	cmpwfse	TMR0
	goto	Color_Exit	
	
	clrf	new_red
	clrf	new_green
	clrf	new_blue
	goto	Color_Exit	
	

; Blink Colors
; --------------------------------------------------------
Blink_Colors

	incf	blink_timer, f		; Strobe the LEDs.  If timer
	btfss	blink_timer, 2		; ovf, then turn on, else
	goto	blink_clear		; turn off
	
	clrf	blink_timer
	call	Junp_New_RGB1		; Choose random set of colors
	movfw	new_red			; Set all LEDs to those colors
	movwf	red
	movfw	new_green
	movwf	green
	movfw	new_blue
	movwf	blue
	call	Jump_Update_Colors		; Setup driver registers
	goto	Color_Exit

blink_clear				; Turn off all LEDs
	clrf	red
	clrf	green
	clrf	blue
	call	Jump_Update_Colors		; Setup driver registers

Color_Exit		
	goto	Main_Loop


; ----------------------------------------------------------------------	
; Jump Table for 12 bit Instruction set chips
; ----------------------------------------------------------------------

; XP.asm
Jump_XP_Init
	goto	XP_Init
; XPEvent.asm
Jump_XP_WaitNextEvent
	goto	XP_WaitNextEvent
Jump_XP_Delay
	goto	XP_Delay
Jump_XP_WNE_NoHandler
	goto	XP_WNE_NoHandler

	; Utils.asm
;Jump_Ramp
;	goto	Ramp
;Jump_Square
;	goto	Square

Jump_Update_Colors
	goto	Update_Colors
Junp_New_RGB1
	goto	New_RGB1
Jump_Color_Wake
	goto	Color_Wake
Jump_Color_Sleep
	goto	Color_Sleep	
	
;-------------------------------------------------------
; Called when any XPEvent function detects a 
; button push.
;-------------------------------------------------------
XPHandler_ButtonPushed

	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, GREEN_PIN
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, BLUE_PIN
	BUF_BCF	XP_SHADOW_PORTA, XP_OUTPORT, RED_PIN

	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, RED_PIN
	BUF_BCF	XP_SHADOW_PORTA, XP_OUTPORT, BLUE_PIN

	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, BLUE_PIN	
	BUF_BCF	XP_SHADOW_PORTA, XP_OUTPORT, GREEN_PIN
	
	btfss	XP_INPORT, XP_INPUT1	; Loop if pushed
	goto	XPHandler_ButtonPushed
	
	incf	mode,f			; goto next mode
	; Step to next mode, or sleep
	btfss	mode, 2			; If we have done all 4 modes, sleep
	retlw	0x00			; Mode changed, just exit.

Color_Sleep				; Entry point from Init
	
	; Sleep
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, RED_PIN
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, GREEN_PIN
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, BLUE_PIN
	movlw	0x30
	call	Jump_XP_Delay
	
	BUF_BCF	XP_SHADOW_PORTA, XP_OUTPORT, RED_PIN
	movlw	0x30
	call	Jump_XP_Delay
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, RED_PIN
	BUF_BCF	XP_SHADOW_PORTA, XP_OUTPORT, GREEN_PIN
	movlw	0x30
	call	Jump_XP_Delay
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, GREEN_PIN
	BUF_BCF	XP_SHADOW_PORTA, XP_OUTPORT, BLUE_PIN
	movlw	0x30	
	call	Jump_XP_Delay
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, BLUE_PIN
	
	clrf	mode
	
	sleep

Color_Wake			; Entry point from Init

	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, RED_PIN
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, GREEN_PIN
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, BLUE_PIN
	movlw	0x10
	call	Jump_XP_Delay
	
	BUF_BCF	XP_SHADOW_PORTA, XP_OUTPORT, RED_PIN
	movlw	0x10
	call	Jump_XP_Delay
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, RED_PIN
	BUF_BCF	XP_SHADOW_PORTA, XP_OUTPORT, GREEN_PIN
	movlw	0x10
	call	Jump_XP_Delay
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, GREEN_PIN
	BUF_BCF	XP_SHADOW_PORTA, XP_OUTPORT, BLUE_PIN
	movlw	0x10	
	call	Jump_XP_Delay
	BUF_BSF	XP_SHADOW_PORTA, XP_OUTPORT, BLUE_PIN
	
	clrf	mode
	
	btfss	XP_INPORT, XP_INPUT1	; Loop if pushed
	goto	Color_Wake
	
	retlw	0x00
	
;-------------------------------------------------------
; Subroutines for all occasions
;-------------------------------------------------------

	
;-------------------------------------------------------
; Set new_rgb to completely random values
;-------------------------------------------------------

New_RGB1
	movfw	TMR0
	movwf	new_red
	movlw	COLOR_MASK			; trim to COLOR_MASK
	andwf	new_red, f
	btfsc	TMR0, 0				; Fade to black once
	clrf	new_red				; in a while
	btfsc	TMR0, 1				; Because RED is the 
	clrf	new_red				; brighest, it has 2x chance.
	
	movfw	TMR0
	movwf	new_green			; green is dim, chance it
	btfsc	TMR0, 4
	movlw	0xFF
	goto	Grn_Opposite_Red
	movlw	0xaa				; will be opposite RED
Grn_Opposite_Red
	xorwf	new_green, f
	movlw	COLOR_MASK			; trim to COLOR_MASK
	andwf	new_green, f
;	btfsc	TMR0, 2				; may fade to black
;	clrf	new_green
	
	movfw	TMR0
	xorwf	new_blue, f
	movlw	COLOR_MASK			; trim to COLOR_MASK
	andwf	new_blue, f
	btfsc	TMR0, 3				; may fade to black
	clrf	new_blue
	
	retlw	0x00
	
;-------------------------------------------------------
; Update all the color accumulation values given their
; 8 bit values.
;-------------------------------------------------------

Update_Colors

	;movlw	red
	;movwf	FSR
	;call	Jump_Square	

	; ------ Square the hard way to make the 12c509a happy
	movfw	red
	movwf	temp_value_hi
	bcf	STATUS, C
	rlf	temp_value_hi, f
	; incf	FSR,F		; point to first return value
	
	; stolen from Mu8X8
        clrf    red_value_lo
        clrf    red_value_hi
        movlw   8
        movwf   count
        movf    temp_value_hi, W
        bcf     STATUS, C        ; Clear the carry bit in the status Reg.
m_loop_red  rrf     temp_value_hi, F
        btfsc   STATUS, C
        addwf   red_value_hi, F
        rrf     red_value_hi, F
        rrf     red_value_lo, F
        decfsz  count, F
        goto    m_loop_red
	
	;movlw	green
	;movwf	FSR
	;call	Jump_Square	

	; ------ Square the hard way to make the 12c509a happy
	movfw	green
	movwf	temp_value_hi
	bcf	STATUS, C
	rlf	temp_value_hi, f
	; incf	FSR,F		; point to first return value
	
	; stolen from Mu8X8
        clrf    green_value_lo
        clrf    green_value_hi
        movlw   8
        movwf   count
        movf    temp_value_hi, W
        bcf     STATUS, C        ; Clear the carry bit in the status Reg.
m_loop_green  rrf     temp_value_hi, F
        btfsc   STATUS, C
        addwf   green_value_hi, F
        rrf     green_value_hi, F
        rrf     green_value_lo, F
        decfsz  count, F
        goto    m_loop_green
	
	;movlw	blue
	;movwf	FSR
	;call	Jump_Square	
	; ------ Square the hard way to make the 12c509a happy
	movfw	blue
	movwf	temp_value_hi
	bcf	STATUS, C
	rlf	temp_value_hi, f
	; incf	FSR,F		; point to first return value
	
	; stolen from Mu8X8
        clrf    blue_value_lo
        clrf    blue_value_hi
        movlw   8
        movwf   count
        movf    temp_value_hi, W
        bcf     STATUS, C        ; Clear the carry bit in the status Reg.
m_loop_blue  rrf     temp_value_hi, F
        btfsc   STATUS, C
        addwf   blue_value_hi, F
        rrf     blue_value_hi, F
        rrf     blue_value_lo, F
        decfsz  count, F
        goto    m_loop_blue
	
	retlw	0x00
	

	END		
