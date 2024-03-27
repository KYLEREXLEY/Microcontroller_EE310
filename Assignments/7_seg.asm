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
COUNTER equ     23h    //FSR counter reg
REG20   equ     20h    //outer loop counter reg
REG21   equ     21h    //inner loop counter reg
REG22   equ     22h    //innner inner loop counter reg
    
    PSECT absdata,abs,ovrld
    //initialization
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
//7-segment display values 0-F put in reg 0-F for FSR
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
    MOVWF COUNTER    //sets FSR counter to zero
    
    
    LFSR 0,0x00    //sets LFSR to reg0
    
    MOVLW 0xFF
    MOVWF TRISC    //sets PortC as input for push buttons A and B
    MOVFF INDF0,PORTD    //dsiplays zero
    CALL STALL
TEST:
    BTFSC PORTC,4    //tests button A if pressed go to countup
    GOTO COUNTUP
    BTFSC PORTC,3    //tests button B if pressed go to countdown
    GOTO COUNTDOWN
    GOTO TEST        //repeat
    
COUNTUP:
    BTFSC PORTC,3
    CALL STOP        //if button B is also pressed goto stop
    MOVFF PREINC0,PORTD    //increment FSR up and then display
    CALL STALL        //go to stall function to stall for half a second
    MOVLW 0x0E       
    CPFSEQ COUNTER    //if counter equals second to last value go to endcase1
    INFSNZ COUNTER,1    //increment counter up to match FSR reg value
    GOTO ENDCASE1    
    CALL TEST1        //test
    GOTO COUNTUP        //repeat
COUNTDOWN:
    BTFSC PORTC,4
    CALL STOP
    LFSR 0,0x0F    //sets first shown value to last reg value 
    MOVLW 0x0F
    MOVWF COUNTER     //sets counter to same
COUNTDOWN1:
    MOVFF POSTDEC0,PORTD    //displays value then decrements down
    CALL STALL    //stall
    DCFSNZ COUNTER,1    //decrements counter to same value as reg value the pointer is pointing at 
    GOTO ENDCASE2    //if zero it means it displays 1 but the pointer and counter are still at zero so it goes to endcase2
    CALL TEST2
    GOTO COUNTDOWN1    //repeat
TEST1:
    BTFSS PORTC,4    //if button A isnt pressed goto wait
    GOTO WAIT1	
    BTFSC PORTC,3    //if button B is also pressed go to stop
    GOTO STOP
    RETURN    //return back to subroutine
TEST2:
    BTFSS PORTC,3    //if button B is stopped being pressed goto wait
    GOTO WAIT2
    BTFSC PORTC,4    //if button A is also pressed goto Stop
    GOTO STOP
    RETURN
STALL:
    MOVLW       Inner_loop    //initialize stalling values
    MOVWF       REG20
    MOVLW       Inner_Inner_loop
    MOVWF       REG22
    MOVLW       Outer_loop
    MOVWF       REG21
_loop1:
_loop2:
    DECF	REG22,1
    BNZ		_loop2    //inner_inner_loop
    MOVLW	Inner_Inner_loop
    MOVWF	REG22
    DECF        REG21,1 
    BNZ         _loop2    //inner_loop
    DECF        REG20,1
    BNZ         _loop1    //outerloop
    RETURN
STOP:
    LFSR 0,0x00    //returns FSR back to reg 0
    MOVFF INDF0,PORTD    //displays zero
    CALL STALL    //stalls for waiting for input
    BTFSS PORTC,4    //if either button is pressed reset from start
    GOTO START
    BTFSS PORTC,3
    GOTO START
    GOTO STOP
WAIT1:    //wait function for countup
    CALL STALL    //stalls for waiting for input
    BTFSC PORTC,4    //if buttonA is pressed goto return1
    GOTO RETURN1
    BTFSC PORTC,3    //if buttonB is pressed goto return2
    GOTO RETURN2
    GOTO WAIT1
WAIT2:    //wait function for countdown
    CALL STALL
    BTFSC PORTC,4    //if buttonA is pressed goto return3
    GOTO RETURN3
    BTFSC PORTC,3    //if buttonB is pressed goto return4
    GOTO RETURN4
    GOTO WAIT2
RETURN1:    //return to countup function from countup previously
    CALL TEST1
    MOVLW 0x0F
    CPFSEQ COUNTER    //if counter is at max value reset back to start
    GOTO COUNTUP    //otherwise goback to countup
    GOTO START
RETURN2:    //return to countdown function from countup previously
    CALL TEST2
    MOVLW 0x00
    CPFSEQ COUNTER    //if counter is at min value go back to start
    GOTO COUNTDOWN1    //otherwise go to countdown1
    GOTO START
RETURN3:    //return to countup function from countdown previously
    CALL TEST1
    MOVLW 0x0F    
    CPFSEQ COUNTER    //Return3 and 4 are same as 1 and 2 and are just called from different places
    GOTO COUNTUP      //I did this for easier error testing and to know where things went
    GOTO START
RETURN4:    //return to countdown function from countdown previously
    CALL TEST2
    MOVLW 0x00
    CPFSEQ COUNTER
    GOTO COUNTDOWN1
    GOTO START
ENDCASE1:    //endcase scenario for countup 
    INCF COUNTER,1    //increments counter from 0E to 0F because it previously skipped the last increment
    GOTO RETURN1    //now that counter and FSR pointer are both 0F goes back through return1 to test if counter matches 0F 
ENDCASE2:    //endcase scenario for countdown
    GOTO RETURN4    //since the counter is same number as displayed since its postdecrement and not pre
                    //the endcase can goto return4 like normal and just check for if counter is zero
    
