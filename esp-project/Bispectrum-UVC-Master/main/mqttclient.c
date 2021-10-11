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
#include "esp_event.h"
#include "tcpip_adapter.h"
#include "mqtt_client.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/semphr.h"
#include "freertos/queue.h"
#include "freertos/event_groups.h"

#include "lwip/sockets.h"
#include "lwip/dns.h"
#include "lwip/netdb.h"

#include "esp_log.h"

#include "webservice.h"
#include "mqttclient.h"
#include "unitcfg.h"
#include "sntp_client.h"
#include "sdkconfig.h"

static const char *TAG = "MQTT_CLIENT";

esp_mqtt_client_handle_t client;
int msg_id;

uint8_t strContains(char* string, char* toFind) {
	uint8_t slen = strlen(string);
	uint8_t tFlen = strlen(toFind);
	uint8_t found = 0;

	if (slen >= tFlen) {
		for (uint8_t s = 0, t = 0; s < slen; s++) {
			do {

				if (string[s] == toFind[t]) {
					if (++found == tFlen)
						return 1;
					s++;
					t++;
				} else {
					s -= found;
					found = 0;
					t = 0;
				}

			} while (found);
		}
		return 0;
	} else
		return -1;
}

void Mqtt_Send() {

	char txt[256];

	uint8_t mac[6];
	char mactxt[20];
	esp_efuse_mac_get_default(mac);
	sprintf(mactxt, "%02X%02X%02X%02X%02X%02X", mac[0], mac[1], mac[2], mac[3],
			mac[4], mac[5]);

	char topic[71];

	ESP_LOGI(TAG, "mqtt send task start");

	while (1) {

		localtime_r(&UnitData.UpdateTime, &sntp_timeinfo);
		localtime_r(&UnitData.LastDetTime, &sntp_timeinfo);

		if (strContains(UnitCfg.MqttConfig.sousTopic, "temp") == 1) {
			ESP_LOGI(TAG, "[TEMPERATURE] Startup..");
			sprintf(txt, "%0.1f", UnitData.Temp);
		} else if (strContains(UnitCfg.MqttConfig.sousTopic, "humid") == 1) {
			ESP_LOGI(TAG, "[HUMIDITY] Startup..");
			sprintf(txt, "%0.1f", UnitData.Humidity);
		} else if (strContains(UnitCfg.MqttConfig.sousTopic, "lux") == 1) {
			ESP_LOGI(TAG, "[LUXMETRE] Startup..");
			sprintf(txt, "%d", UnitData.Als);
		} else if (strContains(UnitCfg.MqttConfig.sousTopic, "co2") == 1) {
			ESP_LOGI(TAG, "[CO2] Startup..");
			sprintf(txt, "%d", UnitData.aq_Co2Level);
		} else if (strContains(UnitCfg.MqttConfig.sousTopic, "tvoc") == 1) {
			ESP_LOGI(TAG, "[TVOC] Startup..");
			sprintf(txt, "%d", UnitData.aq_Tvoc);
		} else {
			ESP_LOGI(TAG, "ALL Pakage");
			sprintf(txt,
					"{\"uid\":\"%s\",\"data\":[%ld,%0.1f,%0.1f,%d,%d,%d,%d,%ld]}",
					mactxt, UnitData.UpdateTime, UnitData.Temp,
					UnitData.Humidity, UnitData.Als, UnitData.aq_Co2Level,
					UnitData.aq_Tvoc, UnitData.aq_status, UnitData.LastDetTime);
		}

		vTaskDelay(UnitCfg.MqttConfig.TopicTimeout * 1000 / portTICK_PERIOD_MS);

		sprintf(topic, "%s/%s", UnitCfg.MqttConfig.Topic,
				UnitCfg.MqttConfig.sousTopic);

		msg_id = esp_mqtt_client_publish(client, topic, txt, strlen(txt), 0, 0);

		if ((WifiConnectedFlag == false)
				|| (UnitCfg.MqttConfig.MqttLogEnb == false)) {
			xTaskCreatePinnedToCore(&mqtt_app_start, "mqtt_app_start", 4000,
					NULL, 1, NULL, 1);
			vTaskDelete(NULL);
		}
	}
}

static esp_err_t mqtt_event_handler(esp_mqtt_event_handle_t event) {
	client = event->client;

	// your_context_t *context = event->context;
	switch (event->event_id) {
	case MQTT_EVENT_CONNECTED:
		printf("%s:MQTT_EVENT_CONNECTED\r\n", TAG);
		msg_id = esp_mqtt_client_subscribe(client, UnitCfg.MqttConfig.Topic, 1);
		printf("%s:sent subscribe successful, msg_id=%d\r\n", TAG, msg_id);
		break;
	case MQTT_EVENT_DISCONNECTED:
		ESP_LOGE(TAG, "MQTT_EVENT_DISCONNECTED");
		break;

	case MQTT_EVENT_SUBSCRIBED:
		printf("%s:MQTT_EVENT_SUBSCRIBED, msg_id=%d\r\n", TAG, event->msg_id);
		xTaskCreatePinnedToCore(&Mqtt_Send, "Mqtt_Send", 4000, NULL, 1, NULL,
				1);
		break;
	case MQTT_EVENT_UNSUBSCRIBED:
		ESP_LOGE(TAG, "MQTT_EVENT_UNSUBSCRIBED, msg_id=%d", event->msg_id);
		break;
	case MQTT_EVENT_PUBLISHED:
		ESP_LOGI(TAG, "MQTT_EVENT_PUBLISHED, msg_id=%d", event->msg_id);
		break;
	case MQTT_EVENT_DATA:
		ESP_LOGI(TAG, "MQTT_EVENT_DATA Topic:%.*s Data:%.*s", event->topic_len,
				event->topic, event->data_len, event->data);
		break;
	case MQTT_EVENT_ERROR:
		ESP_LOGE(TAG, "MQTT_EVENT_ERROR");
		break;

	default:
		break;
	}
	return ESP_OK;
}

void mqtt_app_start() {
	if ((UnitCfg.MqttConfig.MqttLogEnb)) {
		uint8_t mac[6];
		char mactxt[20];

		esp_efuse_mac_get_default(mac);
		sprintf(mactxt, "%02X%02X%02X%02X%02X%02X", mac[0], mac[1], mac[2],
				mac[3], mac[4], mac[5]);

		ESP_LOGI(TAG, "mqtt task Started");

		esp_mqtt_client_config_t mqtt_cfg =
				{ .event_handle = mqtt_event_handler,
				//.host = "m16.cloudmqtt.com",
				//.port = 12052,
				//.username = "leeyzyeq",
				//.password = "VFBvS6lAWOLU"
				};

		esp_log_level_set(TAG, ESP_LOG_INFO);

		mqtt_cfg.host = (const char*) &UnitCfg.MqttConfig.Server;
		mqtt_cfg.username = (const char*) &UnitCfg.MqttConfig.UserName;
		mqtt_cfg.password = (const char*) &UnitCfg.MqttConfig.Password;
		mqtt_cfg.port = UnitCfg.MqttConfig.Port;
		mqtt_cfg.client_id = (const char*) &UnitCfg.UnitName;

		esp_mqtt_client_handle_t client = esp_mqtt_client_init(&mqtt_cfg);
		esp_mqtt_client_start(client);
	}

	vTaskDelete(NULL);
}
