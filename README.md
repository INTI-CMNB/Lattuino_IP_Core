# Lattuino
An Arduino UNO compatible implementation for the iCE40 FPGAs

Currently oriented to the Kefir I board (iCE40HX4K + Arduino/ChipKit connectors and MCP3008 A/D)

A reduced version (only I/O pins and RS-232, with a small ammount of flash and RAM) is available
for the iCEStick and IceZum Alhambra is available (iCE40HX1K).

## What's needed to synthesize the IP core

You need to install the Lattice [iCECube2](http://www.latticesemi.com/iCEcube2) tool.

You should also install some of the [FPGA Libre](http://fpgalibre.sf.net) tools.
The __lattuino-tools__ package will pull all the needed dependencies.

For Ubuntu:

```
usuario@ubuntu$ curl -sSL http://fpgalibre.sf.net/debian/go | sudo sh
usuario@ubuntu$ sudo apt-get install lattuino-tools
```

For Debian:

```
root@debian# curl -sSL http://fpgalibre.sf.net/debian/go | sh
root@debian# apt-get install lattuino-tools
```

## How to run the synthesis

This core depends on various cores from the [FPGA Libre](http://fpgalibre.sf.net) project.
In order to install the dependencies you'll need to clone the
[FPGA Cores](https://github.com/FPGALibre/fpgacores) repo.

Once installed you'll find a script called __synth_lattuino_1.sh__. Modify the *XIL_TOOLS_ICE_DIR*
variable to point to your iCECube2 installation. Then run the script.

For the iCEStick/IceZum the script is called __synth_lattuino_stick.sh__. Note that we included
a pre-generated bitstream: __lattuino/FPGA/lattuino_stick/pre-gen/Lattuino_Stick_bitmap.bin__.
Also note that the core fits very tightly, so you could have issues if using an iCEcube2 different
than version 2017.01.


## How to add Lattuino support to the Arduino IDE

You'll need a modern version of Arduino's IDE, I used 1.8.1 (works on 1.8.2 and also on 1.6.13, not in 1.6.9)

1. Go to __File/Preferences__ menu
2. Add the following URL http://fpgalibre.sf.net/Lattuino/package_lattuino_index.json as source of additional boards
3. Now enter to the __Tool/Board__ menu and choose the __Boards manager__ option.
4. Scroll down to bottom and look for the __Lattuino 1 by FPGA Libre__ entry.
5. Click on __More info__ and press the __Install__ button.
6. Once installed you'll get a new section under __Tool/Board__ named Lattuino.

## How to configure the core

You can manually edit __FPGA/lattuino_1/cpuconfig.vhdl__ or you can use the configuration tool.

To run the configuration tool you need TCL/Tk installed (UNIX __wish__ command or Cygwin's
__cygwish80__). Then run:

```
make -C tools/tkconfig/ xconfig
```

Note that this will most probably try to rebuild some tools.
If you don't have the GCC compiler installed you can just run:

```
touch tools/tkconfig/tkparse.o tools/tkconfig/tkcond.o tools/tkconfig/tkgen.o tools/tkconfig/tkparse
touch tools/tkconfig/lattuino.tk 
touch tools/tkconfig/lconfig.tk 
make -C tools/tkconfig/ xconfig
```

