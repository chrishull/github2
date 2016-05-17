;PULSE WIDTH MODULATION CONTROLLER FOR RGB LED LIGHTS
;
;COPYRIGHT CLIVE MITCHELL
;
;YOU ARE WELCOME TO USE THIS SOFTWARE FOR NON COMMERCIAL USE.
;
;THE PROGRAM IS DESIGNED TO DRIVE THREE CHANNELS OF LED'S (RGB)
;MAKING THEM DIM AT A PRESET SPEED THROUGH A PSUEDO RANDOM SEQUENCE OF LEVELS.
;EACH CHANNEL DIMS INDEPENDENTLY THROUGH A LOOKUP TABLE OF INTENSITY VALUES
;GIVING A CONTINUOUSLY CHANGING COLOR FROM THE COMBINED OUTPUT OF THE LED'S
;
;THIS SOFTWARE IS TO COMPLEMENT THE PCB DESIGNS AND THE LED MODULES SHOWN ON-SITE
;AT HTTP://WWW.BIGCLIVE.COM
;
;PROCESSOR PIC12C508A
;
;WHEN PROGRAMMING CHIP, SET:-
;OSCILLATOR = INTERNAL RC
;WATCHDOG = ON
;PROTECT = ON OR OFF
;MASTER CLEAR (MCLR) = INTERNAL
;
;PORTS USED:
;
;GP0 = BLUE OUTPUT
;GP1 = GREEN OUTPUT
;GP2 = RED OUTPUT
;GP3 = UNUSED (PULL UP ENABLED)
;GP4 = UNUSED ASSIGNED AS OUTPUT
;GP5 = UNUSED ASSIGNED AS OUTPUT
;
;AT STARTUP THE UNIT WILL AUTOMATICALLY FADE FROM OFF TO FULL WHITE,
;THEN START CYCLING.
;
;HERE WE GO...

        LIST    P=12C508	;TELLS THE ASSEMBLER THE TARGET PROCESSOR

SPEED   EQU     .40		;SPEED SETTING (HIGHER IS SLOWER) ADJUST IF DESIRED.

START   MOVLW   b'10001111'	;LOAD THE OPTION REGISTER
        OPTION
        CLRF	6		;CLEAR THE OUTPUT PORT (FILE 6)
	MOVLW   b'00000000'     ;SET PORTS (ALL AS OUTPUT)
        TRIS	6		;GP3 IS AN INPUT AND NOT AFFECTED
        CLRF    .15             ;RESET LOOK-UP POINTERS
        CLRF    .16		;TO BEGINNING OF LOOKUP TABLES
        CLRF    .17
        MOVLW   .255
        MOVWF   .25             ;PRESET TARGET INTENSITIES AT FULL
        MOVWF   .26		;THIS IS FOR THE INITIAL RAMP UP TO FULL OUTPUT
        MOVWF   .27
        CLRF    .11             ;PRESET ACTUAL INTENSITIES AT ZERO
        CLRF    .12		;THIS WILL DETERMINE THE START POINT OF THE INITIAL
        CLRF    .13		;INTENSITY RAMP UP.

;CHANNEL CONTROL MODULES START HERE
;THIS SECTION CONTROLS THE RAMPING UP AND DOWN OF THE INTENSITIES

REDLVL  BTFSC   .15,0           ;TEST DIMMING DIRECTION BIT
        DECF    .11             ;INCREASE LEVEL
        BTFSS   .15,0           ;TEST DIMMING DIRECTION BIT
        INCF    .11             ;DECREASE LEVEL
        MOVF    .25,0           ;TARGET LEVEL TO W
        XORWF   .11,0           ;COMPARE WITH INTENSITY
        BTFSS   .3,2            ;TEST FOR ZERO (MATCH)
        GOTO    GRNLVL		;IF INTENSITY NOT REACHED THEN NEXT CHANNEL
        INCF    .15             ;INCREMENT LOOK-UP POSITION
        MOVLW   b'00001111'     ;MASK OFF MSB'S
        ANDWF   .15,0           ;CONDITION LOOK-UP POSITION TO W
        CALL    LOOK1           ;FETCH NEW TARGET LEVEL
        MOVWF   .25             ;RESULT TO TARGET
GRNLVL  BTFSC   .16,0
        DECF    .12
        BTFSS   .16,0
        INCF    .12
        MOVF    .26,0
        XORWF   .12,0
        BTFSS   .3,2
        GOTO    BLULVL
        INCF    .16
        MOVLW   b'00001111'
        ANDWF   .16,0
        CALL    LOOK2
        MOVWF   .26
BLULVL  BTFSC   .17,0
        DECF    .13
        BTFSS   .17,0
        INCF    .13
        MOVF    .27,0
        XORWF   .13,0
        BTFSS   .3,2
        GOTO    PWM
        INCF    .17
        MOVLW   b'00001111'
        ANDWF   .17,0
        CALL    LOOK3
        MOVWF   .27


;PULSE WIDTH MODULATION OUTPUT DRIVER
;THIS SECTION CONTROLS THE INTENSITY OF THE LED'S BY PULSING THEM AT
;A VARIABLE MARK TO SPACE RATIO

PWM     MOVLW   SPEED           ;NUMBER OF PWM REPS PER LEVEL
        MOVWF   .10
PWMLOOP CLRWDT
        MOVF    .11,0           ;MOVE INTENSITY FILE TO W
        MOVWF   .21             ;MOVE W TO COUNTING FILE
        MOVF    .12,0
        MOVWF   .22
        MOVF    .13,0
        MOVWF   .23
        CLRF    .8              ;F8 IS THE PWM COUNTER
REDPWM  INCFSZ  .21             ;CHANNEL 1 LEVEL
        GOTO    GRNPWM		;IF NOT ZERO GO TO GREEN CHANNEL
        BSF     6,2             ;IF ZERO, SWITCH ON RED LED'S
GRNPWM  INCFSZ  .22             ;CHANNEL 2 LEVEL
        GOTO    BLUPWM		;IF NOT ZERO GO TO BLUE CHANNEL
        BSF     6,1             ;IF ZERO, SWITCH ON GREEN LED'S
BLUPWM  INCFSZ  .23             ;CHANNEL 3 LEVEL
        GOTO    CHAN		;IF NOT ZERO GO TO NEXT CHANNEL
        BSF     6,0             ;IF ZERO, SWITCH ON BLUE LED'S
CHAN    INCFSZ  .8              ;INCREMENT STEP LOOP
        GOTO    REDPWM          ;NEXT STEP LOOP
        CLRF    6               ;TURN OFF LED'S
        DECFSZ  .10		;DECREMENT SPEED PRESCALER
        GOTO    PWMLOOP		;IF NOT ZERO KEEP PWM,ING
        GOTO	REDLVL		;IF ZERO THEN GET NEXT INTENSITIES

;INTENSITY LOOKUP TABLES
;THESE ARE THE THREE TABLES THAT HOLD THE TARGET INTENSITIES FOR EACH COLOUR.
;YOU CAN VARY THESE VALUES IF YOU WISH.

LOOK1   ADDWF   .2		;RED LOOKUP TABLE
        RETLW   .200		;IF YOU WANT TO MODIFY THE LOOKUP TABLES
        RETLW   .87		;THEN REMEMBER THAT THE FIRST VALUE IS HIGH
        RETLW   .153		;THEN THE SECOND VALUE IS LOWER, THEN HIGHER ETC.
        RETLW   .20
        RETLW   .240
        RETLW   .130
        RETLW   .210		;IF YOU WANTED TO HAVE A BIAS TO GREEN/BLUE, THEN
        RETLW   .5		;YOU COULD PROGRAM REDS LOOKUP TABLE TO BOUNCE AT
        RETLW   .123		;LOWER LEVELS.
        RETLW   .15
        RETLW   .237		;DON'T GO BELOW ABOUT 5, SINCE THE VERY LOWEST LEVELS
        RETLW   .140		;MAY SHOW A VISIBLE STEPPING OF INTENSITY.
        RETLW   .254		;(AS SEEN IN THE SELF TEST AT SWITCH ON)
        RETLW   .167
        RETLW   .240
        RETLW   .6

LOOK2   ADDWF   .2		;GREEN LOOKUP TABLE
        RETLW   .140
        RETLW   .5
        RETLW   .110
        RETLW   .10
        RETLW   .240
        RETLW   .137
        RETLW   .221
        RETLW   .48
        RETLW   .160
        RETLW   .72
        RETLW   .250
        RETLW   .136
        RETLW   .230
        RETLW   .6
        RETLW   .132
        RETLW   .40

LOOK3   ADDWF   .2		;BLUE LOOKUP TABLE
        RETLW   .110
        RETLW   .20
        RETLW   .147
        RETLW   .5
        RETLW   .254
        RETLW   .162
        RETLW   .210
        RETLW   .37
        RETLW   .160
        RETLW   .42
        RETLW   .231
        RETLW   .100
        RETLW   .210
        RETLW   .8
        RETLW   .104
        RETLW   .39

        END		;END OF PROGRAM.  SHORT AND SWEET, JUST HOW IT SHOULD BE.



