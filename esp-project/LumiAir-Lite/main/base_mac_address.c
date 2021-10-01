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

#include "base_mac_address.h"

#define MAC_TAG "BASE_MAC"

const uint8_t MAC_BASE_ADDRESS[8] = { 0x70, 0xB3, 0xD5, 0x01, 0x80, 0x19 };

void BaseMacInit() {
	esp_err_t ret = ESP_OK;

	//ret = esp_read_mac(mac_addr, ESP_MAC_BT);
	ret = esp_base_mac_addr_set(MAC_BASE_ADDRESS);
	if (ret == ESP_OK) {
		ESP_LOGI(MAC_TAG,
				"Use base MAC address which is stored in other external storage(flash, EEPROM, etc)");
	} else {
		ESP_LOGE(MAC_TAG,
				"Use base MAC address which is stored in BLK0 of EFUSE (%s)",
				esp_err_to_name(ret));
	}

	ESP_LOGI(MAC_TAG, "MAC:%02X:%02X:%02X:%02X:%02X:%02X", MAC_BASE_ADDRESS[0], MAC_BASE_ADDRESS[1], MAC_BASE_ADDRESS[2], MAC_BASE_ADDRESS[3], MAC_BASE_ADDRESS[4], MAC_BASE_ADDRESS[5]);

	ESP_LOGI(MAC_TAG, "Changing Base MAC Address is Completed !");

}
