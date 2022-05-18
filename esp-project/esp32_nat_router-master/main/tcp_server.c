/* BSD Socket API Example

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.
*/
#include <string.h>
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

char tx_buffer[sizeof(encryptedHex)];
char rx_buffer[sizeof(encryptedHex)];

int sock;

bool tcpDiconnect = false;

bool UVTaskIsOn = false;
bool stopEventTrigerred = false;
bool detectionTriggered = false;

bool saveNVSData = false;

void checkMessageInput(char *text)
{
    if (strstr(text, "PING"))
    {
        sendTCPCryptedMessage("PONG");
    }
    else if (strstr(text, "GETINFO_1.1"))
    {
        char bufferTCP[sizeof(plaintext)];
        sprintf(bufferTCP, "{\'data\':\'INFO\',\'name\':\'%s\',\'wifi\':[\'%s\',\'%s\'],\'timeDYS\':[%d,%d],\'dataDYS\':[\'%s\',\'%s\',\'%s\']}",
                UnitCfg.UnitName,
                UnitCfg.WifiCfg.AP_SSID, UnitCfg.WifiCfg.AP_PASS,
                UnitCfg.DisinfictionTime, UnitCfg.ActivationTime,
                UnitCfg.Company, UnitCfg.OperatorName, UnitCfg.RoomName);
        sendTCPCryptedMessage(bufferTCP);
    }
    else if (strstr(text, "STARTDESYNFECTIONPROCESS"))
    {
        time_t t;
        time(&t);
        char bufferTCP[sizeof(plaintext)];
        sprintf(bufferTCP, "{\'data\':\'STARTPROCESS\',\'timeSTAMP\':%ld,\'timeZONE\':\'%s\'}", t, UnitCfg.UnitTimeZone);
        sendTCPCryptedMessage(bufferTCP);
    }
    else if (strstr(text, "GOODDATA"))
    {
        char bufferTCP[sizeof(plaintext)];
        sprintf(bufferTCP, "{\'data\':\'success\'}");
        sendTCPCryptedMessage(bufferTCP);
    }
    else
    {
        sendTCPCryptedMessage("WRONG MESSAGE");
    }
}

void checkMessageOut()
{
    if (strstr(rx_buffer, "$discover HuBBoX DELILED"))
    {
        uint8_t mac[6];
        esp_efuse_mac_get_default(mac);
        sprintf(tx_buffer, "{\"man\":\"%s\",\"name\":\"%s\",\"mac\":\"%02X%02X%02X%02X%02X%02X\",\"sn\":\"%s\"}",
                DEFAULT_MANUFACTURE, UnitCfg.UnitName, mac[0], mac[1], mac[2], mac[3], mac[4], mac[5], DEFAULT_SERIAL_NUMBER);
    }
    else
    {
        setTextToDecrypt(rx_buffer);
        ESP_LOGI(TCP_TAG, "Text received after crypt : %s", plaintext);
        char tmp[64];
        if (jsonparse(plaintext, tmp, "mode", 0))
        {
            if (strstr(tmp, "SETTIME"))
            {
                if (jsonparse(plaintext, tmp, "Time", 0))
                {
                    // time
                    time_t t = 0;
                    time_t tl = 0;
                    struct tm ti;

                    time(&tl);
                    localtime_r(&tl, &ti);

                    t = atoi(tmp);
                    ESP_LOGI(TCP_TAG, "Time sync epoch %ld", t);

                    if (jsonparse(plaintext, tmp, "Time", 1))
                    {
                        if (strstr(tmp, "FR"))
                        {
                            sprintf(UnitCfg.UnitTimeZone, "CET-1CEST-2,M3.5.0/02:00:00,M10.5.0/03:00:00");
                        }
                        if (strstr(tmp, "TN"))
                        {
                            sprintf(UnitCfg.UnitTimeZone, "UTC+1");
                        }
                        ESP_LOGI(TCP_TAG, "Time zone %s", UnitCfg.UnitTimeZone);
                        syncTime(t, UnitCfg.UnitTimeZone);
                        saveNVSData = true;
                        sprintf(plaintext, "GOODDATA");
                    }
                }
            }
            else if (strstr(tmp, "SETDISINFECT"))
            {
                if (jsonparse(plaintext, UnitCfg.Company, "data", 0))
                {
                    ESP_LOGI(TCP_TAG, "Company :  %s", UnitCfg.Company);
                    if (jsonparse(plaintext, UnitCfg.OperatorName, "data", 1))
                    {
                        ESP_LOGI(TCP_TAG, "Operator :  %s", UnitCfg.OperatorName);
                    }
                    if (jsonparse(plaintext, UnitCfg.RoomName, "data", 2))
                    {
                        ESP_LOGI(TCP_TAG, "Room :  %s", UnitCfg.RoomName);
                    }
                    if (jsonparse(plaintext, tmp, "Time", 0))
                    {
                        UnitCfg.DisinfictionTime = atoi(tmp);
                        ESP_LOGI(TCP_TAG, "Disinfection time :  %d", UnitCfg.DisinfictionTime);
                        if (jsonparse(plaintext, tmp, "Time", 1))
                        {
                            UnitCfg.ActivationTime = atoi(tmp);
                            ESP_LOGI(TCP_TAG, "Activation time :  %d", UnitCfg.ActivationTime);
                        }
                    }
                    saveNVSData = true;
                    sprintf(plaintext, "STARTDESYNFECTIONPROCESS");
                }
            }
        }
        checkMessageInput(plaintext);
    }
}

void sendTCPCryptedMessage(const char *text)
{
    setTextToEncrypt(text);
    memset(tx_buffer, 0, sizeof(tx_buffer));
    sprintf(tx_buffer, encryptedHex);
}

void txTransmission()
{
    int length = strlen(tx_buffer);
    int to_write = length;
    ESP_LOGI(TCP_TAG, "Message to send : %s", tx_buffer);
    while (to_write > 0)
    {
        int written = send(sock, tx_buffer + (length - to_write), to_write, 0);
        if (written < 0)
        {
            ESP_LOGE(TCP_TAG, "Error occurred during sending: errno %d", errno);
        }
        to_write -= written;
    }
    memset(rx_buffer, 0, sizeof(rx_buffer));
}

void rxTransmission()
{
    saveNVSData = false;
    int len;
    while (true)
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
            break;
        }
        else
        {
            rx_buffer[len] = 0; // Null-terminate whatever is received and treat it like a string
            ESP_LOGI(TCP_TAG, "Received %d bytes: %s", len, rx_buffer);
            checkMessageOut();
            txTransmission();
        }
        delay(50);
    }
    tcpDiconnect = false;
    ESP_LOGE(TCP_TAG, "Communication ended, Shutdown !");
    // Save Data when disconnecting
    saveDataTask(saveNVSData);
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
        sock = accept(listen_sock, (struct sockaddr *)&source_addr, &addr_len);
        if (sock < 0)
        {
            ESP_LOGE(TCP_TAG, "Unable to accept connection: errno %d", errno);
            goto CLEAN_UP;
        }
        else
        {
            struct timeval receiving_timeout;
            receiving_timeout.tv_sec = 1;
            receiving_timeout.tv_usec = 0;
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

            rxTransmission();

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
    xTaskCreate(TCPInit, "TCPInit", 8192, (void *)AF_INET, 3, NULL);
}
