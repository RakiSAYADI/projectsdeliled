/*
 * autolight.h
 *
 *  Created on: Feb 12, 2019
 *      Author: mdt
 */

#ifndef MAIN_AUTOLIGHT_H_
#define MAIN_AUTOLIGHT_H_

#include "unitcfg.h"

typedef struct
{
	bool CcEnb;
	char ZoneCc[2];
	CcPoint_Typedef Ccp[3];
	uint8_t SimTime;
}CCTestStruct_Typedef;

typedef enum
{
	AUTOL_STATE_OFF,
	AUTOL_STATE_REG,
	MANL_STATE_ON,
	MANL_STATE_OFF,
	PROFILE_OFF_STATE
} AutoLightStateDef;

bool NoticeTimeoutTask;
time_t NoticeTimeout;
extern bool PirOutCmd;
extern bool PirDetectionOverride;
extern AutoLightStateDef AutoLightState;
extern bool co2_alert_enable;
extern bool DacLightStatOn;
extern bool ManLightStatOn;
extern CCTestStruct_Typedef CCTestStruct;
extern bool LumTestEnb;
extern bool AutoBrightTaskExit;
extern bool AutoCCTaskExit;

extern TaskHandle_t BlcTaskHandler;
extern TaskHandle_t CcTaskHandler;



void AutoLightStateMachine();
void Co2_MonitorTask();
void SM_MoveToState(AutoLightStateDef ns,uint8_t sm);

#endif /* MAIN_AUTOLIGHT_H_ */
