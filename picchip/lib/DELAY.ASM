;------------------------------------------------------------
; Delay
;------------------------------------------------------------

        #include "w:\picchip\lib\xp.inc"

	UDATA

timer_lo	res	1
timer		res     1
tick_time	res     1

	GLOBAL  Waitx, Tick

; What is the minimum delay time required to show an LED?
; (255 x ?) delay loop

TICK_VALUE	EQU	0x10	; 4.xx mhz clocked systems
; TICK_VALUE	EQU	0x20	; 10 mhz clocked systems

	CODE

;------------------------------------------------------------
; Delay by several ticks.
; (in) W = the number of ticks to delay by. (one based)
;------------------------------------------------------------

Waitx
	movwf	tick_time
Ticks_loop
	call	Tick
	decfsz  tick_time, F
	goto    Ticks_loop
	retlw	0x00

;------------------------------------------------------------
; Delay by one tick.  This is the minimum time required to
; see a flashing LED at the clock speed of this PIC.
; Change the constant TICK_VALUE to change the delay.
;------------------------------------------------------------
Tick
	movlw	TICK_VALUE
	movwf	timer
	GOTO	Delay


;------------------------------------------------------------
; Delay loop
; (in) timer_lo, timer
;------------------------------------------------------------

Delay
	decfsz  timer_lo, F
	goto    Delay
	decfsz  timer, F
	goto    Delay

	retlw	0x00


	END
