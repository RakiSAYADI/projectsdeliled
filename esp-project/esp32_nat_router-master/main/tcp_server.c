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
#include "esp_netif.h"

#include "sys/errno.h"
#include "lwip/err.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include <lwip/netdb.h>

#include "tcp_server.h"
#include "udp_server.h"
#include "unitcfg.h"
#include "aes.h"

#include "sdkconfig.h"

const char *TCP_TAG = "TCP-IP";

char tx_buffer[4096];
char rx_buffer[4096];

bool tcpDiconnect = false;
bool tcpReadOrWrite = false;
bool tcpDecryptMessages = false;

bool UVTaskIsOn = false;
bool stopEventTrigerred = false;
bool detectionTriggered = false;

void checkMessageInput(char *text)
{
}

void rxTransmission(void *pvParameters)
{
    int len;
    int sock = (int)pvParameters;
    do
    {
        if (tcpDiconnect)
        {
            break;
        }
        else
        {
            len = recv(sock, rx_buffer, sizeof(rx_buffer) - 1, 0);
            if (len < 0)
            {
                ESP_LOGE(TCP_TAG, "Error occurred during receiving: errno %d", errno);
            }
            else if (len == 0)
            {
                ESP_LOGW(TCP_TAG, "Connection closed");
                tcpDiconnect = true;
            }
            else
            {
                rx_buffer[len] = 0; // Null-terminate whatever is received and treat it like a string
                ESP_LOGI(TCP_TAG, "Received %d bytes: %s", len, rx_buffer);

                if (tcpDecryptMessages)
                {
                    setTextToDecrypt(rx_buffer);
                    decodeAESCBC();
                    ESP_LOGI(TCP_TAG, "Text received after crypt : %s", plaintext);
                    checkMessageInput(plaintext);
                }
                else
                {
                    if (strContains(rx_buffer, "$dicover HuBBoX DELILED"))
                    {
                        uint8_t mac[6];
                        esp_efuse_mac_get_default(mac);
                        sprintf(tx_buffer, "{\"man\":\"%s\",\"name\":\"%s\",\"mac\":\"%02X%02X%02X%02X%02X%02X\",\"sn\":\"%s\"}",
                                DEFAULT_MANUFACTURE, UnitCfg.UnitName, mac[0], mac[1], mac[2], mac[3], mac[4], mac[5], DEFAULT_SERIAL_NUMBER);
                        tcpDecryptMessages = true;
                    }
                    else
                    {
                        sprintf(tx_buffer, "WRONG MESSAGE");
                        tcpDecryptMessages = false;
                    }
                }
                tcpReadOrWrite = true;
            }
        }
        delay(200);
    } while (len > 0);
    vTaskDelete(NULL);
}

void txTransmission(void *pvParameters)
{
    int len;
    int sock = (int)pvParameters;
    while (true)
    {
        if (tcpDiconnect)
        {
            break;
        }
        else
        {
            if (tcpReadOrWrite)
            {
                len = strlen(tx_buffer);
                int to_write = len;
                while (to_write > 0)
                {
                    int written = send(sock, tx_buffer + (len - to_write), to_write, 0);
                    if (written < 0)
                    {
                        ESP_LOGE(TCP_TAG, "Error occurred during sending: errno %d", errno);
                    }
                    to_write -= written;
                }
                tcpReadOrWrite = false;
            }
        }
        delay(200);
    }
    vTaskDelete(NULL);
}

void TCPCommunication(const int sock)
{
    xTaskCreate(txTransmission, "txTransmission", 8192, (void *)sock, 3, NULL);
    xTaskCreate(rxTransmission, "rxTransmission", 8192, (void *)sock, 3, NULL);
    while (true)
    {
        if (tcpDiconnect)
        {
            break;
        }
        delay(100);
    }
    ESP_LOGE(TCP_TAG, "Communication ended, Shutdown !");
}

void TCPInit(void *pvParameters)
{
    char addr_str[128];
    int addr_family = (int)pvParameters;
    int ip_protocol = 0;
    int keepAlive = 1;
    int keepIdle = KEEPALIVE_IDLE;
    int keepInterval = KEEPALIVE_INTERVAL;
    int keepCount = KEEPALIVE_COUNT;
    struct sockaddr_storage dest_addr;

    if (addr_family == AF_INET)
    {
        struct sockaddr_in *dest_addr_ip4 = (struct sockaddr_in *)&dest_addr;
        dest_addr_ip4->sin_addr.s_addr = inet_addr(ADDRESS_TCP);
        dest_addr_ip4->sin_port = htons(PORT_TCP);
        dest_addr_ip4->sin_family = AF_INET;
        ip_protocol = IPPROTO_IP;
    }

    int listen_sock = socket(addr_family, SOCK_STREAM, ip_protocol);
    if (listen_sock < 0)
    {
        ESP_LOGE(TCP_TAG, "Unable to create socket: errno %d", errno);
        vTaskDelete(NULL);
        return;
    }
    int opt = 1;
    setsockopt(listen_sock, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    ESP_LOGI(TCP_TAG, "Socket created");

    int err = bind(listen_sock, (struct sockaddr *)&dest_addr, sizeof(dest_addr));
    if (err != 0)
    {
        ESP_LOGE(TCP_TAG, "Socket unable to bind: errno %d", errno);
        ESP_LOGE(TCP_TAG, "IPPROTO: %d", addr_family);
        goto CLEAN_UP;
    }
    ESP_LOGI(TCP_TAG, "Socket bound, port %d", PORT_TCP);

    err = listen(listen_sock, 1);
    if (err != 0)
    {
        ESP_LOGE(TCP_TAG, "Error occurred during listen: errno %d", errno);
        goto CLEAN_UP;
    }

    while (1)
    {

        ESP_LOGI(TCP_TAG, "Socket listening");

        struct sockaddr_storage source_addr; // Large enough for both IPv4 or IPv6
        socklen_t addr_len = sizeof(source_addr);
        int sock = accept(listen_sock, (struct sockaddr *)&source_addr, &addr_len);
        if (sock < 0)
        {
            ESP_LOGE(TCP_TAG, "Unable to accept connection: errno %d", errno);
            goto CLEAN_UP;
        }
        else
        {
            struct timeval receiving_timeout;
            receiving_timeout.tv_sec = 0;
            receiving_timeout.tv_usec = 100000;
            if (setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &receiving_timeout, sizeof(receiving_timeout)) < 0)
            {
                ESP_LOGE(TCP_TAG, "... failed to set socket receiving timeout");
                goto CLEAN_UP;
            }

            ESP_LOGI(TCP_TAG, "Timeout Successful");
            // Set tcp keepalive option
            setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE, &keepAlive, sizeof(int));
            setsockopt(sock, IPPROTO_TCP, TCP_KEEPIDLE, &keepIdle, sizeof(int));
            setsockopt(sock, IPPROTO_TCP, TCP_KEEPINTVL, &keepInterval, sizeof(int));
            setsockopt(sock, IPPROTO_TCP, TCP_KEEPCNT, &keepCount, sizeof(int));
            // Convert ip address to string
            if (source_addr.ss_family == PF_INET)
            {
                inet_ntoa_r(((struct sockaddr_in *)&source_addr)->sin_addr, addr_str, sizeof(addr_str) - 1);
            }
            ESP_LOGI(TCP_TAG, "Socket accepted ip address: %s", addr_str);

            TCPCommunication(sock);

            tcpDecryptMessages = false;
            tcpReadOrWrite = false;
            tcpDiconnect = false;

            shutdown(sock, 0);
            close(sock);
        }
        delay(100);
    }

CLEAN_UP:
    close(listen_sock);
    vTaskDelete(NULL);
}

void TCPServer(void)
{
    xTaskCreate(TCPInit, "TCPInit", 4096, (void *)AF_INET, 5, NULL);
}

void sendTCPCryptedMessage(const char *text)
{
    setTextToEncrypt(text);
    encodeAESCBC();
    sprintf(tx_buffer, encryptedHex);
    tcpReadOrWrite = true;
}
