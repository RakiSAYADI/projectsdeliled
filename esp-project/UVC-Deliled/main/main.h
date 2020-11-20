/*
 * main.h
 *
 *  Created on: 19 août 2020
 *      Author: raki
 */

#define UVCROBOTNAME "DEEPLIGHT-G005"
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
	char FLASH_MEMORY[3];
} UnitConfig_Typedef;

extern UnitConfig_Typedef UnitCfg;

void Default_saving();
int InitLoadCfg();
int SaveNVS(UnitConfig_Typedef *data);
