#include <esp_wifi.h>
#include <esp_event.h>
#include <esp_log.h>
#include <esp_system.h>
#include <esp_timer.h>
#include <sys/param.h>
#include "esp_netif.h"

#include <esp_http_server.h>

#include "web_pages/admin_page.h"
#include "unitcfg.h"
#include "http_server.h"

const char *HTTP_TAG = "HTTPServer";

void preprocessString(char *str)
{
    char *p, *q;

    for (p = q = str; *p != 0; p++)
    {
        if (*(p) == '%' && *(p + 1) != 0 && *(p + 2) != 0)
        {
            // quoted hex
            uint8_t a;
            p++;
            if (*p <= '9')
                a = *p - '0';
            else
                a = toupper((unsigned char)*p) - 'A' + 10;
            a <<= 4;
            p++;
            if (*p <= '9')
                a += *p - '0';
            else
                a += toupper((unsigned char)*p) - 'A' + 10;
            *q++ = a;
        }
        else if (*(p) == '+')
        {
            *q++ = ' ';
        }
        else
        {
            *q++ = *p;
        }
    }
    *q = '\0';
}

/* An HTTP GET handler */
esp_err_t indexGetHandler(httpd_req_t *req)
{
    char *buf;
    size_t buf_len;

    /* Get header value string length and allocate memory for length + 1,
     * extra byte for null termination */
    buf_len = httpd_req_get_hdr_value_len(req, "Host") + 1;
    if (buf_len > 1)
    {
        buf = malloc(buf_len);
        /* Copy null terminated value string into buffer */
        if (httpd_req_get_hdr_value_str(req, "Host", buf, buf_len) == ESP_OK)
        {
            ESP_LOGI(HTTP_TAG, "Found header => Host: %s", buf);
        }
        free(buf);
    }

    /* Read URL query string length and allocate memory for length + 1,
     * extra byte for null termination */
    buf_len = httpd_req_get_url_query_len(req) + 1;
    if (buf_len > 1)
    {
        buf = malloc(buf_len);
        if (httpd_req_get_url_query_str(req, buf, buf_len) == ESP_OK)
        {
            ESP_LOGI(HTTP_TAG, "Found URL query => %s", buf);
            if (strcmp(buf, "reset=Reboot") == 0)
            {
                esp_restart();
            }
            char param1[64];
            char param2[64];
            char param3[64];
            /* Get value of expected key from query string */
            if (httpd_query_key_value(buf, "ap_ssid", param1, sizeof(param1)) == ESP_OK)
            {
                ESP_LOGI(HTTP_TAG, "Found URL query parameter => ap_ssid=%s", param1);
                preprocessString(param1);
                if (httpd_query_key_value(buf, "ap_password", param2, sizeof(param2)) == ESP_OK)
                {
                    ESP_LOGI(HTTP_TAG, "Found URL query parameter => ap_password=%s", param2);
                    preprocessString(param2);
                    sprintf(UnitCfg.WifiCfg.AP_SSID, param1);
                    sprintf(UnitCfg.WifiCfg.AP_PASS, param2);
                    ESP_LOGI(HTTP_TAG, "ssid=%s => password=%s", UnitCfg.WifiCfg.AP_SSID, UnitCfg.WifiCfg.AP_PASS);
                    saveDataTask(true);
                    esp_restart();
                }
            }
            if (httpd_query_key_value(buf, "ssid", param1, sizeof(param1)) == ESP_OK)
            {
                ESP_LOGI(HTTP_TAG, "Found URL query parameter => ssid=%s", param1);
                preprocessString(param1);
                if (httpd_query_key_value(buf, "password", param2, sizeof(param2)) == ESP_OK)
                {
                    ESP_LOGI(HTTP_TAG, "Found URL query parameter => password=%s", param2);
                    preprocessString(param2);
                    sprintf(UnitCfg.WifiCfg.STA_SSID, param1);
                    sprintf(UnitCfg.WifiCfg.STA_PASS, param2);
                    ESP_LOGI(HTTP_TAG, "ssid=%s => password=%s", UnitCfg.WifiCfg.STA_SSID, UnitCfg.WifiCfg.STA_PASS);
                    saveDataTask(true);
                    esp_restart();
                }
            }
            if (httpd_query_key_value(buf, "staticip", param1, sizeof(param1)) == ESP_OK)
            {
                ESP_LOGI(HTTP_TAG, "Found URL query parameter => staticip=%s", param1);
                preprocessString(param1);
                if (httpd_query_key_value(buf, "subnetmask", param2, sizeof(param2)) == ESP_OK)
                {
                    ESP_LOGI(HTTP_TAG, "Found URL query parameter => subnetmask=%s", param2);
                    preprocessString(param2);
                    if (httpd_query_key_value(buf, "gateway", param3, sizeof(param3)) == ESP_OK)
                    {
                        ESP_LOGI(HTTP_TAG, "Found URL query parameter => gateway=%s", param3);
                        preprocessString(param3);
                        sprintf(UnitCfg.WifiCfg.STA_IP_STATIC, param1);
                        sprintf(UnitCfg.WifiCfg.STA_SUBNET_MASK, param2);
                        sprintf(UnitCfg.WifiCfg.STA_GATEWAY, param3);
                        ESP_LOGI(HTTP_TAG, "ip static =%s => subnet mask =%s => gateway =%s",
                                 UnitCfg.WifiCfg.STA_IP_STATIC,
                                 UnitCfg.WifiCfg.STA_SUBNET_MASK,
                                 UnitCfg.WifiCfg.STA_GATEWAY);
                        saveDataTask(true);
                        esp_restart();
                    }
                }
            }
        }
        free(buf);
    }
    /* Send response with custom headers and body set as the
     * string passed in user context*/
    const char *resp_str = (const char *)req->user_ctx;
    httpd_resp_send(req, resp_str, strlen(resp_str));
    return ESP_OK;
}

httpd_uri_t indexp = {
    .uri = "/",
    .method = HTTP_GET,
    .handler = indexGetHandler,
};

esp_err_t http_404_error_handler(httpd_req_t *req, httpd_err_code_t err)
{
    httpd_resp_send_err(req, HTTPD_404_NOT_FOUND, "Page not found");
    return ESP_FAIL;
}

void startWebserver(void)
{
    httpd_handle_t server = NULL;
    httpd_config_t config = HTTPD_DEFAULT_CONFIG();

    const char *config_page_template = CONFIG_PAGE;
    char *config_page = malloc(strlen(config_page_template) + 512);
    sprintf(config_page, config_page_template,
            UnitCfg.WifiCfg.AP_SSID,
            UnitCfg.WifiCfg.AP_PASS,
            UnitCfg.WifiCfg.STA_SSID,
            UnitCfg.WifiCfg.STA_PASS,
            UnitCfg.WifiCfg.STA_IP_STATIC,
            UnitCfg.WifiCfg.STA_SUBNET_MASK,
            UnitCfg.WifiCfg.STA_GATEWAY);
    indexp.user_ctx = config_page;

    // Start the httpd server
    ESP_LOGI(HTTP_TAG, "Starting server on port: '%d'", config.server_port);
    if (httpd_start(&server, &config) == ESP_OK)
    {
        // Set URI handlers
        ESP_LOGI(HTTP_TAG, "Registering URI handlers");
        httpd_register_uri_handler(server, &indexp);
    }
    else
    {

        ESP_LOGE(HTTP_TAG, "Error starting server!");
    }
}

void stopWebserver(httpd_handle_t server)
{
    // Stop the httpd server
    httpd_stop(server);
}
