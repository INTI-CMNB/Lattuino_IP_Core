/******************************************************************

  Optimized for size by Salvador E. Tropea

  Original header:
  This is our library for the Adafruit ILI9341 Breakout and Shield
  ----> http://www.adafruit.com/products/1651

  Check out the links above for our tutorials and wiring diagrams
  These displays use SPI to communicate, 4 or 5 pins are required
  to interface (RST is optional)
  Adafruit invests time and resources providing this open source
  code, please support Adafruit and open-source hardware by
  purchasing products from Adafruit!

  Written by Limor Fried/Ladyada for Adafruit Industries.
  MIT license, all text above must be included in any redistribution

 *******************************************************************/

#ifndef _ADAFRUIT_ILI9341H_
#define _ADAFRUIT_ILI9341H_

/* Configurable PINs */
#define CS_PIN  10
#define DC_PIN   9

/* CS and DC are unique */
#define VARIABLE_DC_CS 0
/* Define to 1 if software implemented SPI is needed */
#define ENABLE_SOFT_SPI 0
/* Define to 1 to control the display reset */
#define ENABLE_RST 0
/* Define to 1 to add support for custom fonts */
#define ENABLE_CUSTOM_FONT 0

/* Helpers to make the code clear */
#define USE_HARD_SPI (!ENABLE_SOFT_SPI || (_sclk < 0))
#define USE_SOFT_SPI (ENABLE_SOFT_SPI && (_sclk >= 0))
#define USE_BUILT_IN_FONT (!ENABLE_CUSTOM_FONT || !gfxFont)
#define USE_CUSTOM_FONT (ENABLE_CUSTOM_FONT && gfxFont)

#if ARDUINO >= 100
 #include "Arduino.h"
 #include "Print.h"
#else
 #include "WProgram.h"
#endif
#include <SPI.h>
#include "gfxfont.h"

#if defined(ARDUINO_STM32_FEATHER)
typedef volatile uint32 RwReg;
#endif
#if defined(ARDUINO_FEATHER52)
typedef volatile uint32_t RwReg;
#endif

// This is the 'raw' display w/h - never changes
#define WIDTH  240
#define HEIGHT 320

#define ILI9341_NOP        0x00
#define ILI9341_SWRESET    0x01
#define ILI9341_RDDID      0x04
#define ILI9341_RDDST      0x09

#define ILI9341_SLPIN      0x10
#define ILI9341_SLPOUT     0x11
#define ILI9341_PTLON      0x12
#define ILI9341_NORON      0x13

#define ILI9341_RDMODE     0x0A
#define ILI9341_RDMADCTL   0x0B
#define ILI9341_RDPIXFMT   0x0C
#define ILI9341_RDIMGFMT   0x0D
#define ILI9341_RDSELFDIAG 0x0F

#define ILI9341_INVOFF     0x20
#define ILI9341_INVON      0x21
#define ILI9341_GAMMASET   0x26
#define ILI9341_DISPOFF    0x28
#define ILI9341_DISPON     0x29

#define ILI9341_CASET      0x2A
#define ILI9341_PASET      0x2B
#define ILI9341_RAMWR      0x2C
#define ILI9341_RAMRD      0x2E

#define ILI9341_PTLAR      0x30
#define ILI9341_MADCTL     0x36
#define ILI9341_VSCRSADD   0x37
#define ILI9341_PIXFMT     0x3A

#define ILI9341_FRMCTR1    0xB1
#define ILI9341_FRMCTR2    0xB2
#define ILI9341_FRMCTR3    0xB3
#define ILI9341_INVCTR     0xB4
#define ILI9341_DFUNCTR    0xB6

#define ILI9341_PWCTR1     0xC0
#define ILI9341_PWCTR2     0xC1
#define ILI9341_PWCTR3     0xC2
#define ILI9341_PWCTR4     0xC3
#define ILI9341_PWCTR5     0xC4
#define ILI9341_VMCTR1     0xC5
#define ILI9341_VMCTR2     0xC7

#define ILI9341_RDID1      0xDA
#define ILI9341_RDID2      0xDB
#define ILI9341_RDID3      0xDC
#define ILI9341_RDID4      0xDD

#define ILI9341_GMCTRP1    0xE0
#define ILI9341_GMCTRN1    0xE1
/*
#define ILI9341_PWCTR6     0xFC

 */

// Color definitions
#define ILI9341_BLACK       0x0000      /*   0,   0,   0 */
#define ILI9341_NAVY        0x000F      /*   0,   0, 128 */
#define ILI9341_DARKGREEN   0x03E0      /*   0, 128,   0 */
#define ILI9341_DARKCYAN    0x03EF      /*   0, 128, 128 */
#define ILI9341_MAROON      0x7800      /* 128,   0,   0 */
#define ILI9341_PURPLE      0x780F      /* 128,   0, 128 */
#define ILI9341_OLIVE       0x7BE0      /* 128, 128,   0 */
#define ILI9341_LIGHTGREY   0xC618      /* 192, 192, 192 */
#define ILI9341_DARKGREY    0x7BEF      /* 128, 128, 128 */
#define ILI9341_BLUE        0x001F      /*   0,   0, 255 */
#define ILI9341_GREEN       0x07E0      /*   0, 255,   0 */
#define ILI9341_CYAN        0x07FF      /*   0, 255, 255 */
#define ILI9341_RED         0xF800      /* 255,   0,   0 */
#define ILI9341_MAGENTA     0xF81F      /* 255,   0, 255 */
#define ILI9341_YELLOW      0xFFE0      /* 255, 255,   0 */
#define ILI9341_WHITE       0xFFFF      /* 255, 255, 255 */
#define ILI9341_ORANGE      0xFD20      /* 255, 165,   0 */
#define ILI9341_GREENYELLOW 0xAFE5      /* 173, 255,  47 */
#define ILI9341_PINK        0xF81F

#if defined (__AVR__) || defined(TEENSYDUINO) || defined(ESP8266) || defined (ESP32) || defined(__arm__)
//#define USE_FAST_PINIO
#endif

extern const unsigned char Adafruit_ILI9341_font[];

class Adafruit_ILI9341 : public Print {
    protected:

    public:
        Adafruit_ILI9341(int8_t _CS, int8_t _DC, int8_t _MOSI, int8_t _SCLK, int8_t _RST = -1, int8_t _MISO = -1);
        Adafruit_ILI9341(int8_t _CS, int8_t _DC, int8_t _RST = -1);
        Adafruit_ILI9341();

#ifndef ESP32
        void      begin(uint32_t freq = 0, const uint8_t *aFont = Adafruit_ILI9341_font);
#else
        void      begin(uint32_t freq = 0, SPIClass &spi=SPI, const uint8_t *aFont = Adafruit_ILI9341_font);
#endif
        // CONTROL API
        void      setRotation(uint8_t r);
        void      invertDisplay(boolean i);
        void      scrollTo(uint16_t y);

        // Required Non-Transaction
        void      drawPixel(int16_t x, int16_t y, uint16_t color);

        // Transaction API
        void      startWrite(void);
        void      endWrite(void);
        void      writePixel(int16_t x, int16_t y, uint16_t color);
        void      writeFillRect(int16_t x, int16_t y, int16_t w, int16_t h, uint16_t color);
        void      writeLine(int16_t x0, int16_t y0, int16_t x1, int16_t y1, uint16_t color);
        void      writeFastVLine(int16_t x, int16_t y, int16_t h, uint16_t color);
        void      writeFastHLine(int16_t x, int16_t y, int16_t w, uint16_t color);

        // Transaction API not used by GFX
        void      setAddrWindow(uint16_t x, uint16_t y, uint16_t w, uint16_t h);
        void      writePixel(uint16_t color);
        void      writePixels(uint16_t * colors, uint32_t len);
        void      writeColor(uint16_t color, uint32_t len);
        void      pushColor(uint16_t color);

        // Recommended Non-Transaction
        void      drawFastVLine(int16_t x, int16_t y, int16_t h, uint16_t color);
        void      drawFastHLine(int16_t x, int16_t y, int16_t w, uint16_t color);
        void      fillRect(int16_t x, int16_t y, int16_t w, int16_t h, uint16_t color);
        void      drawBitmap(int16_t x, int16_t y, int16_t w, int16_t h, const uint16_t *pcolors);

        // BASIC DRAW API
        void      fillScreen(uint16_t color);
        void      drawRect(int16_t x, int16_t y, int16_t w, int16_t h, uint16_t color);
        void      drawLine(int16_t x0, int16_t y0, int16_t x1, int16_t y1, uint16_t color);

        // Advanced draw API
        void      fillRoundRect(int16_t x0, int16_t y0, int16_t w, int16_t h,
                     int16_t radius, uint16_t color);
        void      cp437(boolean x=true);
        void      setFont(const GFXfont *f = NULL);
        void      getTextBounds(char *string, int16_t x, int16_t y,
                     int16_t *x1, int16_t *y1, uint16_t *w, uint16_t *h);
        void      getTextBounds(const __FlashStringHelper *s, int16_t x, int16_t y,
                     int16_t *x1, int16_t *y1, uint16_t *w, uint16_t *h);
        void      setTextColor(uint16_t c);
        void      setTextColor(uint16_t c, uint16_t bg);
        void      setTextSize(uint8_t s);
        void      setTextWrap(boolean w);
        void      setCursor(int16_t x, int16_t y);
        void      drawChar(int16_t x, int16_t y, unsigned char c, uint16_t color,
                     uint16_t bg, uint8_t size);
        void      drawXBitmap(int16_t x, int16_t y, const uint8_t *bitmap,
                     int16_t w, int16_t h, uint16_t color);
        void      drawBitmap(int16_t x, int16_t y, const uint8_t *bitmap,
                     int16_t w, int16_t h, uint16_t color);
        void      drawBitmap(int16_t x, int16_t y, const uint8_t *bitmap,
                     int16_t w, int16_t h, uint16_t color, uint16_t bg);
        void      drawBitmap(int16_t x, int16_t y, uint8_t *bitmap,
                     int16_t w, int16_t h, uint16_t color);
        void      drawBitmap(int16_t x, int16_t y, uint8_t *bitmap,
                     int16_t w, int16_t h, uint16_t color, uint16_t bg);
        void      drawRoundRect(int16_t x0, int16_t y0, int16_t w, int16_t h,
                     int16_t radius, uint16_t color);
        void      drawTriangle(int16_t x0, int16_t y0, int16_t x1, int16_t y1,
                     int16_t x2, int16_t y2, uint16_t color);
        void      fillTriangle(int16_t x0, int16_t y0, int16_t x1, int16_t y1,
                     int16_t x2, int16_t y2, uint16_t color);
        void      drawCircle(int16_t x0, int16_t y0, int16_t r, uint16_t color);
        void      drawCircleHelper(int16_t x0, int16_t y0, int16_t r, uint8_t cornername,
                     uint16_t color);
        void      fillCircle(int16_t x0, int16_t y0, int16_t r, uint16_t color);
        void      fillCircleHelper(int16_t x0, int16_t y0, int16_t r, uint8_t cornername,
                     int16_t delta, uint16_t color);

#if ARDUINO >= 100
        size_t    write(uint8_t);
#else
        void      write(uint8_t);
#endif


        uint8_t   readcommand8(uint8_t reg, uint8_t index = 0);

        uint16_t  color565(uint8_t r, uint8_t g, uint8_t b);

        int16_t height(void) const;
        int16_t width(void) const;

        uint8_t getRotation(void) const;

        // get current cursor position (get rotation safe maximum values, using: width() for x, height() for y)
        int16_t getCursorX(void) const;
        int16_t getCursorY(void) const;
      
    protected:
        int16_t
          _width, _height, // Display w/h as modified by current rotation
          cursor_x, cursor_y;
        uint16_t
          textcolor, textbgcolor;
        uint8_t
          textsize,
          rotation;
        boolean
          wrap,   // If set, 'wrap' text at right edge of display
          _cp437; // If set, use correct CP437 charset (default is off)
        GFXfont
          *gfxFont;
        static const uint8_t *builtInFont;

    private:
#ifdef ESP32
        SPIClass _spi;
#endif
        uint32_t _freq;

#if defined (__arm__)
        #define PIN_TYPE  int32_t
        #define SFR_TYPE  RwReg
        #define MASK_TYPE uint32_t
#elif defined (ESP8266) || defined (ESP32)
        #define PIN_TYPE  int8_t
        #define SFR_TYPE  uint32_t
        #define MASK_TYPE uint32_t
#else
        #define PIN_TYPE  int8_t
        #define SFR_TYPE  uint8_t
        #define MASK_TYPE uint8_t
#endif

// Usually we have only 1 display
#if VARIABLE_DC_CS
        PIN_TYPE  _cs, _dc;
  #ifdef USE_FAST_PINIO
        volatile SFR_TYPE *dcport, *csport;
        MASK_TYPE  cspinmask, dcpinmask;
  #endif
#else
        #define _cs  CS_PIN
        #define _dc  DC_PIN
#endif

#if ENABLE_RST
        PIN_TYPE  _rst;
#else
        #define _rst  -1
#endif

#if ENABLE_SOFT_SPI
        PIN_TYPE  _sclk, _mosi, _miso;
  #ifdef USE_FAST_PINIO
        volatile SFR_TYPE *mosiport, *misoport, *clkport;
        MASK_TYPE  mosipinmask, misopinmask, clkpinmask;
  #endif
#else
        #define _sclk  -1
        #define _mosi  -1
        #define _miso  -1
#endif

        void        writeCommand(uint8_t cmd);
        void        spiWrite(uint8_t v);
        uint8_t     spiRead(void);
};

class Adafruit_GFX_Button {

 public:
  Adafruit_GFX_Button(void);
  // "Classic" initButton() uses center & size
  void initButton(Adafruit_ILI9341 *gfx, int16_t x, int16_t y,
   uint16_t w, uint16_t h, uint16_t outline, uint16_t fill,
   uint16_t textcolor, char *label, uint8_t textsize);
  // New/alt initButton() uses upper-left corner & size
  void initButtonUL(Adafruit_ILI9341 *gfx, int16_t x1, int16_t y1,
   uint16_t w, uint16_t h, uint16_t outline, uint16_t fill,
   uint16_t textcolor, char *label, uint8_t textsize);
  void drawButton(boolean inverted = false);
  boolean contains(int16_t x, int16_t y);

  void press(boolean p);
  boolean isPressed();
  boolean justPressed();
  boolean justReleased();

 private:
  Adafruit_ILI9341 *_gfx;
  int16_t       _x1, _y1; // Coordinates of top-left corner
  uint16_t      _w, _h;
  uint8_t       _textsize;
  uint16_t      _outlinecolor, _fillcolor, _textcolor;
  char          _label[10];

  boolean currstate, laststate;
};

class GFXcanvas1 : public Adafruit_ILI9341 {

 public:
  GFXcanvas1(uint16_t w, uint16_t h);
  ~GFXcanvas1(void);
  void     drawPixel(int16_t x, int16_t y, uint16_t color),
           fillScreen(uint16_t color);
  uint8_t *getBuffer(void);
 private:
  uint8_t *buffer;
};

class GFXcanvas16 : public Adafruit_ILI9341 {
  GFXcanvas16(uint16_t w, uint16_t h);
  ~GFXcanvas16(void);
  void      drawPixel(int16_t x, int16_t y, uint16_t color),
            fillScreen(uint16_t color);
  uint16_t *getBuffer(void);
 private:
  uint16_t *buffer;
};

#endif
