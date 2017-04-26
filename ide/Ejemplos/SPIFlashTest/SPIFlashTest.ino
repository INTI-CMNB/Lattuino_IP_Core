/*
  Read Flash ID
*/

// inslude the SPI library:
#include <SPI.h>


// set pin 10 as the slave select for the digital pot:
const int slaveSelectPin = 10;

void setup() {
  // set the slaveSelectPin as an output:
  pinMode(slaveSelectPin, OUTPUT);
  digitalWrite(slaveSelectPin, HIGH);
  Serial.begin(115200);
  // initialize SPI:
  SPI.begin();
  wakeUp();
  delay(10);
}

void loop() 
{
  byte id[3];
  digitalWrite(slaveSelectPin, LOW);
  SPI.transfer(0x9F);
  // Should be EF3013 for W25X40CL
  id[0]=SPI.transfer(0);
  id[1]=SPI.transfer(0);
  id[2]=SPI.transfer(0);
  digitalWrite(slaveSelectPin, HIGH);
  Serial.print(id[0], HEX);
  Serial.print(id[1], HEX);
  Serial.println(id[2], HEX);
  delay(1000);
}


void wakeUp()
{
  // take the SS pin low to select the chip:
  digitalWrite(slaveSelectPin, LOW);
  SPI.transfer(0xAB);
  // take the SS pin high to de-select the chip:
  digitalWrite(slaveSelectPin, HIGH);  
}

