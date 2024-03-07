//-----------------------------
// Title: Temp pic controller
//-----------------------------
// Purpose: It uses received reference temp and measured temp to decide whether
//    something needs to be cooled or heated or not. 
// Dependencies: newAsmTemplate.inc
// Compiler: IDE v6.20
// Author: Kyler Exley 
// OUTPUTS: heating,cooling, or nothing all steming from conreg value
// INPUTS: measured temp and refrence temp one from sensor the other from keypad 
// Versions:
//  	V6.20: today?s date - First version
//-----------------------------
#include ".\newAsmTemplate.inc"
#include <xc.inc>


#define  measuredTempInput 	0 ; this is the input value
#define  refTempInput		15 ; this is the input value
;---------------------
; Definitions
;---------------------
#define SWITCH    LATD,2
#define LED0      PORTD,0
#define LED1	  PORTD,1
#define conReg    0x22
    
 
;---------------------
; Code
;---------------------
PSECT absdata,abs,ovrld
    ORG 0x20
start:
    //sets all values to zero so I can repeat
    MOVLW 0
    MOVWF TRISD,0
    MOVWF 0x23
    MOVWF 0x24
    MOVWF 0x60
    MOVWF 0x61
    MOVWF 0x70
    MOVWF 0x71
    MOVWF 0x22
    
    //sets reg20 and 21 to temp values
    MOVLW refTempInput
    MOVWF 0x20,0
    MOVLW measuredTempInput
    MOVWF 0x21,0
    BTFSC 0x21,7  //If measured temp value has negative bit 7 set go to negative
    goto Negative  //If measured temp is not negative at bit 7 skip this line
   
    //initialized values for hex to dec conversion
    MOVLW measuredTempInput
    MOVWF 0x24	//reg 24 for measured temp hex to dec conversion
    MOVLW refTempInput
    MOVWF 0x23	//reg 23 for reference temp
    
    //converts hex to dec for ref
Decimal1:
    MOVLW 0x0A
    SUBWF 0x23,1    //subtracts A from reg 23
    INCF 0x61	//increments reg  up 1
    BTFSS 0x23,7    //if reg 23 negative skip next line
    BRA Decimal1    //subtract reg 23 again by going back to Decimal1
    DECF 0x61	//decrements reg 61 by 1 for looping one extra time
    MOVLW 0x0A	
    ADDWF 0x23,1    //adds back A to reg 23 to get remainder
    MOVFF 0x23,0x60 //puts reg 23 in reg 60
    
    //converts hex to dec for measured
Decimal2:
    MOVLW 0x0A
    SUBWF 0x24,1    //subtracts A from reg 24
    INCF 0x71	   //increments reg 71  up 1
    BTFSS 0x24,7    //skips next line if becomes negative
    BRA Decimal2    //reapeat
    DECF 0x71	//decrements reg 71 for extra loop counted
    MOVLW 0x0A
    ADDWF 0x24,1    //adds A back to reg 24 to get reamainder for Reg70
    MOVFF 0x24,0x70
    
    MOVFF 0x20,WREG
    CPFSGT  0x21,0  //if measured temp greater than reference temp skip next line
    BRA	Lessthan    //if not greater than go to check if lessthan
    BRA	Cool	//if greater than go to cool
    
Lessthan:	
    CPFSLT  0x21,0  //if measured temp less than refrence temp skip next line
    BRA	Equalto	//if not greater than or lessthan, it is Equalto
    BRA	Hot	//if it is lessthan go to Hot
    
Equalto:	
	BRA Nothing //go to nothing
	
Cool:
     MOVLW 2
     MOVWF conReg,1 //sets conReg at reg 22 to 2
     BRA done	//go to done
     
Negative:
    //negative hex to dec conversion variable initialization
    NEGF 0x21	//negate 2s compliment turns value positive
    MOVFF 0x21,0x24 //sets reg 24 to positive value of measured temp
    MOVLW refTempInput
    MOVWF 0x23	//sets reg 23 to refrence temp
    
//Same Hex to dec conversion for ref temp but for when measured temp is negative
Decimal3:
MOVLW 0x0A
    SUBWF 0x23,1
    INCF 0x61
    BTFSS 0x23,7
    BRA Decimal3
    DECF 0x61
    MOVLW 0x0A
    ADDWF 0x23,1
    MOVFF 0x23,0x60
    
//Same Hex to dec conversion for measured temp but for when measured temp is negative
Decimal4:   
    MOVLW 0x0A
    SUBWF 0x24,1
    INCF 0x71
    BTFSS 0x24,7
    BRA Decimal4
    DECF 0x71
    MOVLW 0x0A
    ADDWF 0x24,1
    MOVFF 0x24,0x70
    
//goto hot when negative because measured is garenteed to be less than reference
    goto Hot	
    
Hot:
    MOVLW 1
    MOVWF conReg,1  //sets conReg to 1 go to done
    BRA done
    
Nothing:
    MOVLW 0
    MOVWF conReg,1  //sets conReg to 0 go to done
    BRA done
    
done:
RLNCF 0x22,0	//rotate conReg to the left to multiply value by 2 for ports
MOVWF LED0  //place it in Wreg and set both Ports to its value
MOVWF LED1
    
goto start




sleep
    

