#ifndef MAIN_HTTPS_OTA_H_
#define MAIN_HTTPS_OTA_H_

void advanced_ota_task(void *pvParameter);

extern const uint8_t server_cert_pem_start[] asm("_binary_ca_cert_pem_start");
extern const uint8_t server_cert_pem_end[] asm("_binary_ca_cert_pem_end");
extern bool otaEnable;
extern bool otaNotNeeded;
extern uint8_t otaProgress;
extern bool otaIsDone;

#endif /* MAIN_HTTPS_OTA_H_ */
