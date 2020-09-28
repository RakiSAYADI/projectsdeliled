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
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "tcpip_adapter.h"

#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include <lwip/netdb.h>

#include "sys/errno.h"

#include "sdkconfig.h"
#include "unitcfg.h"
#include "webservice.h"

static const char *TAG = "UDP_CLIENT";
static const char *payload = "Hello Maestro !";


static void udp_client_task(void *pvParameters)
{
    char rx_buffer[128];
    char addr_str[128];
    int addr_family;
    int ip_protocol;
    int sock;

    while((WifiConnectedFlag==false))
    {
    	vTaskDelay(1000 / portTICK_PERIOD_MS);
    }

    while (1) {

    	if (UnitCfg.UDPConfig.Enable)
    	{
			if (UnitCfg.UDPConfig.ipv4_ipv6)
			{
#define IPV4
			}

#ifdef IPV4
				// IPV4
				struct sockaddr_in dest_addr;
				dest_addr.sin_addr.s_addr = inet_addr(UnitCfg.UDPConfig.Server);
				dest_addr.sin_family = AF_INET;
				dest_addr.sin_port = htons(UnitCfg.UDPConfig.Port);
				addr_family = AF_INET;
				ip_protocol = IPPROTO_IP;
				inet_ntoa_r(dest_addr.sin_addr, addr_str, sizeof(addr_str) - 1);
#else       // IPV6
				struct sockaddr_in6 dest_addr;
				inet6_aton(UnitCfg.UDPConfig.Server, &dest_addr.sin6_addr);
				dest_addr.sin6_family = AF_INET6;
				dest_addr.sin6_port = htons(UnitCfg.UDPConfig.Port);
				addr_family = AF_INET6;
				ip_protocol = IPPROTO_IPV6;
				inet6_ntoa_r(dest_addr.sin6_addr, addr_str, sizeof(addr_str) - 1);
#endif

			sock = socket(addr_family, SOCK_DGRAM, ip_protocol);
			if (sock < 0) {
				ESP_LOGE(TAG, "Unable to create socket: errno %d", errno);
				break;
			}
			ESP_LOGI(TAG, "Socket created, sending to %s:%d", UnitCfg.UDPConfig.Server, UnitCfg.UDPConfig.Port);

			int err = sendto(sock, payload, strlen(payload), 0, (struct sockaddr *)&dest_addr, sizeof(dest_addr));
			if (err < 0) {
				ESP_LOGE(TAG, "Error occurred during sending: errno %d", errno);
				break;
			}
			ESP_LOGI(TAG, "Message sent");

			struct sockaddr_in source_addr; // Large enough for both IPv4 or IPv6
			socklen_t socklen = sizeof(source_addr);
			int len = recvfrom(sock, rx_buffer, sizeof(rx_buffer) - 1, 0, (struct sockaddr *)&source_addr, &socklen);

			// Error occurred during receiving
			if (len < 0) {
				ESP_LOGE(TAG, "recvfrom failed: errno %d", errno);
				break;
			}
			// Data received
			else {
				rx_buffer[len] = 0; // Null-terminate whatever we received and treat like a string
				ESP_LOGI(TAG, "Received %d bytes from %s:", len, addr_str);
				ESP_LOGI(TAG, "%s", rx_buffer);
			}

			vTaskDelay(2000 / portTICK_PERIOD_MS);
        }

    }
    if (sock != -1) {
        ESP_LOGE(TAG, "Shutting down socket and restarting...");
        shutdown(sock, 0);
        close(sock);
    }
    vTaskDelete(NULL);
}

void udp_app_start()
{
    xTaskCreate(udp_client_task, "udp_client", 4096, NULL, 5, NULL);
    vTaskDelete(NULL);
}
