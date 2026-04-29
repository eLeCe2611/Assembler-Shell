//-------------------------------------------------------------------
// Prototipo de la función usada para escribir caracteres, implementada en utils.s
void write_uart(unsigned int);

// Prototipo de funcion para pasar de enteros a cadena (ver mas adelante)
void _itoa(unsigned int val, char *buf, unsigned int base);

//-------------------------------------------------------------------
// Funcion que imprime una cadena por pantalla (UART0)
// Parametro de entrada 1 (R0) char *val --> apunta a la cadena a representar
void printString(char *str)
{
	while(*str != '\0')
		write_uart(*str++);
}

//-------------------------------------------------------------------
// Funcion que imprime un numero por pantalla en decimal (UART0)
// Parametro de entrada 1 (R0) int val --> valor a representar
void printInt(unsigned int val)
{
	char str[11];
	// itoa(val, str);
    _itoa(val,str,10);
	printString(str);
}

//-------------------------------------------------------------------
// Funcion que imprime un numero por pantalla en hexadecimal (UART0)
// Parametro de entrada 1 (R0) int val --> valor a representar
void printHex(unsigned int val)
{
	char str[11];
	_itoa(val,str,16);
	printString(str);
}

//-------------------------------------------------------------------
// Funcion que imprime un numero por pantalla en binario (UART0)
// Parametro de entrada 1 (R0) int val --> valor a representar
void printBin(unsigned int val)
{
	char str[33];
       _itoa(val,str,2);
	printString(str);
}

//----------------------------------------------------------------------
// Funcion que interpreta un numero en una cadena y devuelve el valor de dicho numero (en base decimal)
// Para cuando detecta el primer caracter no numerico. Por ejemplo ante "123as" devuelve el numero 123
// Parametro de entrada 1 (R0) char *val --> apunta a la cadena a convertir en numero 
// Parametro de salida (R0) --> devuelve el numero interpretado
int atoi(char *p) {
    int k = 0;
    while ( (*p - '0' >= 0) && (*p -'0' <= 9)) {
        k = (k << 3) + (k << 1) + (*p) - '0';
        p++;
     }
     return k;
}

//-----------------------------------------------------------------------
// Devuelve la longitud de una cadena
// Parametro de entrada: char *cad --> puntero a la cadena a ver su longitud
// Parametro de salida: int --> longitud de la cadena
int strlen(const char *s) {
    int cont=0;
    while (*s != 0) {
        cont++;
        s++;
    }
    return cont;
}

// Función que da la vuelta a una cadena
// Parametro de entrada: char *cad --> puntero a la cadena a dar la vuelta
// Parametro de salida: puntero a la misma cadena
char *reverse(char *cad) {
    int i = strlen(cad);
    i--;
    for (int j = 0; j < i; j++, i--) {
        char aux = cad[j];
        cad[j] = cad[i];
        cad[i] = aux;
    }
    return cad;
}

// Representa un entero en una cadena en la base indicada (binario, hexadecimal)
// Parametro de entrada 1 (R0) int val --> valor a representar
// Parametro de entrada 2 (R1) char *buf --> cadena donde se almacena la representacion (debe reservarse el espacio)
// Parametro de entrada 3 (R2) unsigned int base --> base de la representacion (2,8,10,16)
void _itoa(unsigned int val, char *buf, unsigned int base)
{
    int n_digits = 0;
    unsigned int digit;

    if (base != 2 && base != 10 && base != 16 && base != 8) {
        return;
    }

    do {
        if (base==10) {
            digit = val%10;
            val = val/10;
        } else if (base==2) { 
            digit = val&1;
            val = val >> 1;
        } else if (base==8) {
            digit = val&7;
            val = val >> 3;
        }else {
            digit = val&0xF;
            val = val >> 4;
        }
        if (digit < 10)
            buf[n_digits] = digit + '0';
        else
        {
            buf[n_digits] = digit + 'A' - 10;
        }
        n_digits++;
    } while (val != 0);
    buf[n_digits] = 0;
    reverse(buf);
}

// Funcion que representa un entero en una cadena en base decimal (10)
// Parametro de entrada 1 (R0) int val --> valor a representar
// Parametro de entrada 2 (R1) char *buf --> cadena donde se almacena la representacion (debe reservarse el espacio)
void itoa(unsigned int val, char *buf) {
    return _itoa(val, buf, 10);
}


//-----------------------------------------------------------------------
// Funcion para copiar cadenas
// Parametro de entrada 1 (R0) char *destination --> apunta a la cadena destino (donde se copiara la cadena)
// Parametro de entrada 2 (R1) char *source --> apunta a la cadena origen
// Parametro de entrada 3 (R2) int num --> longitud maxima a copiar

// Parametro de salida (R0) --> puntero a la cadena copiada
char* strncpy(char* destination, const char* source, int num)
{
	// return if no memory is allocated to the destination
	if (destination == 0)
		return 0;

	// take a pointer pointing to the beginning of destination string
	char* ptr = destination;

	// copy first num characters of C-string pointed by source
	// into the array pointed by destination
	while (*source && num--)
	{
		*destination = *source;
		destination++;
		source++;
	}

	// null terminate destination string
	*destination = '\0';

	// destination is returned by standard strncpy()
	return ptr;
}

//-----------------------------------------------------------------------
// Function to implement a variant of strncat() function
// Parametro de entrada 1 (R0) char *destination --> apunta a la cadena destino (donde se concatenará la cadena)
// Parametro de entrada 2 (R1) const char *addendum --> apunta a la cadena a concatenar
// Parametro de entrada 3. int num --> longitud total maxima

// Parametro de salida (R0) --> puntero a la cadena concatenada
char* strncat(char* destination, const char* addendum, int num) {
    int len_0 = strlen(destination);
    int len_1 = strlen(addendum);
    
    int char_to_copy = len_1;
    if (len_1 + len_0 > num) {
        char_to_copy = num - len_0;
    }
    
    return strncpy(destination + len_0,addendum, char_to_copy);
}

//-----------------------------------------------------------------------
// Compara dos cadenas
// Parametro de entrada 1 (R0) const char *c1 --> apunta a la primera cadena
// Parametro de entrada 2 (R1) const char *c2 --> apunta a la segunda cadena

// Parametro de salida (R0) int --> es 0 si las cadenas son iguales, >0 si c1 > c2.   <0 si c1 < c2
int strcmp(const char *c1, const char *c2) {
    char ret = *c1-*c2;
    while (ret == 0 && *c1 != 0) {
        c1 ++; c2++;
        ret = *c1 - *c2;
    }
    return ret;
}

//-----------------------------------------------------------------------
// Busca un caracter en una cadena. Devuelve la posicion de la primera ocurrencia
// Parametro de entrada 1 (R0) char c -->  caracter a buscar
// Parametro de entrada 2 (R1) char *s --> cadena donde se busca el caracter c

// Parametro de salida (R0) int --> -1 si no encuentra el caracter c. Posicion del primer caracter c en la cadena si lo encuentra
int find(const char c, char *s) {
    int cont = 0;
    while (*(s+cont)!= 0 && c != *(s+cont)) {
        cont++;
    }
    
    if (c != *(s+cont))
        return -1;
    
    return cont;
}

