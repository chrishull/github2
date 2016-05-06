;----------------------------------------------------------
; Use this to build code that is neutural to both the
; 16 and 12 series PIC Chips
;
; This header file is used for all xp(fo).asm modules.
;
; (c) Christopher Hull, Spillikin Aerospace
;----------------------------------------------------------	
	
;----------------------------------------------------------
; BEGIN: Place all XP Equates for the 12C509A here
;----------------------------------------------------------
	
	IFDEF __12C509A

	; Allow for more general conditional assemblies
	#define		SERIES_12	true
	
	MESSG "XP: Compiling for 12C509A"
        LIST    p=12C509A 		; 12C509A is the target processor
        #include "P12C509A.INC"

	; Cross Platform Input and Output pins and ports
	; Used by SRDrvr, XP_Event, Sleep togger, et al.
	
	#define		XP_OUTPORT	GPIO	
	 #define		XP_INPORT	GPIO	
		
	#define		XP_OUTPUT1	2	; GPIO, Pin 2
	#define		XP_OUTPUT2	4	; GPIO, Pin 4
	#define		XP_OUTPUT3	5	; GPIO, Pin 5
	
	#define		XP_INPUT1	3	; GPIO, Pin 3

	ENDIF
;----------------------------------------------------------
; END: 12C509A
;----------------------------------------------------------


;----------------------------------------------------------
; BEGIN: Place all XP Equates for the 12C671 here
;----------------------------------------------------------
	
	IFDEF __12C671

	; Allow for more general conditional assemblies
	#define		SERIES_12	true
	
	MESSG "XP: Compiling for 12C671"
        LIST    p=12C671 		; 12C509A is the target processor
        #include "P12C671.INC"

	#define		XP_PORTA	GPIO	
	#define		XP_TRISA	TRISIO


	
	ENDIF
;----------------------------------------------------------
; END: 12C671
;----------------------------------------------------------

;----------------------------------------------------------
; BEGIN: Place all XP Equates for the 16F84 here
;----------------------------------------------------------
	
	IFDEF __16F84

	; Allow for more general conditional assemblies
	#define		SERIES_16	true
	
	MESSG "XP  Compiling for 16F84."
        LIST    p=16F84 		; PIC16F84 is the target processor
        #include "P16F84.INC"
	
	; 
	;#define		XP_TRISA	TRISA

	;#define		XP_INTPORT	PORTB
	;#define		XP_INTPIN	0
	
	; Cross Platform Input and Output pins and ports
	; Used by SRDrvr, XP_Event, Sleep togger, et al.
	
	#define		XP_OUTPORT	PORTA	
	#define		XP_INPORT	PORTB	
		
	#define		XP_OUTPUT1	1	; PortA, Pin 1
	#define		XP_OUTPUT2	2	; PortA, Pin 2
	#define		XP_OUTPUT3	3	; PortA, Pin 3
	
	#define		XP_INPUT1	0	; PortB, Pin 0 (Int)
	
	ENDIF
;----------------------------------------------------------
; END: 16F84
;----------------------------------------------------------

;----------------------------------------------------------
; Defines and Macros for all occasions
;----------------------------------------------------------
	
	
; -- XP_STATUS flags
	
	; If set, XP_WNE will not scan for events as it waits.
	; It will simply act as a delay routine.
	#define		XP_SKIP_EVENTS			0
	
	; If set, XP_WNE will wait for an event to end, then it will
	; exit if the event completes, or time runs out.
	; If clear, XP_WNE will wait for an event to begin.
	#define		XP_EVENT_IN_PROGRESS		1
	
	; If set, XP_WNE will not call event handlers, but will return
	; an event code instead.
	#define		XP_SKIP_HANDLER			2
	
; -- XP_WaitNextEvent return codes

	; No event took place during the alotted time
	#define		XP_WNE_NO_EVENT			0x00
	
	; A short click took place
	#define		XP_WNE_SHORT_EVENT		0x01
	
	; A long click took place
	#define		XP_WNE_LONG_EVENT		0x02




	
;----------------------------------------------------------
; Set bit in shadow register and then write the register
; to the I/O reg.
; Initialize shadow before using.
;
; W is not preserved
;----------------------------------------------------------
BUF_BSF		macro	shadow, io, bit

	bsf	shadow, bit
	movfw	shadow
	movwf	io
	
	endm

;----------------------------------------------------------
; Clear bit in shadow register and then write the register
; to the I/O reg.
; Initialize shadow before using.
;
; W is NOT preserved
;----------------------------------------------------------
BUF_BCF		macro	shadow, io, bit

	bcf	shadow, bit
	movfw	shadow
	movwf	io
	
	endm

;----------------------------------------------------------
; Compare file register to W, skip if equal
;
; W is NOT preserved
;----------------------------------------------------------
cmpwfse		macro	fr

	subwf	fr, w
	btfss	STATUS, Z
	
	endm
	




