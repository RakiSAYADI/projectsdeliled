/* Base mac address example

 This example code is in the Public Domain (or CC0 licensed, at your option.)

 Unless required by applicable law or agreed to in writing, this
 software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 CONDITIONS OF ANY KIND, either express or implied.
 */

#include <stdlib.h>
#include <string.h>
#include "esp_log.h"
#include "esp_system.h"
#include "sdkconfig.h"
#include <esp_err.h>

#include "main.h"

#define MAC_TAG "BASE_MAC"

uint8_t external_storage_mac_addr[8] = { 0x00, 0x11, 0x22, 0x33, 0x44, 0x55 };

void BaseMacInit() {
	esp_err_t ret = ESP_OK;

	ret = esp_base_mac_addr_set(external_storage_mac_addr);
	if (ret == ESP_OK) {
		ESP_LOGI(MAC_TAG,
				"Use base MAC address which is stored in other external storage(flash, EEPROM, etc)");
	} else {
		ESP_LOGI(MAC_TAG,
				"Use base MAC address which is stored in BLK0 of EFUSE (%s)",
				esp_err_to_name(ret));
	}

	ESP_LOGI(MAC_TAG, "Changing Base MAC Address is Completed !");

}