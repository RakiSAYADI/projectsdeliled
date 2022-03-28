/*
 * gpio.h
 *
 *  Created on: Oct 10, 2018
 *      Author: mdt
 */

#ifndef MAIN_APP_GPIO_H_
#define MAIN_APP_GPIO_H_

typedef enum {
	UNIT_STATUS_NONE,
	UNIT_STATUS_LOADING,
	UNIT_STATUS_ERROR,
	UNIT_STATUS_WIFI_INDEF,
	UNIT_STATUS_WIFI_AP,
	UNIT_STATUS_WIFI_STA,
	UNIT_STATUS_WIFI_GOT_IP,
	UNIT_STATUS_RADIO_ACTIVITY,
	UNIT_STATUS_NORMAL,
	UNIT_STATUS_WARNING_CO2,
	UNIT_STATUS_ALERT_CO2
} UnitStatDef;

void LedStatInit();
void UnitSetStatus(UnitStatDef NewStat);
void LockStatus(bool s);

#endif /* MAIN_APP_GPIO_H_ */
