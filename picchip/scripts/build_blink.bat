echo off
echo Building Blink project


echo Building Blink.asm

echo Assembling...
mpasm blink.asm /o /q

echo Linking...
mplink blink.o %MPLAB_HOME%\lkr\16f84.lkr /o mast.hex
type blink.err

echo on


