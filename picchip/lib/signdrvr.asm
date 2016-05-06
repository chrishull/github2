;----------------------------------------------------------
; Shift Register LED Driver Routines
; This set of routines is designed to take a run length
; and sent it out to the shift registers.
;
; WARNING These methods work only with the 16F84
;
; (c) Christopher Hull, Spillikin Aerospace
;----------------------------------------------------------
	
	#include "w:\picchip\lib\xp.inc"
	
	; Methods used to send out data using run lengths
	global		ShiftOutClear, ShiftOutSign, GetLetter
	
	; GetLetter returns these values
	global		letter_bytes, letter_bits, sign_data, sign_letters
	
; ------------------------------
; Shift register memory allocation
; ------------------------------

	udata

; ------------------------------
; Used by low level routines.
; ------------------------------

; Passed to ShiftOutRL
shiftbytes	res	1

; Passed to ShiftOutBits
shiftvalue	res	1

; Passed to ShiftOutRL and ShiftOutBits
shiftbits	res	1

; ------------------------------
; Output by GetLetter and used by
; all Sign aware routines.
; ------------------------------

letter_bytes	res	1
letter_bits	res	1

; ------------------------------
; Misc
; ------------------------------

current_letter		res	1
temp1			res	1	

; ------------------------------
; Sign Data
; ------------------------------

; MUST BE INITIALIZED!!!
sign_letters	res	1
sign_data	res	.28



; ------------------------------
; Constants
; ------------------------------

; PORTB Pin assignments for shift registers
SHIFT_CLK	EQU	.1
SHIFT_DAT1	EQU	.2

;-------------------------------------------------------------------------
; PROG segment
;-------------------------------------------------------------------------
PROG	CODE



;-------------------------------------------------------------------------
; ShiftClear
; Clear out the given number of shift register bits.
; In: W = the number of bits to zero out.
;-------------------------------------------------------------------------

ShiftOutClear

	bcf	PORTA, SHIFT_DAT1
	movwf	temp1
sc_loop
	bcf	PORTA, SHIFT_CLK	;Clock down
	bsf	PORTA, SHIFT_CLK	;Clock up
	decfsz  temp1, F
	goto    sc_loop

	retlw	0x00
	
;-------------------------------------------------------------------------
; ShiftOutBits
; Given a byte of data to shift out, and a runlength value from 1 to 8,
; send the runlength number of bits out to the shift registers.
; In:   shiftvalue is the data to send out
;	shiftbits is the number of bits to actually send.
; Out:	Data is sent to the shift registers.
; 	ShiftValue and ShiftBits are not preserved.
;
; The least signifigant bits in the byte are shifted out first.  If 
; ShiftBits is a value less than 8, then - (shiftbits - 8) bits will be
; trimmed from the top of the byte.
;
; If the caller wishes to send out multple bytes, the last byte (or 
; partial byte) should be send first, then walk backward to the first
; byte.
;-------------------------------------------------------------------------

ShiftOutBits

; Elliminate high order bits that are not to be used if shiftbits is
; less than 8

	movlw	8
	movwf	temp1
sb_loop2
	movfw	temp1
	cmpwfse		shiftbits
	goto	sb_rot
	goto	sb_loop
	
sb_rot
	rlf	shiftvalue, F
	decf	temp1, F
	goto	sb_loop2

sb_loop
	bcf	PORTA, SHIFT_CLK	;Clock down
	
; Shift out bits from most to least signifigant.  That way high order pins on
; the registers will have high order data.

	; Set XP_PORTA according to the high bit
	btfsc	shiftvalue, 7
	goto	sb_skip
	bcf	PORTA, SHIFT_DAT1
	goto	sb_clock
sb_skip
	bsf	PORTA, SHIFT_DAT1

sb_clock
	
	bsf	PORTA, SHIFT_CLK	;Clock up
	rlf	shiftvalue, F

	decfsz  shiftbits, F
	goto    sb_loop

	retlw	0x00

;-------------------------------------------------------
; ShiftOutRL
; Shift out a runlength of bytes, pointed to by FSR
; 
; @param FSR points to the beginning of a runlength of bytes
;	to shift out to the registers
; @param shiftbytes is the number of bytes to shift out
; @param shiftbits is the number of bits in the last byte
;	to shift out.
; 
; This method shifts out the high order data, followed by
; lower order, til finished.
; FSR is changed by this call.
;-------------------------------------------------------
ShiftOutRL
	
	; Move FSR to the last byte in the array
	decf	shiftbytes, W		; shiftbytes is 1 based, so dec
	addwf	FSR, F			; FSR points to the last byte
	
	; Shift out the last partial byte
	movfw	INDF		; gets value pointed to by FSR
	movwf	shiftvalue
	call	ShiftOutBits

srl_loop	
	; Loop until all other whole bytes have been sent
	decfsz	shiftbytes, F
	goto	srl_run
	retlw	0x00

srl_run
	decf	FSR, F	
	; Shift out the whole byte pointed to by FSR
	movfw	INDF		; gets value pointed to by FSR
	movwf	shiftvalue
	movlw	0x08
	movwf	shiftbits
	call	ShiftOutBits
	
	goto	srl_loop

	
;-----------------------------------------------------------------------------
; The following functions operate on sign_data.
;
; sign_data is of the structure:
;	Each letter consists of the following.
;	(0) is the number of total bytes.
;	(1) is the number of bits used in the last byte.
;	(2 - n) is the data itself.
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
; GetLetter
; 
; This function navigates a Sign data structure.  This is the only function 
; that should do so.  WARNING: If W > the number of letters in sign_data
; this code breaks badly.
; 
; @param W: The letter number to be retrieved (one based).
; 
; @return
;	letter_bytes: The number of bytes in the current letter.
;	letter_bits: The number of bits used in the last byte.
;	FSR: Points to base of letter data.
; @uses temp1
;-----------------------------------------------------------------------------
GetLetter

	movwf	temp1
	movlw	sign_data
	movwf	FSR			; Point to first letter num_bytes
	
gl_loop
	movfw	INDF
	movwf	letter_bytes
	incf	FSR, F			; Point to num_bits
	movfw	INDF
	movwf	letter_bits
	incf	FSR, F			; Point to data

	decfsz	temp1, F		; If last letter return
	goto	gl_next_letter
	retlw	0x00

gl_next_letter	
	movfw	letter_bytes		; Add letter_bytes to FSR to skip to 
	addwf	FSR, F			; next letter position
	goto	gl_loop
	
;-------------------------------------------------------
; ShiftOutSign
; Shift out a list of run length arrays stored in sign_data
; 
; This method shifts out the last letter, followed by the previous,
; and so on so that letters can be stored in order.
;
; WARNING This methods changes letter_bytes and letter_bits
;-------------------------------------------------------
ShiftOutSign
	movfw	sign_letters		; Start with last letter
	movwf	current_letter

ss_loop	
	movfw	current_letter		; Point to the current_letter
	call	GetLetter		; result, FSR pointing to data
	
	movfw	letter_bytes		; set shiftbytes
	movwf	shiftbytes
	movfw	letter_bits		; set shiftbits
	movwf	shiftbits
	call	ShiftOutRL		; shift out them bytes
	
	decfsz	current_letter, F
	goto	ss_loop
	
	retlw	0x00
	

	END		
