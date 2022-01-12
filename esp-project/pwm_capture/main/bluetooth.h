/*
 * gatt_server.h
 *
 *  Created on: Dec 28, 2018
 *      Author: mdt
 */

#ifndef MAIN_BLUETOOTH_H_
#define MAIN_BLUETOOTH_H_

void readingData(char * jsonData);
void readingWifi(char * jsonData);
void transitionAmbianceProcess(int ambianceId);

void bt_main();

#endif /* MAIN_BLUETOOTH_H_ */
