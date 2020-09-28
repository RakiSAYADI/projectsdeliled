/*
 * mqtt_client.c
 *
 *  Created on: Dec 26, 2018
 *      Author: mdt
 */

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include "esp_wifi.h"
#include "esp_system.h"
#include "nvs_flash.h"
#include "esp_event_loop.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/semphr.h"
#include "freertos/queue.h"
#include "freertos/event_groups.h"

#include "lwip/sockets.h"
#include "lwip/dns.h"
#include "lwip/netdb.h"

#include "esp_log.h"
#include "mqtt_client.h"

#include "webservice.h"
#include "mqttclient.h"
#include "unitcfg.h"
#include "sntp_client.h"
#include "sdkconfig.h"

static const char *TAG = "MQTT_CLIENT";

esp_mqtt_client_handle_t client;
int msg_id;

void Mqtt_Send() {

	char txt[256];

	uint8_t mac[6];
	char mactxt[20];
	esp_efuse_mac_get_default(mac);
	sprintf(mactxt,"%02X%02X%02X%02X%02X%02X",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);

	ESP_LOGI(TAG, "mqtt send task start");

	while (1) {

        localtime_r(&UnitData.UpdateTime, &sntp_timeinfo);
        localtime_r(&UnitData.LastDetTime, &sntp_timeinfo);

		sprintf(txt,"{\"uid\":\"%s\",\"data\":[%ld,%0.1f,%0.1f,%d,%d,%d,%d,%ld]}",mactxt,UnitData.UpdateTime,UnitData.Temp,UnitData.Humidity,UnitData.Als,UnitData.aq_Co2Level
					,UnitData.aq_Tvoc,UnitData.aq_status,UnitData.LastDetTime);


        msg_id = esp_mqtt_client_publish(client, UnitCfg.MqttConfig.Topic, txt, strlen(txt), 0, 0);
        vTaskDelay(10000 / portTICK_PERIOD_MS);

        if ((WifiConnectedFlag==false)||(UnitCfg.MqttConfig.MqttLogEnb==false))
        {
        	xTaskCreatePinnedToCore(&mqtt_app_start, "mqtt_app_start", 4000, NULL, 1, NULL,1);
        	vTaskDelete(NULL);
        }
	}
}



static esp_err_t mqtt_event_handler(esp_mqtt_event_handle_t event)
{
	client = event->client;

    // your_context_t *context = event->context;
    switch (event->event_id) {
        case MQTT_EVENT_CONNECTED:
            printf("%s:MQTT_EVENT_CONNECTED\r\n",TAG);
            msg_id = esp_mqtt_client_subscribe(client, UnitCfg.MqttConfig.Topic, 1);
            printf("%s:sent subscribe successful, msg_id=%d\r\n",TAG,msg_id);
            break;
        case MQTT_EVENT_DISCONNECTED:
            ESP_LOGE(TAG, "MQTT_EVENT_DISCONNECTED");
            break;

        case MQTT_EVENT_SUBSCRIBED:
            printf("%s:MQTT_EVENT_SUBSCRIBED, msg_id=%d\r\n",TAG,event->msg_id);
            xTaskCreatePinnedToCore(&Mqtt_Send, "Mqtt_Send", 4000, NULL, 1, NULL,1);
            break;
        case MQTT_EVENT_UNSUBSCRIBED:
            ESP_LOGE(TAG, "MQTT_EVENT_UNSUBSCRIBED, msg_id=%d", event->msg_id);
            break;
        case MQTT_EVENT_PUBLISHED:
            ESP_LOGI(TAG, "MQTT_EVENT_PUBLISHED, msg_id=%d", event->msg_id);
            break;
        case MQTT_EVENT_DATA:
            ESP_LOGI(TAG, "MQTT_EVENT_DATA Topic:%.*s Data:%.*s",event->topic_len, event->topic,event->data_len, event->data);
            break;
        case MQTT_EVENT_ERROR:
            ESP_LOGE(TAG, "MQTT_EVENT_ERROR");
            break;

        default :
        	break;
    }
    return ESP_OK;
}

void mqtt_app_start()
{

	uint8_t mac[6];
	char mactxt[20];

	esp_efuse_mac_get_default(mac);
	sprintf(mactxt,"%02X%02X%02X%02X%02X%02X",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);

	ESP_LOGI(TAG, "mqtt task Started");

    while((WifiConnectedFlag==false)||(sntpTimeSetFlag==false)||(UnitCfg.MqttConfig.MqttLogEnb==false))
    {
    	vTaskDelay(1000 / portTICK_PERIOD_MS);
    }

    esp_mqtt_client_config_t mqtt_cfg = {
        .event_handle = mqtt_event_handler,
		//.host = "m16.cloudmqtt.com",
		//.port = 12052,
		//.username = "leeyzyeq",
		//.password = "VFBvS6lAWOLU"
    };

    esp_log_level_set(TAG, ESP_LOG_INFO);

    mqtt_cfg.host=(const char*)&UnitCfg.MqttConfig.Server;
    mqtt_cfg.username=(const char*)&UnitCfg.MqttConfig.UserName;
    mqtt_cfg.password=(const char*)&UnitCfg.MqttConfig.Password;
    mqtt_cfg.port=UnitCfg.MqttConfig.Port;
    mqtt_cfg.client_id = (const char*)&UnitCfg.UnitName;

    esp_mqtt_client_handle_t client = esp_mqtt_client_init(&mqtt_cfg);
    esp_mqtt_client_start(client);

    vTaskDelete(NULL);
}

