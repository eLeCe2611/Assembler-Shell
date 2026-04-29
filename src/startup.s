.include "src/defs.s"

.text

.globl _start
_start:     		ldr pc,reset_handler_d		// Exception vector
					ldr pc,undefined_handler_d
					ldr pc,swi_handler_d
					ldr pc,prefetch_handler_d
					ldr pc,data_handler_d
					ldr pc,unused_handler_d
					ldr pc,irq_handler_d
					ldr pc,fiq_handler_d

reset_handler_d:    .word reset_handler
undefined_handler_d:.word hang
swi_handler_d:      .word swi_handler
prefetch_handler_d: .word hang
data_handler_d:     .word hang
unused_handler_d:   .word hang
irq_handler_d:      .word hang
fiq_handler_d:      .word hang

// SWI handler routine.............................................
reset_handler:		
                    mov r0,#0x10000				// Copy exception vector
					mov r1,#0x00000
					ldmia r0!,{r2,r3,r4,r5,r6,r7,r8,r9}
					stmia r1!,{r2,r3,r4,r5,r6,r7,r8,r9}
					ldmia r0!,{r2,r3,r4,r5,r6,r7,r8,r9}
					stmia r1!,{r2,r3,r4,r5,r6,r7,r8,r9}
					msr cpsr_c,#0xD1			// FIQ 110 10001
					ldr sp,=FIQ_STACK_TOP
					msr cpsr_c,#0xD2			// IRQ 110 10010
					ldr sp,=IRQ_STACK_TOP
					msr cpsr_c,#0xD3			// SVC 110 10011
					ldr sp,=SVC_STACK_TOP
					msr cpsr_c,#0xD7			// ABT 110 10111
					ldr sp,=ABT_STACK_TOP
					msr cpsr_c,#0xDB			// UND 110 11011
					ldr sp,=UND_STACK_TOP
					msr cpsr_c,#0xD0			// USER 110 10000
					ldr sp,=SYS_STACK_TOP
					b main						// start main
    
.global hang
hang:				b hang
				
// declaracion de punteros a cadenas.............................

str_swi:			.asciz "swi "
msg_error:			.asciz "Parametro Desconocido"	//de C3
msg_spsr:			.asciz "Contenido spsr: "
msg_irq_on:			.asciz "Se habilita irq.\t"
msg_irq_off:		.asciz "Se deshabilita irq.\t"
msg_fiq_on:			.asciz "Se habilita fiq.\t"
msg_fiq_off:		.asciz "Se deshabilita fiq.\t"
                                
.align

// SWI handler routine...........................................

swi_handler: 		stmfd sp!,{r0-r9,lr}		
					ldr r5,[lr,#-4]		//direccion de swi
					bic r5,r5,#0xff000000	//lee el codigo de swi (campo de datos, borramos codigo operacion)

				//imprime en pantalla "swi"
					ldr r0,=str_swi		
					bl printString
					mov r0,r5		//imprime en pantalla el swi code
					bl printInt
					mov r0,#'\n'		//imprime en pantalla enter
					bl write_uart

				// TODO: Añadir aqui el codigo de C2 y C3 de la EPD6

				//TODO: añadir codigo de C4 de la EPD6 (solo para parte opcional 10)

swi_error:		
					ldr r0,=msg_error	//pone el mensaje de error
					bl printString
					mov r0,#'\n'		//enter
					bl write_uart
					b fin_swi_handler

	
fin_swi_handler:			ldmfd sp!,{r0-r9,pc}^	//C3 modifico para recuperar todos

muestra_spsr:		stmfd sp!,{lr}
					ldr r0,=msg_spsr
					bl printString
					mrs r0,spsr
					bl printHex
					mov r0,#'\ '		//enter
					bl write_uart
					mrs r0,spsr
					bl printBin
					mov r0,#'\n'		//enter
					bl write_uart
					ldmfd sp!,{pc}

.end
