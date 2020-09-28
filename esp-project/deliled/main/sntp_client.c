/*
 * sntp_client.c
 *
 *  Created on: Dec 26, 2018
 *      Author: mdt
 */

#include <string.h>
#include <time.h>
#include <sys/time.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event_loop.h"
#include "esp_log.h"
#include "nvs_flash.h"

#include "lwip/err.h"
#include "lwip/apps/sntp.h"

#include "sdkconfig.h"
#include "unitcfg.h"
#include "webservice.h"

const char *TAG_SNTP = "SNTP_CLIENT";

bool sntpTimeSetFlag = false;
time_t sntp_now = 0;
struct tm sntp_timeinfo = { 0 };

void sntp_task() {

	ESP_LOGI(TAG_SNTP, "stnp task Started");

	while (WifiConnectedFlag == false) {
		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}

	time(&sntp_now);
	localtime_r(&sntp_now, &sntp_timeinfo);
	// Is time set? If not, tm_year will be (1970 - 1900).
	if (sntp_timeinfo.tm_year < (2016 - 1900)) {
		ESP_LOGI(TAG_SNTP,
				"Time is not set yet. Connecting to WiFi and getting time over NTP.");

		ESP_LOGI(TAG_SNTP, "Initializing SNTP");
		sntp_setoperatingmode(SNTP_OPMODE_POLL);
		sntp_setservername(0, "pool.ntp.org");
		sntp_init();

		// wait for time to be set

		int retry = 0;
		const int retry_count = 10;
		while (sntp_timeinfo.tm_year < (2016 - 1900) && ++retry < retry_count) {
			ESP_LOGI(TAG_SNTP, "Waiting for system time to be set... (%d/%d)",
					retry, retry_count);
			vTaskDelay(2000 / portTICK_PERIOD_MS);
			time(&sntp_now);
			localtime_r(&sntp_now, &sntp_timeinfo);
		}

		// update 'now' variable with current time
		time(&sntp_now);
	}
	char strftime_buf[64];

	// Set timezone to Eastern Standard Time and print local time

	char tz[10];

	if (UnitCfg.Summer_time) {
		if (UnitCfg.UnitTimeZone == 0) {
			sprintf(tz, "GMT0");
		} else if (UnitCfg.UnitTimeZone < 0) {
			sprintf(tz, "<GMT%d>%d", abs(UnitCfg.UnitTimeZone),
					abs(UnitCfg.UnitTimeZone));
		} else {
			sprintf(tz, "<GMT+%d>-%d", abs(UnitCfg.UnitTimeZone),
					abs(UnitCfg.UnitTimeZone));
		}
		setenv("TZ", tz, 1);
		tzset();
		ESP_LOGI(TAG_SNTP, "Summer time is Enabled");
		struct timeval tv;
		gettimeofday(&tv, NULL);
		tv.tv_sec += 3600;
		settimeofday(&tv, NULL);
		UnitCfg.summer_count = true;
		time_t t = time(NULL);
		struct tm tm = *localtime(&t);
		strftime(strftime_buf, sizeof(strftime_buf), "%c", &tm);
		ESP_LOGI(TAG_SNTP, "The current date/time is: %s", strftime_buf);
	} else {
		UnitCfg.summer_count = false;
		if (UnitCfg.UnitTimeZone == 0) {
			sprintf(tz, "GMT0");
		} else if (UnitCfg.UnitTimeZone < 0) {
			sprintf(tz, "<GMT%d>%d", abs(UnitCfg.UnitTimeZone),
					UnitCfg.UnitTimeZone);
		} else {
			sprintf(tz, "<GMT+%d>-%d", abs(UnitCfg.UnitTimeZone),
					UnitCfg.UnitTimeZone);
		}
		setenv("TZ", tz, 1);
		tzset();
	}

	setenv("TZ", tz, 1);
	tzset();
	localtime_r(&sntp_now, &sntp_timeinfo);
	strftime(strftime_buf, sizeof(strftime_buf), "%c", &sntp_timeinfo);
	ESP_LOGI(TAG_SNTP, "The current date/time in Timezone GMT %d [%s] is: %s",
			UnitCfg.UnitTimeZone, tz, strftime_buf);

	sntpTimeSetFlag = true;

	//sntp_enabled();

	sntp_stop();

	vTaskDelete(NULL);
}
