#ifndef MAIN_SCANWIFI_H_
#define MAIN_SCANWIFI_H_

#define MAX_APs 10

extern bool scanResult;
extern uint16_t ap_count;
extern wifi_ap_record_t ap_info[MAX_APs];

void scanWIFITask(void);

#endif /* MAIN_WEBSERVICE_H_ */
