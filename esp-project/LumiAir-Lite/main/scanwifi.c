#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/event_groups.h"
#include "esp_wifi.h"
#include "esp_log.h"
#include "esp_event.h"
#include "nvs_flash.h"

#include "sdkconfig.h"

#include "scanwifi.h"

const char *SCAN_TAG = "SCAN_WIFI";

wifi_ap_record_t ap_info[MAX_APs];
uint16_t ap_count = 0;
bool scanResult = false;

void print_auth_mode(int authmode)
{
	switch (authmode)
	{
	case WIFI_AUTH_OPEN:
		ESP_LOGI(SCAN_TAG, "Authmode \tWIFI_AUTH_OPEN");
		break;
	case WIFI_AUTH_WEP:
		ESP_LOGI(SCAN_TAG, "Authmode \tWIFI_AUTH_WEP");
		break;
	case WIFI_AUTH_WPA_PSK:
		ESP_LOGI(SCAN_TAG, "Authmode \tWIFI_AUTH_WPA_PSK");
		break;
	case WIFI_AUTH_WPA2_PSK:
		ESP_LOGI(SCAN_TAG, "Authmode \tWIFI_AUTH_WPA2_PSK");
		break;
	case WIFI_AUTH_WPA_WPA2_PSK:
		ESP_LOGI(SCAN_TAG, "Authmode \tWIFI_AUTH_WPA_WPA2_PSK");
		break;
	case WIFI_AUTH_WPA2_ENTERPRISE:
		ESP_LOGI(SCAN_TAG, "Authmode \tWIFI_AUTH_WPA2_ENTERPRISE");
		break;
	case WIFI_AUTH_WPA3_PSK:
		ESP_LOGI(SCAN_TAG, "Authmode \tWIFI_AUTH_WPA3_PSK");
		break;
	case WIFI_AUTH_WPA2_WPA3_PSK:
		ESP_LOGI(SCAN_TAG, "Authmode \tWIFI_AUTH_WPA2_WPA3_PSK");
		break;
	default:
		ESP_LOGI(SCAN_TAG, "Authmode \tWIFI_AUTH_UNKNOWN");
		break;
	}
}

void print_cipher_type(int pairwise_cipher, int group_cipher)
{
	switch (pairwise_cipher)
	{
	case WIFI_CIPHER_TYPE_NONE:
		ESP_LOGI(SCAN_TAG, "Pairwise Cipher \tWIFI_CIPHER_TYPE_NONE");
		break;
	case WIFI_CIPHER_TYPE_WEP40:
		ESP_LOGI(SCAN_TAG, "Pairwise Cipher \tWIFI_CIPHER_TYPE_WEP40");
		break;
	case WIFI_CIPHER_TYPE_WEP104:
		ESP_LOGI(SCAN_TAG, "Pairwise Cipher \tWIFI_CIPHER_TYPE_WEP104");
		break;
	case WIFI_CIPHER_TYPE_TKIP:
		ESP_LOGI(SCAN_TAG, "Pairwise Cipher \tWIFI_CIPHER_TYPE_TKIP");
		break;
	case WIFI_CIPHER_TYPE_CCMP:
		ESP_LOGI(SCAN_TAG, "Pairwise Cipher \tWIFI_CIPHER_TYPE_CCMP");
		break;
	case WIFI_CIPHER_TYPE_TKIP_CCMP:
		ESP_LOGI(SCAN_TAG, "Pairwise Cipher \tWIFI_CIPHER_TYPE_TKIP_CCMP");
		break;
	default:
		ESP_LOGI(SCAN_TAG, "Pairwise Cipher \tWIFI_CIPHER_TYPE_UNKNOWN");
		break;
	}

	switch (group_cipher)
	{
	case WIFI_CIPHER_TYPE_NONE:
		ESP_LOGI(SCAN_TAG, "Group Cipher \tWIFI_CIPHER_TYPE_NONE");
		break;
	case WIFI_CIPHER_TYPE_WEP40:
		ESP_LOGI(SCAN_TAG, "Group Cipher \tWIFI_CIPHER_TYPE_WEP40");
		break;
	case WIFI_CIPHER_TYPE_WEP104:
		ESP_LOGI(SCAN_TAG, "Group Cipher \tWIFI_CIPHER_TYPE_WEP104");
		break;
	case WIFI_CIPHER_TYPE_TKIP:
		ESP_LOGI(SCAN_TAG, "Group Cipher \tWIFI_CIPHER_TYPE_TKIP");
		break;
	case WIFI_CIPHER_TYPE_CCMP:
		ESP_LOGI(SCAN_TAG, "Group Cipher \tWIFI_CIPHER_TYPE_CCMP");
		break;
	case WIFI_CIPHER_TYPE_TKIP_CCMP:
		ESP_LOGI(SCAN_TAG, "Group Cipher \tWIFI_CIPHER_TYPE_TKIP_CCMP");
		break;
	default:
		ESP_LOGI(SCAN_TAG, "Group Cipher \tWIFI_CIPHER_TYPE_UNKNOWN");
		break;
	}
}

void scanWIFITask()
{
	// WIFI Init State
	scanResult = false;

	uint16_t number = MAX_APs;
	memset(ap_info, 0, sizeof(ap_info));

	esp_wifi_scan_start(NULL, true);
	ESP_LOGI(SCAN_TAG, "Start scanning …");
	ESP_ERROR_CHECK(esp_wifi_scan_get_ap_records(&number, ap_info));
	ESP_LOGI(SCAN_TAG, "Scan Completed !");
	ESP_ERROR_CHECK(esp_wifi_scan_get_ap_num(&ap_count));
	ESP_LOGI(SCAN_TAG, "Total APs scanned = %u", ap_count);
	ESP_LOGI(SCAN_TAG, "———————————————————————————————————————————————————————————————");

	for (int i = 0; (i < MAX_APs) && (i < ap_count); i++)
	{
		ESP_LOGI(SCAN_TAG, "SSID \t\t%s", ap_info[i].ssid);
		ESP_LOGI(SCAN_TAG, "RSSI \t\t%d", ap_info[i].rssi);
		print_auth_mode(ap_info[i].authmode);
		if (ap_info[i].authmode != WIFI_AUTH_WEP)
		{
			print_cipher_type(ap_info[i].pairwise_cipher, ap_info[i].group_cipher);
		}
		ESP_LOGI(SCAN_TAG, "Channel \t\t%d\n", ap_info[i].primary);
	}

	ESP_LOGI(SCAN_TAG, "SCANNING WIFI IS COMPLETED \n");
	ESP_LOGI(SCAN_TAG, "———————————————————————————————————————————————————————————————");
	scanResult = true;
}
