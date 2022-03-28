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

#include "main.h"

#include <stdint.h>
#include <inttypes.h>

#define GATTS_TAG "GATTS"

#define GATTS_CHAR_NUM_READ 1
#define GATTS_NUM_HANDLE_READ 1 + (2 * GATTS_CHAR_NUM_READ)

/// Declare the static function

static void gatts_profile_read_event_handler(esp_gatts_cb_event_t event,
											 esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);

static void char_total_read_handler(esp_gatts_cb_event_t event,
									esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);

static void char_total_write_handler(esp_gatts_cb_event_t event,
									 esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);

// Declare uuid of READ and WRITE Service

#define GATTS_SERVICE_UUID_TEST_READ 0x00FF
#define GATTS_UUID_TEST_READ_Total 0xFF01 // capteurs

#define TEST_DEVICE_NAME "MAESTRO"
#define TEST_MANUFACTURER_DATA_LEN 17

#define GATTS_CHAR_VAL_LEN_MAX 512
#define CHAR_ROOM_MAX 0x02
#define PREPARE_BUF_MAX_SIZE 1024

// characteristics values of READ profile

uint8_t total[GATTS_CHAR_VAL_LEN_MAX]; // capteurs	  = {0x4e,0x4f,0x54,0x20,0x43,0x4f,0x4e,0x4e,0x45,0x43,0x54,0x45,0x44,0x4e,0x4f,0x54,0x20,0x21,0x21,0x21,0x21,0x21};

// property of each service

esp_gatt_char_prop_t read_property = 0;
esp_gatt_char_prop_t write_property = 0;

//

esp_attr_value_t TOTAL = {
	.attr_max_len = GATTS_CHAR_VAL_LEN_MAX,
	.attr_len =
		sizeof(total),
	.attr_value = (uint8_t *)&total,
};

static uint8_t adv_config_done = 0;
#define adv_config_flag (1 << 0)
#define scan_rsp_config_flag (1 << 1)

static uint32_t ble_add_char_pos;

static uint8_t adv_service_uuid128[32] = {
	/* LSB <--------------------------------------------------------------------------------> MSB */
	// first uuid, 16bit, [12],[13] is the value
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
	// second uuid, 32bit, [12], [13], [14], [15] is the value
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
	0x00,
};

// The length of adv data must be less than 31 bytes
// static uint8_t test_manufacturer[TEST_MANUFACTURER_DATA_LEN] =  {0x12, 0x23, 0x45, 0x56};
// adv data
static esp_ble_adv_data_t adv_data = {
	.set_scan_rsp = false,
	.include_name =
		true,
	.include_txpower = true,
	.min_interval = 0x20,
	.max_interval = 0x40,
	.appearance = 0x00,
	.manufacturer_len = 0,		 // TEST_MANUFACTURER_DATA_LEN,
	.p_manufacturer_data = NULL, //&test_manufacturer[0],
	.service_data_len = 0,
	.p_service_data = NULL,
	.service_uuid_len = 32,
	.p_service_uuid = adv_service_uuid128,
	.flag =
		(ESP_BLE_ADV_FLAG_GEN_DISC | ESP_BLE_ADV_FLAG_BREDR_NOT_SPT),
};
// scan response data
static esp_ble_adv_data_t scan_rsp_data = {
	.set_scan_rsp = true,
	.include_name = true,
	.include_txpower = true,
	.min_interval = 0x20,
	.max_interval = 0x40,
	.appearance = 0x00,
	.manufacturer_len = 0,		 // TEST_MANUFACTURER_DATA_LEN,
	.p_manufacturer_data = NULL, //&test_manufacturer[0],
	.service_data_len = 0,
	.p_service_data = NULL,
	.service_uuid_len = 32,
	.p_service_uuid = adv_service_uuid128,
	.flag =
		(ESP_BLE_ADV_FLAG_GEN_DISC | ESP_BLE_ADV_FLAG_BREDR_NOT_SPT),
};

static esp_ble_adv_params_t adv_params = {
	.adv_int_min = 0x20,
	.adv_int_max =
		0x40,
	.adv_type = ADV_TYPE_IND,
	.own_addr_type = BLE_ADDR_TYPE_PUBLIC,
	.channel_map = ADV_CHNL_ALL,
	.adv_filter_policy =
		ADV_FILTER_ALLOW_SCAN_ANY_CON_ANY,
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
static struct gatts_profile_inst gl_profile_tab[PROFILE_NUM] = {[SERVICE_READ] = {
																	.gatts_cb = gatts_profile_read_event_handler, .gatts_if = ESP_GATT_IF_NONE, /* Not get the gatt_if, so initial is ESP_GATT_IF_NONE */
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

static struct gatts_char_inst LIST_CHAR_READ[GATTS_CHAR_NUM_READ] = { // SERVICE READ
	{
		.char_uuid.len = ESP_UUID_LEN_16,
		.char_uuid.uuid.uuid16 =
			GATTS_UUID_TEST_READ_Total,
		.char_perm = ESP_GATT_PERM_READ | ESP_GATT_PERM_WRITE,
		.char_property =
			ESP_GATT_CHAR_PROP_BIT_WRITE | ESP_GATT_CHAR_PROP_BIT_READ,
		.char_control = NULL,
		.char_handle = 0,
		.char_val = &TOTAL,
		.char_read_callback = char_total_read_handler,
		.char_write_callback = char_total_write_handler,
	}};

int jsonparse(char *src, char *dst, char *label, unsigned short arrayindex)
{
	char *sp = 0, *ep = 0, *ic = 0;
	char tmp[64];

	sp = strstr(src, label);

	if (sp == NULL)
	{
		// ESP_LOGE(GATTS_TAG, "label %s not found",label);
		return (-1);
	}

	sp = strchr(sp, ':');
	if (sp == NULL)
	{
		ESP_LOGE(GATTS_TAG, "value start not found");
		return (-1);
	}

	if (sp[1] == '"')
	{
		sp++;
		ep = strchr(sp + 1, '"');
		ic = strchr(sp + 1, ',');
		if ((ep == NULL) || ((ep > ic) && (ic != NULL)))
		{
			ESP_LOGE(GATTS_TAG, "type string parsing error");
			return (-1);
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
			return (-1);
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

	ESP_LOGD(GATTS_TAG, "gatts_check_callback write %d num %d handle %d\n",
			 read, GATTS_CHAR_NUM_READ, handle);
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

	ESP_LOGD(GATTS_TAG, "gatts_add_char_READ %d\n", GATTS_CHAR_NUM_READ);
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

	ESP_LOGD(GATTS_TAG, "gatts_check_add_char_READ %d\n", attr_handle);
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

		ESP_LOGD(GATTS_TAG, "FOUND Char READ pos %d handle %d\n",
				 ble_add_char_pos, attr_handle);
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

cJSON *dataStorage;
cJSON *timeArray;

char *config_json;
char tmp[64];

cJSON *messageJson, *jsonData;

uint8_t dataCharRead[GATTS_CHAR_VAL_LEN_MAX];

void char_total_read_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param)
{
	ESP_LOGD(GATTS_TAG, "char_total_read_handler %d\n", param->read.handle);

	ESP_LOGI(GATTS_TAG, "[APP] Free memory: %d bytes", esp_get_free_heap_size());

	sprintf((char *)total,
			"{\"Company\":\"%s\",\"UserName\":\"%s\",\"Detection\":%d,\"RoomName\":\"%s\",\"security\":%d,\"Version\":%d,"
			"\"FirmwareVersion\":\"%s\",\"TimeData\":[%d,%d],\"UVCTimeData\":[%d,%d,%d],\"uvcSt\":%d}",
			UnitCfg.Company, UnitCfg.OperatorName, detectionTriggered,
			UnitCfg.RoomName, UnitCfg.SecurityCodeDismiss, UnitCfg.Version, UnitCfg.FirmwareVersion,
			UnitCfg.DisinfictionTime, UnitCfg.ActivationTime,
			UnitCfg.UVCLifeTime, UnitCfg.UVCTimeExecution,
			UnitCfg.NumberOfDisinfection, UVC_Treatement_State);

	TOTAL.attr_len = strlen((char *)total);

	esp_gatt_rsp_t rsp;
	memset(&rsp, 0, sizeof(esp_gatt_rsp_t));
	rsp.attr_value.handle = param->read.handle;
	if (LIST_CHAR_READ[0].char_val != NULL)
	{
		ESP_LOGD(GATTS_TAG, "char_total_read_handler char_val %d\n",
				 LIST_CHAR_READ[0].char_val->attr_len);
		rsp.attr_value.len = LIST_CHAR_READ[0].char_val->attr_len;
		for (uint32_t pos = 0;
			 pos < LIST_CHAR_READ[0].char_val->attr_len && pos < LIST_CHAR_READ[0].char_val->attr_max_len;
			 pos++)
		{
			rsp.attr_value.value[pos] =
				LIST_CHAR_READ[0].char_val->attr_value[pos];
		}
	}
	ESP_LOGD(GATTS_TAG, "char_total_read_handler = %.*s\n",
			 LIST_CHAR_READ[0].char_val->attr_len,
			 (char *)LIST_CHAR_READ[0].char_val->attr_value);
	ESP_LOGD(GATTS_TAG, "char_total_read_handler esp_gatt_rsp_t\n");

	esp_ble_gatts_send_response(gatts_if, param->read.conn_id,
								param->read.trans_id, ESP_GATT_OK, &rsp);
}

void char_total_write_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param)
{
	ESP_LOGD(GATTS_TAG, "char_light_write_handler %d\n", param->write.handle);
	if (LIST_CHAR_READ[0].char_val != NULL)
	{
		ESP_LOGD(GATTS_TAG, "char_light_write_handler char_val %d\n",
				 param->write.len);
		LIST_CHAR_READ[0].char_val->attr_len = param->write.len;
		for (uint32_t pos = 0; pos < param->write.len; pos++)
		{
			LIST_CHAR_READ[0].char_val->attr_value[pos] = param->write.value[pos];
		}
		ESP_LOGD(GATTS_TAG, "char_light_write_handler = %.*s\n",
				 LIST_CHAR_READ[0].char_val->attr_len,
				 (char *)LIST_CHAR_READ[0].char_val->attr_value);

		uint32_t msize = LIST_CHAR_READ[0].char_val->attr_len + 1;
		config_json = malloc(msize);
		if (config_json != NULL)
		{
			sprintf(config_json, "%.*s", LIST_CHAR_READ[0].char_val->attr_len,
					(char *)LIST_CHAR_READ[0].char_val->attr_value);
		}
	}
	ESP_LOGD(GATTS_TAG, "char_light_write_handler esp_gatt_rsp_t\n");
	// printf("%s\n",light_json);
	esp_ble_gatts_send_response(gatts_if, param->write.conn_id, param->write.trans_id, ESP_GATT_OK, NULL);

	printf("%s\n", config_json);

	if (strContains(config_json, "UVCTreatement : ON") == 1)
	{
		ESP_LOGI(GATTS_TAG, "UVCTreatement is ON ");
		UVTaskIsOn = true;
		xTaskCreate(&UVCTreatement, "UVCTreatement", configMINIMAL_STACK_SIZE * 3, NULL, 5, NULL);
	}
	else if (strContains(config_json, "STOP : ON") == 1)
	{
		ESP_LOGI(GATTS_TAG, "STOP is ON ");
		stopIsPressed = true;
		stopEventTrigerred = true;
	}
	else if (strContains(config_json, "data") == 1)
	{
		messageJson = cJSON_Parse(config_json);
		jsonData = cJSON_GetObjectItemCaseSensitive(messageJson, "data");

		if (cJSON_IsArray(jsonData))
		{
			sprintf(UnitCfg.Company, cJSON_GetStringValue(cJSON_GetArrayItem(jsonData, 0)));
			sprintf(UnitCfg.OperatorName, cJSON_GetStringValue(cJSON_GetArrayItem(jsonData, 1)));
			sprintf(UnitCfg.RoomName, cJSON_GetStringValue(cJSON_GetArrayItem(jsonData, 2)));
			UnitCfg.DisinfictionTime = cJSON_GetArrayItem(jsonData, 3)->valueint;
			UnitCfg.ActivationTime = cJSON_GetArrayItem(jsonData, 4)->valueint;
			savenvsFlag = true;
		}

		cJSON_Delete(messageJson);
	}
	else if (jsonparse(config_json, tmp, "SetVersion", 0) == 0)
	{
		UnitCfg.Version = atoi(tmp);
		ESP_LOGI(GATTS_TAG, "Setting version to %d  ", UnitCfg.Version);
		savenvsFlag = true;
	}
	else if (jsonparse(config_json, UnitCfg.UnitName, "SetName", 0) == 0)
	{
		ESP_LOGI(GATTS_TAG, "Setting name to %s  ", UnitCfg.UnitName);
		savenvsFlag = true;
	}
	else if (strContains(config_json, "(SetUVCLIFETIME : 0)") == 1)
	{
		UnitCfg.UVCTimeExecution = 0;
		UnitCfg.NumberOfDisinfection = 0;
		ESP_LOGI(GATTS_TAG, "Setting uvc life time to %d  ",
				 UnitCfg.UVCTimeExecution);
		savenvsFlag = true;
	}
	else if (jsonparse(config_json, tmp, "SetUVCLIFESecurity", 0) == 0)
	{
		UnitCfg.SecurityCodeDismiss = atoi(tmp);
		if (UnitCfg.SecurityCodeDismiss)
			ESP_LOGI(GATTS_TAG, "Circadien cycle Enabled");
		else
			ESP_LOGI(GATTS_TAG, "Circadien cycle Disabled");
		savenvsFlag = true;
	}
	else
	{
		ESP_LOGE(GATTS_TAG, "BAD MESSAGE");
	}

	free(config_json);

	configParserTask();
}

char *light_json;

char *config_json;

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
		// advertising start complete event to indicate advertising start successfully or failed
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

void gatts_profile_read_event_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param)
{
	switch (event)
	{
	case ESP_GATTS_REG_EVT:
		ESP_LOGD(GATTS_TAG, "REGISTER_APP_EVT_READ, status %d, app_id %d\n", param->reg.status, param->reg.app_id);
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

		// config adv data
		esp_err_t ret = esp_ble_gap_config_adv_data(&adv_data);
		if (ret)
		{
			ESP_LOGE(GATTS_TAG, "config adv data failed, error code = %x", ret);
		}
		adv_config_done |= adv_config_flag;
		// config scan response data
		ret = esp_ble_gap_config_adv_data(&scan_rsp_data);
		if (ret)
		{
			ESP_LOGE(GATTS_TAG,
					 "config scan response data failed, error code = %x", ret);
		}
		adv_config_done |= scan_rsp_config_flag;

		esp_ble_gatts_create_service(gatts_if,
									 &gl_profile_tab[SERVICE_READ].service_id,
									 GATTS_NUM_HANDLE_READ);

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
		// start sent the update connection parameters to the peer device.
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
			ESP_LOGD(GATTS_TAG, "Reg app failed, app_id %04x, status %d\n",
					 param->reg.app_id, param->reg.status);
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
