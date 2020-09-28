/*
 * autolight.h
 *
 *  Created on: Feb 12, 2019
 *      Author: mdt
 */

#ifndef MAIN_AUTOLIGHT_H_
#define MAIN_AUTOLIGHT_H_

#include "unitcfg.h"

typedef struct {
	bool CcEnb;
	char ZoneCc[2];
	CcPoint_Typedef Ccp[3];
	uint8_t SimTime;
} CCTestStruct_Typedef;

typedef enum {
	AUTOL_STATE_OFF, AUTOL_STATE_REG
} AutoLightStateDef;

bool NoticeTimeoutTask;
time_t NoticeTimeout;
extern bool PirOutCmd;
extern bool PirDetectionOverride;
extern bool LightStatUserTakeover;
extern bool LightManualOn;
extern bool ScenesAlive;
extern AutoLightStateDef AutoLightState;
extern bool co2_alert_enable;
extern CCTestStruct_Typedef CCTestStruct;
extern bool LumTestEnb;
extern bool AutoBrightTaskExit;
extern bool AutoCCTaskExit;

void AutoLightStateMachine();
void Co2_MonitorTask();
void SM_MoveToState(AutoLightStateDef ns);

void Scenes();

#endif /* MAIN_AUTOLIGHT_H_ */
