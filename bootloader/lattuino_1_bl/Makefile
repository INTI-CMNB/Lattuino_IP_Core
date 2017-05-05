#!/usr/bin/make
OBJDIR=../../Work
PRJ=lattuino_1_bl
# Size 0x290 b 0x148 w
# 2 kib 0x800 b 0x400 w
START_B_2=0x570
START_W_2=0x2B8
AVRCPU_2=attiny25
AVRCPU_2S=attiny22
# 4 kib 0x1000 b 0x800 w
START_B_4=0xD70
START_W_4=0x6B8
AVRCPU_4=attiny45
# 8 kib 0x2000 b 0x1000 w
START_B_8=0x1D70
START_W_8=0xEB8
AVRCPU_8=attiny85

all: $(OBJDIR) $(OBJDIR)/$(PRJ)_8.vhdl $(OBJDIR)/$(PRJ)_4.vhdl $(OBJDIR)/$(PRJ)_2.vhdl \
	$(OBJDIR)/$(PRJ)_2s.vhdl

$(OBJDIR):
	mkdir $(OBJDIR)

$(OBJDIR)/%.lst: $(OBJDIR)/%.elf
	avr-objdump -h -S $< > $@

$(OBJDIR)/%.bin: $(OBJDIR)/%.elf
	avr-objcopy -O binary $< $@


$(OBJDIR)/$(PRJ)_8.elf: bootloader.c Makefile
	avr-gcc -g -Os -mmcu=$(AVRCPU_8) -D__$(AVRCPU_8)__ -Wl,-Map,$(OBJDIR)/$(PRJ)_8.map,--section-start=.text=$(START_B_8) $< -o $@

$(OBJDIR)/$(PRJ)_4.elf: bootloader.c Makefile
	avr-gcc -g -Os -mmcu=$(AVRCPU_4) -D__$(AVRCPU_4)__ -Wl,-Map,$(OBJDIR)/$(PRJ)_4.map,--section-start=.text=$(START_B_4) $< -o $@

$(OBJDIR)/$(PRJ)_2.elf: bootloader.c Makefile
	avr-gcc -g -Os -mmcu=$(AVRCPU_2) -D__$(AVRCPU_2)__ -Wl,-Map,$(OBJDIR)/$(PRJ)_2.map,--section-start=.text=$(START_B_2) $< -o $@

$(OBJDIR)/$(PRJ)_2s.elf: bootloader.c Makefile
	avr-gcc -g -Os -mmcu=$(AVRCPU_2S) -D__$(AVRCPU_2S)__ -Wl,-Map,$(OBJDIR)/$(PRJ)_2s.map,--section-start=.text=$(START_B_2) $< -o $@
# Nota: -g agrega info de debug, que sirve para que el dump sea más claro

$(OBJDIR)/$(PRJ)_8.dat: $(OBJDIR)/$(PRJ)_8.bin
	bin2hex --vhdl -o $(START_W_8) -b 2 $< $@

$(OBJDIR)/$(PRJ)_4.dat: $(OBJDIR)/$(PRJ)_4.bin
	bin2hex --vhdl -o $(START_W_4) -b 2 $< $@

$(OBJDIR)/$(PRJ)_2.dat: $(OBJDIR)/$(PRJ)_2.bin
	bin2hex --vhdl -o $(START_W_2) -b 2 $< $@

$(OBJDIR)/$(PRJ)_2s.dat: $(OBJDIR)/$(PRJ)_2s.bin
	bin2hex --vhdl -o $(START_W_2) -b 2 $< $@

$(OBJDIR)/$(PRJ)_8.vhdl: ../pm_s_rw.in.vhdl $(OBJDIR)/$(PRJ)_8.dat
	printf $(PRJ)PM_8 > entity.txt
	ln -s $(OBJDIR)/$(PRJ)_8.dat rom.dat
	vhdlspp.pl $< $@
	rm entity.txt rom.dat

$(OBJDIR)/$(PRJ)_4.vhdl: ../pm_s_rw.in.vhdl $(OBJDIR)/$(PRJ)_4.dat
	printf $(PRJ)PM_4 > entity.txt
	ln -s $(OBJDIR)/$(PRJ)_4.dat rom.dat
	vhdlspp.pl $< $@
	rm entity.txt rom.dat

$(OBJDIR)/$(PRJ)_2.vhdl: ../pm_s_rw.in.vhdl $(OBJDIR)/$(PRJ)_2.dat
	printf $(PRJ)PM_2 > entity.txt
	ln -s $(OBJDIR)/$(PRJ)_2.dat rom.dat
	vhdlspp.pl $< $@
	rm entity.txt rom.dat

$(OBJDIR)/$(PRJ)_2s.vhdl: ../pm_s_rw.in.vhdl $(OBJDIR)/$(PRJ)_2s.dat
	printf $(PRJ)PM_2S > entity.txt
	ln -s $(OBJDIR)/$(PRJ)_2s.dat rom.dat
	vhdlspp.pl $< $@
	rm entity.txt rom.dat

