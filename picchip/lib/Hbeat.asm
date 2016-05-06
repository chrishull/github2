;----------------------------------------------------------
; Heartbeat generator utility
; Uses PIN 0 of XP_PORTA
;
; (c) Christopher Hull, Spillikin Aerospace
;----------------------------------------------------------

        #include "w:\picchip\lib\xp.inc"
	
;-------------------------------------------------------
; Export
;-------------------------------------------------------
	global	Heartbeat
	
	extern	XP_SHADOW_PORTA
	
;-------------------------------------------------------
; RAM
;-------------------------------------------------------

	UDATA
HB_TOGGLE	RES	1

;-------------------------------------------------------
; Heartbeat routine
; Toggle RA0 everytime this is called
;-------------------------------------------------------

PROG	CODE

Heartbeat
	btfss	HB_TOGGLE, 0
	goto	MB_SET
	BUF_BCF	XP_SHADOW_PORTA, XP_PORTA, 0
	bcf	HB_TOGGLE, 0
	retlw	0x00
	
MB_SET	BUF_BSF	XP_SHADOW_PORTA, XP_PORTA, 0
	bsf	HB_TOGGLE, 0
	retlw	0x01
	
	END		
