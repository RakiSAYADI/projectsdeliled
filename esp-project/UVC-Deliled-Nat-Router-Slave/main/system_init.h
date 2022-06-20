/*
 * webserver.h
 *
 *  Created on: Apr 1, 2018
 *      Author: mdt
 */

#ifndef MAIN_SYSTEM_INIT_H_
#define MAIN_SYSTEM_INIT_H_

typedef enum {
	UNIT_STATUS_NONE,
	UNIT_STATUS_LOADING,
	UNIT_STATUS_UVC_ERROR,
	UNIT_STATUS_UVC_STARTING,
    UNIT_STATUS_UVC_TREATEMENT,
	UNIT_STATUS_IDLE
} UnitStatDef;

void systemInit(void);

void setUnitStatus(UnitStatDef NewStat);
UnitStatDef getUnitState();

#endif /* MAIN_SYSTEM_INIT_H_ */
