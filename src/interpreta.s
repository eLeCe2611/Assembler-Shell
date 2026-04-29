.include "src/defs.s"

// Funcion que interpreta un comando
// In: r0 --> cadena a interpretar
// Devuelve: r0 == 0 --> comando ok
//  ERR_NON_VALID error en la instruccion
//  ERR_PARSE error en el parseo de una expresion
.global interpreta
interpreta:
        stmdb sp!, {r4-r10, lr}           // Para poder modificar registros --> salvaguardamos todos!
        sub sp,sp, #TAM_STRING            // Reservamos espacio en la pila para una variable auxilar tipo cadena de tamaño TAM_STRING 
        mov r10, #0          // r10 tiene el codigo de error. Antes de salir de la función lo copiaremos a r0 para retornar dicho valor

        bl ignora_espacios        
        mov r4, r0     		// r4 tiene el comando a interpretar sin espacios al principio

        bl strlen
        cmp r0,#0
        beq f_interpr // Si la cadena está vacía, retornamos

        // Nota: Para facilitar la manipulacion de registros virtuales --> guardamos el puntero a los registros en una etiqueta global (registros_virtuales)
        ldr r5,=registros_virtuales   // Ahora r5 apunta a la base de esos registros virtuales: un array de 10 words
comprueba_help:


        // Comparamos cadenas llamando a starts_with o strcmp (ver utils.s y auxiliar.c, respectivamente)

        // Ejemplo strcmp
        mov r0, r4
        ldr r1, =cmd_help	//primero vemos si es el comando es help
        bl strcmp
        cmp r0, #0		// r0=0 es que las cadenas son identicas
        beq ej_help

        // Ejemplo starts with
        @ mov r0, r4
        @ ldr r1, =cmd_help	//primero vemos si el comando empieza por help
        @ bl starts_with
        @ cmp r0, #1		// r0=1 es que empieza por help
        @ beq ej_help
            
        // TODO: Implementa los demas comandos!!!
        

comprueba_set:

	mov r0, r4
	ldr r1, =cmd_set_r
	bl starts_with
	cmp r0, #1
	beq ej_set

comprueba_imput:
	
	mov r0, r4
	ldr r1, =cmd_input
	bl starts_with
	cmp r0, #1
	beq ej_imput

comprueba_print:

	mov r0, r4
	ldr r1, =cmd_print
	bl starts_with
	cmp r0, #1
	beq ej_print
        
comprueba_list_reg:
	
	mov r0, r4
        ldr r1, =cmd_list_reg
        bl strcmp
        cmp r0, #0
        beq ej_list
        b error_cmd

ej_help:
        ldr r0, =mensaje_ayuda
        bl printString
        b f_interpr

ej_set:
	add r0, r4, #5
	bl atoi
	mov r6, r0
	cmp r0, #0
	blt error_cmd
	cmp r0, #9
	bhi error_cmd
	add r0, r4, #7
	bl atoi
	str r0, [r5, r6, lsl #2]
	b f_interpr
	
ej_imput:
	mov r0, sp
	bl get_line
	bl atoi
	mov r6, r0
	add r0, r4, #7
	bl atoi
	cmp r0, #0
	blt error_cmd
	cmp r0, #9
	bhi error_cmd
	str r6, [r5, r0, lsl #2]
	b f_interpr
	
get_line:
	stmdb sp!, {r4-r10, lr}
	mov r0, r4
	mov r6, #0

bucle_get_line:
	bl read_uart
	cmp r0, #'\n'
	beq fin_intro
	cmp r0, #'\r'
	beq fin_intro
	strb r0, [r4, r6]
	bl write_uart
	add r6, r6, #1
	b bucle_get_line

fin_intro:
	mov r0, #0
	strb r0, [r4, r6]
	mov r0, #'\n'
	bl write_uart
	mov r0, r4
	ldmia sp!, {r4-r10, lr}
	bx lr
	
ej_print:
	mov r7, #6
	ldrb r6, [r4, r7]
	cmp r6, #'\"'
	beq ej_print_str
	cmp r6, #'r'
	beq ej_print_reg
	b error_cmd
	
ej_print_str:
	add r7, r7, #1
	ldrb r6, [r4, r7]
	cmp r6, #'\"'
	beq fin_print
	mov r0, r6
	bl write_uart
	b ej_print_str

fin_print:
	mov r0, #'\n'
	bl write_uart
	b f_interpr

ej_print_reg:
	add r0, r4, #7
	bl atoi
	mov r6, r0
	ldrb r0, [r5, r6, lsl #2]
	bl printInt
	mov r0, #'\n'
	bl write_uart
	b f_interpr

ej_list:
	mov r6, #0


buc_list:
	mov r0, #'r'
	bl write_uart
	mov r0, r6
	bl printInt
	mov r0, #'='
	bl write_uart
	ldr r0, [r5, r6, lsl #2]
	add r6, r6, #1
	bl printInt
	mov r0, #'\n'
	bl write_uart
	cmp r6, #10
	beq f_interpr
	b buc_list
	
	

error_cmd:
        mov r10, #ERR_NON_VALID
        b f_interpr
        
f_interpr:
        mov r0, r10                  // Copiamos el codigo de error en r0, que guarda el valor de retorno
        add sp, #TAM_STRING         // Liberamos la variable auxiliar
        ldmia sp!, {r4-r10, pc}

.end
