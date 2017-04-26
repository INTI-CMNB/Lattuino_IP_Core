/***************************************************

  Optimized for size by Salvador E. Tropea

  Original text:
  This is a library for the Adafruit STMPE610 Resistive
  touch screen controller breakout
  ----> http://www.adafruit.com/products/1571
 
  Check out the links above for our tutorials and wiring diagrams
  These breakouts use SPI or I2C to communicate

  Adafruit invests time and resources providing this open source code,
  please support Adafruit and open-source hardware by purchasing
  products from Adafruit!

  Written by Limor Fried/Ladyada for Adafruit Industries.
  MIT license, all text above must be included in any redistribution

 ****************************************************/


#if ARDUINO >= 100
 #include "Arduino.h"
#else
 #include "WProgram.h"
#endif

#ifdef __AVR__
  #include <avr/pgmspace.h>
#elif defined(ESP8266) || defined(ESP32)
  #include <pgmspace.h>
#endif

#ifndef pgm_read_byte
 #define pgm_read_byte(addr) (*(const unsigned char *)(addr))
#endif

#include "Adafruit_STMPE610_b.h"

#if STMPE_ENABLE_SPI
    #if defined (SPI_HAS_TRANSACTION)
        // SPI transaction support allows managing SPI settings and prevents
        // conflicts between libraries, with a hardware-neutral interface
        static SPISettings mySPISettings;
        #if STMPE_ENABLE_SSPI
            // Soft & Hard SPI enabled
            #define BEGIN_TRANSACTION() if (_CLK == -1) SPI.beginTransaction(mySPISettings)
            #define END_TRANSACTION()   if (_CLK == -1) SPI.endTransaction()
        #else
            // Only Hard SPI enabled
            #define BEGIN_TRANSACTION() SPI.beginTransaction(mySPISettings)
            #define END_TRANSACTION()   SPI.endTransaction()
        #endif
    #elif defined (__AVR__)
        static uint8_t SPCRbackup;
        static uint8_t mySPCR;
    #endif
    // Soft vs Hard SPI selection
    #if STMPE_ENABLE_SSPI
        // Soft SPI enabled
        #if STMPE_ENABLE_HSPI
            // Soft & Hard SPI enabled
            #define FOR_HSPI_NOT_SSPI (_CLK == -1)
            #define FOR_SSPI_NOT_HSPI (_CLK != -1)
        #else
            // Only Soft SPI enabled
            #define FOR_HSPI_NOT_SSPI (0)
            #define FOR_SSPI_NOT_HSPI (1)
        #endif
    #else
        // No Soft SPI
        #if STMPE_ENABLE_HSPI
            // Only Hard SPI
            #define FOR_HSPI_NOT_SSPI (1)
            #define FOR_SSPI_NOT_HSPI (0)
        #else
            #error "Internal inconsistency SPI enabled, but HSPI and SSPI disabled"
        #endif
    #endif
#endif

#if STMPE_ENABLE_I2C
    // I2C support
    #if STMPE_ENABLE_SPI
        // SPI & I2C support
        #define FOR_SPI_NOT_I2C (_CS != -1)
        #define FOR_I2C_NOT_SPI (_CS == -1)
        #if STMPE_ENABLE_SSPI && STMPE_ENABLE_HSPI
            // I2C, HSPI and SSPI
            #define FOR_HSPI_ONLY (_CS != -1 && _CLK == -1)
            #define FOR_SSPI_ONLY (_CS != -1 && _CLK != -1)
        #elif STMPE_ENABLE_HSPI
            #define FOR_HSPI_ONLY (1)
            #define FOR_SSPI_ONLY (0)
        #else
            #define FOR_HSPI_ONLY (0)
            #define FOR_SSPI_ONLY (1)
        #endif
    #else
        // Only I2C supported
        #define FOR_SPI_NOT_I2C (0)
        #define FOR_I2C_NOT_SPI (1)
        #define FOR_HSPI_ONLY (0)
        #define FOR_SSPI_ONLY (0)
    #endif
#else
    // No I2C support
    #if STMPE_ENABLE_SPI
        // Only SPI supported
        #define FOR_SPI_NOT_I2C (1)
        #define FOR_I2C_NOT_SPI (0)
        #if STMPE_ENABLE_SSPI && STMPE_ENABLE_HSPI
            // HSPI and SSPI
            #define FOR_HSPI_ONLY (_CLK == -1)
            #define FOR_SSPI_ONLY (_CLK != -1)
        #elif STMPE_ENABLE_HSPI
            #define FOR_HSPI_ONLY (1)
            #define FOR_SSPI_ONLY (0)
        #else
            #define FOR_HSPI_ONLY (0)
            #define FOR_SSPI_ONLY (1)
        #endif
    #else
        // No I2C and no SPI
        #error "No SPI nor I2C support enabled"
    #endif
#endif

/**************************************************************************/
/*! 
    @brief  Instantiates a new STMPE610 class
*/
/**************************************************************************/
// software SPI
#if STMPE_ENABLE_SSPI
Adafruit_STMPE610::Adafruit_STMPE610(uint8_t cspin, uint8_t mosipin, uint8_t misopin, uint8_t clkpin) {
  _CS = cspin;
  _MOSI = mosipin;
  _MISO = misopin;
  _CLK = clkpin;
}
#endif

// hardware SPI
#if STMPE_ENABLE_HSPI
Adafruit_STMPE610::Adafruit_STMPE610(uint8_t cspin) {
  _CS = cspin;
  #if STMPE_ENABLE_SSPI
  _MOSI = _MISO = _CLK = -1;
  #endif
}
#endif

// I2C
#if STMPE_ENABLE_I2C
Adafruit_STMPE610::Adafruit_STMPE610() {
// use i2c
  #if STMPE_ENABLE_SPI
  _CS = -1;
  #endif
}
#endif

static const uint8_t PROGMEM initValues[]=
{
 STMPE_SYS_CTRL2, 0x0, // turn on clocks!
 STMPE_TSC_CTRL, STMPE_TSC_CTRL_XYZ | STMPE_TSC_CTRL_EN, // XYZ and enable!
 STMPE_INT_EN, STMPE_INT_EN_TOUCHDET,
 STMPE_ADC_CTRL1, STMPE_ADC_CTRL1_10BIT | (0x6 << 4), // 96 clocks per conversion
 STMPE_ADC_CTRL2, STMPE_ADC_CTRL2_6_5MHZ,
 STMPE_TSC_CFG, STMPE_TSC_CFG_4SAMPLE | STMPE_TSC_CFG_DELAY_1MS | STMPE_TSC_CFG_SETTLE_5MS,
 STMPE_TSC_FRACTION_Z, 0x6,
 STMPE_FIFO_TH, 1,
 STMPE_FIFO_STA, STMPE_FIFO_STA_RESET,
 STMPE_FIFO_STA, 0,    // unreset
 STMPE_TSC_I_DRIVE, STMPE_TSC_I_DRIVE_50MA,
 STMPE_INT_STA, 0xFF, // reset all ints
 STMPE_INT_CTRL, STMPE_INT_CTRL_POL_HIGH | STMPE_INT_CTRL_ENABLE
};

/**************************************************************************/
/*! 
    @brief  Setups the HW
*/
/**************************************************************************/
boolean Adafruit_STMPE610::begin(uint8_t i2caddr) {
#if STMPE_ENABLE_HSPI
  if (FOR_HSPI_ONLY) {
    // hardware SPI
    pinMode(_CS, OUTPUT);
    digitalWrite(_CS, HIGH);
    
 #if defined (SPI_HAS_TRANSACTION)
    SPI.begin();
    mySPISettings = SPISettings(1000000, MSBFIRST, STMPE_SPI_MODE);
 #elif defined (__AVR__)
    SPCRbackup = SPCR;
    SPI.begin();
    SPI.setClockDivider(SPI_CLOCK_DIV16);
    SPI.setDataMode(STMPE_SPI_MODE);
    mySPCR = SPCR; // save our preferred state
    //Serial.print("mySPCR = 0x"); Serial.println(SPCR, HEX);
    SPCR = SPCRbackup;  // then restore
 #elif defined (__arm__)
    SPI.begin();
    SPI.setClockDivider(84);
    SPI.setDataMode(STMPE_SPI_MODE);
 #endif
  }
#endif

#if STMPE_ENABLE_SSPI
  if (FOR_SSPI_ONLY) {
    // software SPI
    pinMode(_CLK, OUTPUT);
    pinMode(_CS, OUTPUT);
    pinMode(_MOSI, OUTPUT);
    pinMode(_MISO, INPUT);
  }
#endif

#if STMPE_ENABLE_I2C
  if (FOR_I2C_NOT_SPI) {
    Wire.begin();
    _i2caddr = i2caddr;
  }
#endif

  if (getVersion() != 0x811)
     return false;

  // STMPE Initialization
  writeRegister8(STMPE_SYS_CTRL1, STMPE_SYS_CTRL1_RESET);
  delay(10);

  if (0) // Is that really needed?
  for (uint8_t i=0; i<65; i++) {
    readRegister8(i);
  }

  uint8_t c=sizeof(initValues)/2;
  const uint8_t *p=initValues;
  while (c--)
    {
     uint8_t reg=pgm_read_byte(p++);
     uint8_t val=pgm_read_byte(p++);
     writeRegister8(reg,val);
    }

#if STMPE_ENABLE_HSPI && defined (__AVR__) && !defined (SPI_HAS_TRANSACTION)
  if (FOR_HSPI_ONLY)
    SPCR = SPCRbackup;  // restore SPI state
#endif
  return true;
}

boolean Adafruit_STMPE610::touched(void) {
  return (readRegister8(STMPE_TSC_CTRL) & 0x80);
}

boolean Adafruit_STMPE610::bufferEmpty(void) {
  return (readRegister8(STMPE_FIFO_STA) & STMPE_FIFO_STA_EMPTY);
}

uint8_t Adafruit_STMPE610::bufferSize(void) {
  return readRegister8(STMPE_FIFO_SIZE);
}

uint16_t Adafruit_STMPE610::getVersion() {
  uint16_t v;
  //Serial.print("get version");
  v = readRegister8(0);
  v <<= 8;
  v |= readRegister8(1);
  //Serial.print("Version: 0x"); Serial.println(v, HEX);
  return v;
}


/*****************************/

void Adafruit_STMPE610::readData(uint16_t *x, uint16_t *y, uint8_t *z) {
  uint8_t data[4];
  
  for (uint8_t i=0; i<4; i++) {
    data[i] = readRegister8(0xD7); //SPI.transfer(0x00); 
   // Serial.print("0x"); Serial.print(data[i], HEX); Serial.print(" / ");
  }
  *x = data[0];
  *x <<= 4;
  *x |= (data[1] >> 4);
  *y = data[1] & 0x0F; 
  *y <<= 8;
  *y |= data[2]; 
  *z = data[3];

  if (bufferEmpty())
    writeRegister8(STMPE_INT_STA, 0xFF); // reset all ints
}

TS_Point Adafruit_STMPE610::getPoint(void) {
  uint16_t x, y;
  uint8_t z;
  readData(&x, &y, &z);
  return TS_Point(x, y, z);
}

#if STMPE_ENABLE_SPI
uint8_t Adafruit_STMPE610::spiIn() {
 #if STMPE_ENABLE_HSPI
  if (FOR_HSPI_NOT_SSPI) {
  #if defined (SPI_HAS_TRANSACTION)
    uint8_t d = SPI.transfer(0);
    return d;
  #elif defined (__AVR__)
    SPCRbackup = SPCR;
    SPCR = mySPCR;
    uint8_t d = SPI.transfer(0);
    SPCR = SPCRbackup;
    return d;
  #elif defined (__arm__)
    SPI.setClockDivider(84);
    SPI.setDataMode(STMPE_SPI_MODE);
    uint8_t d = SPI.transfer(0);
    return d;
  #endif
  }
 #endif

 #if STMPE_ENABLE_SSPI
  if (FOR_SSPI_NOT_HSPI)
    return shiftIn(_MISO, _CLK, MSBFIRST);
 #endif
}
#endif

#if STMPE_ENABLE_SPI
void Adafruit_STMPE610::spiOut(uint8_t x) {
#if STMPE_ENABLE_HSPI
  if (FOR_HSPI_NOT_SSPI) {
 #if defined (SPI_HAS_TRANSACTION)
    SPI.transfer(x);
 #elif defined (__AVR__)
    SPCRbackup = SPCR;
    SPCR = mySPCR;
    SPI.transfer(x);
    SPCR = SPCRbackup;
 #elif defined (__arm__)
    SPI.setClockDivider(84);
    SPI.setDataMode(STMPE_SPI_MODE);
    SPI.transfer(x);
 #endif
  }
#endif

#if STMPE_ENABLE_SSPI
  if (FOR_SSPI_NOT_HSPI)
    shiftOut(_MOSI, _CLK, MSBFIRST, x);
#endif
}
#endif

uint8_t Adafruit_STMPE610::readRegister8(uint8_t reg) {
  uint8_t x ;

#if STMPE_ENABLE_I2C
  if (FOR_I2C_NOT_SPI) {
   // use i2c
    Wire.beginTransmission(_i2caddr);
    Wire.write((byte)reg);
    Wire.endTransmission();
    Wire.beginTransmission(_i2caddr);
    Wire.requestFrom(_i2caddr, (byte)1);
    x = Wire.read();
    Wire.endTransmission();

    //Serial.print("$"); Serial.print(reg, HEX); 
    //Serial.print(": 0x"); Serial.println(x, HEX);
  }
#endif

#if STMPE_ENABLE_SPI
  if (FOR_SPI_NOT_I2C) {
    BEGIN_TRANSACTION();
    digitalWrite(_CS, LOW);
    spiOut(0x80 | reg); 
    spiOut(0x00);
    x = spiIn(); 
    digitalWrite(_CS, HIGH);
    END_TRANSACTION();
  }
#endif

  return x;
}

uint16_t Adafruit_STMPE610::readRegister16(uint8_t reg) {
  uint16_t x;

#if STMPE_ENABLE_I2C
  if (FOR_I2C_NOT_SPI) {
    // use i2c
    Wire.beginTransmission(_i2caddr);
    Wire.write((byte)reg);
    Wire.endTransmission();
    Wire.requestFrom(_i2caddr, (byte)2);
    x = Wire.read();
    x<<=8;
    x |= Wire.read();
    Wire.endTransmission();

  }
#endif

#if STMPE_ENABLE_SPI
  if (FOR_SPI_NOT_I2C) {
    BEGIN_TRANSACTION();
    digitalWrite(_CS, LOW);
    spiOut(0x80 | reg); 
    spiOut(0x00);
    x = spiIn(); 
    x<<=8;
    x |= spiIn(); 
    digitalWrite(_CS, HIGH);
    END_TRANSACTION();
  }
#endif

  //Serial.print("$"); Serial.print(reg, HEX); 
  //Serial.print(": 0x"); Serial.println(x, HEX);
  return x;
}

void Adafruit_STMPE610::writeRegister8(uint8_t reg, uint8_t val) {

#if STMPE_ENABLE_I2C
  if (FOR_I2C_NOT_SPI) {
    // use i2c
    Wire.beginTransmission(_i2caddr);
    Wire.write((byte)reg);
    Wire.write(val);
    Wire.endTransmission();
  }
#endif

#if STMPE_ENABLE_SPI
  if (FOR_SPI_NOT_I2C) {
    BEGIN_TRANSACTION();
    digitalWrite(_CS, LOW);
    spiOut(reg); 
    spiOut(val);
    digitalWrite(_CS, HIGH);
    END_TRANSACTION();
  }
#endif
}

/****************/

TS_Point::TS_Point(void) {
  x = y = 0;
}

TS_Point::TS_Point(int16_t x0, int16_t y0, int16_t z0) {
  x = x0;
  y = y0;
  z = z0;
}

bool TS_Point::operator==(TS_Point p1) {
  return  ((p1.x == x) && (p1.y == y) && (p1.z == z));
}

bool TS_Point::operator!=(TS_Point p1) {
  return  ((p1.x != x) || (p1.y != y) || (p1.z != z));
}
