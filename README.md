# Lattuino
An Arduino UNO compatible implementation for the iCE40 FPGAs

Currently oriented to the Kefir I board (iCE40HX4K + Arduino/ChipKit connectors and MCP3008 A/D)

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

## How to add Lattuino support to the Arduino IDE

You'll need a modern version of Arduino's IDE, I used 1.8.1

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

