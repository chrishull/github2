;Toggle the GP0 pin at a rate
;determined by DELAY.

        LIST    p=16F84 ; PIC16F84 is the target processor
	#include "P16F84.INC" ; Include header file

; Used by DELAY routines
TIMER1		EQU	0x0C
TIMER2		EQU	0x0D
TIMER3		EQU	0x0E

; Loop vars used by the main routine
M_LOOP1		EQU	0x0F
M_LOOP2		EQU	0x10
M_LOOP3		EQU	0x11

; ------------------------------
; Shift register memory allocation  12 1F
; ------------------------------

; 8 bit shift out to shift registers, not preserved by shift routines
SHIFT1		EQU	0x12
SHIFT2		EQU	0x13
SHIFT3		EQU	0x14	; not used in 48 bit systems

; 24 bit color matched shift, not preserved by shift routines
SHIFTG1		EQU	0x12
SHIFTY1		EQU	0x13
SHIFTR1		EQU	0x14

SHIFTG2		EQU	0x12
SHIFTY2		EQU	0x13
SHIFTR2		EQU	0x14

SHIFTG3		EQU	0x12	; not used in 48 bit systems
SHIFTY3		EQU	0x13	; not used in 48 bit systems
SHIFTR3		EQU	0x14	; not used in 48 bit systems

; ------------------------------
; Color and Linear shadow registers 20 - 2F
; ------------------------------

; 72 bit shift , are preserved by shift routines
SHIFT_1		EQU	0X20
SHIFT_2		EQU	0X21
SHIFT_3		EQU	0X22
SHIFT_4		EQU	0X23
SHIFT_5		EQU	0X24
SHIFT_6		EQU	0X25
SHIFT_7		EQU	0X26		; Not used with 48 LED configuration
SHIFT_8		EQU	0X27		; Not used with 48 LED configuration
SHIFT_9		EQU	0X28		; Not used with 48 LED configuration

; 72 bit color matched shift, are preserved by shift routines
SHIFT_G1	EQU	0X20
SHIFT_G2	EQU	0X21
SHIFT_G3	EQU	0X22		; Not used with 48 LED configuration

SHIFT_Y1	EQU	0X23
SHIFT_Y2	EQU	0X24
SHIFT_Y3	EQU	0X25		; Not used with 48 LED configuration

SHIFT_R1	EQU	0X26
SHIFT_R2	EQU	0X27
SHIFT_R3	EQU	0X28		; Not used with 48 LED configuration

; Loop var used by SHIFT8
SHIFT_LOOP	EQU	0X2F	

; ------------------------------
; Pattern Subroutines 30 - 39
; ------------------------------

; Loops used by all pattern generating routines
LOOP1		EQU	0x30
LOOP2		EQU	0x31
TEMP1		EQU	0x32
TEMP2		EQU	0x33

; Color fill's current fill color
FILL_COLOR	EQU	0x33
NEXT_COLOR	EQU	0x34

; ------------------------------
; Utility Subroutines 3A - 3F
; ------------------------------

DELAY_TIME	EQU	0x3A
TICK_TIME	EQU	0X3B
MASK_COLOR	EQU	0X3C

DEBUG		EQU	0X3D

; ------------------------------
; Constants
; ------------------------------

; PORTB Pin assignments for shift registers
SHIFT1_CLK	EQU	3
SHIFT1_DAT1	EQU	2

SHIFT1_DAT2	EQU	3
SHIFT1_DAT3	EQU	4

; When wired with 3 colored LEDs (full bytes)
GREEN_BYTE	EQU	0X49
YELLOW_BYTE  	EQU	0X92
RED_BYTE	EQU	0X24

; When wired with 3 colored LEDs (least sig bits)
GREEN		EQU	0X01
YELLOW  	EQU	0X02
RED		EQU	0X04

; What is the minimum delay time required to show an LED?
; (255 x ?) delay loop
TICK_VALUE	EQU	0x0A

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
	btfsc	INTCON, T0IF		; If TMR0 ovf then clear
	clrf	TMR0

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
	BCF	OPTION_REG, T0CS	; TMR0 is to get it's signal from the instr cycle

	BCF	STATUS, RP0		; Select bank 0

	BSF	INTCON, T0IE		; Enable timer interrupt
	BCF	INTCON, RBIE		; Kill port change interrupt

	CALL	ZERO_ALL		; Zero out all the shift regs
	
;-------------------------------------------------------
; Main loop
;-------------------------------------------------------

LOOP
	; PWRUP_TEST

	; movfw	TMR0
	; movwf	DEBUG
	; call	DEBUGGER

	CALL	COLOR_ZOOM
	btfsc	TMR0, 0
	call	COLOR_FLASH
	btfsc	TMR0, 1
	CALL	COLOR_FILL
	btfsc	TMR0, 2
	call	COLOR_FLASH
	btfsc	TMR0, 3
	CALL	COLOR_FILL

	GOTO	LOOP

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
	incf	LOOP1

	movlw	RED			; set fill color based on lower bits of next color
	btfsc	NEXT_COLOR, 0
	movlw	GREEN
	btfsc	NEXT_COLOR, 1
	movlw	YELLOW
	movwf	FILL_COLOR
	incf	NEXT_COLOR, f		; rotate to the next color we want to use

	call	RLF_72
	call	RLF_72
	call	RLF_72

CF_LOOP
	movfw	FILL_COLOR
	addwf	SHIFT_1, f
	CALL	SHIFT_48		; Send to LEDs
	MOVLW	0x08
	CALL	TICKS

	CALL	RLF_72			; Rotate x3 for next color
	CALL	RLF_72
	CALL	RLF_72

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
	incf	LOOP2

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
	CALL	RLF_72			; Rotate x3 for next color
	CALL	RLF_72
	CALL	RLF_72
	MOVLW	3
	CALL	TICKS

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
	CALL	RRF_72			; Rotate x3 for next color
	CALL	RRF_72
	CALL	RRF_72
	MOVLW	3
	CALL	TICKS

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
	incf	LOOP2

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
	CALL	DELAY
	
	call	ZERO_ALL		; Set the yellow LEDs
	movlw	0xff			
	movwf	SHIFT_Y1
	movwf	SHIFT_Y2
	movwf	SHIFT_Y3

	btfsc	NEXT_COLOR, 0		; If bit set, Set the red LEDs
	goto	CFL_GREEN
	call	ZERO_ALL
	movlw	0xff
	movwf	SHIFT_R1
	movwf	SHIFT_R2
	movwf	SHIFT_R3

CFL_GREEN
	btfsc	NEXT_COLOR, 1		; If bit set, Set the green LEDs
	goto	CFL_YELLOW
	call	ZERO_ALL
	movlw	0xff
	movwf	SHIFT_G1
	movwf	SHIFT_G2
	movwf	SHIFT_G3

CFL_YELLOW
	call	SHIFT_GYR3

	MOVLW	4
	CALL	TICKS

	decfsz  LOOP1, F		; flash this color again
	GOTO	CFL_LOOP1

	decfsz  LOOP2, F		; do another random color
	GOTO	CFL_LOOP2

	call	ZERO_ALL		; clear and exit
	call	SHIFT_GYR3
	retlw	0x00

;---------------------------------------------------------------------
;	Shift register driver routines
;---------------------------------------------------------------------

; Shift 8 bits out of the SHIFT1 register into the first 8 bits of
; the shift register.  This is the base shift method
; (out) SHIFT1 is shifted out.  The value is SHIFT1 is not preserved.

SHIFTOUT_8
	MOVLW	8
	MOVWF	SHIFT_LOOP	

S8_LOOP
	; Set PORTB according to the high bit
	BTFSC	SHIFT1, 7
	GOTO	S8_SKIP
	BCF	PORTB, SHIFT1_DAT1
	GOTO	S8_CLOCK
S8_SKIP
	BSF	PORTB, SHIFT1_DAT1

S8_CLOCK
	BSF	PORTB, SHIFT1_CLK	;Clock GND
	BCF	PORTB, SHIFT1_CLK	;Clock PULLUP
	RLF	SHIFT1, F

	decfsz  SHIFT_LOOP, F
	goto    S8_LOOP

	retlw	0x00
		

; Shift 8 bits out of the SHIFTR1 SHIFTY1 and SHIFTG1 registers into the 
; first 24 bits of the shift register, matching the LED colors.  \
; This is the base shift method
; (out) SHIFTR1, SHIFTY1, and SHIFTG1 is shifted out.  Values are lost.

SHIFTOUT_GYR
	MOVLW	8
	MOVWF	SHIFT_LOOP	

SGYR8_LOOP

	BTFSC	SHIFTR1, 7
	GOTO	SGYR8_SKIP_R
	BCF	PORTB, SHIFT1_DAT1
	GOTO	SGYR8_CLOCK_R
SGYR8_SKIP_R
	BSF	PORTB, SHIFT1_DAT1

SGYR8_CLOCK_R
	BSF	PORTB, SHIFT1_CLK	;Clock GND
	BCF	PORTB, SHIFT1_CLK	;Clock PULLUP

	BTFSC	SHIFTY1, 7
	GOTO	SGYR8_SKIP_Y
	BCF	PORTB, SHIFT1_DAT1
	GOTO	SGYR8_CLOCK_Y
SGYR8_SKIP_Y
	BSF	PORTB, SHIFT1_DAT1

SGYR8_CLOCK_Y
	BSF	PORTB, SHIFT1_CLK	;Clock GND
	BCF	PORTB, SHIFT1_CLK	;Clock PULLUP

	BTFSC	SHIFTG1, 7
	GOTO	SGYR8_SKIP_G
	BCF	PORTB, SHIFT1_DAT1
	GOTO	SGYR8_CLOCK_G
SGYR8_SKIP_G
	BSF	PORTB, SHIFT1_DAT1

SGYR8_CLOCK_G
	BSF	PORTB, SHIFT1_CLK	;Clock GND
	BCF	PORTB, SHIFT1_CLK	;Clock PULLUP
	
	RLF	SHIFTG1, F
	RLF	SHIFTY1, F
	RLF	SHIFTR1, F

	decfsz  SHIFT_LOOP, F
	goto    SGYR8_LOOP

	retlw	0x00

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

; Shift out 72 bits.  
;	(in) SHIFT_1 to SHIFT_9.  Values are preserved.
SHIFT_72
	MOVFW	SHIFT_9
	MOVWF	SHIFT1
	CALL	SHIFTOUT_8
	MOVFW	SHIFT_8
	MOVWF	SHIFT1
	CALL	SHIFTOUT_8
	MOVFW	SHIFT_7
	MOVWF	SHIFT1
	CALL	SHIFTOUT_8
	GOTO	SHIFT_48

; Shift out 6 sets of GYR color bits.  
;	(in) SHIFT_G1, SHIFT_Y1, and SHIFT_R1 to 3.  Values are preserved.

SHIFT_GYR3

	MOVFW	SHIFT_G3
	MOVWF	SHIFTG1
	MOVFW	SHIFT_Y3
	MOVWF	SHIFTY1
	MOVFW	SHIFT_R3
	MOVWF	SHIFTR1
	CALL	SHIFTOUT_GYR

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

ST_LOOP1
	BSF	PORTB, SHIFT1_DAT1	;Set the bit
	CALL	DELAY
	BSF	PORTB, SHIFT1_CLK	;Clock GND
	CALL	DELAY
	BCF	PORTB, SHIFT1_CLK	;Clock PULLUP
	CALL	DELAY

	decfsz  SHIFT_LOOP, F
	goto    ST_LOOP1

	MOVFW	SHIFT1
	MOVWF	SHIFT_LOOP	

ST_LOOP2
	BCF	PORTB, SHIFT1_DAT1	;Clear the bit
	CALL	DELAY
	BSF	PORTB, SHIFT1_CLK	;Clock GND
	CALL	DELAY
	BCF	PORTB, SHIFT1_CLK	;Clock PULLUP
	CALL	DELAY

	decfsz  SHIFT_LOOP, F
	goto    ST_LOOP2

	retlw	0x00

; Count from 0 to 255.  Shift the bits out using SHIFTOUT_8
; Each bank of 8 LEDs should replicate the counting pattern of the
; previous bank.
; (out) LOOP1 and TEMP1 are used.

COUNTER_TEST
	MOVLW	0xFF
	MOVWF	LOOP1
	CLRF	TEMP1

C_LOOP
	MOVFW	TEMP1
	MOVWF	SHIFT1
	CALL	SHIFTOUT_8
	CALL	DELAY
	CALL	DELAY
	CALL	DELAY
	CALL	DELAY

	
	INCF	TEMP1, F

	decfsz  LOOP1, F		; loop
	GOTO	C_LOOP

	retlw	0x00

; Shift 8 1's in to SHIFTL, each time sending them out to the LEDs.
; Then shift 8 0's.  Shift the bits out using SHIFTOUT_8
; Each bank of 8 LEDs should replicate the shifting pattern of the
; previous bank.
; (out) LOOP1 and TEMP1 are used

FILL_TEST
	MOVLW	0x8
	MOVWF	LOOP1
	MOVLW	1
	MOVWF	TEMP1

FILL_LOOP
	MOVFW	TEMP1
	MOVWF	SHIFT1
	CALL	SHIFTOUT_8
	CALL	DELAY

	BSF	STATUS, C
	RLF	TEMP1, F

	decfsz  LOOP1, F
	GOTO	FILL_LOOP

	MOVLW	0x8
	MOVWF	LOOP1

EMPTY_LOOP
	MOVFW	TEMP1
	MOVWF	SHIFT1
	CALL	SHIFTOUT_8
	CALL	DELAY

	BCF	STATUS, C
	RLF	TEMP1, F

	decfsz  LOOP1, F
	GOTO	EMPTY_LOOP

	retlw	0x00

; Flash all LEDs on, then off and then set the first 8 to some debug value
; Alsu used to show version number at start :-)
; (in) DEBUG used to display value

DEBUGGER
	call	SET_ALL		; Signal start of debug, flash all RED
	call	SHIFT_48
	call	DELAY

	MOVLW	0x3
	MOVWF	LOOP1

DEBUG_LOOP
	call	ZERO_ALL
	CALL	SHIFT_48
	call	DELAY
	call	ZERO_ALL		; Show debug value in YELLOW
	movfw	DEBUG
	movwf	SHIFT_1
	CALL	SHIFT_48
	call	DELAY
	decfsz  LOOP1, F
	GOTO	DEBUG_LOOP

	call	DELAY
	call	DELAY

	retlw	0x00

; Run a visual test at power up

PWRUP_TEST
	MOVLW	48			; Shift 48 1s and 0s slowly
	CALL	SLOW_TEST
	CALL	DELAY
	CALL	COUNTER_TEST		; Count to 256
	CALL	DELAY
	retlw	0x00

;---------------------------------------------------------------------
;	Utility routines
;---------------------------------------------------------------------

; General purpose rotate for SHIFT_1 thru SHIFT_6
; (out) SHIFT_1 thru SHIFT_6 rotated 1 position left

RLF_72
	BCF	STATUS, C
	RLF	SHIFT_1, F
	RLF	SHIFT_2, F
	RLF	SHIFT_3, F
	RLF	SHIFT_4, F
	RLF	SHIFT_5, F
	RLF	SHIFT_6, F
	RLF	SHIFT_7, F
	RLF	SHIFT_8, F
	RLF	SHIFT_9, F
	retlw	0x00

; General purpose rotate for SHIFT_1 thru SHIFT_6
; (out) SHIFT_1 thru SHIFT_6 rotated 1 position right

RRF_72
	BCF	STATUS, C
	RRF	SHIFT_9, F
	RRF	SHIFT_8, F
	RRF	SHIFT_7, F
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
	CLRF	SHIFT_7
	CLRF	SHIFT_8
	CLRF	SHIFT_9
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
	MOVWF	SHIFT_7
	MOVWF	SHIFT_8
	MOVWF	SHIFT_9
	retlw	0x00


; Delay a given number of ticks.
; (i) W = number of ticks to delay.

TICKS
	MOVWF	TICK_TIME
TICKS_LOOP
	CALL	TICK
	decfsz  TICK_TIME, F
	goto    TICKS_LOOP
	retlw	0x00

; Delays the minimum amount of time required to show an LED
TICK
	clrf	TIMER3
	MOVLW	TICK_VALUE
	MOVWF	DELAY_TIME		;TEMP2 = 255
	GOTO	DELAY2

; Delay loop
; Delay 255 x 255

DELAY
	clrf	TIMER3
	MOVLW	0xFF 
	MOVWF	DELAY_TIME		;TEMP2 = 255
	GOTO	DELAY2

; Delay loop
; (in) DELAY_TIME 

DELAY2

	MOVLW	0xFF 
	MOVWF	TIMER1			;TEMP1 = 255
	MOVFW	DELAY_TIME
	MOVWF	TIMER2

DLOOP2
	decfsz  TIMER1, F
	goto    DLOOP2

	decfsz  TIMER2, F
	goto    DLOOP2

	retlw	0x00

	END		
