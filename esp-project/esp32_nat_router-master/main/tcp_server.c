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
#include "system_init.h"
#include "unitcfg.h"
#include "uvc_task.h"
#include "aes.h"
#include "i2c.h"

#include "sdkconfig.h"

const char *TCP_TAG = "TCP-IP";

const bool readWithEncryption = false;

void sendTCPCryptedMessage(const char *text);

char tx_buffer[sizeof(encryptedHex)];
char rx_buffer[sizeof(encryptedHex)];
char bufferTCP[sizeof(plaintext)];

int sock;

bool tcpDisconnect = false;
bool saveNVSData = false;

time_t timeSt;

char *getStateToString(UnitStatDef UnitStat)
{
    switch (UnitStat)
    {
    case UNIT_STATUS_NONE:
        return "NONE";
        break;
    case UNIT_STATUS_LOADING:
        return "LOADING";
        break;
    case UNIT_STATUS_UVC_ERROR:
        return "ERROR";
        break;
    case UNIT_STATUS_UVC_STARTING:
        return "STARTING";
        break;
    case UNIT_STATUS_UVC_TREATEMENT:
        return "UVC";
        break;
    case UNIT_STATUS_IDLE:
        return "IDLE";
        break;
    }
    return "error";
}

bool readAutoData(char *jsonData, char day[4], int dayID)
{
    char tmp[64];
    bool stateFlag = false;

    if (jsonparse(jsonData, tmp, day, 0))
    {
        stateFlag = true;
        UnitCfg.autoUvc[dayID].state = atoi(tmp);

        if (UnitCfg.autoUvc[dayID].state)
        {
            ESP_LOGI(TCP_TAG, "%s is selected !", day);
        }
        else
        {
            ESP_LOGI(TCP_TAG, "%s is not selected !", day);
        }

        if (jsonparse(jsonData, tmp, day, 1))
        {
            UnitCfg.autoUvc[dayID].autoTrigTime = atoi(tmp);
            ESP_LOGI(TCP_TAG, "%s time is %ld", day, UnitCfg.autoUvc[dayID].autoTrigTime);
        }
        if (jsonparse(jsonData, tmp, day, 2))
        {
            UnitCfg.autoUvc[dayID].DisinfictionTime = atoi(tmp);
            ESP_LOGI(TCP_TAG, "%s disinfection is %d", day, UnitCfg.autoUvc[dayID].DisinfictionTime);
        }
        if (jsonparse(jsonData, tmp, day, 3))
        {
            UnitCfg.autoUvc[dayID].ActivationTime = atoi(tmp);
            ESP_LOGI(TCP_TAG, "%s activation is %d", day, UnitCfg.autoUvc[dayID].ActivationTime);
        }
    }
    return stateFlag;
}

void checkMessageInput(char *text)
{
    if (strstr(text, "PONG"))
    {
        if (readWithEncryption)
        {
            sendTCPCryptedMessage("{\"data\":\"PONG\"}");
        }
        else
        {
            sprintf(tx_buffer, "{\"data\":\"PONG\"}");
        }
    }
    else if (strstr(text, "GETINFO_1.1"))
    {
        time(&timeSt);
        if (readWithEncryption)
        {
            sprintf(bufferTCP, "{\"data\":\"INFO\",\"name\":\"%s\",\"state\":\"%s\",\"timeSt\":%ld,\"timeUVC\":%d,\"wifi\":[\"%s\",\"%s\"],\"encrypt\":%d,\"timeDYS\":[%d,%d],\"dataDYS\":[\"%s\",\"%s\",\"%s\"]}",
                    UnitCfg.UnitName, getStateToString(getUnitState()), timeSt, timeUVC,
                    UnitCfg.WifiCfg.AP_SSID, UnitCfg.WifiCfg.AP_PASS, readWithEncryption,
                    UnitCfg.DisinfictionTime, UnitCfg.ActivationTime,
                    UnitCfg.Company, UnitCfg.OperatorName, UnitCfg.RoomName);
            ESP_LOGI(TCP_TAG, "text to send and encrypt %s", bufferTCP);
            sendTCPCryptedMessage(bufferTCP);
        }
        else
        {
            sprintf(tx_buffer, "{\"data\":\"INFO\",\"name\":\"%s\",\"state\":\"%s\",\"timeSt\":%ld,\"timeUVC\":%d,\"wifi\":[\"%s\",\"%s\"],\"encrypt\":%d,\"timeDYS\":[%d,%d],\"dataDYS\":[\"%s\",\"%s\",\"%s\"]}",
                    UnitCfg.UnitName, getStateToString(getUnitState()), timeSt, timeUVC,
                    UnitCfg.WifiCfg.AP_SSID, UnitCfg.WifiCfg.AP_PASS, readWithEncryption,
                    UnitCfg.DisinfictionTime, UnitCfg.ActivationTime,
                    UnitCfg.Company, UnitCfg.OperatorName, UnitCfg.RoomName);
            ESP_LOGI(TCP_TAG, "text to send and encrypt %s", tx_buffer);
        }
    }
    else if (strstr(text, "GETINFO_2.1"))
    {
        if (readWithEncryption)
        {
            sprintf(bufferTCP, "{\"data\":\"AUTO\",\"name\":\"%s\",\"state\":\"%s\",\"Mon\":[%d,%ld,%d,%d],\"Tue\":[%d,%ld,%d,%d],\"Wed\":[%d,%ld,%d,%d],\"Thu\":[%d,%ld,%d,%d],\"Fri\":[%d,%ld,%d,%d],\"Sat\":[%d,%ld,%d,%d],\"Sun\":[%d,%ld,%d,%d]}",
                    UnitCfg.UnitName, getStateToString(getUnitState()),
                    UnitCfg.autoUvc[1].state, UnitCfg.autoUvc[1].autoTrigTime, UnitCfg.autoUvc[1].DisinfictionTime, UnitCfg.autoUvc[1].ActivationTime,
                    UnitCfg.autoUvc[2].state, UnitCfg.autoUvc[2].autoTrigTime, UnitCfg.autoUvc[2].DisinfictionTime, UnitCfg.autoUvc[2].ActivationTime,
                    UnitCfg.autoUvc[3].state, UnitCfg.autoUvc[3].autoTrigTime, UnitCfg.autoUvc[3].DisinfictionTime, UnitCfg.autoUvc[3].ActivationTime,
                    UnitCfg.autoUvc[4].state, UnitCfg.autoUvc[4].autoTrigTime, UnitCfg.autoUvc[4].DisinfictionTime, UnitCfg.autoUvc[4].ActivationTime,
                    UnitCfg.autoUvc[5].state, UnitCfg.autoUvc[5].autoTrigTime, UnitCfg.autoUvc[5].DisinfictionTime, UnitCfg.autoUvc[5].ActivationTime,
                    UnitCfg.autoUvc[6].state, UnitCfg.autoUvc[6].autoTrigTime, UnitCfg.autoUvc[6].DisinfictionTime, UnitCfg.autoUvc[6].ActivationTime,
                    UnitCfg.autoUvc[0].state, UnitCfg.autoUvc[0].autoTrigTime, UnitCfg.autoUvc[0].DisinfictionTime, UnitCfg.autoUvc[0].ActivationTime);
            ESP_LOGI(TCP_TAG, "text to send and encrypt %s", bufferTCP);
            sendTCPCryptedMessage(bufferTCP);
        }
        else
        {
            sprintf(tx_buffer, "{\"data\":\"AUTO\",\"name\":\"%s\",\"state\":\"%s\",\"Mon\":[%d,%ld,%d,%d],\"Tue\":[%d,%ld,%d,%d],\"Wed\":[%d,%ld,%d,%d],\"Thu\":[%d,%ld,%d,%d],\"Fri\":[%d,%ld,%d,%d],\"Sat\":[%d,%ld,%d,%d],\"Sun\":[%d,%ld,%d,%d]}",
                    UnitCfg.UnitName, getStateToString(getUnitState()),
                    UnitCfg.autoUvc[1].state, UnitCfg.autoUvc[1].autoTrigTime, UnitCfg.autoUvc[1].DisinfictionTime, UnitCfg.autoUvc[1].ActivationTime,
                    UnitCfg.autoUvc[2].state, UnitCfg.autoUvc[2].autoTrigTime, UnitCfg.autoUvc[2].DisinfictionTime, UnitCfg.autoUvc[2].ActivationTime,
                    UnitCfg.autoUvc[3].state, UnitCfg.autoUvc[3].autoTrigTime, UnitCfg.autoUvc[3].DisinfictionTime, UnitCfg.autoUvc[3].ActivationTime,
                    UnitCfg.autoUvc[4].state, UnitCfg.autoUvc[4].autoTrigTime, UnitCfg.autoUvc[4].DisinfictionTime, UnitCfg.autoUvc[4].ActivationTime,
                    UnitCfg.autoUvc[5].state, UnitCfg.autoUvc[5].autoTrigTime, UnitCfg.autoUvc[5].DisinfictionTime, UnitCfg.autoUvc[5].ActivationTime,
                    UnitCfg.autoUvc[6].state, UnitCfg.autoUvc[6].autoTrigTime, UnitCfg.autoUvc[6].DisinfictionTime, UnitCfg.autoUvc[6].ActivationTime,
                    UnitCfg.autoUvc[0].state, UnitCfg.autoUvc[0].autoTrigTime, UnitCfg.autoUvc[0].DisinfictionTime, UnitCfg.autoUvc[0].ActivationTime);
            ESP_LOGI(TCP_TAG, "text to send and encrypt %s", tx_buffer);
        }
    }
    else if (strstr(text, "STARTDESYNFECTIONPROCESS"))
    {
        time(&timeSt);
        if (readWithEncryption)
        {
            sprintf(bufferTCP, "{\"data\":\"START\",\"timeSTAMP\":%ld}", timeSt);
            sendTCPCryptedMessage(bufferTCP);
        }
        else
        {
            sprintf(tx_buffer, "{\"data\":\"START\",\"timeSTAMP\":%ld}", timeSt);
        }
    }
    else if (strstr(text, "GOODDATA"))
    {
        if (readWithEncryption)
        {
            sprintf(bufferTCP, "{\"data\":\"success\"}");
            sendTCPCryptedMessage(bufferTCP);
        }
        else
        {
            sprintf(tx_buffer, "{\"data\":\"success\"}");
        }
    }
    else
    {
        if (readWithEncryption)
        {
            sendTCPCryptedMessage("WRONG MESSAGE");
        }
        else
        {
            sprintf(tx_buffer, "WRONG MESSAGE");
        }
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
        if (readWithEncryption)
        {
            setTextToDecrypt(rx_buffer);
            ESP_LOGI(TCP_TAG, "Text received after crypt : %s", plaintext);
            sprintf(rx_buffer, plaintext);
        }
        char tmp[64];
        if (jsonparse(rx_buffer, tmp, "mode", 0))
        {
            if (strstr(tmp, "SETTIME"))
            {
                if (jsonparse(rx_buffer, tmp, "Time", 0))
                {
                    // time
                    time_t t = 0;
                    time_t tl = 0;
                    struct tm ti;

                    time(&tl);
                    localtime_r(&tl, &ti);

                    t = atoi(tmp);
                    ESP_LOGI(TCP_TAG, "Time sync epoch %ld", t);

                    if (jsonparse(rx_buffer, tmp, "Time", 1))
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
                        saveTimeOnBattery = true;
                        sprintf(rx_buffer, "GOODDATA");
                    }
                }
            }
            else if (strstr(tmp, "SETDISINFECT"))
            {
                if (jsonparse(rx_buffer, UnitCfg.Company, "data", 0))
                {
                    ESP_LOGI(TCP_TAG, "Company :  %s", UnitCfg.Company);
                    if (jsonparse(rx_buffer, UnitCfg.OperatorName, "data", 1))
                    {
                        ESP_LOGI(TCP_TAG, "Operator :  %s", UnitCfg.OperatorName);
                    }
                    if (jsonparse(rx_buffer, UnitCfg.RoomName, "data", 2))
                    {
                        ESP_LOGI(TCP_TAG, "Room :  %s", UnitCfg.RoomName);
                    }
                    if (jsonparse(rx_buffer, tmp, "Time", 0))
                    {
                        UnitCfg.DisinfictionTime = atoi(tmp);
                        ESP_LOGI(TCP_TAG, "Disinfection time :  %d", UnitCfg.DisinfictionTime);
                        if (jsonparse(rx_buffer, tmp, "Time", 1))
                        {
                            UnitCfg.ActivationTime = atoi(tmp);
                            ESP_LOGI(TCP_TAG, "Activation time :  %d", UnitCfg.ActivationTime);
                        }
                    }
                    saveNVSData = true;
                    sprintf(rx_buffer, "GOODDATA");
                }
            }
            else if (strstr(tmp, "START"))
            {
                if ((getUnitState() == UNIT_STATUS_IDLE) || (getUnitState() == UNIT_STATUS_UVC_ERROR))
                {
                    stopEventTrigerred = false;
                    setUnitStatus(UNIT_STATUS_UVC_STARTING);
                    sprintf(rx_buffer, "GOODDATA");
                }
            }
            else if (strstr(tmp, "AUTOUVC"))
            {
                saveNVSData = readAutoData(rx_buffer, "Mon", 1);
                saveNVSData = readAutoData(rx_buffer, "Tue", 2);
                saveNVSData = readAutoData(rx_buffer, "Wed", 3);
                saveNVSData = readAutoData(rx_buffer, "Thu", 4);
                saveNVSData = readAutoData(rx_buffer, "Fri", 5);
                saveNVSData = readAutoData(rx_buffer, "Sat", 6);
                saveNVSData = readAutoData(rx_buffer, "Sun", 0);
                sprintf(rx_buffer, "GOODDATA");
            }
            else if (strstr(tmp, "PING"))
            {
                sprintf(rx_buffer, "PONG");
            }
            else if (strstr(tmp, "STOP"))
            {
                stopEventTrigerred = true;
                sprintf(rx_buffer, "GOODDATA");
            }
            else if (strstr(tmp, "ENCRYPT"))
            {
                // readWithEncryption = !readWithEncryption;
                sprintf(rx_buffer, "GOODDATA");
            }
        }
        checkMessageInput(rx_buffer);
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
    ESP_LOGI(TCP_TAG, "Message to send length %d : %s", strlen(tx_buffer), tx_buffer);
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
            tcpDisconnect = true;
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
    tcpDisconnect = false;
    ESP_LOGE(TCP_TAG, "Communication ended, Shutdown !");
    // Save Data when disconnecting
    saveDataTask(saveNVSData);
}

void TCPInit()
{
    char addr_str[128];
    struct sockaddr_storage dest_addr;
    struct sockaddr_in *dest_addr_ip4 = (struct sockaddr_in *)&dest_addr;
    dest_addr_ip4->sin_addr.s_addr = inet_addr(ADDRESS_TCP);
    dest_addr_ip4->sin_port = htons(PORT_TCP);
    dest_addr_ip4->sin_family = AF_INET;

    int listen_sock = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    if (listen_sock < 0)
    {
        ESP_LOGE(TCP_TAG, "Unable to create socket: errno %d", errno);
        vTaskDelete(NULL);
        return;
    }

    ESP_LOGI(TCP_TAG, "Socket created");

    int err = bind(listen_sock, (struct sockaddr *)&dest_addr, sizeof(dest_addr));
    if (err != 0)
    {
        ESP_LOGE(TCP_TAG, "Socket unable to bind: errno %d", errno);
        ESP_LOGE(TCP_TAG, "IPPROTO: %d", AF_INET);
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
    xTaskCreate(TCPInit, "TCPInit", 8192 * 4, NULL, 3, NULL);
}
