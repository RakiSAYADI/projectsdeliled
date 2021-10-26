#include <string.h>
#include <time.h>
#include <sys/time.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_event.h"
#include "esp_log.h"
#include "esp_attr.h"
#include "esp_sleep.h"
#include "nvs_flash.h"
#include "esp_sntp.h"

#include "webservice.h"
#include "unitcfg.h"

const char *TAG_SNTP = "SNTP";

bool sntpTimeSetFlag = false;
time_t sntp_now = 0;
struct tm sntp_timeinfo = {0};

void sntp_task()
{
    ESP_LOGI(TAG_SNTP, "stnp task Started");

    if (WifiConnectedFlag)
    {

        time(&sntp_now);
        localtime_r(&sntp_now, &sntp_timeinfo);
        // Is time set? If not, tm_year will be (1970 - 1900).
        if (sntp_timeinfo.tm_year < (2016 - 1900))
        {
            ESP_LOGI(TAG_SNTP, "Time is not set yet. Connecting to WiFi and getting time over NTP.");

            ESP_LOGI(TAG_SNTP, "Initializing SNTP");
            sntp_setoperatingmode(SNTP_OPMODE_POLL);
            sntp_setservername(0, "pool.ntp.org");
            sntp_init();

            // wait for time to be set

            int retry = 0;
            const int retry_count = 10;
            while (sntp_timeinfo.tm_year < (2016 - 1900) && ++retry < retry_count)
            {
                ESP_LOGI(TAG_SNTP, "Waiting for system time to be set... (%d/%d)", retry, retry_count);
                vTaskDelay(2000 / portTICK_PERIOD_MS);
                time(&sntp_now);
                localtime_r(&sntp_now, &sntp_timeinfo);
            }

            // update 'now' variable with current time
            time(&sntp_now);
        }
        // Set timezone to Eastern Standard Time and print local time
        char strftime_buf[64];
        char tz[50];

        // Tunisia time zone
        sprintf(tz, "UTC+%d", abs(UnitCfg.UnitTimeZone));

        // France time zone
        sprintf(tz, "CET-%dCEST-%d,M3.5.0/02:00:00,M10.5.0/03:00:00", abs(UnitCfg.UnitTimeZone), abs(UnitCfg.UnitTimeZone) + 1);

        setenv("TZ", tz, 1);
        tzset();
        localtime_r(&sntp_now, &sntp_timeinfo);
        strftime(strftime_buf, sizeof(strftime_buf), "%c", &sntp_timeinfo);
        ESP_LOGI(TAG_SNTP, "The current date/time in Timezone GMT %d [%s] is: %s", UnitCfg.UnitTimeZone, tz, strftime_buf);

        sntpTimeSetFlag = true;

        sntp_stop();
    }

    vTaskDelete(NULL);
}
