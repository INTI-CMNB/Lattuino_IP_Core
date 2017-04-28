# Lattuino_IP_Core
An Arduino UNO compatible implementation for the iCE40 FPGAs

Currently oriented to the Kefir I board (iCE40HX4K + Arduino/ChipKit connectors and MCP3008 A/D)

## How to add Lattuino support to the Arduino IDE

1. Go to File/Preferences menu
2. Add the following URL http://fpgalibre.sf.net/Lattuino/package_lattuino_index.json as source of additional boards
3. Now enter to the __Tool/Board__ menu and choose the __Boards manager__ option.
4. Scroll down to bottom and look for the __Lattuino 1 by FPGA Libre__ entry.
5. Click on __More info__ and press the __Install__ button.
6. Once installed you'll get a new section under __Tool/Board__ named Lattuino.
