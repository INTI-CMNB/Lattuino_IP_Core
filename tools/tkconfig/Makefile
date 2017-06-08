
CC=gcc
CFLAGS=-g

all: lconfig.tk

xconfig: lconfig.tk
	wish -f lconfig.tk
	perl gen_config.pl < .config > ../../FPGA/lattuino_1/cpuconfig.vhdl
	perl gen_config_v.pl < .config > ../../FPGA/lattuino_1_v/cpuconfig.v

wconfig: lconfig.tk
	cygwish80 -f lconfig.tk
	perl gen_config.pl < .config > ../../FPGA/lattuino_1/cpuconfig.vhdl
	perl gen_config_v.pl < .config > ../../FPGA/lattuino_1_v/cpuconfig.v

tkparse: tkparse.o tkcond.o tkgen.o
	$(CC) tkparse.o tkcond.o tkgen.o -o tkparse

lconfig.tk: lattuino.tk header.tk tail.tk
	cat header.tk lattuino.tk tail.tk > lconfig.tk
	chmod a+x lconfig.tk

lattuino.tk : config.in tkparse
	./tkparse < config.in > lattuino.tk

clean:
	-rm lconfig.tk lattuino.tk *.o tkparse *.exe .config

dist-clean: clean
	-rm .config .config.old
	cp defconfig .config
