;----------------------------------------------------------
; This section of code alters red, green, and blue
; in different patterns.
;
; It is part of the interrupt service routine and 
; is written to execute in a flow thru fashion.
;
; (c) Christopher Hull, Spillikin Aerospace
;----------------------------------------------------------

        LIST    p=16F84 		; PIC16F84 is the target processor
        #include "P16F84.INC"
	
	#include "color.inc"
	
;----------------------------------------------------------
; External links
;----------------------------------------------------------

	extern	Log, FunnyLog, Square, Ramp
	extern	Waitx
	
;----------------------------------------------------------
; Interrupt handler file registers
;----------------------------------------------------------

	UDATA


get_new_colors		RES	1
next_color		RES	1

blink_timer		RES	1
blink_mode		RES	1

mode			RES	1	; Current pattern mode
mode_clk_lo		RES	1	; Cycles til next mode
mode_clk_hi		RES	1


; ------------------------------
; Constants
; ------------------------------

RED_PIN			EQU	1	; Bit off of portA for Red LED
GREEN_PIN		EQU	2	; Bit off of portA for Green LED
BLUE_PIN		EQU	3	; Bit off of portA for Blue LED

COLOR_MASK		EQU	0x7f	; We handle 4 bits per channel
COLOR_MAX		EQU	127	; Tha's 16 levels per channel


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
	; --------------------------------------------------------
IntT0IF
	incf	clk_lo, F
	btfss	clk_lo, 7
	goto	Int_Exit
	
	;incf	clk_hi, F
	;btfss	clk_hi, 0
	;goto	Int_Exit
	
	; Perform these functions every tenth of a second or so.
	; --------------------------------------------------------
	clrf	clk_hi
	clrf	clk_lo
	call	Heartbeat
	

	
	
	btfsc	mode, 0			; Ramp or blink
	goto	Blink_Colors

	
	; Ramp Colors from old to new
	; --------------------------------------------------------
	
	; If we are still moving the colors, then jump to Move_Colors
	; Else pick new random colors	
	btfss	get_new_colors, 0
	goto	New_Random_Colors
	
	; Move RGB values toward the NEW_RGB values
	clrf	get_new_colors		; say that we are not still changing

	movlw	new_red			; point to new_red, red
	movwf	FSR
	call	Ramp			; Ramp the color
	iorwf	get_new_colors, f	; If nonzero then change took place

	movlw	new_green		; point to new_green, grn
	movwf	FSR
	call	Ramp			; Ramp the color
	iorwf	get_new_colors, f	; If nonzero then change took place

	movlw	new_blue		; point to new_blue, blu
	movwf	FSR
	call	Ramp			; Ramp the color
	iorwf	get_new_colors, f	; If nonzero then change took place

	; Update the color registers with new values after ramping
	call	Update_Colors
	
	goto	Int_Exit


	; Blink Colors
	; --------------------------------------------------------
Blink_Colors














	
	; Select a new set of random colors
	; --------------------------------------------------------
New_Random_Colors

	bsf	get_new_colors, 0
	
	call	New_RGB1
	;call	New_RGB2
	goto	Int_Exit	
	
		

	
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
	bcf	STATUS,IRP		; Select bank 0 for all indirect stuff
	
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

	clrf	red			; Clear all color registers
	clrf	green
	clrf	blue
	call	Update_Colors
	clrf	new_red			; Clear all color registers
	clrf	new_green
	clrf	new_blue
	
	movfw	TMO0			; randomize
	clrf	mode
	movwf	mode_clk_lo
	movwf	mode_clk_hi

	
	clrf	get_new_colors
	
	BSF	PORTA, RED_PIN		; Set all to high (off)
	BSF	PORTA, GREEN_PIN
	BSF	PORTA, BLUE_PIN

	; Turn on each and then back off,  startup test
	BCF	PORTA, RED_PIN
	movlw	0x10
	call	Waitx
	BSF	PORTA, RED_PIN
	BCF	PORTA, GREEN_PIN
	movlw	0x10
	call	Waitx
	BSF	PORTA, GREEN_PIN
	BCF	PORTA, BLUE_PIN
	movlw	0x10
	call	Waitx
	BSF	PORTA, BLUE_PIN
	movlw	0xf0
	call	Waitx	
	
;-------------------------------------------------------
; Main loop
; Drive the LED as fast as you can.
;-------------------------------------------------------

LOOP
	
	clrw				; Skip if LED is off
	subwf	red,w
	btfsc	STATUS, Z
	goto	skip_red
	
	movfw	red_value_hi
	movwf	temp_value_hi
	bcf	STATUS,C
	movfw	red_value_lo		; Add red_value to red_reg as fast
	addwf	red_register_lo,f	; as possible.  When we overflow
	btfsc	STATUS, C		; prop the carry
	incf	temp_value_hi, f
	movfw	temp_value_hi		; turn the LED on, else off.
	addwf	red_register_hi,f
	btfss	STATUS, C
	GOTO	Red2
	BCF	PORTA, RED_PIN		; Light the LED for every overflow
	GOTO	Red1
Red2	
	BSF	PORTA, RED_PIN		; Do not light the LED
Red1	
skip_red
	clrw				; Skip if LED is off
	subwf	green,w
	btfsc	STATUS, Z
	goto	skip_green

	movfw	green_value_hi
	movwf	temp_value_hi
	bcf	STATUS,C
	movfw	green_value_lo		; Add green_value to green_reg as fast
	addwf	green_register_lo,f	; as possible.  When we overflow
	btfsc	STATUS, C		; prop the carry
	incf	temp_value_hi, f
	movfw	temp_value_hi		; turn the LED on, else off.
	addwf	green_register_hi,f
	btfss	STATUS, C
	GOTO	Green2
	BCF	PORTA, GREEN_PIN	; Light the LED for every overflow
	GOTO	Green1
Green2	
	BSF	PORTA, GREEN_PIN	; Do not light the LED
Green1	

skip_green
	clrw				; Skip if LED is off
	subwf	blue,w
	btfsc	STATUS, Z
	goto	skip_blue
	
	bcf	STATUS,C
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
	BCF	PORTA, BLUE_PIN		; Light the LED for every overflow
	GOTO	Blue1
Blue2	
	BSF	PORTA, BLUE_PIN		; Do not light the LED
Blue1	
skip_blue

	; We need to generate a random number here because the
	; timer is zero when the business logic runs
	movfw	TMR0
	btfsc	TMR0,0
	xorwf	rand1, f
	btfsc	TMR0,1
	xorwf	rand2, f
	xorwf	rand3, f
	
	goto	LOOP

	
;-------------------------------------------------------
; Subroutines for all occasions
;-------------------------------------------------------

;-------------------------------------------------------
; Set new_rgb to completely random values
;-------------------------------------------------------

New_RGB1
	movlw	COLOR_MASK			; new_red = rand 0-15
	andwf	rand1,w
	movwf	new_red	
	movlw	COLOR_MASK			; new_red = rand 0-15
	andwf	rand2,w
	movwf	new_green
	movlw	COLOR_MASK			; new_red = rand 0-15
	andwf	rand3,w
	movwf	new_blue	
	retlw	0x00
	
;-------------------------------------------------------
; Set new_rgb to random values, but make sure
; the brightness is always the same.
;-------------------------------------------------------

New_RGB2
	incf	next_color, f
	btfsc	next_color, 0
	goto	new2_Green
	btfss	next_color, 1
	goto	new2_Blue
	
	movlw	COLOR_MASK		; new_red = rand 0-15
	andwf	rand1,w
	movwf	new_red	
	movwf	new_green		; split the difference
	movlw	COLOR_MAX
	subwf	new_green,f		; g = COLOR_MAX - red
	bcf	STATUS,C
	rrf	new_green, f		; g = g / 2
	movfw	new_green
	movwf	new_blue
	retlw	0x00

new2_Green	
	movlw	COLOR_MASK			; new_blue = rand 0-15
	andwf	rand1,w
	movwf	new_blue	
	movwf	new_green		; split the difference
	movlw	COLOR_MAX
	subwf	new_green,f		; g = 16 - blue
	bcf	STATUS,C
	rrf	new_green, f		; g = g / 2
	movfw	new_green
	movwf	new_red
	retlw	0x00

new2_Blue	
	movlw	COLOR_MASK			; new_red = rand 0-15
	andwf	rand2,w
	movwf	new_green
	movwf	new_blue		; split the difference
	movlw	COLOR_MAX
	subwf	new_blue,f		; b = 16 - grn
	bcf	STATUS,C
	rrf	new_blue, f		; g = g / 2
	movfw	new_blue
	movwf	new_red
	
	retlw	0x00
	
;-------------------------------------------------------
; Update all the color accumulation values given their
; 8 bit values.
;-------------------------------------------------------

Update_Colors

	movlw	red
	movwf	FSR
	call	Square	

	movlw	green
	movwf	FSR
	call	Square	

	movlw	blue
	movwf	FSR
	call	Square	
	
	retlw	0x00
	

	END		
