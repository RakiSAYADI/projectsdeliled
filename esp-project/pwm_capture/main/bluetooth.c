#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "esp_bt.h"
#include "esp_wifi.h"
#include <driver/dac.h>
#include "cJSON.h"

#include "esp_gap_ble_api.h"
#include "esp_gatts_api.h"
#include "esp_bt_defs.h"
#include "esp_bt_main.h"
#include "esp_gatt_common_api.h"

#include "sdkconfig.h"

#include "bluetooth.h"
#include "unitcfg.h"
#include "scanwifi.h"
#include "lightcontrol.h"
#include "wificonnect.h"

#include <stdint.h>
#include <inttypes.h>

#define GATTS_TAG 					"GATTS"

#define GATTS_CHAR_NUM_READ			2
#define GATTS_NUM_HANDLE_READ     	1+(2*GATTS_CHAR_NUM_READ)

///Declare the static function

static void gatts_profile_read_event_handler(esp_gatts_cb_event_t event,
		esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);

static void char_total_read_handler(esp_gatts_cb_event_t event,
		esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);

static void char_total_write_handler(esp_gatts_cb_event_t event,
		esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);
static void char_total2_read_handler(esp_gatts_cb_event_t event,
		esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);

static void char_total2_write_handler(esp_gatts_cb_event_t event,
		esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);

//Declare uuid of READ and WRITE Service

#define GATTS_SERVICE_UUID_TEST_READ    	0x00FF
#define GATTS_UUID_TEST_READ_Total        	0xFF01 //capteurs
#define GATTS_UUID_TEST_READ_Total2       	0xFF02 //wifi

#define GATTS_CHAR_VAL_LEN_MAX 				512

//characteristics values of READ profile

uint8_t total[GATTS_CHAR_VAL_LEN_MAX]; //capteurs

//property of each service

esp_gatt_char_prop_t read_property = 0;
esp_gatt_char_prop_t write_property = 0;

//

esp_attr_value_t TOTAL = { .attr_max_len = GATTS_CHAR_VAL_LEN_MAX, .attr_len =
		sizeof(total), .attr_value = (uint8_t *) &total, };

static uint8_t adv_config_done = 0;
#define adv_config_flag      (1 << 0)
#define scan_rsp_config_flag (1 << 1)

static uint32_t ble_add_char_pos;

static uint8_t adv_service_uuid128[32] = {
		/* LSB <--------------------------------------------------------------------------------> MSB */
		//first uuid, 16bit, [12],[13] is the value
		0xfb, 0x34, 0x9b, 0x5f, 0x80, 0x00, 0x00, 0x80, 0x00, 0x10, 0x00, 0x00,
		0xEE, 0x00, 0x00, 0x00,
		//second uuid, 32bit, [12], [13], [14], [15] is the value
		0xfb, 0x34, 0x9b, 0x5f, 0x80, 0x00, 0x00, 0x80, 0x00, 0x10, 0x00, 0x00,
		0xFF, 0x00, 0x00, 0x00, };

// The length of adv data must be less than 31 bytes
//static uint8_t test_manufacturer[TEST_MANUFACTURER_DATA_LEN] =  {0x12, 0x23, 0x45, 0x56};
//adv data
static esp_ble_adv_data_t adv_data = { .set_scan_rsp = false, .include_name =
true, .include_txpower = true, .min_interval = 0x20, .max_interval = 0x40,
		.appearance = 0x00,
		.manufacturer_len = 0, //TEST_MANUFACTURER_DATA_LEN,
		.p_manufacturer_data = NULL, //&test_manufacturer[0],
		.service_data_len = 0, .p_service_data = NULL, .service_uuid_len = 32,
		.p_service_uuid = adv_service_uuid128, .flag =
				(ESP_BLE_ADV_FLAG_GEN_DISC | ESP_BLE_ADV_FLAG_BREDR_NOT_SPT), };
// scan response data
static esp_ble_adv_data_t scan_rsp_data = { .set_scan_rsp = true,
		.include_name = true, .include_txpower = true, .min_interval = 0x20,
		.max_interval = 0x40, .appearance = 0x00,
		.manufacturer_len = 0, //TEST_MANUFACTURER_DATA_LEN,
		.p_manufacturer_data = NULL, //&test_manufacturer[0],
		.service_data_len = 0, .p_service_data = NULL, .service_uuid_len = 32,
		.p_service_uuid = adv_service_uuid128, .flag =
				(ESP_BLE_ADV_FLAG_GEN_DISC | ESP_BLE_ADV_FLAG_BREDR_NOT_SPT), };

static esp_ble_adv_params_t adv_params = { .adv_int_min = 0x20, .adv_int_max =
		0x40, .adv_type = ADV_TYPE_IND, .own_addr_type = BLE_ADDR_TYPE_PUBLIC,
		.channel_map = ADV_CHNL_ALL, .adv_filter_policy =
				ADV_FILTER_ALLOW_SCAN_ANY_CON_ANY, };

#define PROFILE_NUM 2
#define SERVICE_READ 0
#define SERVICE_WRITE 1

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
static struct gatts_profile_inst gl_profile_tab[PROFILE_NUM] = { [SERVICE_READ
		] = { .gatts_cb = gatts_profile_read_event_handler, .gatts_if =
		ESP_GATT_IF_NONE, /* Not get the gatt_if, so initial is ESP_GATT_IF_NONE */
		} };

struct gatts_char_inst {
	esp_bt_uuid_t char_uuid;
	esp_gatt_perm_t char_perm;
	esp_gatt_char_prop_t char_property;
	esp_attr_value_t *char_val;
	esp_attr_control_t *char_control;
	uint16_t char_handle;
	esp_gatts_cb_t char_read_callback;
	esp_gatts_cb_t char_write_callback;

};

static struct gatts_char_inst LIST_CHAR_READ[GATTS_CHAR_NUM_READ] = { //SERVICE READ
		{ .char_uuid.len = ESP_UUID_LEN_16, .char_uuid.uuid.uuid16 = // char Data
				GATTS_UUID_TEST_READ_Total, .char_perm = ESP_GATT_PERM_READ
				| ESP_GATT_PERM_WRITE, .char_property =
		ESP_GATT_CHAR_PROP_BIT_WRITE | ESP_GATT_CHAR_PROP_BIT_READ,
				.char_control = NULL, .char_handle = 0, .char_val = &TOTAL,
				.char_read_callback = char_total_read_handler,
				.char_write_callback = char_total_write_handler, }, { // char Wifi
				.char_uuid.len = ESP_UUID_LEN_16, .char_uuid.uuid.uuid16 =
				GATTS_UUID_TEST_READ_Total2, .char_perm = ESP_GATT_PERM_READ
						| ESP_GATT_PERM_WRITE, .char_property =
				ESP_GATT_CHAR_PROP_BIT_WRITE | ESP_GATT_CHAR_PROP_BIT_READ,
						.char_control = NULL, .char_handle = 0, .char_val =
								&TOTAL, .char_read_callback =
								char_total2_read_handler, .char_write_callback =
								char_total2_write_handler, } };

int jsonparse(char *src, char *dst, char *label, unsigned short arrayindex) {
	char *sp = 0, *ep = 0, *ic = 0;
	char tmp[64];

	sp = strstr(src, label);

	if (sp == NULL) {
		//ESP_LOGE(GATTS_TAG, "label %s not found",label);
		return (-1);
	}

	sp = strchr(sp, ':');
	if (sp == NULL) {
		ESP_LOGE(GATTS_TAG, "value start not found");
		return (-1);
	}

	if (sp[1] == '"') {
		sp++;
		ep = strchr(sp + 1, '"');
		ic = strchr(sp + 1, ',');
		if ((ep == NULL) || ((ep > ic) && (ic != NULL))) {
			ESP_LOGE(GATTS_TAG, "type string parsing error");
			return (-1);
		}
	} else if (sp[1] == '[') {
		sp++;
		ep = strchr(sp + 1, ']');
		ic = strchr(sp + 1, ':');
		if ((ep == NULL) || ((ep > ic) && (ic != NULL))) {
			ESP_LOGE(GATTS_TAG, "type array parsing error");
			return (-1);
		}

		ic = strchr(sp + 1, ',');
		if ((ic < ep) && (ic != NULL))
			ep = ic;

		for (int i = 0; i < arrayindex; i++) {
			sp = ep;
			ep = strchr(sp + 1, ',');

			if (ep == NULL) {
				ic = strchr(sp + 1, ']');
				ep = ic;
			}
		}

		if (sp[1] == '"') {
			sp++;
			ep = strchr(sp + 1, '"');
		}
	} else {
		ep = strchr(sp + 1, ',');
		if (ep == NULL)
			ep = strchr(sp + 1, '}');
		ic = strchr(sp + 1, ':');
		if ((ep == NULL) || ((ep > ic) && (ic != NULL))) {
			ESP_LOGE(GATTS_TAG, "type int parsing error");
			return (-1);
		}
	}

	strncpy(tmp, sp + 1, ep - sp - 1);
	tmp[ep - sp - 1] = 0;

	memset(dst, 0x00, strlen(tmp) + 1);
	memcpy(dst, tmp, strlen(tmp));

	return (0);
}

void gatts_check_callback(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if,
		esp_ble_gatts_cb_param_t *param) {
	uint16_t handle = 0;
	uint8_t read = 1;
	switch (event) {
	case ESP_GATTS_READ_EVT: {
		read = 1;
		handle = param->read.handle;
		break;
	}
	case ESP_GATTS_WRITE_EVT: {
		read = 0;
		handle = param->write.handle;
		break;
	}
	default:
		break;
	}

	ESP_LOGD(GATTS_TAG, "gatts_check_callback write %d num %d handle %d\n",
			read, GATTS_CHAR_NUM_READ, handle);
	for (uint32_t pos = 0; pos < GATTS_CHAR_NUM_READ; pos++) {
		if (LIST_CHAR_READ[pos].char_handle == handle) {
			if (read == 1) {
				if (LIST_CHAR_READ[pos].char_read_callback != NULL) {
					LIST_CHAR_READ[pos].char_read_callback(event, gatts_if,
							param);
				}
			}
			if (read == 0) {
				if (LIST_CHAR_READ[pos].char_write_callback != NULL) {
					LIST_CHAR_READ[pos].char_write_callback(event, gatts_if,
							param);
				}
			}
			break;
		}
	}
}

void gatts_add_char_READ() {

	ESP_LOGD(GATTS_TAG, "gatts_add_char_READ %d\n", GATTS_CHAR_NUM_READ);
	for (uint32_t pos = 0; pos < GATTS_CHAR_NUM_READ; pos++) {
		if (LIST_CHAR_READ[pos].char_handle == 0) {
			ESP_LOGI(GATTS_TAG, "ADD pos %d handle %d service %d\n", pos,
					LIST_CHAR_READ[pos].char_handle,
					gl_profile_tab[SERVICE_READ].service_handle);
			ble_add_char_pos = pos;
			esp_ble_gatts_add_char(gl_profile_tab[SERVICE_READ].service_handle,
					&LIST_CHAR_READ[pos].char_uuid,
					LIST_CHAR_READ[pos].char_perm,
					LIST_CHAR_READ[pos].char_property,
					LIST_CHAR_READ[pos].char_val,
					LIST_CHAR_READ[pos].char_control);
			break;
		}
	}
}

void gatts_check_add_char_READ(esp_bt_uuid_t char_uuid, uint16_t attr_handle) {

	ESP_LOGD(GATTS_TAG, "gatts_check_add_char_READ %d\n", attr_handle);
	if (attr_handle != 0) {
		if (char_uuid.len == ESP_UUID_LEN_16) {
			ESP_LOGI(GATTS_TAG, "Char READ UUID16: %x", char_uuid.uuid.uuid16);
		} else if (char_uuid.len == ESP_UUID_LEN_32) {
			ESP_LOGI(GATTS_TAG, "Char READ UUID32: %x", char_uuid.uuid.uuid32);
		} else if (char_uuid.len == ESP_UUID_LEN_128) {
			ESP_LOGI(GATTS_TAG,
					"Char READ UUID128: %x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x",
					char_uuid.uuid.uuid128[0], char_uuid.uuid.uuid128[1],
					char_uuid.uuid.uuid128[2], char_uuid.uuid.uuid128[3],
					char_uuid.uuid.uuid128[4], char_uuid.uuid.uuid128[5],
					char_uuid.uuid.uuid128[6], char_uuid.uuid.uuid128[7],
					char_uuid.uuid.uuid128[8], char_uuid.uuid.uuid128[9],
					char_uuid.uuid.uuid128[10], char_uuid.uuid.uuid128[11],
					char_uuid.uuid.uuid128[12], char_uuid.uuid.uuid128[13],
					char_uuid.uuid.uuid128[14], char_uuid.uuid.uuid128[15]);
		} else {
			ESP_LOGE(GATTS_TAG, "Char READ UNKNOWN LEN %d\n", char_uuid.len);
		}

		ESP_LOGD(GATTS_TAG, "FOUND Char READ pos %d handle %d\n",
				ble_add_char_pos, attr_handle);
		LIST_CHAR_READ[ble_add_char_pos].char_handle = attr_handle;
		gatts_add_char_READ();
	}
}

bool savenvsFlag = false;

void char_total_read_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if,
		esp_ble_gatts_cb_param_t *param) {
	ESP_LOGD(GATTS_TAG, "char_total_read_handler %d\n", param->read.handle);

	ESP_LOGI(GATTS_TAG, "[APP] Free memory: %d bytes",
			esp_get_free_heap_size());

	sprintf((char*) total,
			"{\"Ver\":%d,\"FirmV\":\"%s\",\"SCR\":%d,"
					"\"Amb1\":[\"%s\",\"%s\"],\"Amb2\":[\"%s\",\"%s\"],"
					"\"Amb3\":[\"%s\",\"%s\"],\"Amb4\":[\"%s\",\"%s\"],"
					"\"Amb5\":[\"%s\",\"%s\"],\"Amb6\":[\"%s\",\"%s\"],\"wifiSt\":%d,"
					"\"zone\":[\"%s\",\"%s\",\"%s\",\"%s\"],\"lun\":[%d,%ld,%d,\"%s\",%d,%d,\"%s\"],"
					"\"mar\":[%d,%ld,%d,\"%s\",%d,%d,\"%s\"],\"mer\":[%d,%ld,%d,\"%s\",%d,%d,\"%s\"],"
					"\"jeu\":[%d,%ld,%d,\"%s\",%d,%d,\"%s\"],\"ven\":[%d,%ld,%d,\"%s\",%d,%d,\"%s\"],"
					"\"sam\":[%d,%ld,%d,\"%s\",%d,%d,\"%s\"],\"dim\":[%d,%ld,%d,\"%s\",%d,%d,\"%s\"]}",
			UnitCfg.Version, UnitCfg.FirmwareVersion, scanResult,
			UnitCfg.ColortrProfile[0].name, UnitCfg.ColortrProfile[0].Hue,
			UnitCfg.ColortrProfile[1].name, UnitCfg.ColortrProfile[1].Hue,
			UnitCfg.ColortrProfile[2].name, UnitCfg.ColortrProfile[2].Hue,
			UnitCfg.ColortrProfile[3].name, UnitCfg.ColortrProfile[3].Hue,
			UnitCfg.ColortrProfile[4].name, UnitCfg.ColortrProfile[4].Hue,
			UnitCfg.ColortrProfile[5].name, UnitCfg.ColortrProfile[5].Hue,
			stateConnection, UnitCfg.Zones.ZONE1, UnitCfg.Zones.ZONE2,
			UnitCfg.Zones.ZONE3, UnitCfg.Zones.ZONE4, UnitCfg.alarmDay[1].state,
			UnitCfg.alarmDay[1].autoTrigTime, UnitCfg.alarmDay[1].duration,
			UnitCfg.alarmDay[1].hue, UnitCfg.alarmDay[1].startLumVal,
			UnitCfg.alarmDay[1].finishLumVal, UnitCfg.alarmDay[1].zones,
			UnitCfg.alarmDay[2].state, UnitCfg.alarmDay[2].autoTrigTime,
			UnitCfg.alarmDay[2].duration, UnitCfg.alarmDay[2].hue,
			UnitCfg.alarmDay[2].startLumVal, UnitCfg.alarmDay[2].finishLumVal,
			UnitCfg.alarmDay[2].zones, UnitCfg.alarmDay[3].state,
			UnitCfg.alarmDay[3].autoTrigTime, UnitCfg.alarmDay[3].duration,
			UnitCfg.alarmDay[3].hue, UnitCfg.alarmDay[3].startLumVal,
			UnitCfg.alarmDay[3].finishLumVal, UnitCfg.alarmDay[3].zones,
			UnitCfg.alarmDay[4].state, UnitCfg.alarmDay[4].autoTrigTime,
			UnitCfg.alarmDay[4].duration, UnitCfg.alarmDay[4].hue,
			UnitCfg.alarmDay[4].startLumVal, UnitCfg.alarmDay[4].finishLumVal,
			UnitCfg.alarmDay[4].zones, UnitCfg.alarmDay[5].state,
			UnitCfg.alarmDay[5].autoTrigTime, UnitCfg.alarmDay[5].duration,
			UnitCfg.alarmDay[5].hue, UnitCfg.alarmDay[5].startLumVal,
			UnitCfg.alarmDay[5].finishLumVal, UnitCfg.alarmDay[5].zones,
			UnitCfg.alarmDay[6].state, UnitCfg.alarmDay[6].autoTrigTime,
			UnitCfg.alarmDay[6].duration, UnitCfg.alarmDay[6].hue,
			UnitCfg.alarmDay[6].startLumVal, UnitCfg.alarmDay[6].finishLumVal,
			UnitCfg.alarmDay[6].zones, UnitCfg.alarmDay[0].state,
			UnitCfg.alarmDay[0].autoTrigTime, UnitCfg.alarmDay[0].duration,
			UnitCfg.alarmDay[0].hue, UnitCfg.alarmDay[0].startLumVal,
			UnitCfg.alarmDay[0].finishLumVal, UnitCfg.alarmDay[0].zones);

	TOTAL.attr_len = strlen((char *) total);

	esp_gatt_rsp_t rsp;
	memset(&rsp, 0, sizeof(esp_gatt_rsp_t));
	rsp.attr_value.handle = param->read.handle;
	if (LIST_CHAR_READ[0].char_val != NULL) {
		ESP_LOGD(GATTS_TAG, "char_total_read_handler char_val %d\n",
				LIST_CHAR_READ[0].char_val->attr_len);
		rsp.attr_value.len = LIST_CHAR_READ[0].char_val->attr_len;
		for (uint32_t pos = 0;
				pos < LIST_CHAR_READ[0].char_val->attr_len
						&& pos < LIST_CHAR_READ[0].char_val->attr_max_len;
				pos++) {
			rsp.attr_value.value[pos] =
					LIST_CHAR_READ[0].char_val->attr_value[pos];
		}
	}
	ESP_LOGD(GATTS_TAG, "char_total_read_handler = %.*s\n",
			LIST_CHAR_READ[0].char_val->attr_len,
			(char* )LIST_CHAR_READ[0].char_val->attr_value);
	ESP_LOGD(GATTS_TAG, "char_total_read_handler esp_gatt_rsp_t\n");

	esp_ble_gatts_send_response(gatts_if, param->read.conn_id,
			param->read.trans_id, ESP_GATT_OK, &rsp);
}

void char_total_write_handler(esp_gatts_cb_event_t event,
		esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
	ESP_LOGD(GATTS_TAG, "char_light_write_handler %d\n", param->write.handle);
	if (LIST_CHAR_READ[0].char_val != NULL) {
		char *config_json;
		ESP_LOGD(GATTS_TAG, "char_light_write_handler char_val %d\n",
				param->write.len);
		LIST_CHAR_READ[0].char_val->attr_len = param->write.len;
		for (uint32_t pos = 0; pos < param->write.len; pos++) {
			LIST_CHAR_READ[0].char_val->attr_value[pos] =
					param->write.value[pos];
		}
		ESP_LOGD(GATTS_TAG, "char_light_write_handler = %.*s\n",
				LIST_CHAR_READ[0].char_val->attr_len,
				(char* )LIST_CHAR_READ[0].char_val->attr_value);

		uint32_t msize = LIST_CHAR_READ[0].char_val->attr_len + 1;
		config_json = malloc(msize);
		if (config_json != NULL) {
			sprintf(config_json, "%.*s", LIST_CHAR_READ[0].char_val->attr_len,
					(char*) LIST_CHAR_READ[0].char_val->attr_value);
			printf("%s\n", config_json);

			readingData(config_json);

			free(config_json);

			saveDataTask(savenvsFlag);
		}
	}
	ESP_LOGD(GATTS_TAG, "char_light_write_handler esp_gatt_rsp_t\n");
	esp_ble_gatts_send_response(gatts_if, param->write.conn_id,
			param->write.trans_id, ESP_GATT_OK, NULL);
}
void char_total2_read_handler(esp_gatts_cb_event_t event,
		esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
	ESP_LOGD(GATTS_TAG, "char_total_read_handler %d\n", param->read.handle);

	ESP_LOGI(GATTS_TAG, "[APP] Free memory: %d bytes",
			esp_get_free_heap_size());

	sprintf((char*) total, "{\"AP_RECORDS\":[\"%s\"",
			stationRecords[0].ap_records);
	char apSSID[33];
	for (int i = 1; i < ap_num; i++) {
		sprintf((char*) apSSID, ",\"%s\"", stationRecords[i].ap_records);
		strcpy((char*) total + strlen((char*) total), apSSID);
	}
	strcpy((char*) total + strlen((char*) total), "]}");
	ESP_LOGI(GATTS_TAG, "total = %s", (char* ) total);

	TOTAL.attr_len = strlen((char *) total);

	esp_gatt_rsp_t rsp;
	memset(&rsp, 0, sizeof(esp_gatt_rsp_t));
	rsp.attr_value.handle = param->read.handle;
	if (LIST_CHAR_READ[1].char_val != NULL) {
		ESP_LOGD(GATTS_TAG, "char_total_read_handler char_val %d\n",
				LIST_CHAR_READ[1].char_val->attr_len);
		rsp.attr_value.len = LIST_CHAR_READ[1].char_val->attr_len;
		for (uint32_t pos = 0;
				pos < LIST_CHAR_READ[1].char_val->attr_len
						&& pos < LIST_CHAR_READ[1].char_val->attr_max_len;
				pos++) {
			rsp.attr_value.value[pos] =
					LIST_CHAR_READ[1].char_val->attr_value[pos];
		}
	}
	ESP_LOGD(GATTS_TAG, "char_total_read_handler = %.*s\n",
			LIST_CHAR_READ[1].char_val->attr_len,
			(char* )LIST_CHAR_READ[1].char_val->attr_value);
	ESP_LOGD(GATTS_TAG, "char_total_read_handler esp_gatt_rsp_t\n");

	esp_ble_gatts_send_response(gatts_if, param->read.conn_id,
			param->read.trans_id, ESP_GATT_OK, &rsp);
}

void char_total2_write_handler(esp_gatts_cb_event_t event,
		esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
	ESP_LOGD(GATTS_TAG, "char_light_write_handler %d\n", param->write.handle);
	if (LIST_CHAR_READ[1].char_val != NULL) {
		char *config_json;
		ESP_LOGD(GATTS_TAG, "char_light_write_handler char_val %d\n",
				param->write.len);
		LIST_CHAR_READ[1].char_val->attr_len = param->write.len;
		for (uint32_t pos = 0; pos < param->write.len; pos++) {
			LIST_CHAR_READ[1].char_val->attr_value[pos] =
					param->write.value[pos];
		}
		ESP_LOGD(GATTS_TAG, "char_light_write_handler = %.*s\n",
				LIST_CHAR_READ[1].char_val->attr_len,
				(char* )LIST_CHAR_READ[1].char_val->attr_value);

		uint32_t msize = LIST_CHAR_READ[1].char_val->attr_len + 1;
		config_json = malloc(msize);
		if (config_json != NULL) {
			sprintf(config_json, "%.*s", LIST_CHAR_READ[1].char_val->attr_len,
					(char*) LIST_CHAR_READ[1].char_val->attr_value);
			printf("%s\n", config_json);

			readingWifi(config_json);

			free(config_json);

		}
	}
	ESP_LOGD(GATTS_TAG, "char_light_write_handler esp_gatt_rsp_t\n");
	esp_ble_gatts_send_response(gatts_if, param->write.conn_id,
			param->write.trans_id, ESP_GATT_OK, NULL);
}
uint8_t cmd = 0, subcmd = 0, subcmdhue = 0, subcmdlum = 0, subcmdstab = 0,
		subcmdhueold = 0, subcmdlumold = 0, subcmdstabold = 0, zone = 0;

bool transtionAmbiancesActivated = false;

HSLStruct HSLtmp;

time_t t = 0;
uint32_t tz = 0;

void readingWifi(char * jsonData) {
	char tmp[64];
	if (jsonparse(jsonData, tmp, "SCAN", 0) == 0) {
		if (atoi(tmp) == 1) {
			ESP_LOGI(GATTS_TAG, "Scan is Activated");
			scanWIFITask();
		} else {
			ESP_LOGE(GATTS_TAG, "Scan is not activated");
		}
	} else {

	}
}

bool readAlertMessage(char * jsonData, char day[4], int dayID) {
	char tmp[64];
	bool stateFlag = false;

	if (jsonparse(jsonData, tmp, day, 0) == 0) {

		UnitCfg.alarmDay[dayID].state = atoi(tmp);

		if (UnitCfg.alarmDay[dayID].state) {
			ESP_LOGI(GATTS_TAG, "%s is selected !", day);
		} else {
			ESP_LOGI(GATTS_TAG, "%s is not selected !", day);
		}
		stateFlag = true;

		if (jsonparse(jsonData, tmp, day, 1) == 0) {
			UnitCfg.alarmDay[dayID].autoTrigTime = atoi(tmp);

			ESP_LOGI(GATTS_TAG, "%s time is %ld", day,
					UnitCfg.alarmDay[dayID].autoTrigTime);
			stateFlag = true;

		}
		if (jsonparse(jsonData, tmp, day, 2) == 0) {
			UnitCfg.alarmDay[dayID].duration = atoi(tmp);

			ESP_LOGI(GATTS_TAG, "%s duration is %d", day,
					UnitCfg.alarmDay[dayID].duration);
			stateFlag = true;

		}
		if (jsonparse(jsonData, UnitCfg.alarmDay[dayID].hue, day, 3) == 0) {

			ESP_LOGI(GATTS_TAG, "%s hue is %s", day,
					UnitCfg.alarmDay[dayID].hue);
			stateFlag = true;

		}
		if (jsonparse(jsonData, tmp, day, 4) == 0) {
			UnitCfg.alarmDay[dayID].startLumVal = atoi(tmp);
			ESP_LOGI(GATTS_TAG, "%s start lum is %d", day,
					UnitCfg.alarmDay[dayID].startLumVal);
			stateFlag = true;

		}
		if (jsonparse(jsonData, tmp, day, 5) == 0) {
			UnitCfg.alarmDay[dayID].finishLumVal = atoi(tmp);
			ESP_LOGI(GATTS_TAG, "%s start lum is %d", day,
					UnitCfg.alarmDay[dayID].finishLumVal);
			stateFlag = true;

		}
		if (jsonparse(jsonData, UnitCfg.alarmDay[dayID].zones, day, 6) == 0) {
			ESP_LOGI(GATTS_TAG, "%s zone is %s\n", day,
					UnitCfg.alarmDay[dayID].zones);
			stateFlag = true;

		}
	}
	return stateFlag;
}

void readingData(char * jsonData) {
	char tmp[64];
	savenvsFlag = false;

	//wakeup DATA

	savenvsFlag = readAlertMessage(jsonData, "lun", 1);
	savenvsFlag = readAlertMessage(jsonData, "mar", 2);
	savenvsFlag = readAlertMessage(jsonData, "mer", 3);
	savenvsFlag = readAlertMessage(jsonData, "jeu", 4);
	savenvsFlag = readAlertMessage(jsonData, "ven", 5);
	savenvsFlag = readAlertMessage(jsonData, "sam", 6);
	savenvsFlag = readAlertMessage(jsonData, "dim", 0);

	//Zones Names

	if (jsonparse(jsonData, UnitCfg.Zones.ZONE1, "zones", 0) == 0) {

		ESP_LOGI(GATTS_TAG, "zone 1 is %s", UnitCfg.Zones.ZONE1);
		savenvsFlag = true;

		if (jsonparse(jsonData, UnitCfg.Zones.ZONE2, "zones", 1) == 0) {

			ESP_LOGI(GATTS_TAG, "zone 2 is %s", UnitCfg.Zones.ZONE2);
			savenvsFlag = true;

		}
		if (jsonparse(jsonData, UnitCfg.Zones.ZONE3, "zones", 2) == 0) {

			ESP_LOGI(GATTS_TAG, "zone 3 is %s", UnitCfg.Zones.ZONE3);
			savenvsFlag = true;

		}
		if (jsonparse(jsonData, UnitCfg.Zones.ZONE4, "zones", 3) == 0) {

			ESP_LOGI(GATTS_TAG, "zone 4 is %s", UnitCfg.Zones.ZONE4);
			savenvsFlag = true;

		}

	} else if (jsonparse(jsonData, tmp, "system", 0) == 0) {
		//system
		if (atoi(tmp) == 0) {
			ESP_LOGI(GATTS_TAG, "System apply default setting");

			Default_saving();
		} else {

			ESP_LOGI(GATTS_TAG, "System restart");
			esp_restart();
		}

	} else if (jsonparse(jsonData, UnitCfg.WifiCfg.WIFI_SSID, "wa", 0) == 0) {
		ESP_LOGD(GATTS_TAG, "set ap ssid %s", UnitCfg.WifiCfg.WIFI_SSID);

		if (jsonparse(jsonData, UnitCfg.WifiCfg.WIFI_PASS, "wp", 0) == 0) {
			ESP_LOGD(GATTS_TAG, "set ap password %s",
					UnitCfg.WifiCfg.WIFI_PASS);
		}

		savenvsFlag = true;
	} else if (jsonparse(jsonData, tmp, "light", 0) == 0) {
		//light
		cmd = atoi(tmp);

		if (jsonparse(jsonData, tmp, "light", 1) == 0) {
			subcmd = atoi(tmp);
		}
		if (jsonparse(jsonData, tmp, "light", 2) == 0) {
			zone = strtol(tmp, NULL, 16);
		}

		// On/Off

		if ((cmd == LCMD_SWITCH_ON_OFF) && (zone != 0)) {
			MilightHandler(LCMD_SWITCH_ON_OFF, subcmd, zone & 0x0F);
		}
		//radio
		MilightHandler(cmd, subcmd, zone & 0x0F);

		ESP_LOGI(GATTS_TAG, "Light control manu cmd %d subcmd %d zone %d", cmd,
				subcmd, zone);

		transtionAmbiancesActivated = false;

	} else if (jsonparse(jsonData, UnitCfg.UnitName, "dname", 0) == 0) {
		ESP_LOGI(GATTS_TAG, "set device name %s", UnitCfg.UnitName);
		savenvsFlag = true;
	} else if (jsonparse(jsonData, tmp, "Time", 0) == 0) {

		// time
		time_t tl = 0;
		struct tm ti;

		time(&tl);
		localtime_r(&tl, &ti);

		if (ti.tm_year < (2016 - 1900)) {
			t = atoi(tmp);
			ESP_LOGI(GATTS_TAG, "Time sync epoch %ld", t);

			if (jsonparse(jsonData, tmp, "Time", 1) == 0) {
				tz = atoi(tmp);
				ESP_LOGI(GATTS_TAG, "Time zone %d", tz / 3600);
				syncTime(t, tz);
				UnitCfg.timeZone = tz / 3600;
				savenvsFlag = true;
			}
		} else
			ESP_LOGE(GATTS_TAG, "Time sync ignored");
	} else if (jsonparse(jsonData, tmp, "hue", 0) == 0) {
		// hue
		uint32_t rgb = 0;

		transtionAmbiancesActivated = false;

		rgb = strtol(tmp, NULL, 16);
		RgbToHSL(rgb, &HSLtmp);

		if (jsonparse(jsonData, tmp, "zone", 0) == 0) {
			zone = strtol(tmp, NULL, 16);
		}

		// apply hue
		cmd = 3;
		subcmdhue = HSLtmp.Hue;

		if (subcmdhue != subcmdhueold) {
			MilightHandler(cmd, subcmdhue, zone & 0xF);
			ESP_LOGI(GATTS_TAG,
					"Light control cmd %d subcmd %d subcmdold %d zone %d", cmd,
					subcmdhue, subcmdhueold, zone);
			subcmdhueold = subcmdhue;
		}

		// apply brightness
		cmd = 7;
		subcmdlum = HSLtmp.Bri;
		if (subcmdlum != subcmdlumold) {
			MilightHandler(cmd, subcmdlum, zone);
			ESP_LOGI(GATTS_TAG,
					"Light control cmd %d subcmd %d subcmdold %d zone %d", cmd,
					subcmdlum, subcmdlumold, zone);
			subcmdlumold = subcmdlum;
		}

		// apply saturation
		cmd = 9;
		subcmdstab = HSLtmp.Sat;
		if (subcmdstab != subcmdstabold) {
			MilightHandler(cmd, subcmdstab, zone);
			ESP_LOGI(GATTS_TAG,
					"Light control cmd %d subcmd %d subcmdold %d zone %d", cmd,
					subcmdstab, subcmdstabold, zone);
			subcmdstabold = subcmdstab;
		}

	} else

	if (jsonparse(jsonData, UnitCfg.ColortrProfile[0].name, "couleur1", 0)
			== 0) {

		//Couleur 1

		ESP_LOGI(GATTS_TAG, "Profile Color name set %s",
				UnitCfg.ColortrProfile[0].name);
		savenvsFlag = true;
		if (jsonparse(jsonData, UnitCfg.ColortrProfile[0].Hue, "couleur1", 1)
				== 0) {
			ESP_LOGI(GATTS_TAG, "Profile Color Hue set %s",
					UnitCfg.ColortrProfile[0].Hue);
			savenvsFlag = true;

		}

	} else

	if (jsonparse(jsonData, UnitCfg.ColortrProfile[1].name, "couleur2", 0)
			== 0) {

		//Couleur 2

		ESP_LOGI(GATTS_TAG, "Profile Color name set %s",
				UnitCfg.ColortrProfile[1].name);
		savenvsFlag = true;
		if (jsonparse(jsonData, UnitCfg.ColortrProfile[1].Hue, "couleur2", 1)
				== 0) {
			ESP_LOGI(GATTS_TAG, "Profile Color Hue set %s",
					UnitCfg.ColortrProfile[1].Hue);
			savenvsFlag = true;

		}

	} else

	if (jsonparse(jsonData, UnitCfg.ColortrProfile[2].name, "couleur3", 0)
			== 0) {

		//Couleur 3

		ESP_LOGI(GATTS_TAG, "Profile Color name set %s",
				UnitCfg.ColortrProfile[2].name);
		savenvsFlag = true;
		if (jsonparse(jsonData, UnitCfg.ColortrProfile[2].Hue, "couleur3", 1)
				== 0) {
			ESP_LOGI(GATTS_TAG, "Profile Color Hue set %s",
					UnitCfg.ColortrProfile[2].Hue);
			savenvsFlag = true;

		}

	} else

	if (jsonparse(jsonData, UnitCfg.ColortrProfile[3].name, "couleur4", 0)
			== 0) {

		//Couleur 4

		ESP_LOGI(GATTS_TAG, "Profile Color name set %s",
				UnitCfg.ColortrProfile[3].name);
		savenvsFlag = true;
		if (jsonparse(jsonData, UnitCfg.ColortrProfile[3].Hue, "couleur4", 1)
				== 0) {
			ESP_LOGI(GATTS_TAG, "Profile Color Hue set %s",
					UnitCfg.ColortrProfile[3].Hue);
			savenvsFlag = true;

		}

	} else

	if (jsonparse(jsonData, UnitCfg.ColortrProfile[4].name, "couleur5", 0)
			== 0) {

		//Couleur 5

		ESP_LOGI(GATTS_TAG, "Profile Color name set %s",
				UnitCfg.ColortrProfile[4].name);
		savenvsFlag = true;
		if (jsonparse(jsonData, UnitCfg.ColortrProfile[4].Hue, "couleur5", 1)
				== 0) {
			ESP_LOGI(GATTS_TAG, "Profile Color Hue set %s",
					UnitCfg.ColortrProfile[4].Hue);
			savenvsFlag = true;

		}

	} else

	if (jsonparse(jsonData, UnitCfg.ColortrProfile[5].name, "couleur6", 0)
			== 0) {

		//Couleur 6

		ESP_LOGI(GATTS_TAG, "Profile Color name set %s",
				UnitCfg.ColortrProfile[5].name);
		savenvsFlag = true;
		if (jsonparse(jsonData, UnitCfg.ColortrProfile[5].Hue, "couleur6", 1)
				== 0) {
			ESP_LOGI(GATTS_TAG, "Profile Color Hue set %s",
					UnitCfg.ColortrProfile[5].Hue);
			savenvsFlag = true;

		}

	} else if (jsonparse(jsonData, tmp, "Favoris", 0) == 0) {
		ESP_LOGI(GATTS_TAG, "Ambiance Color set %s", tmp);
		if (strcmp(tmp, "Ambiance 1") == 0) {
			ESP_LOGI(GATTS_TAG, "Ambiance 1 is Selected");
			transitionAmbianceProcess(0);
		} else if (strcmp(tmp, "Ambiance 2") == 0) {
			ESP_LOGI(GATTS_TAG, "Ambiance 2 is Selected");
			transitionAmbianceProcess(1);
		} else if (strcmp(tmp, "Ambiance 3") == 0) {
			ESP_LOGI(GATTS_TAG, "Ambiance 3 is Selected");
			transitionAmbianceProcess(2);
		} else if (strcmp(tmp, "Ambiance 4") == 0) {
			ESP_LOGI(GATTS_TAG, "Ambiance 4 is Selected");
			transitionAmbianceProcess(3);
		} else if (strcmp(tmp, "Ambiance 5") == 0) {
			ESP_LOGI(GATTS_TAG, "Ambiance 5 is Selected");
			transitionAmbianceProcess(4);
		} else if (strcmp(tmp, "Ambiance 6") == 0) {
			ESP_LOGI(GATTS_TAG, "Ambiance 6 is Selected");
			transitionAmbianceProcess(5);
		} else {
			ESP_LOGI(GATTS_TAG, "Unknown Ambiance");
		}
	} else {
		ESP_LOGE(GATTS_TAG, "BAD MESSAGE");
	}
}

void transitionAmbianceProcess(int ambianceId) {
	uint32_t rgb = 0;
	rgb = strtol(UnitCfg.ColortrProfile[ambianceId].Hue, NULL, 16);
	RgbToHSL(rgb, &HSLtmp);
//	if (jsonparse(jsonData, tmp, "zone", 0) == 0) {
//		zone = strtol(tmp, NULL, 16);
//	}
	zone = 15;
	if (!transtionAmbiancesActivated) {
		// apply hue
		cmd = 3;
		subcmdhue = HSLtmp.Hue;
		MilightHandler(cmd, subcmdhue, zone);
		ESP_LOGI(GATTS_TAG,
				"Light control cmd %d subcmd %d subcmdold %d zone %d", cmd,
				subcmdhue, subcmdhueold, zone);
		subcmdhueold = subcmdhue;

		// apply brightness
		cmd = 7;
		subcmdlum = HSLtmp.Bri;
		MilightHandler(cmd, subcmdlum, zone);
		ESP_LOGI(GATTS_TAG,
				"Light control cmd %d subcmd %d subcmdold %d zone %d", cmd,
				subcmdlum, subcmdlumold, zone);
		subcmdlumold = subcmdlum;

		// apply saturation
		cmd = 9;
		subcmdstab = HSLtmp.Sat;
		MilightHandler(cmd, subcmdstab, zone);
		ESP_LOGI(GATTS_TAG,
				"Light control cmd %d subcmd %d subcmdold %d zone %d", cmd,
				subcmdstab, subcmdstabold, zone);
		subcmdstabold = subcmdstab;

		transtionAmbiancesActivated = true;
	} else {
		float penteTransHue = 0, penteTransLum = 0, penteTransStab = 0;
		uint8_t transOutHue = 0, transOutLum = 0, transOutStab = 0;
		uint16_t progressTime = 0;
		subcmdhue = HSLtmp.Hue;
		subcmdlum = HSLtmp.Bri;
		subcmdstab = HSLtmp.Sat;
		penteTransHue = (subcmdhue - subcmdhueold) / 2000.0;
		penteTransLum = (subcmdlum - subcmdlumold) / 2000.0;
		penteTransStab = (subcmdstab - subcmdstabold) / 2000.0;

		while (progressTime <= 2000) {
			cmd = 3;
			transOutHue = (penteTransHue * progressTime) + subcmdhueold;
			MilightHandler(cmd, transOutHue, zone);
			cmd = 7;
			transOutLum = (penteTransLum * progressTime) + subcmdlumold;
			MilightHandler(cmd, transOutLum, zone);
			cmd = 9;
			transOutStab = (penteTransStab * progressTime) + subcmdstabold;
			MilightHandler(cmd, transOutStab, zone);
			progressTime += 50;
			delay(50);
			ESP_LOGI(GATTS_TAG, "Light control hue %d lum %d stab %d zone %d",
					transOutHue, transOutLum, transOutStab, zone);
		}
		subcmdhueold = subcmdhue;
		subcmdlumold = subcmdlum;
		subcmdstabold = subcmdstab;
	}
}

void gap_event_handler(esp_gap_ble_cb_event_t event,
		esp_ble_gap_cb_param_t *param) {
	switch (event) {

	case ESP_GAP_BLE_ADV_DATA_SET_COMPLETE_EVT:
		adv_config_done &= (~adv_config_flag);
		if (adv_config_done == 0) {
			esp_ble_gap_start_advertising(&adv_params);
		}
		break;
	case ESP_GAP_BLE_SCAN_RSP_DATA_SET_COMPLETE_EVT:
		adv_config_done &= (~scan_rsp_config_flag);
		if (adv_config_done == 0) {
			esp_ble_gap_start_advertising(&adv_params);
		}
		break;

	case ESP_GAP_BLE_ADV_START_COMPLETE_EVT:
		//advertising start complete event to indicate advertising start successfully or failed
		if (param->adv_start_cmpl.status != ESP_BT_STATUS_SUCCESS) {
			ESP_LOGE(GATTS_TAG, "Advertising start failed\n");
		}
		break;
	case ESP_GAP_BLE_ADV_STOP_COMPLETE_EVT:
		if (param->adv_stop_cmpl.status != ESP_BT_STATUS_SUCCESS) {
			ESP_LOGE(GATTS_TAG, "Advertising stop failed\n");
		} else {
			ESP_LOGI(GATTS_TAG, "Stop adv successfully\n");
		}
		break;
	case ESP_GAP_BLE_UPDATE_CONN_PARAMS_EVT:
		ESP_LOGD(GATTS_TAG,
				"update connection params status = %d, min_int = %d, max_int = %d,conn_int = %d,latency = %d, timeout = %d",
				param->update_conn_params.status,
				param->update_conn_params.min_int,
				param->update_conn_params.max_int,
				param->update_conn_params.conn_int,
				param->update_conn_params.latency,
				param->update_conn_params.timeout);
		break;
	default:
		break;
	}
}

void gatts_profile_read_event_handler(esp_gatts_cb_event_t event,
		esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
	switch (event) {
	case ESP_GATTS_REG_EVT:
		ESP_LOGD(GATTS_TAG, "REGISTER_APP_EVT_READ, status %d, app_id %d\n",
				param->reg.status, param->reg.app_id);
		gl_profile_tab[SERVICE_READ].service_id.is_primary = true;
		gl_profile_tab[SERVICE_READ].service_id.id.inst_id = 0x00;
		gl_profile_tab[SERVICE_READ].service_id.id.uuid.len = ESP_UUID_LEN_16;
		gl_profile_tab[SERVICE_READ].service_id.id.uuid.uuid.uuid16 =
		GATTS_SERVICE_UUID_TEST_READ;

		esp_err_t set_dev_name_ret = esp_ble_gap_set_device_name(
				UnitCfg.UnitName);
		if (set_dev_name_ret) {
			ESP_LOGE(GATTS_TAG, "set device name failed, error code = %x",
					set_dev_name_ret);
		}

		//config adv data
		esp_err_t ret = esp_ble_gap_config_adv_data(&adv_data);
		if (ret) {
			ESP_LOGE(GATTS_TAG, "config adv data failed, error code = %x", ret);
		}
		adv_config_done |= adv_config_flag;
		//config scan response data
		ret = esp_ble_gap_config_adv_data(&scan_rsp_data);
		if (ret) {
			ESP_LOGE(GATTS_TAG,
					"config scan response data failed, error code = %x", ret);
		}
		adv_config_done |= scan_rsp_config_flag;

		esp_ble_gatts_create_service(gatts_if,
				&gl_profile_tab[SERVICE_READ].service_id,
				GATTS_NUM_HANDLE_READ);

		break;
	case ESP_GATTS_READ_EVT: {
		ESP_LOGI(GATTS_TAG,
				"GATT_READ_EVT_READ, conn_id %d, trans_id %d, handle %d",
				param->read.conn_id, param->read.trans_id, param->read.handle);
		gatts_check_callback(event, gatts_if, param);
		break;
	}
	case ESP_GATTS_WRITE_EVT: {
		ESP_LOGI(GATTS_TAG,
				"GATT_READ_EVT_READ, conn_id %d, trans_id %d, handle %d",
				param->write.conn_id, param->write.trans_id,
				param->write.handle);
		gatts_check_callback(event, gatts_if, param);
		break;
		break;
	}
	case ESP_GATTS_EXEC_WRITE_EVT:
		break;
	case ESP_GATTS_MTU_EVT:
		ESP_LOGI(GATTS_TAG, "ESP_GATTS_MTU_EVT, MTU %d", param->mtu.mtu);
		break;
	case ESP_GATTS_UNREG_EVT:
		break;
	case ESP_GATTS_CREATE_EVT:
		ESP_LOGI(GATTS_TAG,
				"CREATE_SERVICE_EVT_READ, status %d,  service_handle %d\n",
				param->create.status, param->create.service_handle);
		gl_profile_tab[SERVICE_READ].service_handle =
				param->create.service_handle;
		gl_profile_tab[SERVICE_READ].char_uuid.len =
				LIST_CHAR_READ[0].char_uuid.len;
		gl_profile_tab[SERVICE_READ].char_uuid.uuid.uuid16 =
				LIST_CHAR_READ[0].char_uuid.uuid.uuid16;

		esp_ble_gatts_start_service(
				gl_profile_tab[SERVICE_READ].service_handle);
		gatts_add_char_READ();
		break;
	case ESP_GATTS_ADD_INCL_SRVC_EVT:
		break;
	case ESP_GATTS_ADD_CHAR_EVT: {
		ESP_LOGI(GATTS_TAG,
				"ADD_CHAR_EVT_READ, status %d,  attr_handle %d, service_handle %d\n",
				param->add_char.status, param->add_char.attr_handle,
				param->add_char.service_handle);
		gl_profile_tab[SERVICE_READ].char_handle = param->add_char.attr_handle;
		if (param->add_char.status == ESP_GATT_OK) {
			gatts_check_add_char_READ(param->add_char.char_uuid,
					param->add_char.attr_handle);
		}
		break;
	}
	case ESP_GATTS_ADD_CHAR_DESCR_EVT:
		break;
	case ESP_GATTS_DELETE_EVT:
		break;
	case ESP_GATTS_START_EVT:
		ESP_LOGI(GATTS_TAG,
				"SERVICE_START_EVT_READ, status %d, service_handle %d\n",
				param->start.status, param->start.service_handle);
		break;
	case ESP_GATTS_STOP_EVT:
		break;
	case ESP_GATTS_CONNECT_EVT: {
		esp_ble_conn_update_params_t conn_params = { 0 };
		memcpy(conn_params.bda, param->connect.remote_bda,
				sizeof(esp_bd_addr_t));
		/* For the IOS system, please reference the apple official documents about the ble connection parameters restrictions. */
		conn_params.latency = 0;
		conn_params.max_int = 0x20;    // max_int = 0x20*1.25ms = 40ms
		conn_params.min_int = 0x10;    // min_int = 0x10*1.25ms = 20ms
		conn_params.timeout = 400;     // timeout = 400*10ms = 4000ms
		ESP_LOGI(GATTS_TAG,
				"ESP_GATTS_CONNECT_EVT, conn_id %d, remote %02x:%02x:%02x:%02x:%02x:%02x:",
				param->connect.conn_id, param->connect.remote_bda[0],
				param->connect.remote_bda[1], param->connect.remote_bda[2],
				param->connect.remote_bda[3], param->connect.remote_bda[4],
				param->connect.remote_bda[5]);
		gl_profile_tab[SERVICE_READ].conn_id = param->connect.conn_id;
		//start sent the update connection parameters to the peer device.
		esp_ble_gap_update_conn_params(&conn_params);
		break;
	}
	case ESP_GATTS_DISCONNECT_EVT:
		ESP_LOGI(GATTS_TAG, "ESP_GATTS_DISCONNECT_EVT_READ");
		esp_ble_gap_start_advertising(&adv_params);
		break;
	case ESP_GATTS_CONF_EVT:
		ESP_LOGI(GATTS_TAG, "ESP_GATTS_CONF_EVT, status %d",
				param->conf.status);
		if (param->conf.status != ESP_GATT_OK) {
			esp_log_buffer_hex(GATTS_TAG, param->conf.value, param->conf.len);
		}
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

void gatts_event_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if,
		esp_ble_gatts_cb_param_t *param) {
	/* If event is register event, store the gatts_if for each profile */
	if (event == ESP_GATTS_REG_EVT) {
		if (param->reg.status == ESP_GATT_OK) {
			gl_profile_tab[param->reg.app_id].gatts_if = gatts_if;
		} else {
			ESP_LOGD(GATTS_TAG, "Reg app failed, app_id %04x, status %d\n",
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

	ESP_LOGI(GATTS_TAG, "ACTIVATING BLUETOOTH \n");

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
	ret = esp_ble_gatts_app_register(SERVICE_READ);
	if (ret) {
		ESP_LOGE(GATTS_TAG, "gatts app register error, error code = %x", ret);
		return;
	}
	esp_err_t local_mtu_ret = esp_ble_gatt_set_local_mtu(512);
	if (local_mtu_ret) {
		ESP_LOGE(GATTS_TAG, "set local  MTU failed, error code = %x",
				local_mtu_ret);
	}

	ESP_LOGI(GATTS_TAG, "BLUETOOTH IS ACTIVATED \n");

	return;
}
