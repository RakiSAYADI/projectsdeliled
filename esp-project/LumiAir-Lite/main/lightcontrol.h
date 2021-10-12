#ifndef MAIN_LIGHTCONTROL_H_
#define MAIN_LIGHTCONTROL_H_

#include <stdint.h>

#define USE_RADIO
#define USE_0_10V

#define 	LCMD_SWITCH_ON_OFF 1
#define 	LCMD_SWITCH_ON 2
#define 	LCMD_SET_COLOR 3
#define 	LCMD_MODE_SETTING 4
#define 	LCMD_PAIRING 5
#define 	LCMD_SET_WHITE 6
#define 	LCMD_SET_BRIGTHNESS 7
#define 	LCMD_SET_TEMP 8
#define 	LCMD_SET_SAT 9
#define 	LCMD_SET_MODE 10

#define 	LSUBCMD_SWITCH_ON	0
#define 	LSUBCMD_SWITCH_OFF	1

#define 	LSUBCMD_MODE_SDW	0
#define 	LSUBCMD_MODE_SUP	1
#define 	LSUBCMD_MODE_TMODE	2

#define 	LSUBCMD_PAIR	1
#define 	LSUBCMD_UNPAIR	0

extern int8_t PID_Out;

typedef struct {
	uint8_t Hue;
	uint8_t Sat;
	uint8_t Bri;
} HSLStruct;

void RgbToHSL(uint32_t rgb, HSLStruct *tmp);
void HueToHSL(char hueChar[64], char hueZone[3]);

void Mi_mode(uint8_t id, uint8_t md);

void lightControl_Init();
void MilightHandler(uint8_t cmd, uint8_t subcmd, uint8_t zonecode);

#endif /* MAIN_LIGHTCONTROL_H_ */
