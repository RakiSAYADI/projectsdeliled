/*
 * autolight.h
 *
 *  Created on: Feb 12, 2019
 *      Author: mdt
 */

#ifndef MAIN_AUTOLIGHT_H_
#define MAIN_AUTOLIGHT_H_

#include "unitcfg.h"

typedef enum {
	AUTOL_STATE_OFF, AUTOL_STATE_REG
} AutoLightStateDef;

bool NoticeTimeoutTask;
time_t NoticeTimeout;
extern bool PirOutCmd;
extern bool PirDetectionOverride;
extern AutoLightStateDef AutoLightState;
extern bool co2_alert_enable;

void AutoLightStateMachine();
void Co2_MonitorTask();
void SM_MoveToState(AutoLightStateDef ns);

#endif /* MAIN_AUTOLIGHT_H_ */
