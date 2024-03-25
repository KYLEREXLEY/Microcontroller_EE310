//-----------------------------
// Title: 7-segment display
//-----------------------------
// Purpose: To increment a counting 7-segment display using 
// 2 push buttons.
// Dependencies: newAsmTemplate.inc
// Compiler: IDE v6.20
// Author: Kyler Exley 
// OUTPUTS: 7-segmment display
// INPUTS: Button A,Button B
// Versions:
//  	V6.20: 3/23/2024 - First version
//-----------------------------
#include ".\newAsmTemplate.inc"
#include <xc.inc>

Inner_loop  equ 255
Inner_Inner_loop equ 1
Outer_loop  equ 255
COUNTER equ     23h
REG20   equ     20h   // in HEX
REG21   equ     21h
REG22   equ     22h
    
    PSECT absdata,abs,ovrld
    
    ORG 0x20    
    BANKSEL ANSELC
    CLRF ANSELC
    BANKSEL LATC
    CLRF LATC
    BANKSEL TRISC
    CLRF TRISC
    BANKSEL PORTC
    CLRF PORTC
    BANKSEL PORTD
    CLRF PORTD
    BANKSEL LATD
    CLRF LATD
    BANKSEL ANSELD
    CLRF ANSELD
    BANKSEL TRISD
    CLRF TRISD
    CLRF FSR0L
    CLRF FSR0H
START:
    MOVLW 0xC0
    MOVWF 0x00
    MOVLW 0xF9
    MOVWF 0x01
    MOVLW 0xA4
    MOVWF 0x02
    MOVLW 0xB0
    MOVWF 0x03
    MOVLW 0x99
    MOVWF 0x04
    MOVLW 0x92
    MOVWF 0x05
    MOVLW 0x82
    MOVWF 0x06
    MOVLW 0xF8
    MOVWF 0x07
    MOVLW 0x80
    MOVWF 0x08
    MOVLW 0x90
    MOVWF 0x09
    MOVLW 0x88
    MOVWF 0x0A
    MOVLW 0x83
    MOVWF 0x0B
    MOVLW 0xC6
    MOVWF 0x0C
    MOVLW 0xA1
    MOVWF 0x0D
    MOVLW 0x86
    MOVWF 0x0E
    MOVLW 0x8E
    MOVWF 0x0F
    MOVLW 0x00
    MOVWF COUNTER
    
    
    LFSR 0,0x00
    
    MOVLW 0xFF
    MOVWF TRISC
    MOVFF INDF0,PORTD
    CALL STALL
TEST:
    BTFSC PORTC,4
    GOTO COUNTUP
    BTFSC PORTC,3
    GOTO COUNTDOWN
    GOTO TEST
    
COUNTUP:
    BTFSC PORTC,3
    CALL STOP
    MOVFF PREINC0,PORTD
    CALL STALL
    MOVLW 0x0E
    CPFSEQ COUNTER
    INFSNZ COUNTER,1
    GOTO ENDCASE1
    CALL TEST1
    GOTO COUNTUP
COUNTDOWN:
    BTFSC PORTC,4
    CALL STOP
    LFSR 0,0x0F
    MOVLW 0x0F
    MOVWF COUNTER
COUNTDOWN1:
    MOVFF POSTDEC0,PORTD
    CALL STALL
    DCFSNZ COUNTER,1
    GOTO ENDCASE2
    CALL TEST2
    GOTO COUNTDOWN1
TEST1:
    BTFSS PORTC,4
    GOTO WAIT1	
    BTFSC PORTC,3
    GOTO STOP
    RETURN
TEST2:
    BTFSS PORTC,3
    GOTO WAIT2
    BTFSC PORTC,4
    GOTO STOP
    RETURN
STALL:
    MOVLW       Inner_loop
    MOVWF       REG20
    MOVLW       Inner_Inner_loop
    MOVWF       REG22
    MOVLW       Outer_loop
    MOVWF       REG21
_loop1:
_loop2:
    DECF	REG22,1
    BNZ		_loop2
    MOVLW	Inner_Inner_loop
    MOVWF	REG22
    DECF        REG21,1 
    BNZ         _loop2
    DECF        REG20,1
    BNZ         _loop1
    RETURN
STOP:
    LFSR 0,0x00
    MOVFF INDF0,PORTD
    MOVFF POSTINC0,PORTD
    CALL STALL
    BTFSS PORTC,4
    GOTO START
    BTFSS PORTC,3
    GOTO START
    GOTO STOP
WAIT1:
    CALL STALL
    BTFSC PORTC,4
    GOTO RETURN1
    BTFSC PORTC,3
    GOTO RETURN2
    GOTO WAIT1
WAIT2:
    CALL STALL
    BTFSC PORTC,4
    GOTO RETURN3
    BTFSC PORTC,3
    GOTO RETURN4
    GOTO WAIT2
RETURN1:
    CALL TEST1
    MOVLW 0x0F
    CPFSEQ COUNTER
    GOTO COUNTUP
    GOTO START
RETURN2:
    CALL TEST2
    MOVLW 0x00
    CPFSEQ COUNTER
    GOTO COUNTDOWN1
    GOTO START
RETURN3:
    CALL TEST1
    MOVLW 0x0F
    CPFSEQ COUNTER
    GOTO COUNTUP
    GOTO START
RETURN4:
    CALL TEST2
    MOVLW 0x00
    CPFSEQ COUNTER
    GOTO COUNTDOWN1
    GOTO START
ENDCASE1:
    INCF COUNTER,1
    GOTO RETURN1
ENDCASE2:
    GOTO RETURN4
    