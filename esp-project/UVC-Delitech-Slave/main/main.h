/*
 * main.h
 *
 *  Created on: 19 août 2020
 *      Author: raki
 */

void LedStatInit();
void wifiConnectionClient();

int set_relay_state(int relay, uint32_t level);
int cntrl_states[4];
void generate_json();
char *json_unformatted;

#define delay(ms) (vTaskDelay(ms/portTICK_RATE_MS))

uint8_t strContains(char* string, char* toFind);

bool detectionTriggered;
bool stopIsPressed;
bool UVTreatementIsOn;

void UVCTreatement();

typedef struct {
	char UnitName[64];
	char Company[64];
	char OperatorName[64];
	char RoomName[64];
	uint8_t DisinfictionTime;
	uint8_t ActivationTime;
	char FLASH_MEMORY[3];
} UnitConfig_Typedef;

extern UnitConfig_Typedef UnitCfg;

void Default_saving();
int InitLoadCfg();
int SaveNVS(UnitConfig_Typedef *data);
