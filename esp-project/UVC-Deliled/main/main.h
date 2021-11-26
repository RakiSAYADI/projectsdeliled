/*
 * main.h
 *
 *  Created on: 19 août 2020
 *      Author: raki
 */

#ifndef MAIN_MAIN_H_
#define MAIN_MAIN_H_

#define UVCROBOTNAME "DEEPLIGHT-E007"
#define FIRMWAREVERSIONNAME "3.0.0"
#define VERSION 0

void bt_main();
void LedStatInit();
void BaseMacInit();

#define delay(ms) (vTaskDelay(ms/portTICK_RATE_MS))

int set_relay_state(int relay, uint32_t level);
int cntrl_states[4];
void generate_json();
char *json_unformatted;

uint8_t strContains(char* string, char* toFind);

bool detectionTriggered;
bool stopIsPressed;
bool stopEventTrigerred;
bool UVTaskIsOn;
bool UVTreatementIsOn;

void UVCTreatement();

typedef enum {
	State_OK,
	State_In_PROGRESS,
	State_Stopped
}desinfectionState;

typedef struct {
	char UnitName[64];
	char Company[64];
	char OperatorName[64];
	char RoomName[64];
	uint8_t Version;
	uint8_t DisinfictionTime;
	uint8_t ActivationTime;
	int UVCTimeExecution;
	int UVCLifeTime;
	int NumberOfDisinfection;
	bool SecurityCodeDismiss;
	char FirmwareVersion[7];
	char FLASH_MEMORY[3];
} UnitConfig_Typedef;

extern desinfectionState UVC_Treatement_State;
extern UnitConfig_Typedef UnitCfg;

void UVCSetStatus(desinfectionState NewStat);
void Default_saving();
int InitLoadCfg();
int SaveNVS(UnitConfig_Typedef *data);

#endif /* MAIN_MAIN_H_ */
