	LIST
;	Include file for all Blink.asm procs
;
	NOLIST

	
; RAMBASE		EQU	0x0C

RAMBASE		EQU	0x20

; Used by DELAY routines
TIMER1		EQU	RAMBASE + 0x00
TIMER2		EQU	RAMBASE + 0x01
TIMER3		EQU	RAMBASE + 0x02

; Loop vars used by the main routine
M_LOOP1		EQU	RAMBASE + 0x03
M_LOOP2		EQU	RAMBASE + 0x04
M_LOOP3		EQU	RAMBASE + 0x05

; ------------------------------
; Shift register memory allocation  10 1F
; ------------------------------

; 8 bit shift out to shift registers, not preserved by shift routines
SHIFT1		EQU	RAMBASE + 0x10
SHIFT2		EQU	RAMBASE + 0x11
SHIFT3		EQU	RAMBASE + 0x12	; not used in 48 bit systems

; 24 bit color matched shift, not preserved by shift routines
SHIFTG1		EQU	RAMBASE + 0x10
SHIFTY1		EQU	RAMBASE + 0x11
SHIFTR1		EQU	RAMBASE + 0x12

SHIFTG2		EQU	RAMBASE + 0x10
SHIFTY2		EQU	RAMBASE + 0x11
SHIFTR2		EQU	RAMBASE + 0x12

SHIFTG3		EQU	RAMBASE + 0x10	; not used in 48 bit systems
SHIFTY3		EQU	RAMBASE + 0x11	; not used in 48 bit systems
SHIFTR3		EQU	RAMBASE + 0x12	; not used in 48 bit systems

; ------------------------------
; Color and Linear shadow registers 20 - 2F
; ------------------------------

; 72 bit shift , are preserved by shift routines
SHIFT_1		EQU	RAMBASE + 0X20
SHIFT_2		EQU	RAMBASE + 0X21
SHIFT_3		EQU	RAMBASE + 0X22
SHIFT_4		EQU	RAMBASE + 0X23
SHIFT_5		EQU	RAMBASE + 0X24
SHIFT_6		EQU	RAMBASE + 0X25
SHIFT_7		EQU	RAMBASE + 0X26		; Not used with 48 LED configuration
SHIFT_8		EQU	RAMBASE + 0X27		; Not used with 48 LED configuration
SHIFT_9		EQU	RAMBASE + 0X28		; Not used with 48 LED configuration

; 72 bit color matched shift, are preserved by shift routines
SHIFT_G1	EQU	RAMBASE + 0X20
SHIFT_G2	EQU	RAMBASE + 0X21
SHIFT_G3	EQU	RAMBASE + 0X22		; Not used with 48 LED configuration

SHIFT_Y1	EQU	RAMBASE + 0X23
SHIFT_Y2	EQU	RAMBASE + 0X24
SHIFT_Y3	EQU	RAMBASE + 0X25		; Not used with 48 LED configuration

SHIFT_R1	EQU	RAMBASE + 0X26
SHIFT_R2	EQU	RAMBASE + 0X27
SHIFT_R3	EQU	RAMBASE + 0X28		; Not used with 48 LED configuration

; Loop var used by SHIFT8
SHIFT_LOOP	EQU	RAMBASE + 0X2F	

; ------------------------------
; Pattern Subroutines 30 - 39
; ------------------------------

; Loops used by all pattern generating routines
LOOP1		EQU	RAMBASE + 0x30
LOOP2		EQU	RAMBASE + 0x31
TEMP1		EQU	RAMBASE + 0x32
TEMP2		EQU	RAMBASE + 0x33

; Color fill's current fill color
FILL_COLOR	EQU	RAMBASE + 0x33
NEXT_COLOR	EQU	RAMBASE + 0x34

; ------------------------------
; Utility Subroutines 3A - 3F
; ------------------------------

DELAY_TIME	EQU	RAMBASE + 0x3A
TICK_TIME	EQU	RAMBASE + 0X3B
MASK_COLOR	EQU	RAMBASE + 0X3C

DEBUG		EQU	RAMBASE + 0X3D

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

; What is the minimum delay time required to show an LED?
; (255 x ?) delay loop
TICK_VALUE	EQU	0x0A


	LIST
	
	

