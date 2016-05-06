;----------------------------------------------------------
; Cross Platform Event Monitoring component.
; Works like the Mac's old WaitNextEvent, then calls 
; dispatch routine provided by the application.
;
; Works for 12 and 16 series PICs.
; Replaces DELAY.ASM
;
; (c) Christopher Hull, Spillikin Aerospace
;----------------------------------------------------------

        #include "w:\picchip\lib\xp.inc"
	
	#define		BUTTON_DOWN_TIME	0xff

;-------------------------------------------------------
; Export
;-------------------------------------------------------
	
	; This must be provided by the application
	extern	XPHandler_ButtonPushed
	
	; This is provided by XP.ASM
	extern	XP_STATUS
	
	; Links for the jump table
	extern		Jump_XP_Delay
	global		XP_Delay
	extern		Jump_XP_WaitNextEvent
	global		XP_WaitNextEvent
	extern		Jump_XP_WNE_NoHandler
	global		XP_WNE_NoHandler	
	
	global		XP_RANDOM
	

XPEventData	udata

timer_lo	res	1
timer		res     1
tick_time	res     1

; 
XP_RANDOM	res	1




; What is the minimum delay time required to show an LED?
; (255 x ?) delay loop

TICK_VALUE		equ	0x06	; 4.xx mhz clocked systems
; TICK_VALUE		equ	0x0c	; 10 mhz clocked systems

; Number of ticks the button needs to be held down to detect a
; real push

EVENT_TIME		equ	0x20

PROG	CODE

;--------------------------------------------------------------------------
; This section for all processors
;--------------------------------------------------------------------------


	
;------------------------------------------------------------
; Delay by a given number of ticks.
; (in) W = the number of ticks to delay by. (one based)
; If an event takes place, call a service routine at the app
; layer.  TICK_VALUE may be changed to alter the delay
; time.
;
; (Stack note) This function makes no calls, and may JUMP to a service 
; routine, so it may be the 2nd CALL in a chain.
;
; XP_WNE is a somewhat complex little state machine.
;------------------------------------------------------------

XP_WNE_NoHandler
	bsf	XP_STATUS, XP_SKIP_HANDLER	; Skip handlers
	goto	XP_WaitNextEvent
XP_Delay
	bsf	XP_STATUS, XP_SKIP_EVENTS	; Skip all event detection
	
XP_WaitNextEvent
	movwf	tick_time
	bcf	XP_STATUS, XP_EVENT_IN_PROGRESS
	
XP_WNE_Tick_Time_Loop
	movlw	TICK_VALUE			; Loop for next tick
	movwf	timer

	; Handle one of three states.
	;   If XP_SKIP_EVENTS is set, we just loop for a period of time.
	;   else...
	;	If XP_EVENT_IN_PROGRESS is not set, wait for the button to 
	;	be pushed down.  If tick_time expires, exit
	;	else
	;	Wait for event to end.
XP_WNE_Fast_Loop
	btfsc	XP_STATUS, XP_SKIP_EVENTS	; Skip all event detection
	goto	XP_WNE_NoEvent			; if SET
	btfss	XP_STATUS, XP_EVENT_IN_PROGRESS	; Wait for button to
	goto	XP_WNE_WaitStart		; be pressed, if CLEAR

	; Jump here to process event in progress
	; (wait for button to be released)
	btfss	XP_INPORT, XP_INPUT1		; If held down, simply loop
	goto	XP_WNE_NoEvent	
	; Clear XP_EVENT_IN_PROGRESS and XP_SKIP_EVENTS
	; The button was released too soon.  Exit indicating a short event.
	bcf	XP_STATUS, XP_EVENT_IN_PROGRESS
	bcf	XP_STATUS, XP_SKIP_EVENTS
	retlw	XP_WNE_SHORT_EVENT
	
	; Jump here to process button not pushed
XP_WNE_WaitStart
	btfsc	XP_INPORT, XP_INPUT1	; If not pushed, simply loop
	goto	XP_WNE_NoEvent
	; Set XP_EVENT_IN_PROGRESS
	bsf	XP_STATUS, XP_EVENT_IN_PROGRESS
	movlw	EVENT_TIME		; Time need to detect a real
	movwf	tick_time		; button push
	
	; Jump here for simple wait loop
XP_WNE_NoEvent
	decfsz  timer_lo, F
	goto    XP_WNE_Fast_Loop
	decfsz  timer, F
	goto    XP_WNE_Fast_Loop	; Wait this tick
	
	incf	XP_RANDOM		; Our fake random number.
	
	decfsz  tick_time, F		; Wait tick_time ticks
	goto    XP_WNE_Tick_Time_Loop

	; If we get here, time has expired.  
	; Clear XP_SKIP_EVENTS in case it was set
	bcf	XP_STATUS, XP_SKIP_EVENTS
	; Exit if no event was in progress
	btfss	XP_STATUS, XP_EVENT_IN_PROGRESS
	retlw	XP_WNE_NO_EVENT		; No event, just exit
	
	; Clear XP_EVENT_IN_PROGRESS
	; If XP_SKIP_HANDLER not set, jump to the event handler
	; else ret with event code.
	bcf	XP_STATUS, XP_EVENT_IN_PROGRESS
XP_WNE_EventHold
	; btfss	XP_INPORT, XP_INPUT1	; If still pushed, loop
	; goto	XP_WNE_EventHold	
	btfss	XP_STATUS, XP_SKIP_HANDLER
	goto	XPHandler_ButtonPushed
	
	; Clear XP_EVENT_IN_PROGRESS, exit with code.
	bcf	XP_STATUS, XP_SKIP_HANDLER
	retlw	XP_WNE_LONG_EVENT

	
	END		
