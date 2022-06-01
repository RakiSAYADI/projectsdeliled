/* Console example

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.
*/

#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include "esp_system.h"
#include "esp_log.h"
#include "esp_vfs_dev.h"
#include "linenoise/linenoise.h"
#include "argtable3/argtable3.h"
#include "esp_vfs_fat.h"
#include "nvs.h"
#include "nvs_flash.h"

#include "sdkconfig.h"
#include "unitcfg.h"
#include "nat_router.h"
#include "system_init.h"

#include "freertos/event_groups.h"
#include "esp_wifi.h"

#include "lwip/opt.h"
#include "lwip/err.h"
#include "lwip/sys.h"

#include <esp_http_server.h>

#include "lwip/lwip_napt.h"

/* FreeRTOS event group to signal when we are connected*/
EventGroupHandle_t wifi_event_group;

/* The event group allows multiple bits for each event, but we only care about one event
 * - are we connected to the AP with an IP? */
const int WIFI_CONNECTED_BIT = BIT0;

uint32_t my_ip;
uint32_t my_ap_ip;

esp_netif_t *wifiAP;
esp_netif_t *wifiSTA;

uint16_t CONNECT_COUNT = 0;
bool AP_CONNECT = false;

const char *NAT_TAG = "ESP32 NAT router";

esp_err_t wifi_event_handler(void *ctx, system_event_t *event)
{
    esp_netif_dns_info_t dns;

    ESP_LOGI(NAT_TAG, "event id: %d" ,event->event_id);

    switch (event->event_id)
    {
    case SYSTEM_EVENT_STA_START:
        esp_wifi_connect();
        break;
    case SYSTEM_EVENT_STA_GOT_IP:
        AP_CONNECT = true;
        ESP_LOGI(NAT_TAG, "got ip:" IPSTR, IP2STR(&event->event_info.got_ip.ip_info.ip));
        my_ip = event->event_info.got_ip.ip_info.ip.addr;
        if (esp_netif_get_dns_info(wifiSTA, ESP_NETIF_DNS_MAIN, &dns) == ESP_OK)
        {
            dhcps_dns_setserver((const ip_addr_t *)&dns.ip);
            ESP_LOGI(NAT_TAG, "set dns to:" IPSTR, IP2STR(&dns.ip.u_addr.ip4));
        }
        xEventGroupSetBits(wifi_event_group, WIFI_CONNECTED_BIT);
        break;
    case SYSTEM_EVENT_STA_DISCONNECTED:
        ESP_LOGI(NAT_TAG, "disconnected - retry to connect to the AP");
        AP_CONNECT = false;
        esp_wifi_connect();
        xEventGroupClearBits(wifi_event_group, WIFI_CONNECTED_BIT);
        break;
    case SYSTEM_EVENT_AP_STACONNECTED:
        CONNECT_COUNT++;
        ESP_LOGI(NAT_TAG, "%d. station connected", CONNECT_COUNT);
        break;
    case SYSTEM_EVENT_AP_STADISCONNECTED:
        CONNECT_COUNT--;
        ESP_LOGI(NAT_TAG, "station disconnected - %d remain", CONNECT_COUNT);
        break;
    default:
        break;
    }
    return ESP_OK;
}

const int CONNECTED_BIT = BIT0;
#define JOIN_TIMEOUT_MS (2000)

void wifi_init(const char *ssid,
               const char *passwd,
               const char *static_ip,
               const char *subnet_mask,
               const char *gateway_addr,
               const char *ap_ssid,
               const char *ap_passwd,
               const char *ap_ip)
{
    ip_addr_t dnsserver;

    wifi_event_group = xEventGroupCreate();
    wifiAP = esp_netif_create_default_wifi_ap();
    wifiSTA = esp_netif_create_default_wifi_sta();

    tcpip_adapter_ip_info_t ipInfo_sta;
    if ((strlen(ssid) > 0) && (strlen(static_ip) > 0) && (strlen(subnet_mask) > 0) && (strlen(gateway_addr) > 0))
    {
        my_ip = ipInfo_sta.ip.addr = ipaddr_addr(static_ip);
        ipInfo_sta.gw.addr = ipaddr_addr(gateway_addr);
        ipInfo_sta.netmask.addr = ipaddr_addr(subnet_mask);
        tcpip_adapter_dhcpc_stop(TCPIP_ADAPTER_IF_STA); // Don't run a DHCP client
        tcpip_adapter_set_ip_info(TCPIP_ADAPTER_IF_STA, &ipInfo_sta);
    }

    my_ap_ip = ipaddr_addr(ap_ip);

    esp_netif_ip_info_t ipInfo_ap;
    ipInfo_ap.ip.addr = my_ap_ip;
    ipInfo_ap.gw.addr = my_ap_ip;
    IP4_ADDR(&ipInfo_ap.netmask, 255, 255, 255, 0);
    esp_netif_dhcps_stop(wifiAP); // stop before setting ip WifiAP
    esp_netif_set_ip_info(wifiAP, &ipInfo_ap);
    esp_netif_dhcps_start(wifiAP);

    ESP_ERROR_CHECK(esp_event_loop_init(wifi_event_handler, NULL));

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));

    /* ESP WIFI CONFIG */
    wifi_config_t wifi_config = {0};
    wifi_config_t ap_config = {
        .ap = {
            .channel = 0,
            .authmode = WIFI_AUTH_WPA2_PSK,
            .ssid_hidden = 0,
            .max_connection = 8,
            .beacon_interval = 100,
        }};

    strlcpy((char *)ap_config.sta.ssid, ap_ssid, sizeof(ap_config.sta.ssid));
    if (strlen(ap_passwd) < 8)
    {
        ap_config.ap.authmode = WIFI_AUTH_OPEN;
    }
    else
    {
        strlcpy((char *)ap_config.sta.password, ap_passwd, sizeof(ap_config.sta.password));
    }

    if (strlen(ssid) > 0)
    {
        strlcpy((char *)wifi_config.sta.ssid, ssid, sizeof(wifi_config.sta.ssid));
        strlcpy((char *)wifi_config.sta.password, passwd, sizeof(wifi_config.sta.password));
        ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_APSTA));
        ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_STA, &wifi_config));
    }
    else
    {
        ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_AP));
    }

    ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_AP, &ap_config));

    // Enable DNS (offer) for dhcp server
    dhcps_offer_t dhcps_dns_value = OFFER_DNS;
    dhcps_set_option_info(6, &dhcps_dns_value, sizeof(dhcps_dns_value));

    // Set custom dns server address for dhcp server
    dnsserver.u_addr.ip4.addr = ipaddr_addr(DEFAULT_DNS);
    dnsserver.type = IPADDR_TYPE_V4;
    dhcps_dns_setserver(&dnsserver);

    xEventGroupWaitBits(wifi_event_group, CONNECTED_BIT, pdFALSE, pdTRUE, JOIN_TIMEOUT_MS / portTICK_PERIOD_MS);

    ESP_ERROR_CHECK(esp_wifi_start());

    if (strlen(ssid) > 0)
    {
        ESP_LOGI(NAT_TAG, "wifi_init_apsta finished.");
        ESP_LOGI(NAT_TAG, "connect to ap SSID: %s ", ssid);
    }
    else
    {
        ESP_LOGI(NAT_TAG, "wifi_init_ap with default finished.");
    }
}

void natRouter(void)
{
    // Setup WIFI
    wifi_init(UnitCfg.WifiCfg.STA_SSID,
              UnitCfg.WifiCfg.STA_PASS,
              UnitCfg.WifiCfg.STA_IP_STATIC,
              UnitCfg.WifiCfg.STA_SUBNET_MASK,
              UnitCfg.WifiCfg.STA_GATEWAY,
              UnitCfg.WifiCfg.AP_SSID,
              UnitCfg.WifiCfg.AP_PASS,
              UnitCfg.WifiCfg.AP_IP);

    ip_napt_enable(my_ap_ip, 1);
    ESP_LOGI(NAT_TAG, "NAT is enabled");
}
