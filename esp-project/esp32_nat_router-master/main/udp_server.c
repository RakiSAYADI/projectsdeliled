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
#include "unitcfg.h"
#include "uvc_task.h"
#include "system_init.h"

const char *UDP_TAG = "UDP";

const char *pingUVCOrdreSlave = "PING";
const char *UVCOrdreSlave = "UVC IS ON";
const char *stopUVCOrdreSlave = "STOP UVC";

SlaveUnit_Typedef slaves[UDP_MAX_SLAVES];

int sock = 0;

int checkSlavesAvailablityArray()
{
	for (int i = 0; i < UDP_MAX_SLAVES; i++)
	{
		if (!slaves[i].enable)
			return i;
	}
	return -1;
}

void SlaveTask(void *pvParameters)
{
	int err = 0;
	int connectionPinger = 0;
	SlaveUnit_Typedef *slave = (SlaveUnit_Typedef *)pvParameters;
	uint8_t slaveid = slave->id;

	while (true)
	{
		if (slave->enable)
		{
			if (getUnitState() == UNIT_STATUS_UVC_STARTING)
			{
				char *UVCData;
				delay((slaveid + 1) * 100);
				ESP_LOGI(UDP_TAG, "UVC order to %d", (slaveid + 1));
				UVCData = malloc(100);
				memset(UVCData, 0, 100);
				sprintf(UVCData, "{\"DisinfictionTime\":%d,\"ActivationTime\":%d}", UnitCfg.DisinfictionTime, UnitCfg.ActivationTime);
				// send message to Slaves
				err = sendto(sock, UVCData, strlen(UVCData), 0, (struct sockaddr *)&slave->source_addr_slave, sizeof(slave->source_addr_slave));
				if (err < 0)
				{
					ESP_LOGE(UDP_TAG, "Error occurred during sending: errno %d", errno);
					goto OUT_SLAVE;
				}
				ESP_LOGI(UDP_TAG, "Sending Successful time data, id : %d", slaveid);
				free(UVCData);
				// send message to Slaves
				err = sendto(sock, UVCOrdreSlave, strlen(UVCOrdreSlave), 0, (struct sockaddr *)&slave->source_addr_slave, sizeof(slave->source_addr_slave));
				if (err < 0)
				{
					ESP_LOGE(UDP_TAG, "Error occurred during sending: errno %d", errno);
					goto OUT_SLAVE;
				}
				ESP_LOGI(UDP_TAG, "Sending Successful uvc ordre, id : %d", slaveid);
				while (true)
				{
					if (stopEventTrigerred)
					{
						delay((slaveid + 1) * 100);
						ESP_LOGI(UDP_TAG, "STOP order to %d", (slaveid + 1));
						err = sendto(sock, stopUVCOrdreSlave, strlen(stopUVCOrdreSlave), 0, (struct sockaddr *)&slave->source_addr_slave, sizeof(slave->source_addr_slave));
						if (err < 0)
						{
							ESP_LOGE(UDP_TAG, "Error occurred during sending: errno %d", errno);
							goto OUT_SLAVE;
						}
						ESP_LOGI(UDP_TAG, "Sending stop message Successful, id : %d", slaveid);
						break;
					}
					delay(50);
				}
			}
			if ((getUnitState() == UNIT_STATUS_IDLE) || (getUnitState() == UNIT_STATUS_UVC_ERROR))
			{
				if (connectionPinger == 600)
				{
					delay((slaveid + 1) * 100);
					ESP_LOGI(UDP_TAG, "PING order to %d", (slaveid + 1));
					err = sendto(sock, pingUVCOrdreSlave, strlen(pingUVCOrdreSlave), 0, (struct sockaddr *)&slave->source_addr_slave, sizeof(slave->source_addr_slave));
					if (err < 0)
					{
						ESP_LOGE(UDP_TAG, "Error occurred during sending: errno %d", errno);
						goto OUT_SLAVE;
					}
					ESP_LOGI(UDP_TAG, "Sending ping message Successful, id : %d", slaveid);
					connectionPinger = 0;
				}
				else
				{
					connectionPinger++;
				}
			}
			// TEST of disconnecting
			if (errno != 11 && errno != 0)
			{
			OUT_SLAVE:
				ESP_LOGE(UDP_TAG, "Disconnecting Client : %d", errno);
				stopEventTrigerred = false;
				slave->enable = false;
			}
		}
		delay(100);
	}
	vTaskDelete(NULL);
}

void UDPInit()
{
	char addr_str[128];
	char rx_buffer[128];
	struct sockaddr_in dest_addr;
	struct sockaddr_in6 source_addr; // Large enough for both IPv4 or IPv6
	int8_t availableSlave = 0;
	int len, err;
RESTART:
	dest_addr.sin_addr.s_addr = inet_addr(ADDRESS_UDP);
	dest_addr.sin_family = AF_INET;
	dest_addr.sin_port = htons(PORT_UDP);
	inet_ntoa_r(dest_addr.sin_addr, addr_str, sizeof(addr_str) - 1);
	sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
	if (sock < 0)
	{
		ESP_LOGE(UDP_TAG, "Unable to create socket: errno %d", errno);
		goto OUT;
	}
	ESP_LOGI(UDP_TAG, "Socket created");
	err = bind(sock, (struct sockaddr *)&dest_addr, sizeof(dest_addr));
	if (err < 0)
	{
		ESP_LOGE(UDP_TAG, "Socket unable to bind: errno %d", errno);
		goto OUT;
	}
	ESP_LOGI(UDP_TAG, "Socket bound, port %d", PORT_UDP);
	while (true)
	{
		ESP_LOGI(UDP_TAG, "Waiting for data from Slaves");
		socklen_t socklen = sizeof(source_addr);
		len = recvfrom(sock, rx_buffer, sizeof(rx_buffer) - 1, 0, (struct sockaddr *)&source_addr, &socklen);
		// Error occurred during receiving
		if (len < 0)
		{
			if (errno == 11)
			{
				ESP_LOGI(UDP_TAG, "Timeout on recieving");
			}
			else
			{
				ESP_LOGE(UDP_TAG, "Shutting down socket and restarting... (%d)", errno);
				shutdown(sock, 0);
				close(sock);
				goto RESTART;
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
			if (strstr(rx_buffer, "{\"Detection\":1}"))
			{
				stopEventTrigerred = true;
			}
			else if (strstr(rx_buffer, "PONG"))
			{
				ESP_LOGI(UDP_TAG, "GOOD Connection from %s", addr_str);
			}
			else if (strstr(rx_buffer, "DELILED_CLIENT"))
			{
				availableSlave = checkSlavesAvailablityArray();
				if (availableSlave == -1)
				{
					ESP_LOGI(UDP_TAG, "No more slaves to add");
				}
				else
				{
					slaves[availableSlave].source_addr_slave = source_addr;
					slaves[availableSlave].enable = true;
					ESP_LOGI(UDP_TAG, "Slave id is %d", availableSlave);
				}
			}
			else
			{
				ESP_LOGI(UDP_TAG, "unknown message");
			}
		}
		delay(50);
		ESP_LOGI(UDP_TAG, "Reading again");
	}
OUT:
	ESP_LOGE(UDP_TAG, "Shutting down socket and restarting...");
	shutdown(sock, 0);
	close(sock);
	vTaskDelete(NULL);
}

void UDPServer()
{
	ESP_LOGI(UDP_TAG, "THIS IS MASTER");
	// start udp server task
	xTaskCreate(UDPInit, "UDPInit", 4096, NULL, 3, NULL);
	// start udp clients tasks
	for (int i = 0; i < UDP_MAX_SLAVES; i++)
	{
		slaves[i].id = i;
		xTaskCreate(SlaveTask, "SlaveTask", 4096, &slaves[i], 3, NULL);
	}
}
