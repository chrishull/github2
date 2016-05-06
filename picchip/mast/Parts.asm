;----------------------------------------------------------------------
; Color Police
; Flash alternating colors in a back and forth pattern, like a police
; car.
;----------------------------------------------------------------------

COLOR_POLICE

	MOVFW	TMR0			; Number of different colors to flash
	MOVWF	LOOP2
	movlw	0x03
	andwf	LOOP2, f
	incf	LOOP2, f

CPL_LOOP2
	; - First half of mast, show color

	movfw	TMR0			; Number of times to flash this color
	movwf	LOOP1			;
	movlw	0x2f
	andwf	LOOP1, f
	incf	LOOP1, f
	movfw	TMR0			; Use a pair of random colors
	movwf	NEXT_COLOR

CPL_LOOP1	
	call	ZERO_ALL		; Set first half of Y, R, or B
	movlw	0xff			
	movwf	SHIFT_Y1		; Set yellow
	btfsc	NEXT_COLOR, 0
	goto	CPL_GREEN1
	call	ZERO_ALL		; or clear and set Red
	movlw	0xff
	movwf	SHIFT_R1
CPL_GREEN1
	btfsc	NEXT_COLOR, 1
	goto	CPL_YELLOW1
	call	ZERO_ALL		; or clear and set Green
	movlw	0xff
	movwf	SHIFT_G1
CPL_YELLOW1
	call	SHIFT_COLOR		; Display and wait
	MOVLW	0x08
	CALL	XP_WaitNextEvent

	; - Second half of mast, show color
	
	call	ZERO_ALL		; Set first half of Y, R, or B
	movlw	0xff			
	movwf	SHIFT_Y2		; Set yellow
	btfsc	NEXT_COLOR, 2
	goto	CPL_GREEN2
	call	ZERO_ALL		; or clear and set Red
	movlw	0xff
	movwf	SHIFT_R2
CPL_GREEN2
	btfsc	NEXT_COLOR, 3
	goto	CPL_YELLOW2
	call	ZERO_ALL		; or clear and set Green
	movlw	0xff
	movwf	SHIFT_G2
CPL_YELLOW2
	call	SHIFT_COLOR		; Display and wait
	MOVLW	0x08
	CALL	XP_WaitNextEvent
	
	decfsz  LOOP1, F		; flash this color again
	GOTO	CPL_LOOP1

	decfsz  LOOP2, F		; do another random color
	GOTO	CPL_LOOP2

	call	ZERO_ALL		; clear and exit
	call	SHIFT_COLOR
	retlw	0x00
	
