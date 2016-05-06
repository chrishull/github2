;----------------------------------------------------------
; Cross Platform MPU Initialization functions
;
; So far, we work with the following processors
; 16F84, 12c671, 12c509A
;
; For each processor, I provide:
;	CONFIG CODE segment with approproate Configuration bits
;	STARTUP CODE segment which jumps to Main (and Interrupt in some cases)
;		Main and Interrupt are provided by the Application.
;
;	CODE SEGMENT contains XP_Init
;		Containing some I/O and Interrupt init code.
;		This must be called by the Application's Main.
;
;	XP_SHADOW_PORTA when used with BUF_BCF and BUF_BSF allows
;	for read modify write of output data where a read reads the pins,
;	and not an output data latch (12x chips need this)
;
;	XP_STATUS is a ever growing additional Status register.
;		See xp.inc for details.
;
; (c) Christopher Hull, Spillikin Aerospace
;----------------------------------------------------------

        #include "w:\picchip\lib\xp.inc"

;-------------------------------------------------------
; Exports used by the outside world
;-------------------------------------------------------
	global	XP_Init, XP_SHADOW_PORTA, XP_STATUS
	
;-------------------------------------------------------
; Code provided by the outside world
;-------------------------------------------------------

	extern	Main, Interrupt
	
	; Needed for 12c test after init code
	; extern	Jump_XP_WaitNextEvent

;-------------------------------------------------------
; Ram used by XP (two little bytes is all I ask)
;-------------------------------------------------------
XPData			udata

; Used in place of read modify write.
; XP_SHADOW_PORTA can be used for BCF and BSF, and then
; written back to XP_PORTA.  See BUF_BSF and BUF_BCF
XP_SHADOW_PORTA		res		1	

; This register is used by the XP modules to remember verious state data
XP_STATUS		res		1

	
;--------- Begin 16F84 Section --------------------------------------------
;--------------------------------------------------------------------------
	IFDEF	__16F84
	
;-------------------------------------------------------
; CONFIG segment for 16F84
; Set Configuration bits;	
;	Use External Oscellator.
;	Turn ON Code protect
;	Kill Watchdog timer
;	Kill Powerup timer
;-------------------------------------------------------
CONFIG 	CODE	
	dw _XT_OSC & _PWRTE_OFF & _WDT_OFF & _CP_ON
	
;-------------------------------------------------------------------------
; STARTUP segment for 16F84
; Jump to Main and Interrupt handlers in application
;-------------------------------------------------------------------------
STARTUP	CODE

	goto	Main			
	nop				; Pad out so interrupt
	nop				;  service routine gets
	nop				;    put at address 0x0004.
	goto	Interrupt	 	; Points to interrupt service routine
	
;-------------------------------------------------------
; PROGRAM segment for 16F84
; IO Initialization
;-------------------------------------------------------
PROG	CODE

XP_Init
			
	bcf	STATUS,IRP		; Select bank 0 for all indirect stuff
	
	BCF	STATUS, RP0		; Select bank 0
	CLRF	PORTA			; Initialize PortA
					; by setting output
					; data latches

	BSF	STATUS, RP0		; Select bank 1
	
	MOVLW	0x00			; Set PORTA data direction to
	MOVWF	TRISA			; all outputs
	
	BCF	OPTION_REG, T0CS	; TMR0 is to get it's signal from the 
					; instr cycle
					
	BCF	OPTION_REG, NOT_RBPU	; Enable all PortB pullups
	BCF	OPTION_REG, INTEDG	; Cause intr to happen on falling edge
	
	BCF	STATUS, RP0		; Select bank 0

	bcf	INTCON, T0IF		; Clear timer interrupt detect
	BSF	INTCON, T0IE		; Enable timer interrupt
	bcf	INTCON, INTF		; Clear PortB interrupt detect
	BSF	INTCON, INTE		; Enable PORTB INT
	
	BSF	INTCON, GIE		; Enable all interrupts
	
	movfw	PORTA			; Init shadow register
	movwf	XP_SHADOW_PORTA
	
	; dovetail

	ENDIF
;--------- End 16F84 Section ----------------------------------------------
;--------------------------------------------------------------------------
	
	
;--------- Begin 12C509A Section -------------------------------------------
;--------------------------------------------------------------------------
	IFDEF	__12C509A
	
;-------------------------------------------------------
; CONFIG segment for 12C509A
; Set Configuration bits
;	Use internal RC osc as clock
;	Turn OFF watchdog timer
;	Turn ON code protect
;
;-------------------------------------------------------
CONFIG 	CODE	
	dw _IntRC_OSC & _WDT_OFF & _CP_ON & _MCLRE_OFF
	
;-------------------------------------------------------------------------
; PROG segment for 12c509a
; Jump to Main in application.  This chip does not do interrupts
;-------------------------------------------------------------------------
STARTUP	CODE

; No STARTUP sigment defined.

	goto	Main				
	
;-------------------------------------------------------
; PROGRAM segment for 12C509A
; Call this code from application's Main
;
; IO Initialization
; 	Set pins 0 - 2 output, 3 - 5 input.  
;	Pin 3 = wake on change
; 	Enable weak pullups
;-------------------------------------------------------
PROG	CODE

XP_Init
	; bcf	STATUS, IRP		; Select bank 0 for all indirect stuff
					; 12c509a indirect addressing only works
					; with bank 0
	
	clrf	GPIO			; Clear I/O Port
	
	; No Bank Selection needed as all needed registers are in bank 0
	; No TRIS reg is memory mapped.  Use the tris instr to xfer W to Opt
	
	; Any input pin can be read at any time.
	; so there is no need to ever set a pin
	; for input.  12c509a seems to not allow output if you even try.
	
	movlw	0x01			; Set TRIS data direction to
	tris	GPIO			; 0 and 3 in, all others out.

	
	; No OPTION reg is memory mapped.  Use the option instr to xfer W to Opt
	; TMR0 is to get it's signal from the instr cycle
	; Enbale weak pullups on pins 0, 1, 3
	; Enbale wake on change pins 0, 1, 3
	clrw
	option

	movfw	GPIO			; Init cross platform shadow register
	movwf	XP_SHADOW_PORTA

	; Test toggle an output pin on the 12c509a
;	clrf	XP_STATUS
;XP_Test_Loop
		
;	BSF	GPIO, 1
;	MOVLW	0x05			; Pause
;	CALL	Jump_XP_WaitNextEvent
;	BCF	GPIO, 1
;	MOVLW	0x05			; Pause
;	CALL	Jump_XP_WaitNextEvent
	
;	decfsz	XP_STATUS
;	goto	XP_Test_Loop
	
	; dovetail

	ENDIF
;--------- End 12C509A Section ---------------------------------------------
;--------------------------------------------------------------------------

;--------- Begin 12C671 Section -------------------------------------------
;--------------------------------------------------------------------------
	IFDEF	__12C671
	
;-------------------------------------------------------
; CONFIG segment for 12C671
; Set Configuration bits
;	Use External Oscellator.
;	Turn ON Code protect
;	Kill Watchdog timer
;	...
;-------------------------------------------------------
CONFIG 	CODE	
	dw _INTRC_OSC_NOCLKOUT & _PWRTE_ON & _WDT_OFF & _CP_ON & _MCLRE_OFF

;-------------------------------------------------------------------------
; STARTUP segment for 12C671
; Jump to Main and Interrupt handlers in application
;-------------------------------------------------------------------------
STARTUP	CODE

	goto	Main			
	nop				; Pad out so interrupt
	nop				;  service routine gets
	nop				;    put at address 0x0004.
	goto	Interrupt	 	; Points to interrupt service routine
	
;-------------------------------------------------------
; PROGRAM segment for 12C509A
; Call this code from application's Main
;
; IO and Interrupt Initialization
; 	Set pins 0, 1,  2, 4, 5 output, 3 input.  
;	Pin 3 = wake on change
; 	Enable weak pullups
;	Enable timer interrupt
;-------------------------------------------------------
PROG	CODE

XP_Init

	bcf	STATUS, IRP		; Select bank 0 for all indirect stuff
	

	
	CLRF	GPIO			; Clear I/O Port
	
	BSF	STATUS, RP0		; Select bank 1
	MOVLW	0xc8			; Set PORTA data direction to
	MOVWF	TRISIO			; 0, 1, 2, 4, 5 as output
	
	;MOVLW	0x00			; Clear W Reg
	;TRIS	GPIO			; Set GPIO as outputs
	
	BCF	OPTION_REG, T0CS	; TMR0 is to get it's signal from the instr cycle
	BCF	STATUS, RP0		; Select bank 0

	bcf	INTCON, T0IF		; Clear timer interrupt detect
	BSF	INTCON, T0IE		; Enable timer interrupt

	BSF	INTCON, GIE		; Enable interrupts

	movfw	GPIO			; Init shadow register
	movwf	XP_SHADOW_PORTA
	
	; dovetail

	ENDIF
;--------- End 12C671 Section ---------------------------------------------
;--------------------------------------------------------------------------
	
;--------------------------------------------------------------------------
; This section should work with all processors
; WARNING - Dovetail from the above Init code.
;--------------------------------------------------------------------------

	; Dovetail from Inits


	clrf	XP_STATUS


	retlw	0



	END		
