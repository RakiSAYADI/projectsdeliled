/*
 * bluetooth.c
 *
 *  Created on: 19 août 2020
 *      Author: raki
 */

// Copyright 2015-2016 Espressif Systems (Shanghai) PTE LTD
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "cJSON.h"
#include "esp_bt.h"

#include "esp_gap_ble_api.h"
#include "esp_gatts_api.h"
#include "esp_bt_defs.h"
#include "esp_bt_main.h"
#include "esp_gatt_common_api.h"

#include "sdkconfig.h"

#include "main.h"

#define GATTS_TAG "GATTS_DEMO"

// Declare the static function 
static void gatts_profile_a_event_handler(esp_gatts_cb_event_t event,
		esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);

#define GATTS_SERVICE_UUID_TEST_A   0x00FF
#define GATTS_CHAR_UUID_TEST_A      0xFF01
#define GATTS_DESCR_UUID_TEST_A     0x3333
#define GATTS_NUM_HANDLE_TEST_A     4

#define TEST_DEVICE_NAME            "relay32"
#define TEST_MANUFACTURER_DATA_LEN  17
#define GATTS_CHAR_VAL_LEN_MAX 		512

uint8_t total[GATTS_CHAR_VAL_LEN_MAX];
esp_attr_value_t TOTAL = { .attr_max_len =
GATTS_CHAR_VAL_LEN_MAX, .attr_len = sizeof(total), .attr_value = total, };

static uint8_t test_service_uuid128[32] = {
		/* LSB <--------------------------------------------------------------------------------> MSB */
		//first uuid, 16bit, [12],[13] is the value
		0xfb, 0x34, 0x9b, 0x5f, 0x80, 0x00, 0x00, 0x80, 0x00, 0x10, 0x00, 0x00,
		0xAB, 0xCD, 0x00, 0x00,
		//second uuid, 32bit, [12], [13], [14], [15] is the value
		0xfb, 0x34, 0x9b, 0x5f, 0x80, 0x00, 0x00, 0x80, 0x00, 0x10, 0x00, 0x00,
		0xAB, 0xCD, 0xAB, 0xCD, };

//static uint8_t test_manufacturer[TEST_MANUFACTURER_DATA_LEN] =  {0x12, 0x23, 0x45, 0x56};
static esp_ble_adv_data_t test_adv_data = { .set_scan_rsp = false,
		.include_name = true, .include_txpower = true, .min_interval = 0x20,
		.max_interval = 0x40, .appearance = 0x00,
		.manufacturer_len = 0, //TEST_MANUFACTURER_DATA_LEN,
		.p_manufacturer_data = NULL, //&test_manufacturer[0],
		.service_data_len = 0, .p_service_data = NULL, .service_uuid_len = 32,
		.p_service_uuid = test_service_uuid128, .flag =
				(ESP_BLE_ADV_FLAG_GEN_DISC | ESP_BLE_ADV_FLAG_BREDR_NOT_SPT), };

static esp_ble_adv_params_t test_adv_params = { .adv_int_min = 0x20,
		.adv_int_max = 0x40, .adv_type = ADV_TYPE_IND, .own_addr_type =
				BLE_ADDR_TYPE_PUBLIC,
		//.peer_addr            =
		//.peer_addr_type       =
		.channel_map = ADV_CHNL_ALL, .adv_filter_policy =
				ADV_FILTER_ALLOW_SCAN_ANY_CON_ANY, };

#define PROFILE_NUM 1
#define PROFILE_A_APP_ID 0

struct gatts_profile_inst {
	esp_gatts_cb_t gatts_cb;
	uint16_t gatts_if;
	uint16_t app_id;
	uint16_t conn_id;
	uint16_t service_handle;
	esp_gatt_srvc_id_t service_id;
	uint16_t char_handle;
	esp_bt_uuid_t char_uuid;
	esp_gatt_perm_t perm;
	esp_gatt_char_prop_t property;
	uint16_t descr_handle;
	esp_bt_uuid_t descr_uuid;
};

/* One gatt-based profile one app_id and one gatts_if, this array will store the gatts_if returned by ESP_GATTS_REG_EVT */
static struct gatts_profile_inst gl_profile_tab[PROFILE_NUM] = {
		[PROFILE_A_APP_ID] = { .gatts_cb = gatts_profile_a_event_handler,
				.gatts_if = ESP_GATT_IF_NONE, /* Not get the gatt_if, so initial is ESP_GATT_IF_NONE */
		}, };

static void gap_event_handler(esp_gap_ble_cb_event_t event,
		esp_ble_gap_cb_param_t *param) {
	switch (event) {
	case ESP_GAP_BLE_ADV_DATA_SET_COMPLETE_EVT:
		esp_ble_gap_start_advertising(&test_adv_params);
		break;
	case ESP_GAP_BLE_ADV_DATA_RAW_SET_COMPLETE_EVT:
		esp_ble_gap_start_advertising(&test_adv_params);
		break;
	case ESP_GAP_BLE_SCAN_RSP_DATA_RAW_SET_COMPLETE_EVT:
		esp_ble_gap_start_advertising(&test_adv_params);
		break;
	default:
		break;
	}
}

bool savenvsFlag = false;

void configParserTask() {

	if (savenvsFlag) {
		SaveNVS(&UnitCfg);
		savenvsFlag = false;
	}
}

uint8_t dataCharRead[GATTS_CHAR_VAL_LEN_MAX];

cJSON *dataStorage;
cJSON *timeArray;

char *config_json;

cJSON *messageJson, *jsonData;

static void gatts_profile_a_event_handler(esp_gatts_cb_event_t event,
		esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
	switch (event) {
	case ESP_GATTS_REG_EVT:
		ESP_LOGI(GATTS_TAG, "REGISTER_APP_EVT, status %d, app_id %d\n",
				param->reg.status, param->reg.app_id);
		gl_profile_tab[PROFILE_A_APP_ID].service_id.is_primary = true;
		gl_profile_tab[PROFILE_A_APP_ID].service_id.id.inst_id = 0x00;
		gl_profile_tab[PROFILE_A_APP_ID].service_id.id.uuid.len =
		ESP_UUID_LEN_16;
		gl_profile_tab[PROFILE_A_APP_ID].service_id.id.uuid.uuid.uuid16 =
		GATTS_SERVICE_UUID_TEST_A;

		esp_ble_gap_set_device_name(UnitCfg.UnitName);
		esp_ble_gap_config_adv_data(&test_adv_data);
		esp_ble_gatts_create_service(gatts_if,
				&gl_profile_tab[PROFILE_A_APP_ID].service_id,
				GATTS_NUM_HANDLE_TEST_A);
		break;
	case ESP_GATTS_READ_EVT: {
		ESP_LOGI(GATTS_TAG,
				"GATT_READ_EVT, conn_id %d, trans_id %d, handle %d\n",
				param->read.conn_id, param->read.trans_id, param->read.handle);
		esp_gatt_rsp_t rsp;

		// Minimize the size of the packet. ~20 bytes is the max.
		memset(&rsp, 0, sizeof(esp_gatt_rsp_t));
		rsp.attr_value.handle = param->read.handle;

		dataStorage = cJSON_CreateObject();
		timeArray = cJSON_CreateArray();

		cJSON_AddStringToObject(dataStorage, "Company", UnitCfg.Company);
		cJSON_AddStringToObject(dataStorage, "UserName", UnitCfg.OperatorName);
		cJSON_AddNumberToObject(dataStorage, "Detection", detectionTriggered);
		cJSON_AddStringToObject(dataStorage, "RoomName", UnitCfg.RoomName);

		cJSON_AddItemToArray(timeArray,
				cJSON_CreateNumber(UnitCfg.DisinfictionTime));
		cJSON_AddItemToArray(timeArray,
				cJSON_CreateNumber(UnitCfg.ActivationTime));

		cJSON_AddItemToObject(dataStorage, "TimeData", timeArray);

		printf("%s\n", cJSON_PrintUnformatted(dataStorage));

		sprintf((char *) dataCharRead, cJSON_PrintUnformatted(dataStorage));

		rsp.attr_value.len = strlen((char *) dataCharRead);

		int i;
		for (i = 0; i < rsp.attr_value.len; i++)
			rsp.attr_value.value[i] = dataCharRead[i];

		cJSON_Delete(dataStorage);

		if (rsp.attr_value.len > 0) // Only send the packet if the value length is greater than zero.
			esp_ble_gatts_send_response(gatts_if, param->read.conn_id,
					param->read.trans_id, ESP_GATT_OK, &rsp);
		break;
	}
	case ESP_GATTS_WRITE_EVT: {
		ESP_LOGI(GATTS_TAG,
				"GATT_WRITE_EVT, conn_id %d, trans_id %d, handle %d\n",
				param->write.conn_id, param->write.trans_id,
				param->write.handle);
		ESP_LOGI(GATTS_TAG, "GATT_WRITE_EVT, value len %d, value %08x\n",
				param->write.len, *(uint32_t * )param->write.value);

		uint32_t msize = param->write.len + 1;
		config_json = malloc(msize);
		if (config_json != NULL) {
			sprintf(config_json, "%.*s", param->write.len,
					(char*) param->write.value);
		}

		printf("%s\n", config_json);

		if (strContains(config_json, "UVCTreatement : ON") == 1) {
			ESP_LOGI(GATTS_TAG, "UVCTreatement is ON ");
			UVTaskIsOn=true;
			xTaskCreate(&UVCTreatement, "UVCTreatement",
			configMINIMAL_STACK_SIZE * 3, NULL, 5,
			NULL);
		} else if (strContains(config_json, "STOP : ON") == 1) {
			ESP_LOGI(GATTS_TAG, "STOP is ON ");
			stopIsPressed = true;
			stopEventTrigerred = true;
		} else if (strContains(config_json, "data") == 1) {
			messageJson = cJSON_Parse(config_json);
			jsonData = cJSON_GetObjectItemCaseSensitive(messageJson, "data");

			if (cJSON_IsArray(jsonData)) {
				sprintf(UnitCfg.Company,
						cJSON_GetStringValue(cJSON_GetArrayItem(jsonData, 0)));
				sprintf(UnitCfg.OperatorName,
						cJSON_GetStringValue(cJSON_GetArrayItem(jsonData, 1)));
				sprintf(UnitCfg.RoomName,
						cJSON_GetStringValue(cJSON_GetArrayItem(jsonData, 2)));
				UnitCfg.DisinfictionTime =
						cJSON_GetArrayItem(jsonData, 3)->valueint;
				UnitCfg.ActivationTime =
						cJSON_GetArrayItem(jsonData, 4)->valueint;
				savenvsFlag = true;
			}

			cJSON_Delete(messageJson);

		} else {
			ESP_LOGE(GATTS_TAG, "BAD MESSAGE");
		}

		free(config_json);

		configParserTask();

		esp_ble_gatts_send_response(gatts_if, param->write.conn_id,
				param->write.trans_id, ESP_GATT_OK, NULL);
		break;
	}
	case ESP_GATTS_EXEC_WRITE_EVT:
	case ESP_GATTS_MTU_EVT:
		ESP_LOGI(GATTS_TAG, "ESP_GATTS_MTU_EVT, MTU %d", param->mtu.mtu);
		break;
	case ESP_GATTS_CONF_EVT:
	case ESP_GATTS_UNREG_EVT:
		break;
	case ESP_GATTS_CREATE_EVT:
		ESP_LOGI(GATTS_TAG,
				"CREATE_SERVICE_EVT, status %d,  service_handle %d\n",
				param->create.status, param->create.service_handle);
		gl_profile_tab[PROFILE_A_APP_ID].service_handle =
				param->create.service_handle;
		gl_profile_tab[PROFILE_A_APP_ID].char_uuid.len = ESP_UUID_LEN_16;
		gl_profile_tab[PROFILE_A_APP_ID].char_uuid.uuid.uuid16 =
		GATTS_CHAR_UUID_TEST_A;

		esp_ble_gatts_start_service(
				gl_profile_tab[PROFILE_A_APP_ID].service_handle);

		esp_ble_gatts_add_char(gl_profile_tab[PROFILE_A_APP_ID].service_handle,
				&gl_profile_tab[PROFILE_A_APP_ID].char_uuid,
				ESP_GATT_PERM_READ | ESP_GATT_PERM_WRITE,
				ESP_GATT_CHAR_PROP_BIT_READ | ESP_GATT_CHAR_PROP_BIT_WRITE,
				&TOTAL, NULL);
		break;
	case ESP_GATTS_ADD_INCL_SRVC_EVT:
		break;
	case ESP_GATTS_ADD_CHAR_EVT: {
		uint16_t length = 0;
		const uint8_t *prf_char;

		ESP_LOGI(GATTS_TAG,
				"ADD_CHAR_EVT, status %d,  attr_handle %d, service_handle %d\n",
				param->add_char.status, param->add_char.attr_handle,
				param->add_char.service_handle);
		gl_profile_tab[PROFILE_A_APP_ID].char_handle =
				param->add_char.attr_handle;
		gl_profile_tab[PROFILE_A_APP_ID].descr_uuid.len = ESP_UUID_LEN_16;
		gl_profile_tab[PROFILE_A_APP_ID].descr_uuid.uuid.uuid16 =
		ESP_GATT_UUID_CHAR_CLIENT_CONFIG;
		esp_ble_gatts_get_attr_value(param->add_char.attr_handle, &length,
				&prf_char);

		ESP_LOGI(GATTS_TAG, "the gatts demo char length = %x\n", length);
		esp_ble_gatts_add_char_descr(
				gl_profile_tab[PROFILE_A_APP_ID].service_handle,
				&gl_profile_tab[PROFILE_A_APP_ID].descr_uuid,
				ESP_GATT_PERM_READ | ESP_GATT_PERM_WRITE, NULL, NULL);
		break;
	}
	case ESP_GATTS_ADD_CHAR_DESCR_EVT:
		ESP_LOGI(GATTS_TAG,
				"ADD_DESCR_EVT, status %d, attr_handle %d, service_handle %d\n",
				param->add_char.status, param->add_char.attr_handle,
				param->add_char.service_handle);
		break;
	case ESP_GATTS_DELETE_EVT:
		break;
	case ESP_GATTS_START_EVT:
		ESP_LOGI(GATTS_TAG, "SERVICE_START_EVT, status %d, service_handle %d\n",
				param->start.status, param->start.service_handle);
		break;
	case ESP_GATTS_STOP_EVT:
		break;
	case ESP_GATTS_CONNECT_EVT:
		ESP_LOGI(GATTS_TAG,
				"ESP_GATTS_CONNECT_EVT, conn_id %d, remote %02x:%02x:%02x:%02x:%02x:%02x:",
				param->connect.conn_id, param->connect.remote_bda[0],
				param->connect.remote_bda[1], param->connect.remote_bda[2],
				param->connect.remote_bda[3], param->connect.remote_bda[4],
				param->connect.remote_bda[5]);
		gl_profile_tab[PROFILE_A_APP_ID].conn_id = param->connect.conn_id;
		break;
	case ESP_GATTS_DISCONNECT_EVT:
		ESP_LOGI(GATTS_TAG, "ESP_GATTS_DISCONNECT_EVT");
		detectionTriggered = false;
		esp_ble_gap_start_advertising(&test_adv_params);
		break;
	case ESP_GATTS_OPEN_EVT:
	case ESP_GATTS_CANCEL_OPEN_EVT:
	case ESP_GATTS_CLOSE_EVT:
	case ESP_GATTS_LISTEN_EVT:
	case ESP_GATTS_CONGEST_EVT:
	default:
		break;
	}
}

static void gatts_event_handler(esp_gatts_cb_event_t event,
		esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
	/* If event is register event, store the gatts_if for each profile */
	if (event == ESP_GATTS_REG_EVT) {
		if (param->reg.status == ESP_GATT_OK) {
			gl_profile_tab[param->reg.app_id].gatts_if = gatts_if;
		} else {
			ESP_LOGI(GATTS_TAG, "Reg app failed, app_id %04x, status %d\n",
					param->reg.app_id, param->reg.status);
			return;
		}
	}

	/* If the gatts_if equal to profile A, call profile A cb handler,
	 * so here call each profile's callback */
	do {
		int idx;
		for (idx = 0; idx < PROFILE_NUM; idx++) {
			if (gatts_if == ESP_GATT_IF_NONE || /* ESP_GATT_IF_NONE, not specify a certain gatt_if, need to call every profile cb function */
			gatts_if == gl_profile_tab[idx].gatts_if) {
				if (gl_profile_tab[idx].gatts_cb) {
					gl_profile_tab[idx].gatts_cb(event, gatts_if, param);
				}
			}
		}
	} while (0);
}

void bt_main() {

	esp_err_t ret;

	ESP_ERROR_CHECK(esp_bt_controller_mem_release(ESP_BT_MODE_CLASSIC_BT));

	esp_bt_controller_config_t bt_cfg = BT_CONTROLLER_INIT_CONFIG_DEFAULT()
	;
	ret = esp_bt_controller_init(&bt_cfg);
	if (ret) {
		ESP_LOGE(GATTS_TAG, "%s initialize controller failed\n", __func__);
		return;
	}

	ret = esp_bt_controller_enable(ESP_BT_MODE_BLE);

	if (ret) {
		ESP_LOGE(GATTS_TAG, "%s enable controller failed\n", __func__);
		return;
	}
	ret = esp_bluedroid_init();
	if (ret) {
		ESP_LOGE(GATTS_TAG, "%s init bluetooth failed\n", __func__);
		return;
	}
	ret = esp_bluedroid_enable();
	if (ret) {
		ESP_LOGE(GATTS_TAG, "%s enable bluetooth failed\n", __func__);
		return;
	}

	ret = esp_ble_gatts_register_callback(gatts_event_handler);
	if (ret) {
		ESP_LOGE(GATTS_TAG, "gatts register error, error code = %x", ret);
		return;
	}
	ret = esp_ble_gap_register_callback(gap_event_handler);
	if (ret) {
		ESP_LOGE(GATTS_TAG, "gap register error, error code = %x", ret);
		return;
	}
	ret = esp_ble_gatts_app_register(PROFILE_A_APP_ID);
	if (ret) {
		ESP_LOGE(GATTS_TAG, "gatts app register error, error code = %x", ret);
		return;
	}
	esp_err_t local_mtu_ret = esp_ble_gatt_set_local_mtu(512);
	if (local_mtu_ret) {
		ESP_LOGE(GATTS_TAG, "set local  MTU failed, error code = %x",
				local_mtu_ret);
	}

	return;
}