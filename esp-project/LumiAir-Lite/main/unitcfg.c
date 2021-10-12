#include "esp_log.h"
#include "string.h"
#include "stdio.h"
#include "esp_err.h"
#include "esp_event.h"
#include "nvs.h"
#include "nvs_flash.h"
#include "stdlib.h"

#include "sdkconfig.h"

#include "unitcfg.h"

const char *NVS_TAG = "NVS";

UnitConfig_Typedef UnitCfg;
UnitData_Typedef UnitData;

#define UNITCFG_NAMESPACE "unitcfgnvs"
#define KEY_CONNECTION_INFO "unitcfg"
#define KEY_VERSION "key"
#define KEY_VERSION_VAL 0x01

bool SaveNVS(UnitConfig_Typedef *data)
{
	nvs_handle handle;
	esp_err_t err = ESP_FAIL;

	err = nvs_open(UNITCFG_NAMESPACE, NVS_READWRITE, &handle);

	if (err != ESP_OK)
	{
		ESP_LOGE(NVS_TAG, "nvs_open: %x", err);
		return false;
	}

	err = nvs_set_blob(handle, KEY_CONNECTION_INFO, data,
					   sizeof(UnitConfig_Typedef));

	if (err != ESP_OK)
	{
		ESP_LOGE(NVS_TAG, "Error Setting NVS Blob (%d).", err);
		nvs_close(handle);
		return false;
	}

	err = nvs_set_u32(handle, KEY_VERSION, KEY_VERSION_VAL);

	if (err != ESP_OK)
	{
		ESP_LOGE(NVS_TAG, "Error Setting Key version (%d).", err);
		nvs_close(handle);
		return false;
	}

	err = nvs_commit(handle);

	if (err != ESP_OK)
	{
		ESP_LOGE(NVS_TAG, "Error Writing NVS (%d).", err);
		nvs_close(handle);
		return false;
	}

	nvs_close(handle);

	ESP_LOGI(NVS_TAG, "Configuration saved");

	return true;
}

bool LoadNVS(UnitConfig_Typedef *data)
{
	nvs_handle handle;
	size_t size;
	esp_err_t err;
	uint32_t version;

	err = nvs_open(UNITCFG_NAMESPACE, NVS_READWRITE, &handle);

	if (err != 0)
	{
		ESP_LOGE(NVS_TAG, "nvs_open: %x", err);
		return false;
	}

	err = nvs_get_u32(handle, KEY_VERSION, &version);
	if (err != ESP_OK)
	{
		ESP_LOGE(NVS_TAG, "Incompatible versions (%d).", err);
		nvs_close(handle);
		return false;
	}

	size = sizeof(UnitConfig_Typedef);
	err = nvs_get_blob(handle, KEY_CONNECTION_INFO, data, &size);

	if (err != ESP_OK)
	{
		ESP_LOGE(NVS_TAG, "No Unit config record found (%d)", err);
		nvs_close(handle);
		return false;
	}

	nvs_close(handle);

	//ESP_LOGI("NVS", "Configuration Loaded (%d) bytes",size);

	ESP_LOGI(NVS_TAG, "Configuration Loaded (%d) bytes", sizeof(UnitCfg));

	return true;
}

bool InitLoadCfg()
{
	if (!LoadNVS(&UnitCfg))
	{
		Default_saving();
	}
	else
	{
		ESP_LOGI(NVS_TAG, "Unit Config Loading OK");
	}

	return true;
}

void Default_saving()
{
	sprintf(UnitCfg.UnitName, "Lumiair-Lite");

	UnitCfg.UserLcProfile.CcEnb = false;
	sprintf(UnitCfg.UserLcProfile.ZoneCc, "F");

	UnitCfg.UserLcProfile.Ccp[0].CcLevel = 100;
	UnitCfg.UserLcProfile.Ccp[0].CcTime = 28800;
	UnitCfg.UserLcProfile.Ccp[1].CcLevel = 0;
	UnitCfg.UserLcProfile.Ccp[1].CcTime = 43200;
	UnitCfg.UserLcProfile.Ccp[2].CcLevel = 100;
	UnitCfg.UserLcProfile.Ccp[2].CcTime = 61200;

	for (int i = 0; i < 4; i++)
	{
		sprintf(UnitCfg.Zones_info[i].zonename, "Zone %d", i + 1);

		sprintf(UnitCfg.ColortrProfile[i].ambname, "Ambiance%d", i + 1);
		sprintf(UnitCfg.ColortrProfile[i].Hue, "000000");
		sprintf(UnitCfg.ColortrProfile[i].zone, "F");
	}

	UnitData.state = 0;

	sprintf(UnitCfg.WifiCfg.WIFI_SSID, "ssid");
	sprintf(UnitCfg.WifiCfg.WIFI_PASS, "password");

	UnitCfg.Co2LevelWarEnb = false;
	UnitCfg.Co2LevelEmailEnb = false;
	sprintf(UnitCfg.Email, "exemple@mail.com");
	UnitCfg.Co2NotifyEnb = false;
	UnitCfg.Co2LevelZoneEnb = false;
	sprintf(UnitCfg.Co2LevelSelect, "0");
	UnitCfg.Co2LevelWar = 1500;

	UnitCfg.PirSensitivity = 500;
	UnitCfg.UnitTimeZone = 0;

	sprintf(UnitCfg.FLASH_MEMORY, "OK");

	if (SaveNVS(&UnitCfg))
	{
		ESP_LOGI(NVS_TAG, "Unit Config saving OK");
	}
	else
	{
		ESP_LOGE(NVS_TAG, "Unit Config saving NOT OK");
	}
}

void syncTime(time_t t, uint32_t tzone)
{
	struct tm tm_time;
	struct timeval tv_time;
	time_t epoch = t;
	char strftime_buf[64];

	//set timezone

	char tz[10];
	int8_t tzc = 0;

	tzc = tzone / 3600;

	if (tzc == 0)
	{
		sprintf(tz, "CET0");
	}
	else if (tzc < 0)
	{
		sprintf(tz, "CET%d", tzc);
	}
	else
	{
		sprintf(tz, "CET-%d", tzc);
	}

	setenv("TZ", tz, 1);
	tzset();

	// set time
	tv_time.tv_sec = epoch;
	tv_time.tv_usec = 0;

	settimeofday(&tv_time, 0);

	time(&epoch);

	localtime_r(&epoch, &tm_time);
	strftime(strftime_buf, sizeof(strftime_buf), "%c", &tm_time);
	ESP_LOGW(NVS_TAG, "The current date/time UTC is: %s", strftime_buf);
}
