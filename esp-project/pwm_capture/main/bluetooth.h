/*
 * gatt_server.h
 *
 *  Created on: Dec 28, 2018
 *      Author: mdt
 */

#ifndef MAIN_BLUETOOTH_H_
#define MAIN_BLUETOOTH_H_

void readingData(char * jsonData);

void bt_main();

#define delay(ms) (vTaskDelay(ms/portTICK_RATE_MS))

#endif /* MAIN_BLUETOOTH_H_ */
