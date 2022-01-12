/*
 * sntp_client.h
 *
 *  Created on: Dec 26, 2018
 *      Author: mdt
 */

#ifndef MAIN_SNTP_CLIENT_H_
#define MAIN_SNTP_CLIENT_H_

extern bool sntpTimeSetFlag;
extern time_t sntp_now;
extern struct tm sntp_timeinfo;

void sntp_task();

#endif /* MAIN_SNTP_CLIENT_H_ */
