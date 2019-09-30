/*
 * ej_parcial_2.asm
 *
 *  Created: 9/27/2019 12:45:01 PM
 *   Author: denise
 *	atmega328p
 */ 
;--------------------------------------------------------------------------------------------------------------
; Realizar una rutina que codifique un string ubicado en memoria de código.
; El dato se envía por el puerto serie usando la función EnviarCarácter() y 
; el argumento se pasa en el R7 "del banco 0. " (esto del banco es para un micro "antiguo" y puede ignorarse)
; La codificación es la siguiente: 
; case 1: si es un caracter alfabetico, se imprime la letra que está
;		tres posiciones por encima de la original (ejemplo: 'A' ---> 'D'). 
;		Si se llega al fin del alfabeto, se epmieza por el principio('Y'--->'B', 'x'--->'a'). 
; case 2: Si es un numero se codifica sumandole 17 al ASCII del número(ej:'0'=48--->48+17=65='A')
; default: Cualquier otro caracter se invierten los nibbles del valor ASCII (ej:'<'=60=0x3C--->0xC3=195).
;--------------------------------------------------------------------------------------------------------------
	.DSEG
	; .ORG 0x100 ; esto no va
VECTOR: .byte 1000
		
.DEF CARACT=R16
.DEF ASCII_A=R17
.DEF ASCII_Z=R18
.DEF ASCII_aMIN=R19
.DEF ASCII_zMIN=R20
.DEF ASCII_0=R21
.DEF ASCII_9=R22
.DEF STR_TER=R23

.EQU NUM=3

	.CSEG
	rjmp	MAIN	; Salteo los vectores de interrupción
	
	.org	INT_VECTORS_SIZE
MAIN:
	LDI R20,LOW(RAMEND)
	OUT SPL,R20
	LDI R20,HIGH(RAMEND)
	OUT SPH,R20 		; inicialicé el stack (OK)
	LDI ASCII_A,	0x41
	LDI ASCII_Z,	0x5A
	LDI ASCII_aMIN,	0x61
	LDI ASCII_zMIN,	122
	LDI ASCII_0,	0x30
	LDI ASCII_9,	0x39
	LDI STR_TER,	0xFF
	LDI ZL,LOW(2*T_ROM)
	LDI ZH,HIGH(2*T_ROM)
	LDI YL,LOW(VECTOR)
	LDI YH,HIGH(VECTOR)
	RCALL CODIFICAR_STRING
MAIN2:
	RJMP MAIN2		; Al terminar me quedo en un bucle infinito sin hacer nada

CODIFICAR_STRING:
LOOP1:
	LPM CARACT,Z+
	;CP STR_TER,CARACT	; error!
	CP CARACT, STR_TER	; es al revés.  Hay una forma más económica, sin usar un registro: 
	cpi CARACT, 0xFF	; se puede definir .EQU STR_TER = 0xFF
	BREQ OUT_1
	RCALL CODIFICAR_CARACTER
	ST Y+,CARACT
	RJMP LOOP1
OUT_1:
	RET


CODIFICAR_CARACTER:
	CP CARACT,ASCII_A
	BRSH CHEQUEAR_Z
	CP ASCII_9,CARACT	; AL REVÉS
	BRSH CHEQUEAR_0
	RJMP CODIFICAR_NIBBLE
RET_1:
	RET

CHEQUEAR_Z:
	CP ASCII_Z,CARACT	; AL REVÉS
	BRSH CODIFICAR_LETRA_MAYUSCULA
	CP CARACT,ASCII_aMIN
	BRLO CODIFICAR_NIBBLE
	CP ASCII_zMIN,CARACT
	BRSH CODIFICAR_LETRA_MINUSCULA
	RJMP CODIFICAR_NIBBLE

CHEQUEAR_0:
	CP CARACT,ASCII_0
	BRSH CODIFICAR_NUMERO
	RJMP CODIFICAR_NIBBLE

CODIFICAR_LETRA_MAYUSCULA:
	LDI R26,0x58
	LDI R27,NUM
	CP CARACT,R26
	BRSH LETRA_MAS_X
	ADD CARACT,R27
	RJMP RET_1

LETRA_MAS_X:
	LDI R27,26
	LDI R20,NUM
	SUB R27,R20
	SUB CARACT,R27
	RJMP RET_1

CODIFICAR_LETRA_MINUSCULA:
	LDI R26,0x78
	LDI R27,NUM
	CP CARACT,R26
	BRSH LETRA_MAS_xMIN
	ADD CARACT,R27
	RJMP RET_1

LETRA_MAS_xMIN:
	LDI R27,26
	LDI R20,NUM
	SUB R27,R20
	SUB CARACT,R27
	RJMP RET_1

CODIFICAR_NUMERO:
	LDI R27,17
	ADD CARACT,R27
	RJMP RET_1

CODIFICAR_NIBBLE:
	SWAP CARACT
	RJMP RET_1	
	
T_ROM: .DB "<12",0
