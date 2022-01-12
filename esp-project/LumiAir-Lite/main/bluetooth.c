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
#include "cJSON.h"

#include "esp_gap_ble_api.h"
#include "esp_gatts_api.h"
#include "esp_bt_defs.h"
#include "esp_bt_main.h"
#include "esp_gatt_common_api.h"

#include "sdkconfig.h"

#include "unitcfg.h"
#include "autolight.h"
#include "app_gpio.h"
#include "webservice.h"
#include "lightcontrol.h"
#include "https_ota.h"
#include "scanwifi.h"
#include "i2c.h"

#define GATTS_TAG "GATTS"

#define GATTS_CHAR_NUM_READ 2
#define GATTS_NUM_HANDLE_READ 1 + (2 * GATTS_CHAR_NUM_READ)

///Declare the functions

void gatts_profile_read_event_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);

void char_total_read_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);

void char_total_write_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);

void char_total2_read_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);

void char_total2_write_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);

bool configData(char *jsonData);

//Declare uuid of READ and WRITE Service

#define GATTS_SERVICE_UUID_TEST_READ 0x00FF
#define GATTS_UUID_TEST_READ_Total 0xFF01  //capteurs
#define GATTS_UUID_TEST_READ_Total2 0xFF02 //data

#define TEST_DEVICE_NAME "MAESTRO"
#define TEST_MANUFACTURER_DATA_LEN 17

#define GATTS_CHAR_VAL_LEN_MAX 512
#define CHAR_ROOM_MAX 0x02
#define PREPARE_BUF_MAX_SIZE 1024

//characteristics values of READ profile

uint8_t total[GATTS_CHAR_VAL_LEN_MAX];
uint8_t total2[GATTS_CHAR_VAL_LEN_MAX];

//property of each service

esp_gatt_char_prop_t read_property = 0;
esp_gatt_char_prop_t write_property = 0;

//

esp_attr_value_t TOTAL = {
	.attr_max_len = GATTS_CHAR_VAL_LEN_MAX,
	.attr_len = sizeof(total),
	.attr_value = (uint8_t *)&total,
};
esp_attr_value_t TOTAL2 = {
	.attr_max_len = GATTS_CHAR_VAL_LEN_MAX,
	.attr_len = sizeof(total2),
	.attr_value = (uint8_t *)&total2,
};

uint8_t adv_config_done = 0;
#define adv_config_flag (1 << 0)
#define scan_rsp_config_flag (1 << 1)

uint32_t ble_add_char_pos;

uint8_t adv_service_uuid128[32] = {
	/* LSB <--------------------------------------------------------------------------------> MSB */
	//first uuid, 16bit, [12],[13] is the value
	0xfb,
	0x34,
	0x9b,
	0x5f,
	0x80,
	0x00,
	0x00,
	0x80,
	0x00,
	0x10,
	0x00,
	0x00,
	0xEE,
	0x00,
	0x00,
	0x00,
	//second uuid, 32bit, [12], [13], [14], [15] is the value
	0xfb,
	0x34,
	0x9b,
	0x5f,
	0x80,
	0x00,
	0x00,
	0x80,
	0x00,
	0x10,
	0x00,
	0x00,
	0xFF,
	0x00,
	0x00,
	0x00};

// The length of adv data must be less than 31 bytes
//uint8_t test_manufacturer[TEST_MANUFACTURER_DATA_LEN] =  {0x12, 0x23, 0x45, 0x56};
//adv data
esp_ble_adv_data_t adv_data = {
	.set_scan_rsp = false,
	.include_name = true,
	.include_txpower = true,
	.min_interval = 0x20,
	.max_interval = 0x40,
	.appearance = 0x00,
	.manufacturer_len = 0,		 //TEST_MANUFACTURER_DATA_LEN,
	.p_manufacturer_data = NULL, //&test_manufacturer[0],
	.service_data_len = 0,
	.p_service_data = NULL,
	.service_uuid_len = 32,
	.p_service_uuid = adv_service_uuid128,
	.flag = (ESP_BLE_ADV_FLAG_GEN_DISC | ESP_BLE_ADV_FLAG_BREDR_NOT_SPT),
};
// scan response data
esp_ble_adv_data_t scan_rsp_data = {
	.set_scan_rsp = true,
	.include_name = true,
	.include_txpower = true,
	.min_interval = 0x20,
	.max_interval = 0x40,
	.appearance = 0x00,
	.manufacturer_len = 0,		 //TEST_MANUFACTURER_DATA_LEN,
	.p_manufacturer_data = NULL, //&test_manufacturer[0],
	.service_data_len = 0,
	.p_service_data = NULL,
	.service_uuid_len = 32,
	.p_service_uuid = adv_service_uuid128,
	.flag = (ESP_BLE_ADV_FLAG_GEN_DISC | ESP_BLE_ADV_FLAG_BREDR_NOT_SPT),
};

esp_ble_adv_params_t adv_params = {
	.adv_int_min = 0x20,
	.adv_int_max = 0x40,
	.adv_type = ADV_TYPE_IND,
	.own_addr_type = BLE_ADDR_TYPE_PUBLIC,
	.channel_map = ADV_CHNL_ALL,
	.adv_filter_policy = ADV_FILTER_ALLOW_SCAN_ANY_CON_ANY,
};

#define PROFILE_NUM 2
#define SERVICE_READ 0
#define SERVICE_WRITE 1

struct gatts_profile_inst
{
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
struct gatts_profile_inst gl_profile_tab[PROFILE_NUM] =
	{[SERVICE_READ] = {
		 .gatts_cb = gatts_profile_read_event_handler,
		 .gatts_if = ESP_GATT_IF_NONE, /* Not get the gatt_if, so initial is ESP_GATT_IF_NONE */
	 }};

struct gatts_char_inst
{
	esp_bt_uuid_t char_uuid;
	esp_gatt_perm_t char_perm;
	esp_gatt_char_prop_t char_property;
	esp_attr_value_t *char_val;
	esp_attr_control_t *char_control;
	uint16_t char_handle;
	esp_gatts_cb_t char_read_callback;
	esp_gatts_cb_t char_write_callback;
};

struct gatts_char_inst LIST_CHAR_READ[GATTS_CHAR_NUM_READ] = { //SERVICE READ
	{
		.char_uuid.len = ESP_UUID_LEN_16,
		.char_uuid.uuid.uuid16 = GATTS_UUID_TEST_READ_Total,
		.char_perm = ESP_GATT_PERM_READ | ESP_GATT_PERM_WRITE,
		.char_property = ESP_GATT_CHAR_PROP_BIT_WRITE | ESP_GATT_CHAR_PROP_BIT_READ,
		.char_control = NULL,
		.char_handle = 0,
		.char_val = &TOTAL,
		.char_read_callback = char_total_read_handler,
		.char_write_callback = char_total_write_handler,
	},
	{
		.char_uuid.len = ESP_UUID_LEN_16,
		.char_uuid.uuid.uuid16 = GATTS_UUID_TEST_READ_Total2,
		.char_perm = ESP_GATT_PERM_READ | ESP_GATT_PERM_WRITE,
		.char_property = ESP_GATT_CHAR_PROP_BIT_WRITE | ESP_GATT_CHAR_PROP_BIT_READ,
		.char_control = NULL,
		.char_handle = 0,
		.char_val = &TOTAL2,
		.char_read_callback = char_total2_read_handler,
		.char_write_callback = char_total2_write_handler,
	}};

bool deviceIsIOS = false;
int charIOSCounter = 0;

bool jsonparse(char *src, char *dst, char *label, unsigned short arrayindex)
{
	char *sp = 0, *ep = 0, *ic = 0;
	char tmp[64];

	sp = strstr(src, label);

	if (sp == NULL)
	{
		//ESP_LOGE(GATTS_TAG, "label %s not found",label);
		return false;
	}

	sp = strchr(sp, ':');
	if (sp == NULL)
	{
		ESP_LOGE(GATTS_TAG, "value start not found");
		return false;
	}

	if (sp[1] == '"')
	{
		sp++;
		ep = strchr(sp + 1, '"');
		ic = strchr(sp + 1, ',');
		if ((ep == NULL) || ((ep > ic) && (ic != NULL)))
		{
			ESP_LOGE(GATTS_TAG, "type string parsing error");
			return false;
		}
	}
	else if (sp[1] == '[')
	{
		sp++;
		ep = strchr(sp + 1, ']');
		ic = strchr(sp + 1, ':');
		if ((ep == NULL) || ((ep > ic) && (ic != NULL)))
		{
			ESP_LOGE(GATTS_TAG, "type array parsing error");
			return false;
		}

		ic = strchr(sp + 1, ',');
		if ((ic < ep) && (ic != NULL))
			ep = ic;

		for (int i = 0; i < arrayindex; i++)
		{
			sp = ep;
			ep = strchr(sp + 1, ',');

			if (ep == NULL)
			{
				ic = strchr(sp + 1, ']');
				ep = ic;
			}
		}

		if (sp[1] == '"')
		{
			sp++;
			ep = strchr(sp + 1, '"');
		}
	}
	else
	{
		ep = strchr(sp + 1, ',');
		if (ep == NULL)
			ep = strchr(sp + 1, '}');
		ic = strchr(sp + 1, ':');
		if ((ep == NULL) || ((ep > ic) && (ic != NULL)))
		{
			ESP_LOGE(GATTS_TAG, "type int parsing error");
			return false;
		}
	}

	strncpy(tmp, sp + 1, ep - sp - 1);
	tmp[ep - sp - 1] = 0;

	memset(dst, 0x00, strlen(tmp) + 1);
	memcpy(dst, tmp, strlen(tmp));

	return true;
}

void gatts_check_callback(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if,
						  esp_ble_gatts_cb_param_t *param)
{
	uint16_t handle = 0;
	uint8_t read = 1;
	switch (event)
	{
	case ESP_GATTS_READ_EVT:
	{
		read = 1;
		handle = param->read.handle;
		break;
	}
	case ESP_GATTS_WRITE_EVT:
	{
		read = 0;
		handle = param->write.handle;
		break;
	}
	default:
		break;
	}

	for (uint32_t pos = 0; pos < GATTS_CHAR_NUM_READ; pos++)
	{
		if (LIST_CHAR_READ[pos].char_handle == handle)
		{
			if (read == 1)
			{
				if (LIST_CHAR_READ[pos].char_read_callback != NULL)
				{
					LIST_CHAR_READ[pos].char_read_callback(event, gatts_if,
														   param);
				}
			}
			if (read == 0)
			{
				if (LIST_CHAR_READ[pos].char_write_callback != NULL)
				{
					LIST_CHAR_READ[pos].char_write_callback(event, gatts_if,
															param);
				}
			}
			break;
		}
	}
}

void gatts_add_char_READ()
{

	for (uint32_t pos = 0; pos < GATTS_CHAR_NUM_READ; pos++)
	{
		if (LIST_CHAR_READ[pos].char_handle == 0)
		{
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

void gatts_check_add_char_READ(esp_bt_uuid_t char_uuid, uint16_t attr_handle)
{

	if (attr_handle != 0)
	{
		if (char_uuid.len == ESP_UUID_LEN_16)
		{
			ESP_LOGI(GATTS_TAG, "Char READ UUID16: %x", char_uuid.uuid.uuid16);
		}
		else if (char_uuid.len == ESP_UUID_LEN_32)
		{
			ESP_LOGI(GATTS_TAG, "Char READ UUID32: %x", char_uuid.uuid.uuid32);
		}
		else if (char_uuid.len == ESP_UUID_LEN_128)
		{
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
		}
		else
		{
			ESP_LOGE(GATTS_TAG, "Char READ UNKNOWN LEN %d\n", char_uuid.len);
		}

		LIST_CHAR_READ[ble_add_char_pos].char_handle = attr_handle;
		gatts_add_char_READ();
	}
}

bool savenvsFlag = false;

void configParserTask()
{
	if (savenvsFlag)
	{
		SaveNVS(&UnitCfg);
		savenvsFlag = false;
	}
}

char tmp[64];

void char_total_read_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param)
{

	ESP_LOGI(GATTS_TAG, "[APP] Free memory: %d bytes", esp_get_free_heap_size());

	time(&UnitData.UpdateTime);

	if (otaEnable)
	{
		sprintf((char *)total, "{\"ota\":[%d,%d,%d]}", otaNotNeeded, otaProgress, otaIsDone);
	}
	else
	{
		sprintf((char *)total, "{\"EnvData\":[%ld,%ld,%d,%d,%hu,%hu,%hu,%d,%d],\"SCR\":%d,\"ver\":\"%s\"}",
				UnitData.UpdateTime, UnitData.LastDetTime, (uint8_t)UnitData.Temp, (uint8_t)UnitData.Humidity,
				UnitData.Als, UnitData.aq_Co2Level, UnitData.aq_Tvoc, WifiConnectedFlag, UnitData.aq_status, scanResult, UnitCfg.versionSystem);
	}

	TOTAL.attr_len = strlen((char *)total);

	esp_gatt_rsp_t rsp;
	memset(&rsp, 0, sizeof(esp_gatt_rsp_t));
	rsp.attr_value.handle = param->read.handle;
	if (LIST_CHAR_READ[0].char_val != NULL)
	{
		rsp.attr_value.len = LIST_CHAR_READ[0].char_val->attr_len;
		for (uint32_t pos = 0; pos < LIST_CHAR_READ[0].char_val->attr_len && pos < LIST_CHAR_READ[0].char_val->attr_max_len; pos++)
		{
			rsp.attr_value.value[pos] = LIST_CHAR_READ[0].char_val->attr_value[pos];
		}
	}

	esp_ble_gatts_send_response(gatts_if, param->read.conn_id, param->read.trans_id, ESP_GATT_OK, &rsp);
}

void char_total_write_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param)
{
	if (LIST_CHAR_READ[0].char_val != NULL)
	{
		LIST_CHAR_READ[0].char_val->attr_len = param->write.len;
		for (uint32_t pos = 0; pos < param->write.len; pos++)
		{
			LIST_CHAR_READ[0].char_val->attr_value[pos] = param->write.value[pos];
		}

		uint32_t msize = LIST_CHAR_READ[0].char_val->attr_len + 1;
		char *config_total_json;
		config_total_json = malloc(msize);
		if (config_total_json != NULL)
		{
			sprintf(config_total_json, "%.*s", LIST_CHAR_READ[0].char_val->attr_len, (char *)LIST_CHAR_READ[0].char_val->attr_value);
			printf("%s\n", config_total_json);
			savenvsFlag = configData(config_total_json);
			configParserTask();
			free(config_total_json);
		}
	}
	esp_ble_gatts_send_response(gatts_if, param->write.conn_id, param->write.trans_id, ESP_GATT_OK, NULL);
}

void char_total2_read_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param)
{
	ESP_LOGI(GATTS_TAG, "[APP] Free memory: %d bytes", esp_get_free_heap_size());

	if (scanResult)
	{
		sprintf((char *)total2, "{\"AP_RECORDS\":[\"%s\"", ap_info[0].ssid);
		char apSSID[40];
		for (int i = 1; i < ap_count; i++)
		{
			sprintf((char *)apSSID, ",\"%s\"", ap_info[i].ssid);
			strcpy((char *)total2 + strlen((char *)total2), apSSID);
		}
		strcpy((char *)total2 + strlen((char *)total2), "]}");
		ESP_LOGI(GATTS_TAG, "total2 = %s", (char *)total2);
		scanResult = false;
	}
	else
	{
		if (deviceIsIOS)
		{
			switch (charIOSCounter)
			{
			case 0:
				sprintf((char *)total2,
						"{\"wifi\":[\"%s\",\"%s\"],\"cc\":[%d,\"%s\"],\"tabcc\":[%d,%ld,%d,%ld,%d,%ld,%d,%ld,%d,%ld]}",
						UnitCfg.WifiCfg.WIFI_SSID, UnitCfg.WifiCfg.WIFI_PASS,
						UnitCfg.UserLcProfile.CcEnb, UnitCfg.UserLcProfile.ZoneCc,
						UnitCfg.UserLcProfile.Ccp[0].CcLevel, UnitCfg.UserLcProfile.Ccp[0].CcTime,
						UnitCfg.UserLcProfile.Ccp[1].CcLevel, UnitCfg.UserLcProfile.Ccp[1].CcTime,
						UnitCfg.UserLcProfile.Ccp[2].CcLevel, UnitCfg.UserLcProfile.Ccp[2].CcTime,
						UnitCfg.UserLcProfile.Ccp[3].CcLevel, UnitCfg.UserLcProfile.Ccp[3].CcTime,
						UnitCfg.UserLcProfile.Ccp[4].CcLevel, UnitCfg.UserLcProfile.Ccp[4].CcTime);
				charIOSCounter++;
				break;
			case 1:
				sprintf((char *)total2,
						"{\"ZN\":[\"%s\",\"%s\",\"%s\",\"%s\"]}",
						UnitCfg.Zones_info[0].zonename, UnitCfg.Zones_info[1].zonename,
						UnitCfg.Zones_info[2].zonename, UnitCfg.Zones_info[3].zonename);
				charIOSCounter++;
				break;
			case 2:
				sprintf((char *)total2, "{\"Amb\":[\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"],\"PP\":\"%s\"}",
						UnitCfg.ColortrProfile[0].ambname, UnitCfg.ColortrProfile[0].Hue,
						UnitCfg.ColortrProfile[1].ambname, UnitCfg.ColortrProfile[1].Hue,
						UnitCfg.ColortrProfile[2].ambname, UnitCfg.ColortrProfile[2].Hue,
						UnitCfg.ColortrProfile[3].ambname, UnitCfg.ColortrProfile[3].Hue,
						UnitCfg.passPIN);
				charIOSCounter = 0;
				break;
			}
		}
		else
		{
			sprintf((char *)total2,
					"{\"wifi\":[\"%s\",\"%s\"],\"cc\":[%d,\"%s\"],\"tabcc\":[%d,%ld,%d,%ld,%d,%ld,%d,%ld,%d,%ld],\"ZN\":[\"%s\",\"%s\",\"%s\",\"%s\"],"
					"\"Amb\":[\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"],\"PP\":\"%s\"}",
					UnitCfg.WifiCfg.WIFI_SSID, UnitCfg.WifiCfg.WIFI_PASS,
					UnitCfg.UserLcProfile.CcEnb, UnitCfg.UserLcProfile.ZoneCc,
					UnitCfg.UserLcProfile.Ccp[0].CcLevel, UnitCfg.UserLcProfile.Ccp[0].CcTime,
					UnitCfg.UserLcProfile.Ccp[1].CcLevel, UnitCfg.UserLcProfile.Ccp[1].CcTime,
					UnitCfg.UserLcProfile.Ccp[2].CcLevel, UnitCfg.UserLcProfile.Ccp[2].CcTime,
					UnitCfg.UserLcProfile.Ccp[3].CcLevel, UnitCfg.UserLcProfile.Ccp[3].CcTime,
					UnitCfg.UserLcProfile.Ccp[4].CcLevel, UnitCfg.UserLcProfile.Ccp[4].CcTime,
					UnitCfg.Zones_info[0].zonename, UnitCfg.Zones_info[1].zonename,
					UnitCfg.Zones_info[2].zonename, UnitCfg.Zones_info[3].zonename,
					UnitCfg.ColortrProfile[0].ambname, UnitCfg.ColortrProfile[0].Hue,
					UnitCfg.ColortrProfile[1].ambname, UnitCfg.ColortrProfile[1].Hue,
					UnitCfg.ColortrProfile[2].ambname, UnitCfg.ColortrProfile[2].Hue,
					UnitCfg.ColortrProfile[3].ambname, UnitCfg.ColortrProfile[3].Hue,
					UnitCfg.passPIN);
		}
	}

	TOTAL2.attr_len = strlen((char *)total2);

	esp_gatt_rsp_t rsp;
	memset(&rsp, 0, sizeof(esp_gatt_rsp_t));
	rsp.attr_value.handle = param->read.handle;
	if (LIST_CHAR_READ[1].char_val != NULL)
	{
		rsp.attr_value.len = LIST_CHAR_READ[1].char_val->attr_len;
		for (uint32_t pos = 0;
			 pos < LIST_CHAR_READ[1].char_val->attr_len && pos < LIST_CHAR_READ[1].char_val->attr_max_len;
			 pos++)
		{
			rsp.attr_value.value[pos] = LIST_CHAR_READ[1].char_val->attr_value[pos];
		}
	}

	esp_ble_gatts_send_response(gatts_if, param->read.conn_id, param->read.trans_id, ESP_GATT_OK, &rsp);
}

void char_total2_write_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param)
{
	if (LIST_CHAR_READ[1].char_val != NULL)
	{
		LIST_CHAR_READ[1].char_val->attr_len = param->write.len;
		for (uint32_t pos = 0; pos < param->write.len; pos++)
		{
			LIST_CHAR_READ[1].char_val->attr_value[pos] =
				param->write.value[pos];
		}

		uint32_t msize = LIST_CHAR_READ[1].char_val->attr_len + 1;
		char *config_total2_json;
		config_total2_json = malloc(msize);
		if (config_total2_json != NULL)
		{
			sprintf(config_total2_json, "%.*s", LIST_CHAR_READ[1].char_val->attr_len,
					(char *)LIST_CHAR_READ[1].char_val->attr_value);
			printf("%s\n", config_total2_json);
			savenvsFlag = configData(config_total2_json);
			configParserTask();
			free(config_total2_json);
		}
	}
	esp_ble_gatts_send_response(gatts_if, param->write.conn_id,
								param->write.trans_id, ESP_GATT_OK, NULL);
}

bool configData(char *jsonData)
{
	uint8_t cmd = 0, subcmd = 0, zone = 0;
	char tmp[64];
	bool saveFlag = false;

	time_t t = 0;
	uint32_t tz = 0;
	//Zones Names

	if (jsonparse(jsonData, UnitCfg.Zones_info[0].zonename, "zones", 0))
	{

		ESP_LOGI(GATTS_TAG, "zone 1 is %s", UnitCfg.Zones_info[0].zonename);
		saveFlag = true;

		if (jsonparse(jsonData, UnitCfg.Zones_info[1].zonename, "zones", 1))
		{

			ESP_LOGI(GATTS_TAG, "zone 2 is %s", UnitCfg.Zones_info[1].zonename);
			saveFlag = true;
		}
		if (jsonparse(jsonData, UnitCfg.Zones_info[2].zonename, "zones", 2))
		{

			ESP_LOGI(GATTS_TAG, "zone 3 is %s", UnitCfg.Zones_info[2].zonename);
			saveFlag = true;
		}
		if (jsonparse(jsonData, UnitCfg.Zones_info[3].zonename, "zones", 3))
		{

			ESP_LOGI(GATTS_TAG, "zone 4 is %s", UnitCfg.Zones_info[3].zonename);
			saveFlag = true;
		}
	}
	else if (jsonparse(jsonData, tmp, "system", 0))
	{
		//system
		if (atoi(tmp) == 0)
		{
			ESP_LOGI(GATTS_TAG, "System apply default setting");
			Default_saving();
		}
		else
		{
			ESP_LOGI(GATTS_TAG, "System restart");
			esp_restart();
		}
	}
	else if (jsonparse(jsonData, tmp, "OTA", 0))
	{
		if (atoi(tmp) == 1)
		{
			ESP_LOGI(GATTS_TAG, "OTA is Activated");
			scanWIFITask();
		}
		else
		{
			ESP_LOGE(GATTS_TAG, "OTA is not activated");
		}
	}
	else if (jsonparse(jsonData, tmp, "SCAN", 0))
	{
		if (atoi(tmp) == 1)
		{
			ESP_LOGI(GATTS_TAG, "Scan is Activated");
			scanWIFITask();
		}
		else
		{
			ESP_LOGE(GATTS_TAG, "Scan is not activated");
		}
	}
	else if (jsonparse(jsonData, tmp, "IOS", 0))
	{
		if (atoi(tmp) == 0)
		{
			ESP_LOGW(GATTS_TAG, "Device Connected is NOT AN IOS");
			deviceIsIOS = false;
		}
		else
		{
			ESP_LOGW(GATTS_TAG, "Device Connected is AN IOS");
			deviceIsIOS = true;
		}
	}
	else if (jsonparse(jsonData, tmp, "cc", 0))
	{
		if (atoi(tmp) == 0)
		{
			ESP_LOGE(GATTS_TAG, "Circadian cycle is deactivated");
			UnitCfg.UserLcProfile.CcEnb = false;
		}
		else
		{
			ESP_LOGI(GATTS_TAG, "Circadian cycle is activated");
			UnitCfg.UserLcProfile.CcEnb = true;
		}
		saveFlag = true;
	}
	else if (jsonparse(jsonData, UnitCfg.passPIN, "PP", 0))
	{
		ESP_LOGI(GATTS_TAG, "set PIN CODE %s", UnitCfg.passPIN);
		saveFlag = true;
	}
	else if (jsonparse(jsonData, UnitCfg.WifiCfg.WIFI_SSID, "wa", 0))
	{
		ESP_LOGI(GATTS_TAG, "set ap ssid %s", UnitCfg.WifiCfg.WIFI_SSID);

		if (jsonparse(jsonData, UnitCfg.WifiCfg.WIFI_PASS, "wp", 0))
		{
			ESP_LOGI(GATTS_TAG, "set ap password %s", UnitCfg.WifiCfg.WIFI_PASS);
		}
		saveFlag = true;
	}
	else if (jsonparse(jsonData, tmp, "light", 0))
	{
		//light
		cmd = atoi(tmp);

		if (jsonparse(jsonData, tmp, "light", 1))
		{
			subcmd = atoi(tmp);
		}
		if (jsonparse(jsonData, tmp, "light", 2))
		{
			zone = strtol(tmp, NULL, 16);
		}

		//radio
		MilightHandler(cmd, subcmd, zone & 0x0F);

		ESP_LOGI(GATTS_TAG, "Light control manu cmd %d subcmd %d zone %d", cmd, subcmd, zone);
	}
	else if (jsonparse(jsonData, UnitCfg.UnitName, "dname", 0))
	{
		ESP_LOGI(GATTS_TAG, "set device name %s", UnitCfg.UnitName);
		saveFlag = true;
	}
	else if (jsonparse(jsonData, tmp, "Time", 0))
	{

		// time
		time_t tl = 0;
		struct tm ti;

		time(&tl);
		localtime_r(&tl, &ti);

		if (ti.tm_year < (2016 - 1900))
		{
			t = atoi(tmp);
			ESP_LOGI(GATTS_TAG, "Time sync epoch %ld", t);

			if (jsonparse(jsonData, tmp, "Time", 1))
			{
				tz = atoi(tmp);
				ESP_LOGI(GATTS_TAG, "Time zone %d", tz / 3600);
				syncTime(t, tz);
				saveTimeOnBattery = true;
				UnitCfg.UnitTimeZone = tz / 3600;
				saveFlag = true;
			}
		}
		else
			ESP_LOGE(GATTS_TAG, "Time sync ignored");
	}
	else if (jsonparse(jsonData, tmp, "hue", 0))
	{
		char tmpzone[3];
		if (jsonparse(jsonData, tmpzone, "hue", 1))
		{
			// hue
			HueToHSL(tmp, tmpzone);
		}
	}
	else if (jsonparse(jsonData, UnitCfg.ColortrProfile[0].ambname, "couleur1", 0))
	{

		//Couleur 1

		ESP_LOGI(GATTS_TAG, "Profile Color name set %s",
				 UnitCfg.ColortrProfile[0].ambname);
		saveFlag = true;
		if (jsonparse(jsonData, UnitCfg.ColortrProfile[0].Hue, "couleur1", 1))
		{
			ESP_LOGI(GATTS_TAG, "Profile Color Hue set %s",
					 UnitCfg.ColortrProfile[0].Hue);
			saveFlag = true;
		}
	}
	else if (jsonparse(jsonData, UnitCfg.ColortrProfile[1].ambname, "couleur2", 0))
	{
		//Couleur 2

		ESP_LOGI(GATTS_TAG, "Profile Color name set %s", UnitCfg.ColortrProfile[1].ambname);
		saveFlag = true;
		if (jsonparse(jsonData, UnitCfg.ColortrProfile[1].Hue, "couleur2", 1))
		{
			ESP_LOGI(GATTS_TAG, "Profile Color Hue set %s", UnitCfg.ColortrProfile[1].Hue);
			saveFlag = true;
		}
	}
	else if (jsonparse(jsonData, UnitCfg.ColortrProfile[2].ambname, "couleur3", 0))
	{

		//Couleur 3

		ESP_LOGI(GATTS_TAG, "Profile Color name set %s", UnitCfg.ColortrProfile[2].ambname);
		saveFlag = true;
		if (jsonparse(jsonData, UnitCfg.ColortrProfile[2].Hue, "couleur3", 1))
		{
			ESP_LOGI(GATTS_TAG, "Profile Color Hue set %s",
					 UnitCfg.ColortrProfile[2].Hue);
			saveFlag = true;
		}
	}
	else

		if (jsonparse(jsonData, UnitCfg.ColortrProfile[3].ambname, "couleur4", 0))
	{

		//Couleur 4

		ESP_LOGI(GATTS_TAG, "Profile Color name set %s",
				 UnitCfg.ColortrProfile[3].ambname);
		saveFlag = true;
		if (jsonparse(jsonData, UnitCfg.ColortrProfile[3].Hue, "couleur4", 1))
		{
			ESP_LOGI(GATTS_TAG, "Profile Color Hue set %s",
					 UnitCfg.ColortrProfile[3].Hue);
			saveFlag = true;
		}
	}
	else if (jsonparse(jsonData, tmp, "Favoris", 0))
	{
		ESP_LOGI(GATTS_TAG, "Ambiance Color set %s", tmp);
		if (strcmp(tmp, "Ambiance 1") == 0)
		{
			ESP_LOGI(GATTS_TAG, "Ambiance 1 is Selected");
			HueToHSL(UnitCfg.ColortrProfile[0].Hue, UnitCfg.ColortrProfile[0].zone);
		}
		else if (strcmp(tmp, "Ambiance 2") == 0)
		{
			ESP_LOGI(GATTS_TAG, "Ambiance 2 is Selected");
			HueToHSL(UnitCfg.ColortrProfile[1].Hue, UnitCfg.ColortrProfile[1].zone);
		}
		else if (strcmp(tmp, "Ambiance 3") == 0)
		{
			ESP_LOGI(GATTS_TAG, "Ambiance 3 is Selected");
			HueToHSL(UnitCfg.ColortrProfile[2].Hue, UnitCfg.ColortrProfile[2].zone);
		}
		else if (strcmp(tmp, "Ambiance 4") == 0)
		{
			ESP_LOGI(GATTS_TAG, "Ambiance 4 is Selected");
			HueToHSL(UnitCfg.ColortrProfile[3].Hue, UnitCfg.ColortrProfile[3].zone);
		}
		else
		{
			ESP_LOGI(GATTS_TAG, "Unknown Ambiance");
		}
	}
	else
	{
		ESP_LOGE(GATTS_TAG, "BAD MESSAGE");
	}
	return saveFlag;
}

void gap_event_handler(esp_gap_ble_cb_event_t event,
					   esp_ble_gap_cb_param_t *param)
{
	switch (event)
	{

	case ESP_GAP_BLE_ADV_DATA_SET_COMPLETE_EVT:
		adv_config_done &= (~adv_config_flag);
		if (adv_config_done == 0)
		{
			esp_ble_gap_start_advertising(&adv_params);
		}
		break;
	case ESP_GAP_BLE_SCAN_RSP_DATA_SET_COMPLETE_EVT:
		adv_config_done &= (~scan_rsp_config_flag);
		if (adv_config_done == 0)
		{
			esp_ble_gap_start_advertising(&adv_params);
		}
		break;

	case ESP_GAP_BLE_ADV_START_COMPLETE_EVT:
		//advertising start complete event to indicate advertising start successfully or failed
		if (param->adv_start_cmpl.status != ESP_BT_STATUS_SUCCESS)
		{
			ESP_LOGE(GATTS_TAG, "Advertising start failed\n");
		}
		break;
	case ESP_GAP_BLE_ADV_STOP_COMPLETE_EVT:
		if (param->adv_stop_cmpl.status != ESP_BT_STATUS_SUCCESS)
		{
			ESP_LOGE(GATTS_TAG, "Advertising stop failed\n");
		}
		else
		{
			ESP_LOGI(GATTS_TAG, "Stop adv successfully\n");
		}
		break;
	case ESP_GAP_BLE_UPDATE_CONN_PARAMS_EVT:
		break;
	default:
		break;
	}
}

void gatts_profile_read_event_handler(esp_gatts_cb_event_t event,
									  esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param)
{
	switch (event)
	{
	case ESP_GATTS_REG_EVT:
		gl_profile_tab[SERVICE_READ].service_id.is_primary = true;
		gl_profile_tab[SERVICE_READ].service_id.id.inst_id = 0x00;
		gl_profile_tab[SERVICE_READ].service_id.id.uuid.len = ESP_UUID_LEN_16;
		gl_profile_tab[SERVICE_READ].service_id.id.uuid.uuid.uuid16 =
			GATTS_SERVICE_UUID_TEST_READ;

		esp_err_t set_dev_name_ret = esp_ble_gap_set_device_name(
			UnitCfg.UnitName);
		if (set_dev_name_ret)
		{
			ESP_LOGE(GATTS_TAG, "set device name failed, error code = %x",
					 set_dev_name_ret);
		}

		//config adv data
		esp_err_t ret = esp_ble_gap_config_adv_data(&adv_data);
		if (ret)
		{
			ESP_LOGE(GATTS_TAG, "config adv data failed, error code = %x", ret);
		}
		adv_config_done |= adv_config_flag;
		//config scan response data
		ret = esp_ble_gap_config_adv_data(&scan_rsp_data);
		if (ret)
		{
			ESP_LOGE(GATTS_TAG,
					 "config scan response data failed, error code = %x", ret);
		}
		adv_config_done |= scan_rsp_config_flag;

		esp_ble_gatts_create_service(gatts_if, &gl_profile_tab[SERVICE_READ].service_id, GATTS_NUM_HANDLE_READ);

		break;
	case ESP_GATTS_READ_EVT:
	{
		ESP_LOGI(GATTS_TAG,
				 "GATT_READ_EVT_READ, conn_id %d, trans_id %d, handle %d",
				 param->read.conn_id, param->read.trans_id, param->read.handle);
		gatts_check_callback(event, gatts_if, param);
		break;
	}
	case ESP_GATTS_WRITE_EVT:
	{
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
		gl_profile_tab[SERVICE_READ].char_uuid.len =
			LIST_CHAR_READ[1].char_uuid.len;
		gl_profile_tab[SERVICE_READ].char_uuid.uuid.uuid16 =
			LIST_CHAR_READ[1].char_uuid.uuid.uuid16;

		esp_ble_gatts_start_service(
			gl_profile_tab[SERVICE_READ].service_handle);
		gatts_add_char_READ();
		break;
	case ESP_GATTS_ADD_INCL_SRVC_EVT:
		break;
	case ESP_GATTS_ADD_CHAR_EVT:
	{
		ESP_LOGI(GATTS_TAG,
				 "ADD_CHAR_EVT_READ, status %d,  attr_handle %d, service_handle %d\n",
				 param->add_char.status, param->add_char.attr_handle,
				 param->add_char.service_handle);
		gl_profile_tab[SERVICE_READ].char_handle = param->add_char.attr_handle;
		if (param->add_char.status == ESP_GATT_OK)
		{
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
	case ESP_GATTS_CONNECT_EVT:
	{
		esp_ble_conn_update_params_t conn_params = {0};
		memcpy(conn_params.bda, param->connect.remote_bda,
			   sizeof(esp_bd_addr_t));
		/* For the IOS system, please reference the apple official documents about the ble connection parameters restrictions. */
		conn_params.latency = 0;
		conn_params.max_int = 0x20; // max_int = 0x20*1.25ms = 40ms
		conn_params.min_int = 0x10; // min_int = 0x10*1.25ms = 20ms
		conn_params.timeout = 400;	// timeout = 400*10ms = 4000ms
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
		deviceIsIOS = false;
		esp_ble_gap_start_advertising(&adv_params);
		break;
	case ESP_GATTS_CONF_EVT:
		ESP_LOGI(GATTS_TAG, "ESP_GATTS_CONF_EVT, status %d",
				 param->conf.status);
		if (param->conf.status != ESP_GATT_OK)
		{
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
						 esp_ble_gatts_cb_param_t *param)
{
	/* If event is register event, store the gatts_if for each profile */
	if (event == ESP_GATTS_REG_EVT)
	{
		if (param->reg.status == ESP_GATT_OK)
		{
			gl_profile_tab[param->reg.app_id].gatts_if = gatts_if;
		}
		else
		{
			return;
		}
	}

	/* If the gatts_if equal to profile A, call profile A cb handler,
	 * so here call each profile's callback */
	do
	{
		int idx;
		for (idx = 0; idx < PROFILE_NUM; idx++)
		{
			if (gatts_if == ESP_GATT_IF_NONE || /* ESP_GATT_IF_NONE, not specify a certain gatt_if, need to call every profile cb function */
				gatts_if == gl_profile_tab[idx].gatts_if)
			{
				if (gl_profile_tab[idx].gatts_cb)
				{
					gl_profile_tab[idx].gatts_cb(event, gatts_if, param);
				}
			}
		}
	} while (0);
}

void bt_main()
{

	esp_err_t ret;

	ESP_ERROR_CHECK(esp_bt_controller_mem_release(ESP_BT_MODE_CLASSIC_BT));

	esp_bt_controller_config_t bt_cfg = BT_CONTROLLER_INIT_CONFIG_DEFAULT();
	ret = esp_bt_controller_init(&bt_cfg);
	if (ret)
	{
		ESP_LOGE(GATTS_TAG, "%s initialize controller failed\n", __func__);
		return;
	}

	ESP_LOGI(GATTS_TAG, "[APP] Free memory: %d bytes", esp_get_free_heap_size());

	ret = esp_bt_controller_enable(ESP_BT_MODE_BLE);

	if (ret)
	{
		ESP_LOGE(GATTS_TAG, "%s enable controller failed\n", __func__);
		return;
	}
	ret = esp_bluedroid_init();
	if (ret)
	{
		ESP_LOGE(GATTS_TAG, "%s init bluetooth failed\n", __func__);
		return;
	}
	ret = esp_bluedroid_enable();
	if (ret)
	{
		ESP_LOGE(GATTS_TAG, "%s enable bluetooth failed\n", __func__);
		return;
	}

	ret = esp_ble_gatts_register_callback(gatts_event_handler);
	if (ret)
	{
		ESP_LOGE(GATTS_TAG, "gatts register error, error code = %x", ret);
		return;
	}
	ret = esp_ble_gap_register_callback(gap_event_handler);
	if (ret)
	{
		ESP_LOGE(GATTS_TAG, "gap register error, error code = %x", ret);
		return;
	}
	ret = esp_ble_gatts_app_register(SERVICE_READ);
	if (ret)
	{
		ESP_LOGE(GATTS_TAG, "gatts app register error, error code = %x", ret);
		return;
	}
	esp_err_t local_mtu_ret = esp_ble_gatt_set_local_mtu(512);
	if (local_mtu_ret)
	{
		ESP_LOGE(GATTS_TAG, "set local  MTU failed, error code = %x",
				 local_mtu_ret);
	}

	return;
}
