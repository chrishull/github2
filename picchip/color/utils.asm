;----------------------------------------------------------
; 
;
; (c) Christopher Hull, Spillikin Aerospace
;----------------------------------------------------------

        #include "w:\picchip\lib\xp.inc"

	; extern  mulcnd, mulplr, H_byte, L_byte, multiply
;-------------------------------------------------------
; Export
;-------------------------------------------------------
	global	Log, FunnyLog, Square, Ramp, Limit
	
	extern	XP_SHADOW_PORTA
	
;-------------------------------------------------------
; Utility file registers
;-------------------------------------------------------

Util		udata_ovr

power		res	1
log_lo		res	1
log_hi		res	1
temp1		res	1

Util		udata_ovr

mulcnd  RES     1       ; 8 bit multiplicand
mulplr  RES     1       ; 8 bit multiplier
H_byte  RES     1       ; High byte of the 16 bit result
L_byte  RES     1       ; Low byte of the 16 bit result
count   RES     1       ; loop counter


PROG	CODE

;-------------------------------------------------------
; Log function
; Given the first 4 bits of N, return 2^N.
; @param FSR (0) points to a single byte power value
;	FSR (1 - 2) points to space where the log is returned.
; FSR is changed by this call.
;-------------------------------------------------------

Log
	movfw	INDF		; read power value
	movwf	power
	movlw	0x0f		; only use the lower 4 bits
	andwf	power, f
	incf	FSR,F		; point to first return value
	
	clrf	temp1		; special case for zero
	subwf	temp1,w		; w = power - 0
	btfsc	STATUS,Z
	goto	log_return_z
	
	movlw	0x0f		; Make sure power is in the range
	andwf	power, f	; 1 - 17
	incf	power, F
	movlw	0x01		; Set log to 0x0001
	movwf	log_lo
	clrf	log_hi
	
log_loop
	decfsz	power, F	; dec counter and loop
	goto	log_loop2	; if finished, exit
	
	movfw	log_lo		; return lo and hi values via FSR
	movwf	INDF
	incf	FSR, F
	movfw	log_hi
	movwf	INDF
	
	retlw	0x00

log_return_z
	clrf	INDF
	incf	FSR, F
	clrf	INDF
	retlw	0x00
	
log_loop2	
	bcf	STATUS,C	; square the result
	rlf	log_lo, F
	rlf	log_hi, F
	goto	log_loop

	
;-------------------------------------------------------
; FunnyLog function
; Given a full 8 bit value, rotate out the 5 LSBits using the
; 3 MSBits.
; @param FSR (0) points to a single byte power value
;	FSR (1 - 2) points to space where the log is returned.
; FSR is changed by this call.
;-------------------------------------------------------

FunnyLog
	movfw	INDF		; read power value
	movwf	power
	incf	FSR,F		; point to first return value
	
	movlw	0x03		; Use first 2 bits as the "value"
	andwf	power, w
	movwf	log_lo		; lo is 0000 00xx
	bsf	log_lo, 0	; lo is 0000 0xx1
	bcf	STATUS, C
	rlf	log_lo, f	; lo is 0000 00x1
	clrf	log_hi		; value is 00000000 000000x1
	
	
	movlw	0x1c		; Use next 3 bits as "mantissa" / 3
	andwf	power, f	; power is 000x xx00
	bcf	STATUS,C	; rotate -> 2x
	rrf	power,f
	rrf	power,f		; power is 0 - 7
	incf	power, f	; power is 1 - 8 (will rotate 0 - 7 x)
	
funny_log_loop
	decfsz	power, F	; dec counter and loop
	goto	funny_log_loop2	; if finished, exit
	
	movfw	log_lo		; return lo and hi values via FSR
	movwf	INDF
	incf	FSR, F
	movfw	log_hi
	movwf	INDF
	retlw	0x00

funny_log_loop2	
	bcf	STATUS,C	; Mult by 4
	rlf	log_lo, F	; do this (power - 1) x
	rlf	log_hi, F
	bcf	STATUS,C
	rlf	log_lo, F
	rlf	log_hi, F
	goto	funny_log_loop

	
;-------------------------------------------------------
; Square function
; Square an 8 bit value, return 16 bit result.
; @param FSR (0) points to a single byte value
;	FSR (1 - 2) points to space where the square is returned.
; FSR is changed by this call.
;-------------------------------------------------------
Square
	movfw	INDF		; read value
	movwf	mulcnd
	movwf	mulplr
	bcf	STATUS, C
	rlf	mulcnd, f
	bcf	STATUS, C
	rlf	mulplr, f	
	incf	FSR,F		; point to first return value
	
	; stolen from Mu8X8
        clrf    H_byte
        clrf    L_byte
        movlw   8
        movwf   count
        movf    mulcnd, W
        bcf     STATUS, C        ; Clear the carry bit in the status Reg.
m_loop  rrf     mulplr, F
        btfsc   STATUS, C
        addwf   H_byte, F
        rrf     H_byte, F
        rrf     L_byte, F
        decfsz  count, F
        goto    m_loop
	
	;bcf	STATUS, C
	;rlf	L_byte		; multiply by 2
	;rlf	H_byte
	;btfsc	STATUS, C	; preserve high bit
	;bsf	H_byte, 7
	
	movfw	L_byte		; return lo and hi values via FSR
	movwf	INDF
	incf	FSR, F
	movfw	H_byte
	movwf	INDF
	retlw	0x00
	
;-------------------------------------------------------
; Ramp function
; Move one value toward another.  Return direction moved in W.
; @param FSR (0) points to the stationary byte
;	FSR (1) points to the moving value.
; Return
; If the values are equal, W = 0, if value was moved up, then W = 1
; If value is moved down, then W = FF
; FSR is changed by this call.
;-------------------------------------------------------
Ramp
	; Move RGB values toward the NEW_RGB values
	movfw	INDF			; Get the static value and 
	movwf	temp1			; store in temp1
	incf	FSR, F
	
	movfw	INDF			; Get the moving value
	subwf	temp1, W		; w = red - new_red
	btfsc	STATUS,Z		; if Z is set then equal
	goto	ramp_equal
	btfsc	STATUS,C		; if C is set, then red too low
	goto	ramp_inc

	decf	INDF, F			; Decrement
	;movlw	0xff
	;iorwf	no_get_new_colors, f	; If nonzero then change took place
	retlw	0xff
	
ramp_inc	
	incf	INDF, F			; Increment
	;movlw	0x01
	;iorwf	no_get_new_colors, f	; If nonzero then change took place
	retlw	0x01
	
ramp_equal	
	retlw	0x00
	
;-------------------------------------------------------
; Limit Function
; Make sure the value pointed to by FSR is less than
; the value in W
; In:  W = the limit  FSR points to the value to limit.
;-------------------------------------------------------

Limit
	movwf	temp1			; Remember the limit
	
	clrw				; special case for zero limit
	subwf	temp1,W
	btfss	STATUS,Z		; if Z is set then limit is zero
	goto	limit_test	

	clrf	INDF			; return zero
	retlw	0
	
limit_test				; Check to see if we are under limit	
	movfw	INDF			; Get the value
	subwf	temp1, W		; w = limit - value
	btfsc	STATUS,Z		; if Z is set then equal
	goto	limit_too_high
	btfsc	STATUS,C		; if C is set, then value too high
	goto	limit_too_high

	retlw	0
	
limit_too_high				; Divide value in half
	bcf	STATUS,C
	rrf	INDF, F
	goto	limit_test
	










	
	END		
