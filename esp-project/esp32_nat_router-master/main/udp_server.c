/* BSD Socket API Example

 This example code is in the Public Domain (or CC0 licensed, at your option.)

 Unless required by applicable law or agreed to in writing, this
 software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 CONDITIONS OF ANY KIND, either express or implied.
 */
#include <string.h>
#include <sys/param.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/portmacro.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "sdkconfig.h"
#include "sys/errno.h"

#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include <lwip/netdb.h>

#include "udp_server.h"
#include "tcp_server.h"
#include "unitcfg.h"

const char *UDP_TAG = "UDP";

const char *UVCOrdreSlave = "UVC IS ON";
const char *stopUVCOrdreSlave = "STOP UVC";

char addr_str[128];

struct sockaddr_in6 source_addr; // Large enough for both IPv4 or IPv6
bool DetectionOnSlave = false;
int slave_number = 1;

TaskHandle_t xSlaveTask;

void SlaveTask(void *pvParameters)
{
	const int sock = (int)pvParameters;
	struct sockaddr_in6 source_addr_slave = source_addr;
	int slaveid = slave_number++;
	ESP_LOGI(UDP_TAG, "Slave number = %d", slaveid);
	while (true)
	{
		if (UVTaskIsOn)
		{
			char *UVCData;
			delay(slaveid * 100);
			ESP_LOGI(UDP_TAG, "UVC order to %d", slaveid);
			UVCData = malloc(100);
			memset(UVCData, 0, 100);
			sprintf(UVCData, "{\"DisinfictionTime\":%d,\"ActivationTime\":%d}", UnitCfg.DisinfictionTime, UnitCfg.ActivationTime);
			// send message to Slaves
			int err = sendto(sock, UVCData, strlen(UVCData), 0, (struct sockaddr *)&source_addr_slave, sizeof(source_addr_slave));
			if (err < 0)
			{
				ESP_LOGE(UDP_TAG, "Error occurred during sending: errno %d", errno);
				break;
			}
			ESP_LOGI(UDP_TAG, "Sending Successful time data");
			free(UVCData);
			// send message to Slaves
			err = sendto(sock, UVCOrdreSlave, strlen(UVCOrdreSlave), 0, (struct sockaddr *)&source_addr_slave, sizeof(source_addr_slave));
			if (err < 0)
			{
				ESP_LOGE(UDP_TAG, "Error occurred during sending: errno %d", errno);
				break;
			}
			ESP_LOGI(UDP_TAG, "Sending Successful uvc ordre");
			UVTaskIsOn = false;
		}
		if (DetectionOnSlave)
		{
			delay(slaveid * 100);
			DetectionOnSlave = false;
			detectionTriggered = true;
			UVTaskIsOn = false;
		}
		if (detectionTriggered)
		{
			delay(slaveid * 100);
			ESP_LOGI(UDP_TAG, "STOP order to %d", slaveid);
			int err = sendto(sock, stopUVCOrdreSlave, strlen(stopUVCOrdreSlave), 0, (struct sockaddr *)&source_addr_slave, sizeof(source_addr_slave));
			if (err < 0)
			{
				ESP_LOGE(UDP_TAG, "Error occurred during sending: errno %d", errno);
			}
			ESP_LOGI(UDP_TAG, "Sending detection message Successful");
			delay(2000);
			detectionTriggered = false;
			UVTaskIsOn = false;
		}
		if (stopEventTrigerred)
		{
			delay(slaveid * 100);
			stopEventTrigerred = false;
			ESP_LOGI(UDP_TAG, "STOP order to %d", slaveid);
			int err = sendto(sock, stopUVCOrdreSlave, strlen(stopUVCOrdreSlave), 0, (struct sockaddr *)&source_addr_slave, sizeof(source_addr_slave));
			if (err < 0)
			{
				ESP_LOGE(UDP_TAG, "Error occurred during sending: errno %d", errno);
			}
			ESP_LOGI(UDP_TAG, "Sending stop message Successful");
			detectionTriggered = true;
			delay(2000);
			detectionTriggered = false;
			UVTaskIsOn = false;
		}
		// TEST of disconnecting
		if (errno != 11 && errno != 0)
		{
			printf("%d\n", errno);
			ESP_LOGE(UDP_TAG, "Disconnecting Client");
			break;
		}
		delay(100);
	}
	vTaskDelete(NULL);
}

void UDPInit()
{
	while (true)
	{
		struct sockaddr_in dest_addr;
		dest_addr.sin_addr.s_addr = inet_addr(ADDRESS_UDP);
		dest_addr.sin_family = AF_INET;
		dest_addr.sin_port = htons(PORT_UDP);
		inet_ntoa_r(dest_addr.sin_addr, addr_str, sizeof(addr_str) - 1);
		int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
		if (sock < 0)
		{
			ESP_LOGE(UDP_TAG, "Unable to create socket: errno %d", errno);
			goto OUT;
		}
		ESP_LOGI(UDP_TAG, "Socket created");
		int err = bind(sock, (struct sockaddr *)&dest_addr, sizeof(dest_addr));
		if (err < 0)
		{
			ESP_LOGE(UDP_TAG, "Socket unable to bind: errno %d", errno);
			goto OUT;
		}
		ESP_LOGI(UDP_TAG, "Socket bound, port %d", PORT_UDP);
		char rx_buffer[128];
		while (true)
		{
			ESP_LOGI(UDP_TAG, "Waiting for data from Esclave");
			socklen_t socklen = sizeof(source_addr);
			int len = recvfrom(sock, rx_buffer, sizeof(rx_buffer) - 1, 0, (struct sockaddr *)&source_addr, &socklen);
			// Error occurred during receiving
			if (len < 0)
			{
				if (errno == 11)
				{
					ESP_LOGI(UDP_TAG, "Timeout on recieving");
				}
				else
				{
					ESP_LOGE(UDP_TAG, "recvfrom failed: errno %d", errno);
				}
			}
			// Data received
			else
			{
				// Get the sender's ip address as string
				if (source_addr.sin6_family == PF_INET)
				{
					inet_ntoa_r(((struct sockaddr_in *)&source_addr)->sin_addr.s_addr, addr_str, sizeof(addr_str) - 1);
				}
				else if (source_addr.sin6_family == PF_INET6)
				{
					inet6_ntoa_r(source_addr.sin6_addr, addr_str, sizeof(addr_str) - 1);
				}
				rx_buffer[len] = 0; // Null-terminate whatever we received and treat like a string...
				ESP_LOGI(UDP_TAG, "Received %d bytes from %s:", len, addr_str);
				ESP_LOGI(UDP_TAG, "%s", rx_buffer);
				if (strContains(rx_buffer, "Detection : 1") == 1)
				{
					stopEventTrigerred = true;
				}
				if (strContains(rx_buffer, "Message from CLIENT") == 1)
				{
					xTaskCreate(SlaveTask, "SlaveTask", 4096, (void *)sock, 1, &xSlaveTask);
				}
				else
				{
					ESP_LOGI(UDP_TAG, "this is not the password");
				}
			}
			ESP_LOGI(UDP_TAG, "Reading again");
		}
	OUT:
		ESP_LOGE(UDP_TAG, "Shutting down socket and restarting...");
		shutdown(sock, 0);
		close(sock);
		delay(1000);
	}
	vTaskDelete(NULL);
}

void UDPServer()
{
	ESP_LOGI(UDP_TAG, "THIS IS MASTER");
	xTaskCreate(UDPInit, "UDPInit", 4096, NULL, 5, NULL);
}
