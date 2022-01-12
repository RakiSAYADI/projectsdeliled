/*
 * gatt_server.h
 *
 *  Created on: Dec 28, 2018
 *      Author: mdt
 */

#ifndef GATT_SERVER_H_
#define GATT_SERVER_H_

void GattsInit();

typedef struct {
	uint8_t Hue;
	uint8_t Sat;
	uint8_t Bri;
} HSLStruct;

void RgbToHSL(uint32_t rgb, HSLStruct *tmp);

extern bool TestorAlert;

#endif /* GATT_SERVER_H_ */
