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
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "esp_netif.h"

#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include <lwip/netdb.h>

#include "udp_server.h"
#include "unitcfg.h"
#include "system_init.h"
#include "uvc_task.h"

const char *UDP_TAG = "UDP";

void udp_server_task()
{
    char rx_buffer[256];
    char tx_buffer[256];
    char addr_str[128];
    char tmp[64];
    struct sockaddr_in6 dest_addr;
    int sock, err, len;

    while (1)
    {
        struct sockaddr_in *dest_addr_ip4 = (struct sockaddr_in *)&dest_addr;
        dest_addr_ip4->sin_addr.s_addr = inet_addr(ADDRESS_UDP);
        dest_addr_ip4->sin_family = AF_INET;
        dest_addr_ip4->sin_port = htons(PORT_UDP);

        sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
        if (sock < 0)
        {
            ESP_LOGE(UDP_TAG, "Unable to create socket: errno %d", errno);
            break;
        }
        ESP_LOGI(UDP_TAG, "Socket created");

        err = bind(sock, (struct sockaddr *)&dest_addr, sizeof(dest_addr));
        if (err < 0)
        {
            ESP_LOGE(UDP_TAG, "Socket unable to bind: errno %d", errno);
            break;
        }
        ESP_LOGI(UDP_TAG, "Socket bound, port %d", PORT_UDP);

        while (1)
        {

            ESP_LOGI(UDP_TAG, "Waiting for data");
            struct sockaddr_storage source_addr; // Large enough for both IPv4 or IPv6
            socklen_t socklen = sizeof(source_addr);
            len = recvfrom(sock, rx_buffer, sizeof(rx_buffer) - 1, 0, (struct sockaddr *)&source_addr, &socklen);

            // Error occurred during receiving
            if (len < 0)
            {
                ESP_LOGE(UDP_TAG, "recvfrom failed: errno %d", errno);
                break;
            }
            // Data received
            else
            {
                // Get the sender's ip address as string
                if (source_addr.ss_family == PF_INET)
                {
                    inet_ntoa_r(((struct sockaddr_in *)&source_addr)->sin_addr, addr_str, sizeof(addr_str) - 1);
                }
                else if (source_addr.ss_family == PF_INET6)
                {
                    inet6_ntoa_r(((struct sockaddr_in6 *)&source_addr)->sin6_addr, addr_str, sizeof(addr_str) - 1);
                }

                rx_buffer[len] = 0; // Null-terminate whatever we received and treat like a string...
                ESP_LOGI(UDP_TAG, "Received %d bytes from %s:", len, addr_str);
                ESP_LOGI(UDP_TAG, "%s", rx_buffer);

                if (getUnitState() == UNIT_STATUS_UVC_TREATEMENT)
                {
                    if (jsonparse(rx_buffer, tmp, "detec", 0))
                    {
                        stopEventTrigerred = atoi(tmp);
                    }
                }
                sprintf(tx_buffer, "{\"stop\":%d,\"state\":%d,\"DES\":%d,\"ACT\":%d}", stopEventTrigerred, getUnitState(), UnitCfg.DisinfictionTime, UnitCfg.ActivationTime);

                err = sendto(sock, tx_buffer, strlen(tx_buffer), 0, (struct sockaddr *)&source_addr, sizeof(source_addr));
                if (err < 0)
                {
                    ESP_LOGE(UDP_TAG, "Error occurred during sending: errno %d", errno);
                    break;
                }
            }
        }

        if (sock != -1)
        {
            ESP_LOGE(UDP_TAG, "Shutting down socket and restarting...");
            shutdown(sock, 0);
            close(sock);
        }
    }
    vTaskDelete(NULL);
}

void UDPServer(void)
{
    xTaskCreate(udp_server_task, "udp_server", 4096, NULL, 3, NULL);
}
