#include "wiring_private.h"
#include "pins_arduino.h"

static uint8_t EnabledPWMs=0;

static
void _updatePWM_Mux(void)
{
 WB_ADR=TMR_BASE+6;
 WB_DAT=EnabledPWMs;
}

// Set the pin as regular I/O
void _turnOffPWM(uint8_t timer)
{
 EnabledPWMs&=~(1<<timer);
 _updatePWM_Mux();
}

// Set the pin as PWM
void _turnOnPWM(uint8_t timer)
{
 EnabledPWMs|=~(1<<timer);
 _updatePWM_Mux();
}


