AS_FLAG = --32
GDB_FLAG = -gstabs
LD_FLAG = -m elf_i386

all: bin/pianificatore

obj/pianificatore.o: src/pianificatore.s
	as $(AS_FLAG) $(GDB_FLAG) src/pianificatore.s -o obj/pianificatore.o
	

obj/risultati.o: src/risultati.s
	as $(AS_FLAG) $(GDB_FLAG) src/risultati.s -o obj/risultati.o


obj/Penalty.o: src/Penalty.s
	as $(AS_FLAG) $(GDB_FLAG) src/Penalty.s -o obj/Penalty.o
	
bin/pianificatore:obj/pianificatore.o obj/risultati.o obj/Penalty.o
	ld $(LD_FLAG) obj/pianificatore.o obj/risultati.o obj/Penalty.o -o bin/pianificatore
	
clean:
	rm -f obj/* bin/*
