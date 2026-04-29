
#ARMGNU ?= arm-none-eabi
ARMGNU ?= arm-linux-gnueabi

AARCH = -march=armv5t
AOPS = --warn --fatal-warnings $(AARCH)
COPS = -Wall -O2 -nostdlib -nostartfiles -ffreestanding $(AARCH)

# Cuidado, startup debe ser el primer objeto!!!
OBJETOS = startup.o datos.o utils.o interpreta.o auxiliar.o

all : test.bin main.bin

test.bin : $(OBJETOS) test.o memmap
	$(ARMGNU)-ld $(OBJETOS) test.o -T memmap -o test.elf
	$(ARMGNU)-objdump -D test.elf > test.list
	$(ARMGNU)-objcopy test.elf -O binary test.bin

main.bin : $(OBJETOS) main.o memmap
	$(ARMGNU)-ld $(OBJETOS) main.o -T memmap -o main.elf
	$(ARMGNU)-objdump -D main.elf > main.list
	$(ARMGNU)-objcopy main.elf -O binary main.bin

datos.o : src/datos.s src/defs.s
	$(ARMGNU)-as $(AOPS) src/datos.s -o datos.o

interpreta.o : src/interpreta.s src/defs.s src/datos.s
	$(ARMGNU)-as $(AOPS) src/interpreta.s -o interpreta.o

main.o : src/main.s src/defs.s src/datos.s
	$(ARMGNU)-as $(AOPS) src/main.s -o main.o

test.o : src/test.s
	$(ARMGNU)-as $(AOPS) src/test.s -o test.o

startup.o : src/startup.s src/defs.s
	$(ARMGNU)-as $(AOPS) src/startup.s -o startup.o
	
utils.o : src/utils.s src/defs.s
	$(ARMGNU)-as $(AOPS) src/utils.s -o utils.o
	
auxiliar.o : src/auxiliar.c 
	$(ARMGNU)-gcc -c $(COPS) src/auxiliar.c -o auxiliar.o

clean :
	rm -f *.o
	rm -f *.elf
	rm -f *.bin
	rm -f *.list

