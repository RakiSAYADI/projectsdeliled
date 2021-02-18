/*
 * webserver.h
 *
 *  Created on: Apr 1, 2018
 *      Author: mdt
 */

#ifndef MAIN_SCANWIFI_H_
#define MAIN_SCANWIFI_H_

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event_loop.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "esp_event.h"
#include "tcpip_adapter.h"
#include "lwip/err.h"
#include "lwip/sys.h"

#define MAX_APs 10
typedef struct {
	char ap_records[33];
} apRecords_Typedef;

uint16_t ap_num;
bool scanResult;
apRecords_Typedef stationRecords[MAX_APs];

void scanWIFITask(void);

#endif /* MAIN_WEBSERVICE_H_ */
