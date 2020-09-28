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
#include <curl/curl.h>

#include "esp_gap_ble_api.h"
#include "esp_gatts_api.h"
#include "esp_bt_defs.h"
#include "esp_bt_main.h"
#include "esp_gatt_common_api.h"

#include "sdkconfig.h"
#include "unitcfg.h"
#include "lightcontrol.h"
#include "webservice.h"
#include "autolight.h"
#include "email_test_client.h"
#include "ota_client.h"
#include "sntp_client.h"
#include "https_request.h"
#include "curl_request.h"

#include "esp_partition.h"
#include "esp_spi_flash.h"
#include "esp_image_format.h"
//#include "openssl_client.h"

#include <stdint.h>
#include <inttypes.h>

#define GATTS_TAG 					"GATTS"

#define GATTS_CHAR_NUM_READ			4
#define GATTS_NUM_HANDLE_READ     	1+(2*GATTS_CHAR_NUM_READ)

#define GATTS_CHAR_NUM_WRITE		2
#define GATTS_NUM_HANDLE_WRITE     	1+(2*GATTS_CHAR_NUM_WRITE)

void configParserTask();
void lightParserTask();
void GattSyncTime(time_t t,uint32_t tzone);

///Declare the static function

static void gatts_profile_read_event_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);
static void gatts_profile_write_event_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);

static void char_total_read_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);
static void char_total1_read_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);
static void char_total2_read_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);
static void char_total3_read_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);

static void char_light_write_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);
static void char_wifi_write_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);
void check_pass();


//Declare uuid of READ Service

#define GATTS_SERVICE_UUID_TEST_READ    	0x00FF
#define GATTS_UUID_TEST_READ_Total        	0xFF01 //capteurs
#define GATTS_UUID_TEST_READ_Total1        	0xFF02 //profile
#define GATTS_UUID_TEST_READ_Total2        	0xFF03 //wifi
#define GATTS_UUID_TEST_READ_Total3        	0xFF04 //couleurs

//Declare uuid of WRITE Service

#define GATTS_SERVICE_UUID_TEST_WRITE   	0x00DD
#define GATTS_UUID_TEST_WRITE_LIGHT      	0xDD01
#define GATTS_UUID_TEST_WRITE_WIFI			0xDD02

#define TEST_DEVICE_NAME            		"MAESTRO"
#define TEST_MANUFACTURER_DATA_LEN  		17

#define GATTS_CHAR_VAL_LEN_MAX 				600
#define CHAR_ROOM_MAX 						0x02
#define PREPARE_BUF_MAX_SIZE 				1024

//characteristics values of READ profile

uint8_t total [GATTS_CHAR_VAL_LEN_MAX];  //capteurs	  = {0x4e,0x4f,0x54,0x20,0x43,0x4f,0x4e,0x4e,0x45,0x43,0x54,0x45,0x44,0x4e,0x4f,0x54,0x20,0x21,0x21,0x21,0x21,0x21};
uint8_t total1 [GATTS_CHAR_VAL_LEN_MAX]; //couleurs
uint8_t total2 [GATTS_CHAR_VAL_LEN_MAX]; //avancee
//characteristics values of WRITE profile

uint8_t light[GATTS_CHAR_VAL_LEN_MAX];
uint8_t wifi[GATTS_CHAR_VAL_LEN_MAX];

//property of each service

esp_gatt_char_prop_t read_property = 0;
esp_gatt_char_prop_t write_property = 0;

//

esp_attr_value_t TOTAL =
{
		.attr_max_len = GATTS_CHAR_VAL_LEN_MAX,
		.attr_len     = sizeof(total),
		.attr_value   = (uint8_t *)&total,
};

esp_attr_value_t TOTAL1 =
{
		.attr_max_len = GATTS_CHAR_VAL_LEN_MAX,
		.attr_len     = sizeof(total1),
		.attr_value   = (uint8_t *)&total1,
};

esp_attr_value_t TOTAL2 =
{
		.attr_max_len = GATTS_CHAR_VAL_LEN_MAX,//avancee
		.attr_len     = sizeof(total2),
		.attr_value   = (uint8_t *)&total2,
};

esp_attr_value_t WIFI =
{
    .attr_max_len = GATTS_CHAR_VAL_LEN_MAX,
    .attr_len     = sizeof(wifi),
    .attr_value   = wifi,
};

esp_attr_value_t LIGHT =
{
    .attr_max_len = GATTS_CHAR_VAL_LEN_MAX,
    .attr_len     = sizeof(light),
    .attr_value   = light,
};

static uint8_t adv_config_done = 0;
#define adv_config_flag      (1 << 0)
#define scan_rsp_config_flag (1 << 1)


static uint32_t ble_add_char_pos;

static uint8_t adv_service_uuid128[32] = {
    /* LSB <--------------------------------------------------------------------------------> MSB */
    //first uuid, 16bit, [12],[13] is the value
    0xfb, 0x34, 0x9b, 0x5f, 0x80, 0x00, 0x00, 0x80, 0x00, 0x10, 0x00, 0x00, 0xEE, 0x00, 0x00, 0x00,
    //second uuid, 32bit, [12], [13], [14], [15] is the value
    0xfb, 0x34, 0x9b, 0x5f, 0x80, 0x00, 0x00, 0x80, 0x00, 0x10, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00,
};

// The length of adv data must be less than 31 bytes
//static uint8_t test_manufacturer[TEST_MANUFACTURER_DATA_LEN] =  {0x12, 0x23, 0x45, 0x56};
//adv data
static esp_ble_adv_data_t adv_data = {
    .set_scan_rsp = false,
    .include_name = true,
    .include_txpower = true,
    .min_interval = 0x20,
    .max_interval = 0x40,
    .appearance = 0x00,
    .manufacturer_len = 0, //TEST_MANUFACTURER_DATA_LEN,
    .p_manufacturer_data =  NULL, //&test_manufacturer[0],
    .service_data_len = 0,
    .p_service_data = NULL,
    .service_uuid_len = 32,
    .p_service_uuid = adv_service_uuid128,
    .flag = (ESP_BLE_ADV_FLAG_GEN_DISC | ESP_BLE_ADV_FLAG_BREDR_NOT_SPT),
};
// scan response data
static esp_ble_adv_data_t scan_rsp_data = {
    .set_scan_rsp = true,
    .include_name = true,
    .include_txpower = true,
    .min_interval = 0x20,
    .max_interval = 0x40,
    .appearance = 0x00,
    .manufacturer_len = 0, //TEST_MANUFACTURER_DATA_LEN,
    .p_manufacturer_data =  NULL, //&test_manufacturer[0],
    .service_data_len = 0,
    .p_service_data = NULL,
    .service_uuid_len = 32,
    .p_service_uuid = adv_service_uuid128,
    .flag = (ESP_BLE_ADV_FLAG_GEN_DISC | ESP_BLE_ADV_FLAG_BREDR_NOT_SPT),
};

static esp_ble_adv_params_t adv_params = {
    .adv_int_min        = 0x20,
    .adv_int_max        = 0x40,
    .adv_type           = ADV_TYPE_IND,
    .own_addr_type      = BLE_ADDR_TYPE_PUBLIC,
    .channel_map        = ADV_CHNL_ALL,
    .adv_filter_policy = ADV_FILTER_ALLOW_SCAN_ANY_CON_ANY,
};

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
static struct gatts_profile_inst gl_profile_tab[PROFILE_NUM] = {
    [SERVICE_READ] = {
        .gatts_cb = gatts_profile_read_event_handler,
        .gatts_if = ESP_GATT_IF_NONE,       /* Not get the gatt_if, so initial is ESP_GATT_IF_NONE */
    },
    [SERVICE_WRITE] = {
        .gatts_cb = gatts_profile_write_event_handler,                   /* This demo does not implement, similar as profile A */
		.gatts_if = ESP_GATT_IF_NONE,       /* Not get the gatt_if, so initial is ESP_GATT_IF_NONE */
    },
};


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

static struct gatts_char_inst LIST_CHAR_READ[GATTS_CHAR_NUM_READ] = {			//SERVICE READ
		{
				.char_uuid.len = ESP_UUID_LEN_16,
				.char_uuid.uuid.uuid16 = GATTS_UUID_TEST_READ_Total,
				.char_perm = ESP_GATT_PERM_READ ,
				.char_property = ESP_GATT_CHAR_PROP_BIT_READ,
				.char_control = NULL,
				.char_handle = 0,
				.char_val = &TOTAL,
				.char_read_callback=char_total_read_handler,
		},
		{
				.char_uuid.len = ESP_UUID_LEN_16,
				.char_uuid.uuid.uuid16 = GATTS_UUID_TEST_READ_Total1,
				.char_perm = ESP_GATT_PERM_READ ,
				.char_property = ESP_GATT_CHAR_PROP_BIT_READ  | ESP_GATT_CHAR_PROP_BIT_NOTIFY,
				.char_control = NULL,
				.char_handle = 0,
				.char_val = &TOTAL,
				.char_read_callback=char_total1_read_handler,
		},
		{
				.char_uuid.len = ESP_UUID_LEN_16,
				.char_uuid.uuid.uuid16 = GATTS_UUID_TEST_READ_Total2,
				.char_perm = ESP_GATT_PERM_READ ,
				.char_property = ESP_GATT_CHAR_PROP_BIT_READ  | ESP_GATT_CHAR_PROP_BIT_NOTIFY,
				.char_control = NULL,
				.char_handle = 0,
				.char_val = &TOTAL2,
				.char_read_callback=char_total2_read_handler,
		},
		{
				.char_uuid.len = ESP_UUID_LEN_16,
				.char_uuid.uuid.uuid16 = GATTS_UUID_TEST_READ_Total3,
				.char_perm = ESP_GATT_PERM_READ ,
				.char_property = ESP_GATT_CHAR_PROP_BIT_READ  | ESP_GATT_CHAR_PROP_BIT_NOTIFY,
				.char_control = NULL,
				.char_handle = 0,
				.char_val = &TOTAL1,
				.char_read_callback=char_total3_read_handler,
		}
};

static struct gatts_char_inst LIST_CHAR_WRITE[GATTS_CHAR_NUM_WRITE] = {				//SERVICE WRITE
		{
				.char_uuid.len = ESP_UUID_LEN_16,
				.char_uuid.uuid.uuid16 = GATTS_UUID_TEST_WRITE_WIFI ,
				.char_perm =  ESP_GATT_PERM_WRITE,
				.char_property =  ESP_GATT_CHAR_PROP_BIT_WRITE ,
				.char_control=NULL,
				.char_handle=0,
				.char_val = &WIFI,
				.char_write_callback=char_wifi_write_handler,
		},
		{
				.char_uuid.len = ESP_UUID_LEN_16,
				.char_uuid.uuid.uuid16 = GATTS_UUID_TEST_WRITE_LIGHT ,
				.char_perm = ESP_GATT_PERM_WRITE,
				.char_property = ESP_GATT_CHAR_PROP_BIT_WRITE,
				.char_control = NULL,
				.char_handle = 0,
				.char_val = &LIGHT,
				.char_write_callback=char_light_write_handler,
		}
};


void gatts_check_callback(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
	uint16_t handle=0;
	uint8_t read=1;
    switch (event) {
		case ESP_GATTS_READ_EVT: {
			read=1;
			handle=param->read.handle;
			break;
		}
		case ESP_GATTS_WRITE_EVT: {
			read=0;
			handle=param->write.handle;
			break;
		}
		default:
			break;
    }

	ESP_LOGD(GATTS_TAG, "gatts_check_callback write %d num %d handle %d\n", read, GATTS_CHAR_NUM_READ, handle);
	for (uint32_t pos=0;pos<GATTS_CHAR_NUM_WRITE;pos++) {
		if (LIST_CHAR_WRITE[pos].char_handle==handle) {
			if (read==0) {
				if (LIST_CHAR_WRITE[pos].char_write_callback!=NULL) {
					LIST_CHAR_WRITE[pos].char_write_callback(event, gatts_if, param);
				}
			}
			break;
		}
	}
	ESP_LOGD(GATTS_TAG, "gatts_check_callback read %d num %d handle %d\n", read, GATTS_CHAR_NUM_WRITE, handle);
	for (uint32_t pos=0;pos<GATTS_CHAR_NUM_READ;pos++) {
		if (LIST_CHAR_READ[pos].char_handle==handle) {
			if (read==1) {
				if (LIST_CHAR_READ[pos].char_read_callback!=NULL) {
					LIST_CHAR_READ[pos].char_read_callback(event, gatts_if, param);
				}
			}
			break;
		}
	}
}

void gatts_add_char_READ() {

	ESP_LOGD(GATTS_TAG, "gatts_add_char_READ %d\n", GATTS_CHAR_NUM_READ);
	for (uint32_t pos=0;pos<GATTS_CHAR_NUM_READ;pos++) {
		if (LIST_CHAR_READ[pos].char_handle==0) {
			ESP_LOGI(GATTS_TAG, "ADD pos %d handle %d service %d\n", pos,LIST_CHAR_READ[pos].char_handle,gl_profile_tab[SERVICE_READ].service_handle);
			ble_add_char_pos=pos;
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

void gatts_add_char_WRITE() {

	ESP_LOGD(GATTS_TAG, "gatts_add_char_WRITE %d\n", GATTS_CHAR_NUM_WRITE);
	for (uint32_t pos=0;pos<GATTS_CHAR_NUM_WRITE;pos++) {
		if (LIST_CHAR_WRITE[pos].char_handle==0) {
			ESP_LOGI(GATTS_TAG, "ADD pos %d handle %d service %d\n", pos,LIST_CHAR_WRITE[pos].char_handle,gl_profile_tab[SERVICE_WRITE].service_handle);
			ble_add_char_pos=pos;
			esp_ble_gatts_add_char(gl_profile_tab[SERVICE_WRITE].service_handle,
								   &LIST_CHAR_WRITE[pos].char_uuid,
								   LIST_CHAR_WRITE[pos].char_perm,
								   LIST_CHAR_WRITE[pos].char_property,
								   LIST_CHAR_WRITE[pos].char_val,
								   LIST_CHAR_WRITE[pos].char_control);
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
			ESP_LOGI(GATTS_TAG, "Char READ UUID128: %x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x", char_uuid.uuid.uuid128[0],
					 char_uuid.uuid.uuid128[1], char_uuid.uuid.uuid128[2], char_uuid.uuid.uuid128[3],
					 char_uuid.uuid.uuid128[4], char_uuid.uuid.uuid128[5], char_uuid.uuid.uuid128[6],
					 char_uuid.uuid.uuid128[7], char_uuid.uuid.uuid128[8], char_uuid.uuid.uuid128[9],
					 char_uuid.uuid.uuid128[10], char_uuid.uuid.uuid128[11], char_uuid.uuid.uuid128[12],
					 char_uuid.uuid.uuid128[13], char_uuid.uuid.uuid128[14], char_uuid.uuid.uuid128[15]);
		} else {
			ESP_LOGE(GATTS_TAG, "Char READ UNKNOWN LEN %d\n", char_uuid.len);
		}

		ESP_LOGD(GATTS_TAG, "FOUND Char READ pos %d handle %d\n", ble_add_char_pos,attr_handle);
		LIST_CHAR_READ[ble_add_char_pos].char_handle=attr_handle;
		gatts_add_char_READ();
	}
}

void gatts_check_add_char_WRITE(esp_bt_uuid_t char_uuid, uint16_t attr_handle) {

	ESP_LOGD(GATTS_TAG, "gatts_check_add_char_WRITE %d\n", attr_handle);
	if (attr_handle != 0) {
		if (char_uuid.len == ESP_UUID_LEN_16) {
			ESP_LOGD(GATTS_TAG, "Char WRITE UUID16: %x", char_uuid.uuid.uuid16);
		} else if (char_uuid.len == ESP_UUID_LEN_32) {
			ESP_LOGD(GATTS_TAG, "Char WRITE UUID32: %x", char_uuid.uuid.uuid32);
		} else if (char_uuid.len == ESP_UUID_LEN_128) {
			ESP_LOGD(GATTS_TAG, "Char WRITE UUID128: %x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x,%x", char_uuid.uuid.uuid128[0],
					 char_uuid.uuid.uuid128[1], char_uuid.uuid.uuid128[2], char_uuid.uuid.uuid128[3],
					 char_uuid.uuid.uuid128[4], char_uuid.uuid.uuid128[5], char_uuid.uuid.uuid128[6],
					 char_uuid.uuid.uuid128[7], char_uuid.uuid.uuid128[8], char_uuid.uuid.uuid128[9],
					 char_uuid.uuid.uuid128[10], char_uuid.uuid.uuid128[11], char_uuid.uuid.uuid128[12],
					 char_uuid.uuid.uuid128[13], char_uuid.uuid.uuid128[14], char_uuid.uuid.uuid128[15]);
		} else {
			ESP_LOGE(GATTS_TAG, "Char WRITE UNKNOWN LEN %d\n", char_uuid.len);
		}

		ESP_LOGD(GATTS_TAG, "FOUND Char WRITE pos %d handle %d\n", ble_add_char_pos,attr_handle);
		LIST_CHAR_WRITE[ble_add_char_pos].char_handle=attr_handle;
		gatts_add_char_WRITE();
	}
}



void char_total_read_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
	ESP_LOGD(GATTS_TAG, "char_total_read_handler %d\n", param->read.handle);

	memcpy(&total,(uint8_t *)&UnitData,sizeof(UnitData));

	TOTAL.attr_len = sizeof(UnitData);

	esp_gatt_rsp_t rsp;
	memset(&rsp, 0, sizeof(esp_gatt_rsp_t));
	rsp.attr_value.handle = param->read.handle;
	if (LIST_CHAR_READ[0].char_val!=NULL) {
		ESP_LOGD(GATTS_TAG, "char_total_read_handler char_val %d\n",LIST_CHAR_READ[0].char_val->attr_len);
		rsp.attr_value.len = LIST_CHAR_READ[0].char_val->attr_len;
		for (uint32_t pos=0;pos<LIST_CHAR_READ[0].char_val->attr_len&&pos<LIST_CHAR_READ[0].char_val->attr_max_len;pos++) {
			rsp.attr_value.value[pos] = LIST_CHAR_READ[0].char_val->attr_value[pos];
		}
	}
	ESP_LOGD(GATTS_TAG, "char_total_read_handler = %.*s\n", LIST_CHAR_READ[0].char_val->attr_len, (char*)LIST_CHAR_READ[0].char_val->attr_value);
	ESP_LOGD(GATTS_TAG, "char_total_read_handler esp_gatt_rsp_t\n");
	esp_ble_gatts_send_response(gatts_if, param->read.conn_id, param->read.trans_id,
								ESP_GATT_OK, &rsp);
}

//uint8_t read_profile_count=0;

void char_total1_read_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
	ESP_LOGD(GATTS_TAG, "char_total1_read_handler %d\n", param->read.handle);

	UnitData.auto_zone_1=UnitCfg.UserLcProfile.FixedBrLevel_zone1;
	UnitData.auto_zone_2=UnitCfg.UserLcProfile.FixedBrLevel_zone2;
	UnitData.auto_zone_3=UnitCfg.UserLcProfile.FixedBrLevel_zone3;
	UnitData.auto_zone_4=UnitCfg.UserLcProfile.FixedBrLevel_zone4;
	UnitData.auto_zone_010V=UnitCfg.UserLcProfile.FixedBrLevel_zone_010v;

	//if (read_profile_count==0){

		sprintf((char*)total,"{\"profile_id\":\"%s\",\"PROFILE_1\":{\"pname\":\"%s\",\"pdata\":[%ld,%ld,%ld,%ld],\"lum\":[%d,%d,\"%s\",%d,%d,%d,%d,%d,%d],"
				"\"veille\":[%ld],\"cycle\":[%d,\"%s\",%ld,%ld,%d,%ld,%ld,%d,%ld,%ld,%d]}}",

				UnitCfg.UserLcProfile.profile_name,

				UnitCfg.UserLcProfile.name,
			    UnitCfg.UserLcProfile.AutoTrigTime/3600,(UnitCfg.UserLcProfile.AutoTrigTime%3600)/60,
			    UnitCfg.UserLcProfile.AutoStopTime/3600,(UnitCfg.UserLcProfile.AutoStopTime%3600)/60,

				UnitCfg.UserLcProfile.AutoBrEnb,
				UnitCfg.UserLcProfile.AutoBrRef,
				UnitCfg.UserLcProfile.Zone_lum,
				UnitCfg.UserLcProfile.FixedBrLevel_zone1,
				UnitCfg.UserLcProfile.FixedBrLevel_zone2,
				UnitCfg.UserLcProfile.FixedBrLevel_zone3,
				UnitCfg.UserLcProfile.FixedBrLevel_zone4,
				UnitCfg.UserLcProfile.FixedBrLevel_zone_010v,
				UnitCfg.UserLcProfile.seuil_eclairage,

				(UnitCfg.UserLcProfile.PirTimeout%3600)/60,

				UnitCfg.UserLcProfile.CcEnb,
				UnitCfg.UserLcProfile.ZoneCc,
			    UnitCfg.UserLcProfile.Ccp[0].CcTime/3600,(UnitCfg.UserLcProfile.Ccp[0].CcTime%3600)/60,
				UnitCfg.UserLcProfile.Ccp[0].CcLevel,
			    UnitCfg.UserLcProfile.Ccp[1].CcTime/3600,(UnitCfg.UserLcProfile.Ccp[1].CcTime%3600)/60,
				UnitCfg.UserLcProfile.Ccp[1].CcLevel,
				UnitCfg.UserLcProfile.Ccp[2].CcTime/3600,(UnitCfg.UserLcProfile.Ccp[2].CcTime%3600)/60,
				UnitCfg.UserLcProfile.Ccp[2].CcLevel
				);

		TOTAL.attr_len = strlen((char *)total);
	//}
	/*if (read_profile_count==1){

		sprintf((char*)total,"{\"profile_id\":\"%s\",\"PROFILE_3\":{\"pname\":\"%s\",\"pdata\":[%ld,%ld,%ld,%ld,\"%s\"],\"lum\":[%d,%d,%d,%d,%d,%d,%d,%d],"
				"\"veille\":[%d,%ld,\"%s\"],\"cycle\":[%d,\"%s\",%ld,%ld,%d,%ld,%ld,%d,%ld,%ld,%d]},"
				                                    "\"PROFILE_4\":{\"pname\":\"%s\",\"pdata\":[%ld,%ld,%ld,%ld,\"%s\"],\"lum\":[%d,%d,%d,%d,%d,%d,%d,%d],"
				"\"veille\":[%d,%ld,\"%s\"],\"cycle\":[%d,\"%s\",%ld,%ld,%d,%ld,%ld,%d,%ld,%ld,%d]}}",

				UnitCfg.UserLcProfile.profile_name,

				UnitCfg.UserLcProfile.name,
			    UnitCfg.UserLcProfile.AutoTrigTime/3600,(UnitCfg.UserLcProfile.AutoTrigTime%3600)/60,
			    UnitCfg.UserLcProfile.AutoStopTime/3600,(UnitCfg.UserLcProfile.AutoStopTime%3600)/60,
				UnitCfg.UserLcProfile.Veille_days,

				UnitCfg.UserLcProfile.AutoBrEnb,
				UnitCfg.UserLcProfile.AutoBrRef,
				UnitCfg.UserLcProfile.FixedBrLevel_zone1,
				UnitCfg.UserLcProfile.FixedBrLevel_zone2,
				UnitCfg.UserLcProfile.FixedBrLevel_zone3,
				UnitCfg.UserLcProfile.FixedBrLevel_zone4,
				UnitCfg.UserLcProfile.FixedBrLevel_zone_010v,
				UnitCfg.UserLcProfile.seuil_eclairage,

				UnitCfg.UserLcProfile.VeilleBrEnb,
				(UnitCfg.UserLcProfile.NoticeTimeout%3600)/60,
				UnitCfg.UserLcProfile.veille_zone,

				UnitCfg.UserLcProfile.CcEnb,
				UnitCfg.UserLcProfile.ZoneCc,
			    UnitCfg.UserLcProfile.Ccp[0].CcTime/3600,(UnitCfg.UserLcProfile.Ccp[0].CcTime%3600)/60,
				UnitCfg.UserLcProfile.Ccp[0].CcLevel,
			    UnitCfg.UserLcProfile.Ccp[1].CcTime/3600,(UnitCfg.UserLcProfile.Ccp[1].CcTime%3600)/60,
				UnitCfg.UserLcProfile.Ccp[1].CcLevel,
				UnitCfg.UserLcProfile.Ccp[2].CcTime/3600,(UnitCfg.UserLcProfile.Ccp[2].CcTime%3600)/60,
				UnitCfg.UserLcProfile.Ccp[2].CcLevel,

				UnitCfg.UserLcProfile.name,
			    UnitCfg.UserLcProfile.AutoTrigTime/3600,(UnitCfg.UserLcProfile.AutoTrigTime%3600)/60,
			    UnitCfg.UserLcProfile.AutoStopTime/3600,(UnitCfg.UserLcProfile.AutoStopTime%3600)/60,
				UnitCfg.UserLcProfile.Veille_days,

				UnitCfg.UserLcProfile.AutoBrEnb,
				UnitCfg.UserLcProfile.AutoBrRef,
				UnitCfg.UserLcProfile.FixedBrLevel_zone1,
				UnitCfg.UserLcProfile.FixedBrLevel_zone2,
				UnitCfg.UserLcProfile.FixedBrLevel_zone3,
				UnitCfg.UserLcProfile.FixedBrLevel_zone4,
				UnitCfg.UserLcProfile.FixedBrLevel_zone_010v,
				UnitCfg.UserLcProfile.seuil_eclairage,

				UnitCfg.UserLcProfile.VeilleBrEnb,
				(UnitCfg.UserLcProfile.NoticeTimeout%3600)/60,
				UnitCfg.UserLcProfile.veille_zone,

				UnitCfg.UserLcProfile.CcEnb,
				UnitCfg.UserLcProfile.ZoneCc,
			    UnitCfg.UserLcProfile.Ccp[0].CcTime/3600,(UnitCfg.UserLcProfile.Ccp[0].CcTime%3600)/60,
				UnitCfg.UserLcProfile.Ccp[0].CcLevel,
			    UnitCfg.UserLcProfile.Ccp[1].CcTime/3600,(UnitCfg.UserLcProfile.Ccp[1].CcTime%3600)/60,
				UnitCfg.UserLcProfile.Ccp[1].CcLevel,
				UnitCfg.UserLcProfile.Ccp[2].CcTime/3600,(UnitCfg.UserLcProfile.Ccp[2].CcTime%3600)/60,
				UnitCfg.UserLcProfile.Ccp[2].CcLevel
				);

		TOTAL.attr_len = strlen((char *)total);
		read_profile_count=0;
}*/

	esp_gatt_rsp_t rsp;
	memset(&rsp, 0, sizeof(esp_gatt_rsp_t));
	rsp.attr_value.handle = param->read.handle;
	if (LIST_CHAR_READ[1].char_val!=NULL) {
		ESP_LOGD(GATTS_TAG, "char_total1_read_handler char_val %d\n",LIST_CHAR_READ[1].char_val->attr_len);
		rsp.attr_value.len = LIST_CHAR_READ[1].char_val->attr_len;
		for (uint32_t pos=0;pos<LIST_CHAR_READ[1].char_val->attr_len&&pos<LIST_CHAR_READ[1].char_val->attr_max_len;pos++) {
			rsp.attr_value.value[pos] = LIST_CHAR_READ[1].char_val->attr_value[pos];
		}
	}
	ESP_LOGD(GATTS_TAG, "char_total1_read_handler = %.*s\n", LIST_CHAR_READ[1].char_val->attr_len, (char*)LIST_CHAR_READ[1].char_val->attr_value);
	ESP_LOGD(GATTS_TAG, "char_total1_read_handler esp_gatt_rsp_t\n");
	//read_profile_count++;
	esp_ble_gatts_send_response(gatts_if, param->read.conn_id, param->read.trans_id,
								ESP_GATT_OK, &rsp);
}
void char_total3_read_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
	ESP_LOGD(GATTS_TAG, "char_total1_read_handler %d\n", param->read.handle);

	if (WifiConnectedFlag==false)
	{
		sprintf((char*)UnitCfg.WifiCfg.WIFI_SSID,"null");
	}

	sprintf((char*)total1,"{\"couleur1\":[\"%s\",%d,%d,%d,%d,\"%s\",%d],"
						   "\"couleur2\":[\"%s\",%d,%d,%d,%d,\"%s\",%d],"
						   "\"co2\":[%d,%d,\"%s\",%d,%d,\"%s\",%d],"
						   "\"modem\":\"%s\",\"IP_STATIC\":[%d,\"%s\",\"%s\",\"%s\",\"%s\"],\"UDP\":[%d,%d,\"%s\",%d],\"Z_1\":\"%s\",\"Z_2\":\"%s\","
						   "\"Z_3\":\"%s\",\"Z_4\":\"%s\"}",
			UnitCfg.ColortrProfile[0].name,
			UnitCfg.ColortrProfile[0].blanche,
			UnitCfg.ColortrProfile[0].Rouge,
			UnitCfg.ColortrProfile[0].Vert,
			UnitCfg.ColortrProfile[0].Bleu,
			UnitCfg.ColortrProfile[0].zone,
			UnitCfg.ColortrProfile[0].intensity,
			UnitCfg.ColortrProfile[1].name,
			UnitCfg.ColortrProfile[1].blanche,
			UnitCfg.ColortrProfile[1].Rouge,
			UnitCfg.ColortrProfile[1].Vert,
			UnitCfg.ColortrProfile[1].Bleu,
			UnitCfg.ColortrProfile[1].zone,
			UnitCfg.ColortrProfile[1].intensity,

			UnitCfg.Co2LevelWarEnb,
			UnitCfg.Co2LevelEmailEnb,
			UnitCfg.Email,
			UnitCfg.Co2NotifyEnb,
			UnitCfg.Co2LevelZoneEnb,
			UnitCfg.Co2LevelSelect,
			UnitCfg.Co2LevelWar,

			UnitCfg.WifiCfg.WIFI_SSID,
			UnitCfg.Static_IP.Enable,
			UnitCfg.Static_IP.IP,
			UnitCfg.Static_IP.MASK,
			UnitCfg.Static_IP.GATE_WAY,
			UnitCfg.Static_IP.DNS_SERVER,
			UnitCfg.UDPConfig.Enable,
			UnitCfg.UDPConfig.ipv4_ipv6,
			UnitCfg.UDPConfig.Server,
			UnitCfg.UDPConfig.Port,
			UnitCfg.Zones.ZONE_1,
			UnitCfg.Zones.ZONE_2,
			UnitCfg.Zones.ZONE_3,
			UnitCfg.Zones.ZONE_4
			);

	TOTAL1.attr_len = strlen((char *)total1);

	//ESP_LOGI(GATTS_TAG, "total1 = %s\n",total1);

	esp_gatt_rsp_t rsp;
	memset(&rsp, 0, sizeof(esp_gatt_rsp_t));
	rsp.attr_value.handle = param->read.handle;
	if (LIST_CHAR_READ[3].char_val!=NULL) {
		ESP_LOGD(GATTS_TAG, "char_total3_read_handler char_val %d\n",LIST_CHAR_READ[3].char_val->attr_len);
		rsp.attr_value.len = LIST_CHAR_READ[3].char_val->attr_len;
		for (uint32_t pos=0;pos<LIST_CHAR_READ[3].char_val->attr_len&&pos<LIST_CHAR_READ[3].char_val->attr_max_len;pos++) {
			rsp.attr_value.value[pos] = LIST_CHAR_READ[3].char_val->attr_value[pos];
		}
	}
	ESP_LOGD(GATTS_TAG, "char_total3_read_handler = %.*s\n", LIST_CHAR_READ[3].char_val->attr_len, (char*)LIST_CHAR_READ[3].char_val->attr_value);
	ESP_LOGD(GATTS_TAG, "char_total3_read_handler esp_gatt_rsp_t\n");
	esp_ble_gatts_send_response(gatts_if, param->read.conn_id, param->read.trans_id,
								ESP_GATT_OK, &rsp);
}
void char_total2_read_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
	ESP_LOGD(GATTS_TAG, "char_total2_read_handler %d\n", param->read.handle);

	sprintf((char*)total2,"{\"pir\":%d,\"tz\":%d,\"summer\":%d,\"ftp\":[%d,\"%s\",%d,\"%s\",\"%s\",\"%s\",%d,%d,%ld,%ld],\"mqtt\":[%d,\"%s\",%d,\"%s\",\"%s\",\"%s\",\"%s\",%d]}",
		UnitCfg.PirSensitivity,
		UnitCfg.UnitTimeZone,
		UnitCfg.Summer_time,
		UnitCfg.FtpConfig.FtpLogEnb,
		UnitCfg.FtpConfig.Server,
		UnitCfg.FtpConfig.Port,
		UnitCfg.FtpConfig.UserName,
		UnitCfg.FtpConfig.Password,
		UnitCfg.FtpConfig.Client_id,
		UnitCfg.FtpConfig.ftp_now_or_later,
		UnitCfg.FtpConfig.FtpTimeout_send,
		UnitCfg.FtpConfig.ftp_send/3600,
		(UnitCfg.FtpConfig.ftp_send%3600)/60,
		UnitCfg.MqttConfig.MqttLogEnb,
		UnitCfg.MqttConfig.Server,
		UnitCfg.MqttConfig.Port,
		UnitCfg.MqttConfig.UserName,
		UnitCfg.MqttConfig.Password,
		UnitCfg.MqttConfig.Topic,
		UnitCfg.MqttConfig.sousTopic,
		UnitCfg.MqttConfig.TopicTimeout
			);

	TOTAL2.attr_len = strlen((char *)total2);
	esp_gatt_rsp_t rsp;
	memset(&rsp, 0, sizeof(esp_gatt_rsp_t));
	rsp.attr_value.handle = param->read.handle;
	if (LIST_CHAR_READ[2].char_val!=NULL) {
		ESP_LOGD(GATTS_TAG, "char_total2_read_handler char_val %d\n",LIST_CHAR_READ[2].char_val->attr_len);
		rsp.attr_value.len = LIST_CHAR_READ[2].char_val->attr_len;
		for (uint32_t pos=0;pos<LIST_CHAR_READ[2].char_val->attr_len&&pos<LIST_CHAR_READ[2].char_val->attr_max_len;pos++) {
			rsp.attr_value.value[pos] = LIST_CHAR_READ[2].char_val->attr_value[pos];
		}
	}
	ESP_LOGD(GATTS_TAG, "char_total2_read_handler = %.*s\n", LIST_CHAR_READ[2].char_val->attr_len, (char*)LIST_CHAR_READ[2].char_val->attr_value);
	ESP_LOGD(GATTS_TAG, "char_total2_read_handler esp_gatt_rsp_t\n");
	esp_ble_gatts_send_response(gatts_if, param->read.conn_id, param->read.trans_id,
								ESP_GATT_OK, &rsp);
}

char *light_json;

void char_light_write_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
	ESP_LOGD(GATTS_TAG, "char_light_write_handler %d\n", param->write.handle);
	if (LIST_CHAR_WRITE[0].char_val!=NULL) {
		ESP_LOGD(GATTS_TAG, "char_light_write_handler char_val %d\n",param->write.len);
		LIST_CHAR_WRITE[0].char_val->attr_len = param->write.len;
		for (uint32_t pos=0;pos<param->write.len;pos++) {
			LIST_CHAR_WRITE[0].char_val->attr_value[pos]=param->write.value[pos];
		}
	    if (strncmp((const char *)LIST_CHAR_WRITE[0].char_val->attr_value,"1*",2)==0) {

	    }
	    ESP_LOGD(GATTS_TAG, "char_light_write_handler = %.*s\n", LIST_CHAR_WRITE[0].char_val->attr_len, (char*)LIST_CHAR_WRITE[0].char_val->attr_value);

		uint32_t msize=LIST_CHAR_WRITE[0].char_val->attr_len+1;
		light_json=malloc(msize);
		if (light_json!=NULL)
		{
			sprintf(light_json,"%.*s",LIST_CHAR_WRITE[0].char_val->attr_len, (char*)LIST_CHAR_WRITE[0].char_val->attr_value);
		}

	}
	ESP_LOGD(GATTS_TAG, "char_light_write_handler esp_gatt_rsp_t\n");
    esp_ble_gatts_send_response(gatts_if, param->write.conn_id, param->write.trans_id, ESP_GATT_OK, NULL);

	if (light_json!=NULL)
	{
		xTaskCreatePinnedToCore(&lightParserTask, "lightParserTask", 4000, NULL, 3, NULL,1);
	}
}

char *config_json;

void char_wifi_write_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
	ESP_LOGD(GATTS_TAG, "char_wifi_write_handler %d\n", param->write.handle);

	if (LIST_CHAR_WRITE[1].char_val!=NULL) {
		ESP_LOGD(GATTS_TAG, "char_wifi_write_handler char_val %d\n",param->write.len);
		LIST_CHAR_WRITE[1].char_val->attr_len = param->write.len;
		for (uint32_t pos=0;pos<param->write.len;pos++) {
			LIST_CHAR_WRITE[1].char_val->attr_value[pos]=param->write.value[pos];
		}
		ESP_LOGD(GATTS_TAG, "char_wifi_write_handler = %.*s\n", LIST_CHAR_WRITE[1].char_val->attr_len, (char*)LIST_CHAR_WRITE[1].char_val->attr_value);

		/* */

		uint32_t msize=LIST_CHAR_WRITE[1].char_val->attr_len+1;
		config_json=malloc(msize);
		if (config_json!=NULL)
		{
			sprintf(config_json,"%.*s",LIST_CHAR_WRITE[1].char_val->attr_len, (char*)LIST_CHAR_WRITE[1].char_val->attr_value);
		}
	}
	ESP_LOGD(GATTS_TAG, "char_wifi_write_handler esp_gatt_rsp_t\n");
    esp_ble_gatts_send_response(gatts_if, param->write.conn_id, param->write.trans_id, ESP_GATT_OK, NULL);

	if (config_json!=NULL)
	{
		xTaskCreatePinnedToCore(&configParserTask, "configParserTask", 4000, NULL, 3, NULL,1);
	}
}


static void gap_event_handler(esp_gap_ble_cb_event_t event, esp_ble_gap_cb_param_t *param)
{
    switch (event) {

    case ESP_GAP_BLE_ADV_DATA_SET_COMPLETE_EVT:
        adv_config_done &= (~adv_config_flag);
        if (adv_config_done == 0){
            esp_ble_gap_start_advertising(&adv_params);
        }
        break;
    case ESP_GAP_BLE_SCAN_RSP_DATA_SET_COMPLETE_EVT:
        adv_config_done &= (~scan_rsp_config_flag);
        if (adv_config_done == 0){
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
        	ESP_LOGD(GATTS_TAG, "Stop adv successfully\n");
        }
        break;
    case ESP_GAP_BLE_UPDATE_CONN_PARAMS_EVT:
    	ESP_LOGD(GATTS_TAG, "update connection params status = %d, min_int = %d, max_int = %d,conn_int = %d,latency = %d, timeout = %d",
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

static void gatts_profile_read_event_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
    switch (event) {
    case ESP_GATTS_REG_EVT:
    	ESP_LOGD(GATTS_TAG, "REGISTER_APP_EVT_READ, status %d, app_id %d\n", param->reg.status, param->reg.app_id);
        gl_profile_tab[SERVICE_READ].service_id.is_primary = true;
        gl_profile_tab[SERVICE_READ].service_id.id.inst_id = 0x00;
        gl_profile_tab[SERVICE_READ].service_id.id.uuid.len = ESP_UUID_LEN_16;
        gl_profile_tab[SERVICE_READ].service_id.id.uuid.uuid.uuid16 = GATTS_SERVICE_UUID_TEST_READ;

        esp_err_t set_dev_name_ret = esp_ble_gap_set_device_name(UnitCfg.UnitName);
        if (set_dev_name_ret){
            ESP_LOGE(GATTS_TAG, "set device name failed, error code = %x", set_dev_name_ret);
        }

        //config adv data
        esp_err_t ret = esp_ble_gap_config_adv_data(&adv_data);
        if (ret){
            ESP_LOGE(GATTS_TAG, "config adv data failed, error code = %x", ret);
        }
        adv_config_done |= adv_config_flag;
        //config scan response data
        ret = esp_ble_gap_config_adv_data(&scan_rsp_data);
        if (ret){
            ESP_LOGE(GATTS_TAG, "config scan response data failed, error code = %x", ret);
        }
        adv_config_done |= scan_rsp_config_flag;

        esp_ble_gatts_create_service(gatts_if, &gl_profile_tab[SERVICE_READ].service_id, GATTS_NUM_HANDLE_READ);

        break;
    case ESP_GATTS_READ_EVT: {
    	ESP_LOGI(GATTS_TAG, "GATT_READ_EVT_READ, conn_id %d, trans_id %d, handle %d\n", param->read.conn_id, param->read.trans_id, param->read.handle);
    	gatts_check_callback(event, gatts_if, param);
        break;
    }
    case ESP_GATTS_WRITE_EVT: {
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
        ESP_LOGI(GATTS_TAG, "CREATE_SERVICE_EVT_READ, status %d,  service_handle %d\n", param->create.status, param->create.service_handle);
        gl_profile_tab[SERVICE_READ].service_handle = param->create.service_handle;
        gl_profile_tab[SERVICE_READ].char_uuid.len = LIST_CHAR_READ[0].char_uuid.len;
        gl_profile_tab[SERVICE_READ].char_uuid.uuid.uuid16 = LIST_CHAR_READ[0].char_uuid.uuid.uuid16;

        esp_ble_gatts_start_service(gl_profile_tab[SERVICE_READ].service_handle);
        gatts_add_char_READ();
        break;
    case ESP_GATTS_ADD_INCL_SRVC_EVT:
        break;
    case ESP_GATTS_ADD_CHAR_EVT: {
        ESP_LOGI(GATTS_TAG, "ADD_CHAR_EVT_READ, status %d,  attr_handle %d, service_handle %d\n",
                param->add_char.status, param->add_char.attr_handle, param->add_char.service_handle);
        gl_profile_tab[SERVICE_READ].char_handle = param->add_char.attr_handle;
        if (param->add_char.status==ESP_GATT_OK)
        {
        	gatts_check_add_char_READ(param->add_char.char_uuid,param->add_char.attr_handle);
        }
        break;
    }
    case ESP_GATTS_ADD_CHAR_DESCR_EVT:
        break;
    case ESP_GATTS_DELETE_EVT:
        break;
    case ESP_GATTS_START_EVT:
        ESP_LOGI(GATTS_TAG, "SERVICE_START_EVT_READ, status %d, service_handle %d\n",
                 param->start.status, param->start.service_handle);
        break;
    case ESP_GATTS_STOP_EVT:
        break;
    case ESP_GATTS_CONNECT_EVT: {
        esp_ble_conn_update_params_t conn_params = {0};
        memcpy(conn_params.bda, param->connect.remote_bda, sizeof(esp_bd_addr_t));
        /* For the IOS system, please reference the apple official documents about the ble connection parameters restrictions. */
        conn_params.latency = 0;
        conn_params.max_int = 0x20;    // max_int = 0x20*1.25ms = 40ms
        conn_params.min_int = 0x10;    // min_int = 0x10*1.25ms = 20ms
        conn_params.timeout = 400;    // timeout = 400*10ms = 4000ms
        ESP_LOGI(GATTS_TAG, "ESP_GATTS_CONNECT_EVT, conn_id %d, remote %02x:%02x:%02x:%02x:%02x:%02x:",
                 param->connect.conn_id,
                 param->connect.remote_bda[0], param->connect.remote_bda[1], param->connect.remote_bda[2],
                 param->connect.remote_bda[3], param->connect.remote_bda[4], param->connect.remote_bda[5]);
        gl_profile_tab[SERVICE_READ].conn_id = param->connect.conn_id;
        //start sent the update connection parameters to the peer device.
        esp_ble_gap_update_conn_params(&conn_params);
        //Start readvertising after Connection
        esp_ble_gap_start_advertising(&adv_params);
        break;
    }
    case ESP_GATTS_DISCONNECT_EVT:
        ESP_LOGI(GATTS_TAG, "ESP_GATTS_DISCONNECT_EVT_READ");
        esp_ble_gap_start_advertising(&adv_params);
        break;
    case ESP_GATTS_CONF_EVT:
        ESP_LOGI(GATTS_TAG, "ESP_GATTS_CONF_EVT, status %d", param->conf.status);
        if (param->conf.status != ESP_GATT_OK){
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

esp_gatt_if_t gatts_if_disconnect;
uint16_t connection_id;

static void gatts_profile_write_event_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
	switch (event) {
    case ESP_GATTS_REG_EVT:
        ESP_LOGI(GATTS_TAG, "REGISTER_APP_EVT_WRITE, status %d, app_id %d", param->reg.status, param->reg.app_id);
        gl_profile_tab[SERVICE_WRITE].service_id.is_primary = true;
        gl_profile_tab[SERVICE_WRITE].service_id.id.inst_id = 0x00;
        gl_profile_tab[SERVICE_WRITE].service_id.id.uuid.len = ESP_UUID_LEN_16;
        gl_profile_tab[SERVICE_WRITE].service_id.id.uuid.uuid.uuid16=GATTS_SERVICE_UUID_TEST_WRITE;

        //config adv data
        esp_err_t ret = esp_ble_gap_config_adv_data(&adv_data);
        if (ret){
            ESP_LOGE(GATTS_TAG, "config adv data failed, error code = %x", ret);
        }
        adv_config_done |= adv_config_flag;
        //config scan response data
        ret = esp_ble_gap_config_adv_data(&scan_rsp_data);
        if (ret){
            ESP_LOGE(GATTS_TAG, "config scan response data failed, error code = %x", ret);
        }
        adv_config_done |= scan_rsp_config_flag;

        esp_ble_gatts_create_service(gatts_if, &gl_profile_tab[SERVICE_WRITE].service_id, GATTS_NUM_HANDLE_WRITE);
        break;
    case ESP_GATTS_READ_EVT: {
        ESP_LOGI(GATTS_TAG, "GATT_READ_EVT_WRITE, conn_id %d, trans_id %d, handle %d\n", param->read.conn_id, param->read.trans_id, param->read.handle);
        gatts_check_callback(event, gatts_if, param);
        break;
    }
    case ESP_GATTS_WRITE_EVT: {
    	gatts_check_callback(event, gatts_if, param);
        break;
    }
    case ESP_GATTS_EXEC_WRITE_EVT:
        ESP_LOGI(GATTS_TAG,"ESP_GATTS_EXEC_WRITE_EVT_WRITE");
        esp_ble_gatts_send_response(gatts_if, param->write.conn_id, param->write.trans_id, ESP_GATT_OK, NULL);
        break;
    case ESP_GATTS_MTU_EVT:
        ESP_LOGI(GATTS_TAG, "ESP_GATTS_MTU_EVT, MTU %d", param->mtu.mtu);
        break;
    case ESP_GATTS_UNREG_EVT:
        break;
    case ESP_GATTS_CREATE_EVT:
        ESP_LOGD(GATTS_TAG, "CREATE_SERVICE_EVT_WRITE, status %d,  service_handle %d\n", param->create.status, param->create.service_handle);
        gl_profile_tab[SERVICE_WRITE].service_handle = param->create.service_handle;
        gl_profile_tab[SERVICE_WRITE].char_uuid.len = LIST_CHAR_WRITE[0].char_uuid.len;
        gl_profile_tab[SERVICE_WRITE].char_uuid.uuid.uuid16 = LIST_CHAR_WRITE[0].char_uuid.uuid.uuid16;

        esp_ble_gatts_start_service(gl_profile_tab[SERVICE_WRITE].service_handle);
        gatts_add_char_WRITE();
        break;
    case ESP_GATTS_ADD_INCL_SRVC_EVT:
        break;
    case ESP_GATTS_ADD_CHAR_EVT: {
    	        ESP_LOGI(GATTS_TAG, "ADD_CHAR_EVT_WRITE, status 0x%X,  attr_handle %d, service_handle %d\n",
    	                param->add_char.status, param->add_char.attr_handle, param->add_char.service_handle);
    	        gl_profile_tab[SERVICE_WRITE].char_handle = param->add_char.attr_handle;
    	        if (param->add_char.status==ESP_GATT_OK) {
    	        	gatts_check_add_char_WRITE(param->add_char.char_uuid,param->add_char.attr_handle);
    	        }
        break;
    }
    case ESP_GATTS_ADD_CHAR_DESCR_EVT:
        break;
    case ESP_GATTS_DELETE_EVT:
        break;
    case ESP_GATTS_START_EVT:
        ESP_LOGI(GATTS_TAG, "SERVICE_START_EVT_C, status %d, service_handle %d\n",
                 param->start.status, param->start.service_handle);
        break;
    case ESP_GATTS_STOP_EVT:
        break;
    case ESP_GATTS_CONNECT_EVT: {
        /*ESP_LOGI(GATTS_TAG, "CONNECT_EVT_WRITE, conn_id %d, remote %02x:%02x:%02x:%02x:%02x:%02x:",
                 param->connect.conn_id,
                 param->connect.remote_bda[0], param->connect.remote_bda[1], param->connect.remote_bda[2],
                 param->connect.remote_bda[3], param->connect.remote_bda[4], param->connect.remote_bda[5]);*/
        gl_profile_tab[SERVICE_WRITE].conn_id = param->connect.conn_id;

        connection_id=param->connect.conn_id;
        gatts_if_disconnect=gatts_if;
		if (UnitData.state == 0)
		{
			ESP_LOGI(GATTS_TAG, "Mode Manuel");
		}
		else
		{
			ESP_LOGI(GATTS_TAG, "Mode Auto");
		}
        xTaskCreatePinnedToCore(&check_pass, "check_pass", 4000, NULL, 3, NULL,1);
    }
        break;
    case ESP_GATTS_DISCONNECT_EVT:
        ESP_LOGI(GATTS_TAG, "ESP_GATTS_DISCONNECT_EVT_WRITE");
        esp_ble_gap_start_advertising(&adv_params);
        break;
    case ESP_GATTS_CONF_EVT:
        ESP_LOGI(GATTS_TAG, "ESP_GATTS_CONF_EVT_WRITE, status %d", param->conf.status);
        if (param->conf.status != ESP_GATT_OK){
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

static void gatts_event_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param)
{
    /* If event is register event, store the gatts_if for each profile */
    if (event == ESP_GATTS_REG_EVT) {
        if (param->reg.status == ESP_GATT_OK) {
            gl_profile_tab[param->reg.app_id].gatts_if = gatts_if;
        } else {
        	ESP_LOGD(GATTS_TAG, "Reg app failed, app_id %04x, status %d\n",
                    param->reg.app_id,
                    param->reg.status);
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

FtpConfig_Typedef FtpConfig;
MqttConfig_Typedef MqttConfig;

void check_pass()
{

	ESP_LOGI(GATTS_TAG, "CHECKING PASSWORD");

	vTaskDelay(2400 / portTICK_PERIOD_MS);

	char* diff=0;

	diff=strstr(UnitCfg.passBLE, "deliled");

	if (diff != NULL)
	{
		ESP_LOGI(GATTS_TAG, "CODE VALID");
	}
	else
	{
		ESP_LOGI(GATTS_TAG, "CODE ERROR");
		esp_ble_gatts_close(gatts_if_disconnect, connection_id);
	}

	sprintf(UnitCfg.passBLE,"NULL");
	SaveNVS(&UnitCfg);

	vTaskDelete(NULL);
}

int jsonparse(char *src,char *dst,char *label,unsigned short arrayindex)
{
	char *sp=0,*ep=0,*ic=0;;
	char tmp[64];

	sp=strstr(src,label);

	if (sp==NULL)
		{
			//ESP_LOGE(GATTS_TAG, "label %s not found",label);
			return(-1);
		}


	sp=strchr(sp,':');
	if (sp==NULL)
	{
		ESP_LOGE(GATTS_TAG, "value start not found");
		return(-1);
	}

        if (sp[1]=='"')
          {
            sp++;
            ep=strchr(sp+1,'"');
            ic=strchr(sp+1,',');
            if ((ep==NULL)||((ep>ic)&&(ic!=NULL)))
    		{
    			ESP_LOGE(GATTS_TAG, "type string parsing error");
    			return(-1);
    		}
          }
        else if (sp[1]=='[')
          {
            sp++;
            ep=strchr(sp+1,']');
            ic=strchr(sp+1,':');
            if ((ep==NULL)||((ep>ic)&&(ic!=NULL)))
    		{
    			ESP_LOGE(GATTS_TAG, "type array parsing error");
    			return(-1);
    		}

            ic=strchr(sp+1,',');
            if ((ic<ep)&&(ic!=NULL)) ep=ic;

            for (int i=0;i<arrayindex;i++)
            {
              sp=ep;
              ep=strchr(sp+1,',');

              if (ep==NULL)
              {
				  ic=strchr(sp+1,']');
				  ep=ic;
              }
            }

            if (sp[1]=='"')
            {
              sp++;
              ep=strchr(sp+1,'"');
            }
          }
        else
        {
           ep=strchr(sp+1,',');
           if (ep==NULL)  ep=strchr(sp+1,'}');
           ic=strchr(sp+1,':');
           if ((ep==NULL)||((ep>ic)&&(ic!=NULL)))
			{
				ESP_LOGE(GATTS_TAG, "type int parsing error");
				return(-1);
			}
        }

	strncpy(tmp,sp+1,ep-sp-1);
	tmp[ep-sp-1]=0;

	memset (dst,0x00,strlen(tmp)+1);
	memcpy(dst,tmp,strlen(tmp));

	return(0);
}

//bool first_summer=false;
bool timer_summer=false;
char strftime_buf[64];

bool AdvConfig()
{
	bool savenvsFlag=false;

	char tmp[64];

	uint32_t tmpis=0;

	ESP_LOGD(GATTS_TAG, "Parsing AdvConfig");

	printf("%s\r\n",config_json);

	if (jsonparse(config_json,UnitCfg.Email,"test",0)==0)
		{

		ESP_LOGD(GATTS_TAG, "testing with your email : %s",UnitCfg.Email);

		xTaskCreatePinnedToCore(&email_test_task, "email_test_task",16000 , NULL, 3, NULL,1);

		}

	if (jsonparse(config_json,UnitCfg.UnitName,"dname",0)==0)
		{
		ESP_LOGD(GATTS_TAG, "set device name");
			savenvsFlag = true;
		}

	if (jsonparse(config_json,UnitCfg.WifiCfg.WIFI_SSID,"wa",0)==0)
		{
		ESP_LOGD(GATTS_TAG, "set ap ssid %s",UnitCfg.WifiCfg.WIFI_SSID);

			if (jsonparse(config_json,UnitCfg.WifiCfg.WIFI_PASS,"wp",0)==0)
				{
				ESP_LOGD(GATTS_TAG, "set ap password %s",UnitCfg.WifiCfg.WIFI_PASS);
				}

			savenvsFlag = true;
		}


	if (jsonparse(config_json,tmp,"co2",0)==0)
		{
			UnitCfg.Co2LevelWarEnb = atoi(tmp);

			if (UnitCfg.Co2LevelWarEnb) ESP_LOGI(GATTS_TAG, "CO2 Warning Enabled");
							else ESP_LOGI(GATTS_TAG, "CO2 Warning Disabled");

			savenvsFlag = true;
		}

	if (jsonparse(config_json,tmp,"co2",1)==0)
		{

			UnitCfg.Co2LevelEmailEnb = atoi(tmp);
			if (UnitCfg.Co2LevelEmailEnb) {ESP_LOGI(GATTS_TAG, "Co2 notification email Enabled");}
							else ESP_LOGI(GATTS_TAG, "Co2 notification email Disabled");
			savenvsFlag = true;

		}

	if (jsonparse(config_json,UnitCfg.Email,"co2",2)==0)
		{

			ESP_LOGI(GATTS_TAG, "Co2 Alert Email : %s",UnitCfg.Email);
			savenvsFlag = true;

		}

	if (jsonparse(config_json,tmp,"co2",3)==0)
		{

			UnitCfg.Co2NotifyEnb = atoi(tmp);
			if (UnitCfg.Co2NotifyEnb) ESP_LOGI(GATTS_TAG, "Co2 notification mobile Enabled");
				else ESP_LOGI(GATTS_TAG, "Co2 notification mobile Disabled");
			savenvsFlag = true;

		}

	if (jsonparse(config_json,tmp,"co2",4)==0)
		{

			UnitCfg.Co2LevelZoneEnb = atoi(tmp);
			if (UnitCfg.Co2LevelZoneEnb) ESP_LOGI(GATTS_TAG, "Co2 notification par zone Enabled");
				else ESP_LOGI(GATTS_TAG, "Co2 notification par zone Disabled");
			savenvsFlag = true;

		}
	if (jsonparse(config_json,UnitCfg.Co2LevelSelect,"co2",5)==0)
		{
			ESP_LOGI(GATTS_TAG, "Co2 Zone Selection : %s",UnitCfg.Co2LevelSelect);

			savenvsFlag = true;
		}
	if (jsonparse(config_json,tmp,"co2",6)==0)
		{
			UnitCfg.Co2LevelWar = atoi(tmp);

			ESP_LOGI(GATTS_TAG, "Co2 Level : %d",UnitCfg.Co2LevelWar);

			savenvsFlag = true;
		}
	if (jsonparse(config_json,tmp,"pir",0)==0)
		{
			UnitCfg.PirSensitivity = atoi(tmp);
			ESP_LOGI(GATTS_TAG, "PIR Sensitivity %d",UnitCfg.PirSensitivity);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,tmp,"samples",0)==0)
		{
			UnitCfg.SAMPLES = atoi(tmp);
			ESP_LOGI(GATTS_TAG, "samples %d",UnitCfg.SAMPLES);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,tmp,"summer",0)==0)
	{
		//fputs(UnitCfg.first_summer ? "true" : "false", stdout);

		UnitCfg.first_summer=atoi(tmp);
		if (!WifiConnectedFlag)
		{
			ESP_LOGI(GATTS_TAG, "no internet , no changing time !");
		}
		else
		{
			if ((!(UnitCfg.summer_count))||(!(UnitCfg.Summer_time==UnitCfg.first_summer)))
			{
				UnitCfg.Summer_time = atoi(tmp);
				if (UnitCfg.Summer_time)
				{
					if (!timer_summer)
					{
						ESP_LOGI(GATTS_TAG, "Summer time is Enabled");
						struct timeval tv;
						gettimeofday(&tv, NULL);
						tv.tv_sec += 3600;
						settimeofday(&tv, NULL);
						timer_summer=true;
					}
				}
				else
				{
					if (timer_summer)
					{
						ESP_LOGI(GATTS_TAG, "Summer time is Disabled");
						struct timeval tv;
						gettimeofday(&tv, NULL);
						tv.tv_sec -= 3600;
						settimeofday(&tv, NULL);
						timer_summer=false;
					}
				}
			}
		}
		time_t t = time(NULL);
		struct tm tm = *localtime(&t);
		strftime(strftime_buf, sizeof(strftime_buf), "%c", &tm);
		ESP_LOGI(GATTS_TAG, "The current date/time is: %s",strftime_buf);
		savenvsFlag = true;
		}
	if (jsonparse(config_json,tmp,"tz",0)==0)
		{
			char *sp=0;

			sp=strchr(tmp,'+');
			if (sp==NULL) sp=strchr(tmp,'-');

			if (sp!=NULL)
			{
				UnitCfg.UnitTimeZone = atoi(sp);
				ESP_LOGI(GATTS_TAG, "TZ %d",UnitCfg.UnitTimeZone);
				savenvsFlag = true;
			}

		}

	// ftp
	if (jsonparse(config_json,tmp,"ftp",0)==0)
		{
			UnitCfg.FtpConfig.FtpLogEnb = atoi(tmp);

			if (UnitCfg.FtpConfig.FtpLogEnb) ESP_LOGI(GATTS_TAG, "FTP Log Enabled");
				else ESP_LOGI(GATTS_TAG, "FTP Log Disabled");

			savenvsFlag = true;
		}
	if (jsonparse(config_json,UnitCfg.FtpConfig.Server,"ftp",1)==0)
		{
		ESP_LOGI(GATTS_TAG, "Ftp Server %s",UnitCfg.FtpConfig.Server);
			savenvsFlag = true;
		}

	if (jsonparse(config_json,tmp,"ftp",2)==0)
		{
			UnitCfg.FtpConfig.Port = atoi(tmp);
			ESP_LOGI(GATTS_TAG, "Ftp Server port %d",UnitCfg.FtpConfig.Port);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,UnitCfg.FtpConfig.UserName,"ftp",3)==0)
		{
		ESP_LOGI(GATTS_TAG, "Ftp Server Username %s",UnitCfg.FtpConfig.UserName);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,UnitCfg.FtpConfig.Password,"ftp",4)==0)
		{
		ESP_LOGI(GATTS_TAG, "Ftp Server Password %s",UnitCfg.FtpConfig.Password);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,UnitCfg.FtpConfig.Client_id,"ftp",5)==0)
		{
		ESP_LOGI(GATTS_TAG, "Ftp Server Client ID %s",UnitCfg.FtpConfig.Client_id);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,tmp,"ftp",6)==0)
		{
			UnitCfg.FtpConfig.ftp_now_or_later = atoi(tmp);
			if (UnitCfg.FtpConfig.ftp_now_or_later ) ESP_LOGI(GATTS_TAG, "FTP is sending every period");
				else ESP_LOGI(GATTS_TAG, "FTP is sending every day");
			savenvsFlag = true;
		}
	if (jsonparse(config_json,tmp,"ftp",7)==0)
		{
			UnitCfg.FtpConfig.FtpTimeout_send = atoi(tmp);
			ESP_LOGI(GATTS_TAG, "Ftp Server Timeout sending %d",UnitCfg.FtpConfig.FtpTimeout_send);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,tmp,"ftp",8)==0)
		{
			tmpis=atoi(tmp);
			UnitCfg.FtpConfig.ftp_send  = ((tmpis/100)*3600)+((tmpis%100)*60);
			ESP_LOGI(GATTS_TAG, "Ftp Server sending Trig value %ld",UnitCfg.FtpConfig.ftp_send);
			savenvsFlag = true;
		}

	// ip
	if (jsonparse(config_json,tmp,"IP_STATIC",0)==0)
		{
			UnitCfg.Static_IP.Enable = atoi(tmp);

			if (UnitCfg.Static_IP.Enable) ESP_LOGI(GATTS_TAG, "IP STATIC Enabled");
				else ESP_LOGI(GATTS_TAG, "IP STATIC Disabled");

			savenvsFlag = true;
		}
	if (jsonparse(config_json,UnitCfg.Static_IP.IP,"IP_STATIC",1)==0)
		{
		ESP_LOGI(GATTS_TAG, "IP :  %s",UnitCfg.Static_IP.IP);
				savenvsFlag = true;
		}

	if (jsonparse(config_json,UnitCfg.Static_IP.MASK,"IP_STATIC",2)==0)
		{
		ESP_LOGI(GATTS_TAG, "MASK :  %s",UnitCfg.Static_IP.MASK);
				savenvsFlag = true;
			}
	if (jsonparse(config_json,UnitCfg.Static_IP.GATE_WAY,"IP_STATIC",3)==0)
		{
		ESP_LOGI(GATTS_TAG, "Gate Way : %s",UnitCfg.Static_IP.GATE_WAY);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,UnitCfg.Static_IP.DNS_SERVER,"IP_STATIC",4)==0)
		{
		ESP_LOGI(GATTS_TAG, "DNS : %s",UnitCfg.Static_IP.DNS_SERVER);
			savenvsFlag = true;
		}

	//mqtt
	if (jsonparse(config_json,tmp,"mqtt",0)==0)
		{
			UnitCfg.MqttConfig.MqttLogEnb = atoi(tmp);

			if (UnitCfg.MqttConfig.MqttLogEnb) ESP_LOGI(GATTS_TAG, "Mqtt Log Enabled");
				else ESP_LOGI(GATTS_TAG, "Mqtt Log Disabled");

			savenvsFlag = true;
		}
	if (jsonparse(config_json,UnitCfg.MqttConfig.Server,"mqtt",1)==0)
		{
		ESP_LOGI(GATTS_TAG, "Mqtt Server %s",UnitCfg.MqttConfig.Server);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,tmp,"mqtt",2)==0)
		{
			UnitCfg.MqttConfig.Port = atoi(tmp);
			ESP_LOGI(GATTS_TAG, "Mqtt Server port %d",UnitCfg.MqttConfig.Port);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,UnitCfg.MqttConfig.UserName,"mqtt",3)==0)
		{
		ESP_LOGI(GATTS_TAG, "Mqtt Server Username %s",UnitCfg.MqttConfig.UserName);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,UnitCfg.MqttConfig.Password,"mqtt",4)==0)
		{
		ESP_LOGI(GATTS_TAG, "Mqtt Server Password %s",UnitCfg.MqttConfig.Password);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,UnitCfg.MqttConfig.Topic,"mqtt",5)==0)
		{
		ESP_LOGI(GATTS_TAG, "Mqtt Topic %s",UnitCfg.MqttConfig.Topic);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,UnitCfg.MqttConfig.sousTopic,"mqtt",6)==0)
		{
		ESP_LOGI(GATTS_TAG, "Mqtt sousTopic %s",UnitCfg.MqttConfig.sousTopic);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,tmp,"mqtt",7)==0)
		{
			UnitCfg.MqttConfig.TopicTimeout = atoi(tmp);
			ESP_LOGI(GATTS_TAG, "Mqtt Server timeout %d",UnitCfg.MqttConfig.TopicTimeout);
			savenvsFlag = true;
		}
	//udp
	if (jsonparse(config_json,tmp,"UDP",0)==0)
		{
		UnitCfg.UDPConfig.Enable = atoi(tmp);

			if (UnitCfg.UDPConfig.Enable) ESP_LOGI(GATTS_TAG, "UDP Log Enabled");
				else ESP_LOGI(GATTS_TAG, "UDP Log Disabled");

			savenvsFlag = true;
		}
	if (jsonparse(config_json,tmp,"UDP",1)==0)
		{
		UnitCfg.UDPConfig.ipv4_ipv6 = atoi(tmp);

			if (UnitCfg.UDPConfig.Enable) ESP_LOGI(GATTS_TAG, "UDP IPV6 Enabled");
				else ESP_LOGI(GATTS_TAG, "UUDP IPV4 Enabled");

			savenvsFlag = true;
		}
	if (jsonparse(config_json,UnitCfg.UDPConfig.Server,"UDP",2)==0)
		{
		ESP_LOGI(GATTS_TAG, "UDP Server %s",UnitCfg.UDPConfig.Server);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,tmp,"UDP",3)==0)
		{
			UnitCfg.UDPConfig.Port= atoi(tmp);
			ESP_LOGI(GATTS_TAG, "UDP Server port %d",UnitCfg.UDPConfig.Port);
			savenvsFlag = true;
		}
	// time

	time_t t=0;
	uint32_t tz=0;

	if (jsonparse(config_json,tmp,"Time",0)==0)
		{
			time_t tl=0;
			struct tm ti;

			time(&tl);
			localtime_r(&tl, &ti);

			if (ti.tm_year<(2016-1900))
			{
				t=atoi(tmp);
				ESP_LOGI(GATTS_TAG, "Time sync epoch %ld",t);

				if (jsonparse(config_json,tmp,"Time",1)==0)
				{
					tz=atoi(tmp);
					ESP_LOGI(GATTS_TAG, "Time zone %d",tz/3600);
					GattSyncTime(t,tz);
					savenvsFlag = true;
				}
			}
			else
				ESP_LOGI(GATTS_TAG, "Time sync ignored");
		}

	return(savenvsFlag);
}

bool ProfileConfig()
{

	bool savenvsFlag=false;

	char tmp[64];
	uint32_t tmpi=0;

	//mode
	if (jsonparse(config_json,tmp,"mode",0)==0)
	{

		if (strcmp(tmp, "auto") == 0)
		{
			UnitData.state=1;
			UnitCfg.MODE=1;
		}
		else
		{
			UnitData.state=0;
			UnitCfg.MODE=0;
		}
		savenvsFlag = true;
	}


	//profile

	if (jsonparse(config_json,UnitCfg.UserLcProfile.profile_name,"profilenumber",0)==0)
		{

		ESP_LOGI(GATTS_TAG, "User custom name set %s",UnitCfg.UserLcProfile.profile_name);
		savenvsFlag = true;
		
		}
	if (jsonparse(config_json,UnitCfg.UserLcProfile.name,"pname",0)==0)
		{

		ESP_LOGI(GATTS_TAG, "User profile name set %s",UnitCfg.UserLcProfile.name);
		savenvsFlag = true;
		
		}

	if (jsonparse(config_json,tmp,"pdata",0)==0)
		{

		UnitCfg.UserLcProfile.AutoTrigTimeEnb = atoi(tmp);
				if (UnitCfg.UserLcProfile.AutoTrigTimeEnb) ESP_LOGI(GATTS_TAG, "Triger Time is Enabled");
					else ESP_LOGI(GATTS_TAG, "Triger Time is Disabled");
				savenvsFlag = true;

		}
	if (jsonparse(config_json,UnitCfg.UserLcProfile.Trig_days,"pdata",1)==0)
		{

		ESP_LOGI(GATTS_TAG, "User profile trig days set %s",UnitCfg.UserLcProfile.Trig_days);
				savenvsFlag = true;

		}
	if (jsonparse(config_json,UnitCfg.UserLcProfile.Trig_zone,"pdata",2)==0)
			{

			ESP_LOGI(GATTS_TAG, "User profile trig zone set %s",UnitCfg.UserLcProfile.Trig_zone);
					savenvsFlag = true;

			}
	if (jsonparse(config_json,tmp,"pdata",3)==0)
		{

		tmpi=atoi(tmp);
		UnitCfg.UserLcProfile.AutoTrigTime = ((tmpi/100)*3600)+((tmpi%100)*60);
		ESP_LOGI(GATTS_TAG, "Time Auto Trig value %ld",UnitCfg.UserLcProfile.AutoTrigTime);
		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"pdata",4)==0)
		{

		UnitCfg.UserLcProfile.AutoStopTimeEnb = atoi(tmp);
				if (UnitCfg.UserLcProfile.AutoStopTimeEnb) ESP_LOGI(GATTS_TAG, "STOP Time is Enabled");
					else ESP_LOGI(GATTS_TAG, "STOP Time is Disabled");
				savenvsFlag = true;

		}
	if (jsonparse(config_json,UnitCfg.UserLcProfile.Stop_days,"pdata",5)==0)
		{

		ESP_LOGI(GATTS_TAG, "User profile stop days set %s",UnitCfg.UserLcProfile.Stop_days);
				savenvsFlag = true;

		}
	if (jsonparse(config_json,UnitCfg.UserLcProfile.Stop_zone,"pdata",6)==0)
			{

			ESP_LOGI(GATTS_TAG, "User profile stop zone set %s",UnitCfg.UserLcProfile.Stop_zone);
					savenvsFlag = true;

			}


	if (jsonparse(config_json,tmp,"pdata",7)==0)
		{

		tmpi=atoi(tmp);
		UnitCfg.UserLcProfile.AutoStopTime = ((tmpi/100)*3600)+((tmpi%100)*60);
		ESP_LOGI(GATTS_TAG, "Time Auto stop value %ld",UnitCfg.UserLcProfile.AutoStopTime);
		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"lum",0)==0)
		{
		LumTestEnb = false;
		UnitCfg.UserLcProfile.AutoBrEnb = atoi(tmp);
		if (UnitCfg.UserLcProfile.AutoBrEnb)
		{
			ESP_LOGI(GATTS_TAG, "Auto brightness regulator Enabled");
		}
		else
		{
			ESP_LOGI(GATTS_TAG, "Auto brightness regulator Disabled");
		}
		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"lum",1)==0)
		{

		UnitCfg.UserLcProfile.AutoBrRef = atoi(tmp);
		ESP_LOGI(GATTS_TAG, "Auto brighness regulator reference value %d",UnitCfg.UserLcProfile.AutoBrRef);
		savenvsFlag = true;

		}
	if (jsonparse(config_json,UnitCfg.UserLcProfile.Zone_lum,"lum",2)==0)
		{

		ESP_LOGI(GATTS_TAG, "Brightness zone is %s",UnitCfg.UserLcProfile.Zone_lum);
		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"lum",3)==0)
		{

		UnitCfg.UserLcProfile.FixedBrLevel_zone1 = atoi(tmp);
		ESP_LOGI(GATTS_TAG, " brighness ZONE 1 reference value %d",UnitCfg.UserLcProfile.FixedBrLevel_zone1);
		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"lum",4)==0)
		{

		UnitCfg.UserLcProfile.FixedBrLevel_zone2 = atoi(tmp);
		ESP_LOGI(GATTS_TAG, " brighness ZONE 2 reference value %d",UnitCfg.UserLcProfile.FixedBrLevel_zone2);
		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"lum",5)==0)
		{

		UnitCfg.UserLcProfile.FixedBrLevel_zone3 = atoi(tmp);
		ESP_LOGI(GATTS_TAG, " brighness ZONE 3 reference value %d",UnitCfg.UserLcProfile.FixedBrLevel_zone3);
		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"lum",6)==0)
		{
		
		UnitCfg.UserLcProfile.FixedBrLevel_zone4 = atoi(tmp);
		ESP_LOGI(GATTS_TAG, " brighness ZONE 4 reference value %d",UnitCfg.UserLcProfile.FixedBrLevel_zone4);
		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"lum",7)==0)
		{

		UnitCfg.UserLcProfile.FixedBrLevel_zone_010v = atoi(tmp);
		ESP_LOGI(GATTS_TAG, " brighness ZONE 0/10V reference value %d",UnitCfg.UserLcProfile.FixedBrLevel_zone_010v);
		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"lum",8)==0)
		{

		UnitCfg.UserLcProfile.seuil_eclairage = atoi(tmp);
		if (UnitCfg.UserLcProfile.seuil_eclairage) ESP_LOGI(GATTS_TAG, "Lighting threshold Enabled");
			else ESP_LOGI(GATTS_TAG, "Lighting threshold Disabled");
		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"veille",0)==0)
		{
		
		UnitCfg.UserLcProfile.Alum_Exten_enb = atoi(tmp);
		if (UnitCfg.UserLcProfile.Alum_Exten_enb) ESP_LOGI(GATTS_TAG, "Allum /extenx brighness regulator Enabled");
			else ESP_LOGI(GATTS_TAG, "Allum /extenx brighness regulator Disabled");
		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"veille",1)==0)
		{

		UnitCfg.UserLcProfile.PIRBrEnb = atoi(tmp);
		if (UnitCfg.UserLcProfile.PIRBrEnb) ESP_LOGI(GATTS_TAG, "PIR brighness regulator Enabled");
			else ESP_LOGI(GATTS_TAG, "PIR brighness regulator Disabled");
		savenvsFlag = true;
	
		}
	if (jsonparse(config_json,tmp,"veille",2)==0)
		{
		
		tmpi=atoi(tmp);
		UnitCfg.UserLcProfile.PirTimeout = ((tmpi/100)*3600)+((tmpi%100)*60);
		ESP_LOGI(GATTS_TAG, "PIR timeout value %ld",UnitCfg.UserLcProfile.PirTimeout);
		savenvsFlag = true;

		}
	if (jsonparse(config_json,UnitCfg.UserLcProfile.PIR_days,"veille",3)==0)
		{

		ESP_LOGI(GATTS_TAG, "PIR days set %s",UnitCfg.UserLcProfile.PIR_days);

		savenvsFlag = true;

		}
	if (jsonparse(config_json,UnitCfg.UserLcProfile.PIR_zone,"veille",4)==0)
		{

		ESP_LOGI(GATTS_TAG, "PIR zone set %s",UnitCfg.UserLcProfile.PIR_zone);

		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"cycle",0)==0)
		{

		CCTestStruct.CcEnb=false;
		UnitCfg.UserLcProfile.CcEnb = atoi(tmp);
		if (UnitCfg.UserLcProfile.CcEnb) ESP_LOGI(GATTS_TAG, "Circadien cycle Enabled");
			else ESP_LOGI(GATTS_TAG, "Circadien cycle Disabled");
		savenvsFlag = true;

		}
	if (jsonparse(config_json,UnitCfg.UserLcProfile.ZoneCc,"cycle",1)==0)
		{

		ESP_LOGI(GATTS_TAG, "Cycle Circadien zone set %s",UnitCfg.UserLcProfile.ZoneCc);

		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"cycle",2)==0)
		{

		tmpi=atoi(tmp);
		UnitCfg.UserLcProfile.Ccp[0].CcTime = ((tmpi/100)*3600)+((tmpi%100)*60);
		ESP_LOGI(GATTS_TAG, "Circadien cycle P1 time %ld",UnitCfg.UserLcProfile.Ccp[0].CcTime);
		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"cycle",3)==0)
		{

		UnitCfg.UserLcProfile.Ccp[0].CcLevel = atoi(tmp);
		ESP_LOGI(GATTS_TAG, "Circadien cycle P1 value %d",UnitCfg.UserLcProfile.Ccp[0].CcLevel);
		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"cycle",4)==0)
		{

		tmpi=atoi(tmp);
		UnitCfg.UserLcProfile.Ccp[1].CcTime = ((tmpi/100)*3600)+((tmpi%100)*60);
		ESP_LOGI(GATTS_TAG, "Circadien cycle P2 time %ld",UnitCfg.UserLcProfile.Ccp[1].CcTime);
		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"cycle",5)==0)
		{

		UnitCfg.UserLcProfile.Ccp[1].CcLevel = atoi(tmp);
		ESP_LOGI(GATTS_TAG, "Circadien cycle P2 value %d",UnitCfg.UserLcProfile.Ccp[1].CcLevel);
		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"cycle",6)==0)
		{

		tmpi=atoi(tmp);
		UnitCfg.UserLcProfile.Ccp[2].CcTime = ((tmpi/100)*3600)+((tmpi%100)*60);
		ESP_LOGI(GATTS_TAG, "Circadien cycle P3 time %ld",UnitCfg.UserLcProfile.Ccp[2].CcTime);
		savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"cycle",7)==0)
		{

		UnitCfg.UserLcProfile.Ccp[2].CcLevel = atoi(tmp);
		ESP_LOGI(GATTS_TAG, "Circadien cycle P3 value %d",UnitCfg.UserLcProfile.Ccp[2].CcLevel);
		savenvsFlag = true;

		}
		
	return(savenvsFlag);
}

bool ColorConfig (){

	bool savenvsFlag=false;

	char tmp[64];

		//Couleur 1

	if (jsonparse(config_json,UnitCfg.ColortrProfile[0].name,"couleur1",0)==0)
		{

		ESP_LOGD(GATTS_TAG, "Profile Color name set %s",UnitCfg.ColortrProfile[0].name);
			savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"couleur1",1)==0)
		{
			UnitCfg.ColortrProfile[0].blanche = atoi(tmp);
			ESP_LOGD(GATTS_TAG, "Profile Color WHITE set %d",UnitCfg.ColortrProfile[0].blanche);
			savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"couleur1",2)==0)
		{
			UnitCfg.ColortrProfile[0].Rouge = atoi(tmp);
			ESP_LOGD(GATTS_TAG, "Profile Color Rouge set %d",UnitCfg.ColortrProfile[0].Rouge);
			savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"couleur1",3)==0)
		{
			UnitCfg.ColortrProfile[0].Vert = atoi(tmp);
			ESP_LOGD(GATTS_TAG, "Profile Color Vert set %d",UnitCfg.ColortrProfile[0].Vert);
			savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"couleur1",4)==0)
		{
			UnitCfg.ColortrProfile[0].Bleu = atoi(tmp);
			ESP_LOGD(GATTS_TAG, "Profile Color Bleu set %d",UnitCfg.ColortrProfile[0].Bleu);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,UnitCfg.ColortrProfile[0].zone,"couleur1",5)==0)
		{

		ESP_LOGD(GATTS_TAG, "Profile Color zone set %s",UnitCfg.ColortrProfile[0].zone);
			savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"couleur1",6)==0)
		{
			UnitCfg.ColortrProfile[0].intensity = atoi(tmp);
			ESP_LOGD(GATTS_TAG, "Profile Color intensity set %d",UnitCfg.ColortrProfile[0].intensity);
			savenvsFlag = true;
		}
	
		//Couleur 2

	if (jsonparse(config_json,UnitCfg.ColortrProfile[1].name,"couleur2",0)==0)
		{

			ESP_LOGD(GATTS_TAG, "Profile Color name set %s",UnitCfg.ColortrProfile[1].name);
			savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"couleur2",1)==0)
		{
			UnitCfg.ColortrProfile[1].blanche = atoi(tmp);
			ESP_LOGD(GATTS_TAG, "Profile Color WHITE set %d",UnitCfg.ColortrProfile[1].blanche);
			savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"couleur2",2)==0)
		{
			UnitCfg.ColortrProfile[1].Rouge = atoi(tmp);
			ESP_LOGD(GATTS_TAG, "Profile Color Rouge set %d",UnitCfg.ColortrProfile[1].Rouge);
			savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"couleur2",3)==0)
		{
			UnitCfg.ColortrProfile[1].Vert = atoi(tmp);
			ESP_LOGD(GATTS_TAG, "Profile Color Vert set %d",UnitCfg.ColortrProfile[1].Vert);
			savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"couleur2",4)==0)
		{
			UnitCfg.ColortrProfile[1].Bleu = atoi(tmp);
			ESP_LOGD(GATTS_TAG, "Profile Color Bleu set %d",UnitCfg.ColortrProfile[1].Bleu);
			savenvsFlag = true;
		}
	if (jsonparse(config_json,UnitCfg.ColortrProfile[1].zone,"couleur2",5)==0)
		{

		ESP_LOGD(GATTS_TAG, "Profile Color zone set %s",UnitCfg.ColortrProfile[1].zone);
			savenvsFlag = true;

		}
	if (jsonparse(config_json,tmp,"couleur2",6)==0)
		{
			UnitCfg.ColortrProfile[1].intensity = atoi(tmp);
			ESP_LOGD(GATTS_TAG, "Profile Color intensity set %d",UnitCfg.ColortrProfile[1].intensity);
			savenvsFlag = true;
		}
	//Zonnage

	if (jsonparse(config_json,UnitCfg.Zones.ZONE_1,"zones",0)==0)
	{

		ESP_LOGI(GATTS_TAG, "zone 1 is %s",UnitCfg.Zones.ZONE_1);
		savenvsFlag = true;

	}
	if (jsonparse(config_json,UnitCfg.Zones.ZONE_2,"zones",1)==0)
	{

		ESP_LOGI(GATTS_TAG, "zone 2 is %s",UnitCfg.Zones.ZONE_2);
		savenvsFlag = true;

	}
	if (jsonparse(config_json,UnitCfg.Zones.ZONE_3,"zones",2)==0)
	{

		ESP_LOGI(GATTS_TAG, "zone 3 is %s",UnitCfg.Zones.ZONE_3);
		savenvsFlag = true;

	}
	if (jsonparse(config_json,UnitCfg.Zones.ZONE_4,"zones",3)==0)
	{

		ESP_LOGI(GATTS_TAG, "zone 4 is %s",UnitCfg.Zones.ZONE_4);
		savenvsFlag = true;

	}


return(savenvsFlag);
}

void configParserTask()
{

	bool savenvsFlag=false;

	savenvsFlag=AdvConfig()|ProfileConfig()|ColorConfig();

	if (savenvsFlag)
	{
		SaveNVS(&UnitCfg);
	}

	free(config_json);
	vTaskDelete(NULL);
}


typedef struct
{
	uint8_t Hue;
	uint8_t Sat;
	uint8_t Bri;
}HSLStruct;

void RgbToHSL(uint32_t rgb,HSLStruct *tmp)
{

	float R=0,G=0,B=0;;
	uint8_t  r=0,g=0,b=0;

	r = rgb>>16;
	g = rgb>>8;
	b = rgb;

	R = r / 255.0;
	G = g / 255.0;
	B = b / 255.0;

	float min=1000,max=0;
	char cmax='R';

	if (max<R) {max=R;cmax='R';}
	if (max<G) {max=G;cmax='G';}
	if (max<B) {max=B;cmax='B';}

	if (min>R) min=R;
	if (min>G) min=G;
	if (min>B) min=B;

	float Hue=0;

	switch(cmax)
	{
		case 'R': Hue = (G-B)/(max-min);break;
		case 'G': Hue = 2.0 + (B-R)/(max-min);break;
		case 'B': Hue = 4.0 + (R-G)/(max-min);break;
	}

	Hue*=60;
	if (Hue<0) Hue+=360;

	Hue/=360;

	tmp->Hue=255*Hue;

	float lum=((min+max)/2)*100;
	tmp->Bri=lum;

	float sat=0;
	if (lum>50) sat= ( max-min)/(2.0-max-min);
	else sat=(max-min)/(max+min);
	sat*=100;
	tmp->Sat=sat;

}

#include "ota_check.h"
#include "esp_ota_ops.h"

void lightParserTask()
{
	char tmp[32];
	uint8_t cmd=0,subcmd=0,zone=0;
	uint8_t SelFav=0;
	uint8_t i=0;
	HSLStruct HSLtmp;

	//favoris
	if (jsonparse(light_json,tmp,"Favoris",0)==0)
	{
		xTaskCreate(&curl_get_task, "curl_get_task", 8000, NULL, 3, NULL);
		//xTaskCreatePinnedToCore(&checking_ota, "checking_ota", 5500, NULL, 1, NULL,1);
		for (i=0;i<4;i++)
		{
			if (strcmp(tmp,UnitCfg.ColortrProfile[i].name)==0)
			{
				ESP_LOGI(GATTS_TAG, "Color of Profil %d : %s is selected ",i+1,UnitCfg.ColortrProfile[i].name);
				SelFav=i;
				break;
			}
		}

		uint32_t rgb=UnitCfg.ColortrProfile[SelFav].Rouge*0x10000+UnitCfg.ColortrProfile[SelFav].Vert*0x100+UnitCfg.ColortrProfile[SelFav].Bleu;

		if (rgb!=0)
		{
			RgbToHSL(rgb,&HSLtmp);
			subcmd=HSLtmp.Hue;
			cmd=3;
		}
		else
		{
			subcmd=UnitCfg.ColortrProfile[SelFav].blanche;
			cmd=8;
		}

		if (jsonparse(light_json,tmp,"Favoris",1)==0)
		{
			zone =  strtol(tmp,NULL,16);
			MilightHandler(cmd,subcmd,zone);
			ESP_LOGD(GATTS_TAG, "Light control cmd %d subcmd %d zone %d",cmd,subcmd,zone);
		}
		if (jsonparse(light_json,tmp,"Favoris",2)==0)
		{
			cmd=7;
			subcmd = atoi(tmp);
			MilightHandler(cmd,subcmd,zone);
			ESP_LOGD(GATTS_TAG, "Light control cmd %d subcmd %d zone %d",cmd,subcmd,zone);
		}
	}
	//selecting_fav
	if (jsonparse(light_json,tmp,"rgb",0)==0)
	{
		uint32_t rgb= atoi(tmp);
		if (rgb!=0)
		{
			RgbToHSL(rgb,&HSLtmp);
			subcmd=HSLtmp.Hue;
			cmd=3;
		}
	}
	if (jsonparse(light_json,tmp,"rgb",1)==0)
	{
		zone =  strtol(tmp,NULL,16);
		MilightHandler(cmd,subcmd,zone);
	}
	//seuil
	if (jsonparse(light_json,tmp,"seuil",0)==0)
	{
		UnitCfg.UserLcProfile.seuil_eclairage = atoi(tmp);
		if (UnitCfg.UserLcProfile.seuil_eclairage) {ESP_LOGI(GATTS_TAG, "Lighting threshold Enabled");}
			else {ESP_LOGI(GATTS_TAG, "Lighting threshold Disabled");}
	}
	// zone lum
	if (jsonparse(light_json,UnitCfg.UserLcProfile.Zone_lum,"zone_lum",0)==0)
	{

		ESP_LOGI(GATTS_TAG, "Brightness zone is %s",UnitCfg.UserLcProfile.Zone_lum);

	}

	//light_zone
		if (jsonparse(light_json,tmp,"light_zone",0)==0)
		{

			cmd = atoi(tmp);

			if (jsonparse(light_json,tmp,"light_zone",1)==0)
			{
				subcmd = atoi(tmp);
			}
			if (jsonparse(light_json,tmp,"light_zone",2)==0)
			{
				//sprintf(UnitCfg.UserLcProfile.Zone_lum,tmp);
				zone = strtol(tmp,NULL,16);
			}
			if (jsonparse(light_json,tmp,"light_zone",3)==0)
				{
				UnitCfg.UserLcProfile.seuil_eclairage = atoi(tmp);
				if (UnitCfg.UserLcProfile.seuil_eclairage) {ESP_LOGI(GATTS_TAG, "Lighting threshold Enabled");}
					else {ESP_LOGI(GATTS_TAG, "Lighting threshold Disabled");}

				}
			if (zone ==1)
			{
				UnitData.auto_zone_1=subcmd;
				UnitCfg.UserLcProfile.FixedBrLevel_zone1=subcmd;
			}
			if (zone ==2)
			{
				UnitData.auto_zone_2=subcmd;
				UnitCfg.UserLcProfile.FixedBrLevel_zone2=subcmd;
			}
			if (zone ==4)
			{
				UnitData.auto_zone_3=subcmd;
				UnitCfg.UserLcProfile.FixedBrLevel_zone3=subcmd;
			}
			if (zone ==8)
			{
				UnitData.auto_zone_4=subcmd;
				UnitCfg.UserLcProfile.FixedBrLevel_zone4=subcmd;
			}
			if (zone ==16)
			{
				UnitData.auto_zone_010V=subcmd;
				UnitCfg.UserLcProfile.FixedBrLevel_zone_010v=subcmd;
				dac_output_voltage(DAC_CHANNEL_1, subcmd);
			}
			MilightHandler(cmd,subcmd,zone&0x0F);
			ESP_LOGI(GATTS_TAG, "Light control cmd %d subcmd %d zone %d",cmd,subcmd,zone);
		}

	//light
	if (jsonparse(light_json,tmp,"light",0)==0)
	{
		cmd = atoi(tmp);

		if (jsonparse(light_json,tmp,"light",1)==0)
		{
			subcmd = atoi(tmp);
		}
		if (jsonparse(light_json,tmp,"light",2)==0)
		{
			zone = strtol(tmp,NULL,16);
		}

		// On/Off

		if ((cmd==LCMD_SWITCH_ON_OFF)&&(zone!=0))
		{
			MilightHandler(LCMD_SWITCH_ON_OFF,subcmd,zone&0x0F);
		}
		//radio
		MilightHandler(cmd,subcmd,zone&0x0F);

		//0-10
		if (zone&0x10)
		{
			if (cmd == LCMD_SWITCH_ON_OFF)
			{
				if (subcmd==LSUBCMD_SWITCH_ON)
				{
					dac_output_voltage(DAC_CHANNEL_1, 255);
					ESP_LOGI(GATTS_TAG, "dac off 10V ");
					DacLightStatOn=true;
				}
				else if (subcmd==LSUBCMD_SWITCH_OFF)
				{
					dac_output_voltage(DAC_CHANNEL_1, 0);
					ESP_LOGI(GATTS_TAG, "dac off 0V ");
					DacLightStatOn=false;
				}
			}
			uint16_t dac_out=(subcmd*255)/100;
			if ((cmd==LCMD_SET_BRIGTHNESS)&&(DacLightStatOn==true))
				dac_output_voltage(DAC_CHANNEL_1, dac_out);
		}

		ESP_LOGI(GATTS_TAG, "Light control manu cmd %d subcmd %d zone %d",cmd,subcmd,zone);
	}
	else if (jsonparse(light_json,tmp,"hue",0)==0)
	{
		uint32_t rgb=0;

		rgb=strtol(tmp,NULL,16);
		RgbToHSL(rgb,&HSLtmp);


		if (jsonparse(light_json,tmp,"zone",0)==0)
		{
			zone = strtol(tmp,NULL,16);
		}

		// apply hue
		cmd=3;
		subcmd=HSLtmp.Hue;
		MilightHandler(cmd,subcmd,zone&0xF);
		ESP_LOGD(GATTS_TAG, "Light control cmd %d subcmd %d zone %d",cmd,subcmd,zone);

		// Temp
		//AutoCCTaskExit=true;
/*
		// apply brightness
		cmd=7;
		subcmd=HSLtmp.Bri;
		MilightHandler(cmd,subcmd,zone);
		ESP_LOGI(GATTS_TAG, "Light control cmd %d subcmd %d zone %d",cmd,subcmd,zone);
		// apply saturation
		cmd=9;
		subcmd=HSLtmp.Sat;
		MilightHandler(cmd,subcmd,zone);
		ESP_LOGI(GATTS_TAG, "Light control cmd %d subcmd %d zone %d",cmd,subcmd,zone);
*/

	}

	//test lum
	if (jsonparse(light_json,tmp,"lumtest",0)==0)
	{
		LumTestEnb=true;
	}
	//test cycle circ.
	if (jsonparse(light_json,CCTestStruct.ZoneCc,"cctest",0)==0)
	{

		uint32_t tmpi=0;

		ESP_LOGI(GATTS_TAG, "Test mode config");

		if (jsonparse(light_json,tmp,"cctest",1)==0)
		{
			tmpi=atoi(tmp);
			CCTestStruct.Ccp[0].CcTime = ((tmpi/100)*3600)+((tmpi%100)*60);
			ESP_LOGI(GATTS_TAG, "Circadien cycle P1 time %ld",CCTestStruct.Ccp[0].CcTime);
		}
		if (jsonparse(light_json,tmp,"cctest",2)==0)
		{
			CCTestStruct.Ccp[0].CcLevel = atoi(tmp);
			ESP_LOGI(GATTS_TAG, "Circadien cycle P1 value %d",CCTestStruct.Ccp[0].CcLevel);
		}
		if (jsonparse(light_json,tmp,"cctest",3)==0)
		{
			tmpi=atoi(tmp);
			CCTestStruct.Ccp[1].CcTime = ((tmpi/100)*3600)+((tmpi%100)*60);
			ESP_LOGI(GATTS_TAG, "Circadien cycle P2 time %ld",CCTestStruct.Ccp[1].CcTime);
		}
		if (jsonparse(light_json,tmp,"cctest",4)==0)
		{
			CCTestStruct.Ccp[1].CcLevel = atoi(tmp);
			ESP_LOGI(GATTS_TAG, "Circadien cycle P2 value %d",CCTestStruct.Ccp[1].CcLevel);
		}
		if (jsonparse(light_json,tmp,"cctest",5)==0)
		{
			tmpi=atoi(tmp);
			CCTestStruct.Ccp[2].CcTime = ((tmpi/100)*3600)+((tmpi%100)*60);
			ESP_LOGI(GATTS_TAG, "Circadien cycle P3 time %ld",CCTestStruct.Ccp[2].CcTime);
		}
		if (jsonparse(light_json,tmp,"cctest",6)==0)
		{
			CCTestStruct.Ccp[2].CcLevel = atoi(tmp);
			ESP_LOGI(GATTS_TAG, "Circadien cycle P3 value %d",CCTestStruct.Ccp[2].CcLevel);
		}
		if (jsonparse(light_json,tmp,"cctest",7)==0)
		{
			CCTestStruct.SimTime = atoi(tmp);
			ESP_LOGI(GATTS_TAG, "Circadien cycle Sim Time %d",CCTestStruct.SimTime);
		}

		CCTestStruct.CcEnb=true;
	}

	//system
	if (jsonparse(light_json,tmp,"system",0)==0)
	{
		uint8_t sys_subcmd = atoi(tmp);

		if (sys_subcmd==0)
		{
			ESP_LOGI(GATTS_TAG, "System apply default setting");

			uint8_t mac[6];
			esp_efuse_mac_get_default(mac);

			sprintf(UnitCfg.UnitName,"MAESTRO-%02X:%02X:%02X",mac[3],mac[4],mac[5]);

			sprintf(UnitCfg.UserLcProfile.name,"Bureau");
			sprintf(UnitCfg.UserLcProfile.profile_name,"PROFILE_1");
			sprintf(UnitCfg.UserLcProfile.Trig_days,"0");
			UnitCfg.UserLcProfile.Alum_Exten_enb = false;
			sprintf(UnitCfg.UserLcProfile.Trig_zone,"0");
			UnitCfg.UserLcProfile.PIRBrEnb = false;
			sprintf(UnitCfg.UserLcProfile.Stop_days,"0");
			sprintf(UnitCfg.UserLcProfile.Stop_zone,"0");
			sprintf(UnitCfg.UserLcProfile.PIR_days,"0");
			sprintf(UnitCfg.UserLcProfile.PIR_zone,"0");
			UnitCfg.UserLcProfile.seuil_eclairage =false;
			UnitCfg.UserLcProfile.AutoTrigTime = 0;
			UnitCfg.UserLcProfile.AutoTrigTimeEnb = false;
			UnitCfg.UserLcProfile.AutoStopTimeEnb = false;
			UnitCfg.UserLcProfile.AutoStopTime = 0;
			UnitCfg.UserLcProfile.PirTimeout = 0;
			UnitCfg.UserLcProfile.AutoBrEnb = false;
			UnitCfg.UserLcProfile.AutoBrRef = 0;
			sprintf(UnitCfg.UserLcProfile.Zone_lum,"0");
			UnitCfg.UserLcProfile.FixedBrLevel_zone1 = 0;
			UnitCfg.UserLcProfile.FixedBrLevel_zone2 = 0;
			UnitCfg.UserLcProfile.FixedBrLevel_zone3 = 0;
			UnitCfg.UserLcProfile.FixedBrLevel_zone4 = 0;
			UnitCfg.UserLcProfile.FixedBrLevel_zone_010v = 0;

			UnitCfg.UserLcProfile.CcEnb = false;
			sprintf(UnitCfg.UserLcProfile.ZoneCc,"0");
			UnitCfg.UserLcProfile.Ccp[0].CcLevel = 0;
			UnitCfg.UserLcProfile.Ccp[0].CcTime = 0;
			UnitCfg.UserLcProfile.Ccp[1].CcLevel = 0;
			UnitCfg.UserLcProfile.Ccp[1].CcTime = 0;
			UnitCfg.UserLcProfile.Ccp[2].CcLevel = 0;
			UnitCfg.UserLcProfile.Ccp[2].CcTime = 0;

			sprintf(UnitCfg.ColortrProfile[0].name,"Ambiance1");
			UnitCfg.ColortrProfile[0].blanche=50;
			UnitCfg.ColortrProfile[0].Rouge=0;
			UnitCfg.ColortrProfile[0].Vert=0;
			UnitCfg.ColortrProfile[0].Bleu=0;
			UnitCfg.ColortrProfile[0].intensity=0;
			sprintf(UnitCfg.ColortrProfile[0].zone,"0");
			sprintf(UnitCfg.ColortrProfile[1].name,"Ambiance2");
			UnitCfg.ColortrProfile[1].blanche=50;
			UnitCfg.ColortrProfile[1].Rouge=0;
			UnitCfg.ColortrProfile[1].Vert=0;
			UnitCfg.ColortrProfile[1].Bleu=0;
			UnitCfg.ColortrProfile[1].intensity=0;
			sprintf(UnitCfg.ColortrProfile[1].zone,"0");
			UnitCfg.Co2NotifyEnb=true;
			UnitData.state=0;

			sprintf(UnitCfg.WifiCfg.WIFI_SSID,"ssid");
			sprintf(UnitCfg.WifiCfg.WIFI_PASS,"password");

			UnitCfg.Co2LevelWarEnb = false;
			UnitCfg.Co2LevelEmailEnb = false;
			sprintf(UnitCfg.Email,"delitech.alert@gmail.com");
			UnitCfg.Co2NotifyEnb = false;
			UnitCfg.Co2LevelZoneEnb = false;
			sprintf(UnitCfg.Co2LevelSelect,"a");
			UnitCfg.Co2LevelWar= 1500;

			UnitCfg.PirSensitivity = 500;
			UnitCfg.UnitTimeZone = 0;

			UnitCfg.FtpConfig.FtpLogEnb = false;
			sprintf(UnitCfg.FtpConfig.Server,"ftpserver");
			UnitCfg.FtpConfig.Port = 21;
			sprintf(UnitCfg.FtpConfig.UserName,"ftpuser");
			sprintf(UnitCfg.FtpConfig.Password,"ftppassword");
			sprintf(UnitCfg.FtpConfig.Client_id,"client_1");
			UnitCfg.FtpConfig.ftp_now_or_later = false;
			UnitCfg.FtpConfig.FtpTimeout_send=0;
			UnitCfg.FtpConfig.ftp_send=0;

			UnitCfg.MqttConfig.MqttLogEnb = false;
			sprintf(UnitCfg.MqttConfig.Server,"mqttserver");
			UnitCfg.FtpConfig.Port = 80;
			sprintf(UnitCfg.MqttConfig.UserName,"mqttuser");
			sprintf(UnitCfg.MqttConfig.Password,"mqttpassword");
			sprintf(UnitCfg.MqttConfig.Topic,"mqtttopic");
			sprintf(UnitCfg.MqttConfig.sousTopic,"all");
			UnitCfg.MqttConfig.TopicTimeout = 0;
			UnitCfg.Summer_time=false;
			UnitCfg.first_summer=false;

			UnitCfg.Static_IP.Enable=false;
			sprintf(UnitCfg.Static_IP.IP,"192.168.1.22");
			sprintf(UnitCfg.Static_IP.MASK,"255.255.255.0");
			sprintf(UnitCfg.Static_IP.GATE_WAY,"192.168.1.254");
			sprintf(UnitCfg.Static_IP.DNS_SERVER,"8.8.8.8");

			UnitCfg.UDPConfig.Enable=false;
			UnitCfg.UDPConfig.ipv4_ipv6=false; //default ipv4
			sprintf(UnitCfg.UDPConfig.Server,"192.168.1.22");
			UnitCfg.UDPConfig.Port=3333;

			sprintf(UnitCfg.Zones.ZONE_1,"Zone 1");
			sprintf(UnitCfg.Zones.ZONE_2,"Zone 2");
			sprintf(UnitCfg.Zones.ZONE_3,"Zone 3");
			sprintf(UnitCfg.Zones.ZONE_4,"Zone 4");

			SaveNVS(&UnitCfg);
		}
		else
		{
			//xTaskCreate(&https_get_task, "https_get_task", 6100, NULL, 5, NULL);
			//xTaskCreate(&curl_get_task, "curl_get_task", 9100, NULL, 3, NULL);

			ESP_LOGI(GATTS_TAG, "System restart");
			esp_restart();
		}

	}

	//update
	if (jsonparse(light_json,tmp,"update",0)==0)
	{
		uint8_t sys_subcmd = atoi(tmp);

		if (sys_subcmd==0)
		{
			ESP_LOGI(GATTS_TAG, "UPDATE request has been received");

			xTaskCreatePinnedToCore(&ota_task, "ota_task",8000 , NULL, 3, NULL,1);

		}

	}

	//pass
	if (jsonparse(light_json,UnitCfg.passBLE,"pass",0)==0)
	{
		ESP_LOGI(GATTS_TAG, "SETTING PASS");
		//SaveNVS(&UnitCfg);
	}

	//color
	if (jsonparse(light_json,tmp,"couleur",0)==0)
	{
		uint8_t sys_subcmd = atoi(tmp);

		if (sys_subcmd==0)
		{
			ESP_LOGI(GATTS_TAG, "color apply default setting");

			sprintf(UnitCfg.ColortrProfile[0].name,"Ambiance1");
			UnitCfg.ColortrProfile[0].blanche=50;
			UnitCfg.ColortrProfile[0].Rouge=0;
			UnitCfg.ColortrProfile[0].Vert=0;
			UnitCfg.ColortrProfile[0].Bleu=0;
			UnitCfg.ColortrProfile[0].intensity=0;
			sprintf(UnitCfg.ColortrProfile[0].zone,"0");
			sprintf(UnitCfg.ColortrProfile[1].name,"Ambiance2");
			UnitCfg.ColortrProfile[1].blanche=50;
			UnitCfg.ColortrProfile[1].Rouge=0;
			UnitCfg.ColortrProfile[1].Vert=0;
			UnitCfg.ColortrProfile[1].Bleu=0;
			UnitCfg.ColortrProfile[1].intensity=0;
			sprintf(UnitCfg.ColortrProfile[1].zone,"0");

			SaveNVS(&UnitCfg);

		}
	}


	//profils
	if (jsonparse(light_json,tmp,"profile_init",0)==0)
	{
		uint8_t sys_subcmd = atoi(tmp);

		if (sys_subcmd==0)
		{
			ESP_LOGI(GATTS_TAG, "profil apply default setting");

			sprintf(UnitCfg.UserLcProfile.name,"Bureau");
			sprintf(UnitCfg.UserLcProfile.profile_name,"PROFILE_1");
			UnitCfg.UserLcProfile.Alum_Exten_enb = false;
			sprintf(UnitCfg.UserLcProfile.Trig_days,"0");
			sprintf(UnitCfg.UserLcProfile.Trig_zone,"0");
			UnitCfg.UserLcProfile.PIRBrEnb = false;
			sprintf(UnitCfg.UserLcProfile.Stop_days,"0");
			sprintf(UnitCfg.UserLcProfile.Stop_zone,"0");
			sprintf(UnitCfg.UserLcProfile.PIR_days,"0");
			sprintf(UnitCfg.UserLcProfile.PIR_zone,"0");
			UnitCfg.UserLcProfile.seuil_eclairage =false;
			UnitCfg.UserLcProfile.AutoTrigTime = 0;
			UnitCfg.UserLcProfile.AutoTrigTimeEnb = false;
			UnitCfg.UserLcProfile.AutoStopTimeEnb = false;
			UnitCfg.UserLcProfile.AutoStopTime = 0;
			UnitCfg.UserLcProfile.PirTimeout = 0;
			UnitCfg.UserLcProfile.AutoBrEnb = false;
			UnitCfg.UserLcProfile.AutoBrRef = 0;
			sprintf(UnitCfg.UserLcProfile.Zone_lum,"0");
			UnitCfg.UserLcProfile.FixedBrLevel_zone1 = 0;
			UnitCfg.UserLcProfile.FixedBrLevel_zone2 = 0;
			UnitCfg.UserLcProfile.FixedBrLevel_zone3 = 0;
			UnitCfg.UserLcProfile.FixedBrLevel_zone4 = 0;
			UnitCfg.UserLcProfile.FixedBrLevel_zone_010v = 0;

			UnitCfg.UserLcProfile.CcEnb = false;
			sprintf(UnitCfg.UserLcProfile.ZoneCc,"0");
			UnitCfg.UserLcProfile.Ccp[0].CcLevel = 0;
			UnitCfg.UserLcProfile.Ccp[0].CcTime = 0;
			UnitCfg.UserLcProfile.Ccp[1].CcLevel = 0;
			UnitCfg.UserLcProfile.Ccp[1].CcTime = 0;
			UnitCfg.UserLcProfile.Ccp[2].CcLevel = 0;
			UnitCfg.UserLcProfile.Ccp[2].CcTime = 0;

			UnitCfg.Co2LevelWarEnb = false;
			UnitCfg.Co2LevelEmailEnb = false;
			sprintf(UnitCfg.Email,"delitech.alert@gmail.com");
			UnitCfg.Co2NotifyEnb = false;
			UnitCfg.Co2LevelZoneEnb = false;
			sprintf(UnitCfg.Co2LevelSelect,"a");
			UnitCfg.Co2LevelWar= 1500;

			SaveNVS(&UnitCfg);
		}

	}

	free(light_json);
	vTaskDelete(NULL);
}


void GattSyncTime(time_t t,uint32_t tzone)
{
    struct tm tm_time;
	struct timeval tv_time ;
	time_t epoch=t;
	char strftime_buf[64];

	//set timezone

    char tz[10];
    int32_t tzc=0;

    tzc=tzone/3600;

    if (tzc==0)
    	sprintf(tz,"GMT0");
    else if (tzc<0)
    	sprintf(tz,"<GMT%" PRIi8 ">%" PRIi8 "",abs(tzc),abs(tzc));
    else
    	sprintf(tz,"<GMT+%" PRIi8 ">-%" PRIi8 "",abs(tzc),abs(tzc));

    setenv("TZ",tz, 1);
    tzset();

    // set time
	tv_time.tv_sec=epoch;
	tv_time.tv_usec=0;

	settimeofday(&tv_time,0);

	time(&epoch);

	localtime_r(&epoch, &tm_time);
	strftime(strftime_buf, sizeof(strftime_buf), "%c", &tm_time);
	ESP_LOGE(GATTS_TAG, "The current date/time UTC is: %s", strftime_buf);
}

void GattsInit()
{

	UnitData.UpdateInfo=0;

    esp_err_t ret;

    ESP_ERROR_CHECK(esp_bt_controller_mem_release(ESP_BT_MODE_CLASSIC_BT));

    esp_bt_controller_config_t bt_cfg = BT_CONTROLLER_INIT_CONFIG_DEFAULT();
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
    if (ret){
        ESP_LOGE(GATTS_TAG, "gatts register error, error code = %x", ret);
        return;
    }
    ret = esp_ble_gap_register_callback(gap_event_handler);
    if (ret){
        ESP_LOGE(GATTS_TAG, "gap register error, error code = %x", ret);
        return;
    }
    ret = esp_ble_gatts_app_register(SERVICE_READ);
    if (ret){
        ESP_LOGE(GATTS_TAG, "gatts app register error, error code = %x", ret);
        return;
    }
    ret = esp_ble_gatts_app_register(SERVICE_WRITE);
    if (ret){
        ESP_LOGE(GATTS_TAG, "gatts app register error, error code = %x", ret);
        return;
    }
    esp_err_t local_mtu_ret = esp_ble_gatt_set_local_mtu(512);
    if (local_mtu_ret)
    {
        ESP_LOGE(GATTS_TAG, "set local  MTU failed, error code = %x", local_mtu_ret);
    }

    return;
}
