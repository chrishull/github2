echo off
echo Building Color Project

echo Assembling...
mpasm color.asm /o /q
type color.err
mpasm utils.asm /o /q
type utils.err

echo Linking...
mplink color.o  utils.o %MPLAB_HOME%\lkr\16f84.lkr /o fader.hex

echo on


