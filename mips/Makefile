ifndef CROSS_COMPILE
	CROSS_COMPILE = mipsel-linux-gnu-
endif

CC = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJDUMP = $(CROSS_COMPILE)objdump
TRANSLATE = $(OBJDUMP) -D $(OM_FILE) | sed '/__start/, /^$$/!d' | sed -n '1,/^$$/p' | sed  '/start/d' | awk -F " " '{print $$2}'

OBJECTS = inst_rom.o
OM_FILE = inst_rom.om

export CROSS_COMPILE

all: inst_rom.data

%.o: %.s
	$(CC) -EB -o $@ $<

inst_rom.om: $(OBJECTS)
	$(LD) -EB -o inst_rom.om inst_rom.o 

inst_rom.data: inst_rom.om
	$(TRANSLATE) > $@

clean:
	rm -f *.o *.om 
