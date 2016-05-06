;----------------------------------------------------------
; Code for generating patterns on an LED based sign.
; The prototype is the Gelato sign that may one day adorn the
; front window of the Bean Scene on Murphy street.
;
; Allthough we use the xp code, this code works only with 
; the 16f84
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
	extern		ShiftOutClear, ShiftOutSign, GetLetter
		
	; GetLetter returns these values
	extern		letter_bytes, letter_bits, sign_data, sign_letters
	
	
	extern		SLOW_TEST
	
;----------------------------------------------------------
; Sign Pattern Generator file registers
;----------------------------------------------------------

	UDATA

current_letter	res	1

pattern_loop	res	1
pattern_loop2	res	1
letter_loop1	res	1
letter_loop2	res	1

wormcount	res	1
wormcount2	res	1

load_pattern	res	1

sign_flags	res	1

all_pattern_loop	res	1

;----------------------------------------------------------
; Constants
;----------------------------------------------------------

; sign_flags
WORM_CLEAR	EQU	.0
GLITTER		EQU	.1
STROBE		EQU	.2
LEAVE_ON	EQU	.2

;-------------------------------------------------------------------------
; IDLOCS segment
; Set Version number for this software
;-------------------------------------------------------------------------

IDLOCS CODE
	dw 0x0000
	dw 0x0001
	
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
	
	;movlw	.255
	;call	ShiftOutClear
	
	call	Init_Gelato
	; call	Init_Tester
	
;-------------------------------------------------------
; Main loop
;-------------------------------------------------------
	
loop
	movfw	TMR0
	movwf	all_pattern_loop
	movlw	0x07
	andwf	all_pattern_loop, f
	incf	all_pattern_loop
loop2	
	btfsc	TMR0, 2
	call	SignFlash
	btfss	TMR0, 2
	call	SignWorm	
	btfsc	TMR0, 3
	call	SignStrobe
	btfss	TMR0, 3
	call	SignSpin
	btfsc	TMR0, 4
	call	SignBlink

	decfsz	all_pattern_loop, F
	goto	loop2
	
	call	SignFill
	call	ShiftOutSign
	movlw	.10
	movwf	pattern_loop
pp1	
	movlw	0xff
	call	Waitx
	decfsz	pattern_loop, F
	goto	pp1
	
	goto	loop

	
	
;-----------------------------------------------------------------------
; Pattern Generating Routines
;-----------------------------------------------------------------------

;-------------------------------------------------------
; The sign data structure is based on the following.
; All pattern generating routines use FSR pointed to this.
;
; 	FSR (0) Is the number of elements (letters) in
;	the sign.
;	Each letter consists of the following.
;	(0) is the number of total bytes.
;	(1) is the number of bits used in the last byte.
;	(2 - n) is the data itself.
;-------------------------------------------------------

;-------------------------------------------------------
; Clear all byest used in the sign.
;
;-------------------------------------------------------
SignClear
	movlw	.0
	call	Sign_LoadPattern

	retlw	0x00

;-------------------------------------------------------
; Fill all byest used in the sign.
;
;-------------------------------------------------------
SignFill
	movlw	0xff
	call	Sign_LoadPattern

	retlw	0x00
	
;-------------------------------------------------------
; Set a pattern in all the bytes of the sign
; In: (W) is the pattern to set.
;	current_letter is not preserved
;-------------------------------------------------------
Sign_LoadPattern
	movwf	load_pattern		; save the pattern
		
	; Get the number of letters and store
	movfw	sign_letters
	movwf	current_letter		; start with last letter

slp_loop1	
	movfw	load_pattern
	call	Letter_LoadPattern

	decfsz	current_letter, F
	goto	slp_loop1
	
	retlw	0x00


;-------------------------------------------------------
; Set the given letter to the given pattern
; In: (W) is the patter to load
; 	current_letter is the letter to set the pattern in
;-------------------------------------------------------
Letter_LoadPattern
	
	movwf	load_pattern		; save the pattern
	
	movfw	current_letter		; Point to the Nth letter
	call	GetLetter		; FSR pointed to data

llp_loop2
	movfw	load_pattern
	movwf	INDF			; Clear the data
	incf	FSR, F			; Point to (next) data	
	decfsz	letter_bytes, F
	goto	llp_loop2
	
	retlw	0x00
	
;-------------------------------------------------------
; CFlash each letter in turn
;
;-------------------------------------------------------
SignFlash
	
	bcf	sign_flags, GLITTER	; set or clear GLITTER mode
	btfsc	TMR0, 0
	bsf	sign_flags, GLITTER

	movfw	TMR0
	movwf	pattern_loop
	movlw	0x03
	andwf	pattern_loop, F
	incf	pattern_loop
	movfw	pattern_loop
	movwf	letter_loop1
	movwf	letter_loop2

ss_loop	
	; Get the number of letters and store
	call	SignClear		; Clear out sign
	call	ShiftOutSign
	movlw	0x04
	call	Waitx
	
	movlw	.1
	movwf	current_letter		; start with last letter

ss_loop1	
	btfsc	sign_flags, GLITTER
	goto	ss_glitter
	
	; BEGIN - Fill the letter, display and hold
	movlw	0xff
	call	Letter_LoadPattern
	
	call	ShiftOutSign
	movlw	0x04
	call	Waitx

	goto	ss_skip_glitter
	; EBD - Fill the letter, display and hold
	
	; BEGIN - Glitter the letter using TMR0 data
ss_glitter
	movfw	letter_loop2
	movwf	letter_loop1
ss_gloop2
	movfw	TMR0
	call	Letter_LoadPattern
	
	call	ShiftOutSign
	movlw	0x10
	call	Waitx	
	
	decfsz	letter_loop1
	goto	ss_gloop2
	; END - Glitter the letter using TMR0 data
	
	; Set the LEDs all ON for this letter
ss_skip_glitter	
	movlw	0xff
	call	Letter_LoadPattern
	
	call	ShiftOutSign		; Display the new bits
	movlw	0x10
	call	Waitx

	; Move on to the next letter
	movfw	current_letter		; Have we done the last letter
	cmpwfse	sign_letters
	goto	ss_next_letter
	
	movlw	0x80
	call	Waitx
	
	decfsz	pattern_loop, F		; Play it again sam?
	goto	ss_loop
	
	retlw	0x00

ss_next_letter	
	incf	current_letter, F
	goto	ss_loop1
	
;-------------------------------------------------------
; SignStrobe
;
;-------------------------------------------------------
SignStrobe
	call	SignFill	; Fill out sign

	bcf	sign_flags, GLITTER	; set or clear GLITTER mode
	btfsc	TMR0, 0
	bsf	sign_flags, GLITTER
	
	movfw	TMR0
	movwf	pattern_loop
	movlw	0x03
	andwf	pattern_loop, F
	incf	pattern_loop
	movfw	pattern_loop
	movwf	letter_loop1
	movwf	letter_loop2

sstrobe_repeat_pattern	
	clrf	current_letter

sstrobe_next_letter	
	incf	current_letter		; start with last letter
	
	movfw	letter_loop2		; Reset number of times to strobe
	movwf	letter_loop1

	; FILL letter	
sstrobe_next_strobe
	movfw	current_letter		; Point to the Nth letter
	call	GetLetter		; FSR pointed to data
	
	; Fill the letter either with solid or random, display and wait
sstrobe_loop1
	movlw	0xFF
	btfsc	sign_flags, GLITTER
	movfw	TMR0
	movwf	INDF			; Set the data
	incf	FSR, F			; Point to (next) data	
	decfsz	letter_bytes, F
	goto	sstrobe_loop1
	
	call	ShiftOutSign		; Display sign
	movlw	0x06
	call	Waitx	
	
	; Clear the letter, display and wait
	movlw	0
	call	Letter_LoadPattern
	call	ShiftOutSign		; Display
	movlw	0x0a
	call	Waitx	
	
	decfsz	letter_loop1		; Finished strobing?
	goto	sstrobe_next_strobe

	; Finally, fill and loop to next letter
	movlw	0xFF
	call	Letter_LoadPattern
	
	movfw	current_letter		; Have we done the last letter
	cmpwfse	sign_letters
	goto	sstrobe_next_letter
	
	decfsz	pattern_loop, F		; Play it again sam?
	goto	sstrobe_repeat_pattern
	
	retlw	0x00
	
;-------------------------------------------------------
; SignStrobe
;
;-------------------------------------------------------
SignSpin
	movlw	0xFC
	call	Sign_LoadPattern	; Clear out sign
	
	movfw	TMR0
	movwf	pattern_loop
	movlw	0x03
	andwf	pattern_loop, F
	incf	pattern_loop
	
	movlw	.1			; override
	movwf	pattern_loop
	
spin_again
	clrf	current_letter

sspin_next_letter	
	incf	current_letter		; start with last letter
	
	; Rotate current_letter
	movfw	current_letter		; Point to the Nth letter
	call	GetLetter		; FSR pointed to data
	bcf	STATUS, C
	btfsc	INDF, 7
	bsf	STATUS, C
sspin_loop
	rlf	INDF			; Clear the data
	incf	FSR, F			; Point to (next) data	
	decfsz	letter_bytes, F
	goto	sspin_loop
	
	movfw	current_letter		; Have we done the last letter
	cmpwfse	sign_letters
	goto	sspin_next_letter

	call	ShiftOutSign		; Display letters
	movlw	0x03
	call	Waitx	

	decfsz	pattern_loop2, F		; Play it again sam?
	goto	spin_again
	
	movlw	0x60
	movwf	pattern_loop2
	
	decfsz	pattern_loop, F		; Play it again sam?
	goto	spin_again
	
	retlw	0x00
	
	
;-------------------------------------------------------
; Blink the entire sign on and off
;
;-------------------------------------------------------

SignBlink
	movfw	TMR0
	movwf	pattern_loop
	movlw	0x07
	andwf	pattern_loop, F
	incf	pattern_loop

sb_loop	
	call	SignFill
	call	ShiftOutSign
	movlw	0x30
	call	Waitx
	
	call	SignClear
	call	ShiftOutSign
	movlw	0x10
	call	Waitx	
	
	decfsz	pattern_loop, F		
	goto	sb_loop			; Continue to set bits
	
	retlw	0x00

;-------------------------------------------------------
; Clear all byest used in the sign.
;
; @param FSR points to the beginning of a data structure that
;
;-------------------------------------------------------
SignWorm
	call	SignClear	; Clear out sign

	bcf	sign_flags, LEAVE_ON	; set or clear LEAVE_ON mode
	btfsc	TMR0, 1
	bsf	sign_flags, LEAVE_ON
	
	movfw	TMR0
	movwf	pattern_loop
	movlw	0x07
	andwf	pattern_loop, F
	incf	pattern_loop

sw_loop
	; Get the number of letters and store
	movlw	.1
	movwf	current_letter		; start with last letter

sw_loop1	

	movlw	0			; Clear this letter
	call	Letter_LoadPattern
	
	movfw	current_letter		; Point to the Nth letter
	call	GetLetter		; FSR pointed to data
	movfw	letter_bytes		; Set wormcount
	movwf	wormcount
	bcf	STATUS, C
	rlf	wormcount, f		; Mux by 8 for num of rotates
	rlf	wormcount, f
	rlf	wormcount, f
	movfw	wormcount
	movwf	wormcount2
	incf	wormcount2
	bcf	sign_flags, WORM_CLEAR
	
sw_loop2
	movfw	current_letter		; Get letter_bytes and FSR
	call	GetLetter
	btfss	sign_flags, WORM_CLEAR
	goto	sw_set
	bcf	STATUS, C		; Rotate in a 0
	goto	sw_loop3
	
sw_set
	bsf	STATUS, C		; Rotate in a 1
	
sw_loop3
	rlf	INDF			; Rotate all bytes in
	incf	FSR, F			; current_letter
	decfsz	letter_bytes, F
	goto	sw_loop3

	call	ShiftOutSign		; Display letters
	movlw	0x01
	call	Waitx
	
	decfsz	wormcount, F		
	goto	sw_loop2		; Continue to set bits

	btfsc	sign_flags, LEAVE_ON	; Maybe do not clear
	goto	worm_no_clear
	
	incf	wormcount, F		; Cheat so we will fall thru again
	bsf	sign_flags, WORM_CLEAR	; Switch to clear
	decfsz	wormcount2, F
	goto	sw_loop2

worm_no_clear	
	movfw	current_letter		; Have we done the last letter
	cmpwfse	sign_letters
	goto	sw_next_letter

	movlw	0xff			; Set the last letter
	call	Letter_LoadPattern
	
	decfsz	pattern_loop, F		; Play it again sam?
	goto	sw_loop
	
	retlw	0x00

sw_next_letter	

	movlw	0xff			; Set this letter
	call	Letter_LoadPattern
	
	incf	current_letter, F
	goto	sw_loop1


;-------------------------------------------------------
; Set up array for the Gelato sign
;-------------------------------------------------------
	
Init_Gelato

	; There is 1 letter in this sign.
	movlw	.6
	movwf	sign_letters
	
	; The 'G' has 29 LEDs in it.  4 byts, the last 5 bits used.
	movlw	.4
	movwf	sign_data + 0
	movlw	.5
	movwf	sign_data + 1

	; The 'E' has 16 LEDs in it.  2 byts, the last 8 bits used.
	movlw	.2
	movwf	sign_data + 6
	movlw	.8
	movwf	sign_data + 7

	; The 'L' has 11 LEDs in it.  2 byts, the last 3 bits used.
	movlw	.2
	movwf	sign_data + .10
	movlw	.3
	movwf	sign_data + .11

	; The 'A' has 16 LEDs in it.  2 byts, the last 8 bits used.
	movlw	.2
	movwf	sign_data + .14
	movlw	.8
	movwf	sign_data + .15

	; The 'T' has 11 LEDs in it.  2 byts, the last 3 bits used.
	movlw	.2
	movwf	sign_data + .18
	movlw	.3
	movwf	sign_data + .19

	; The 'o' has 12 LEDs in it.  2 byts, the last 4 bits used.
	movlw	.2
	movwf	sign_data + .22
	movlw	.4
	movwf	sign_data + .23
	
	retlw	0x00	

;-------------------------------------------------------
; Set up array for the Tester
;-------------------------------------------------------	
	
Init_Tester

	movlw	.4
	movwf	sign_letters
	
	movlw	.2
	movwf	sign_data + .0
	movlw	.4
	movwf	sign_data + .1
	
	movlw	.2
	movwf	sign_data + .4
	movlw	.4
	movwf	sign_data + .5
	
	movlw	.2
	movwf	sign_data + .8
	movlw	.4
	movwf	sign_data + .9
	
	movlw	.2
	movwf	sign_data + .12
	movlw	.4
	movwf	sign_data + .13
	

	retlw	0x00	
	

	END		
