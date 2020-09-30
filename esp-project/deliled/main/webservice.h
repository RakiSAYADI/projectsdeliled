/*
 * webserver.h
 *
 *  Created on: Apr 1, 2018
 *      Author: mdt
 */

#ifndef MAIN_WEBSERVICE_H_
#define MAIN_WEBSERVICE_H_

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

extern bool WifiConnectedFlag;

void WebService_Init(void);

#endif /* MAIN_WEBSERVICE_H_ */