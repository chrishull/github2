echo off
echo Building Blink project


echo Building Fader Project

echo Assembling...
mpasm fader.asm /o /q

echo Linking...
mplink fader.o %MPLAB_HOME%\lkr\16f84.lkr /o fader.hex
type fader.err

echo on


