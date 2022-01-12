/*
 * main.h
 *
 *  Created on: 19 août 2020
 *      Author: raki
 */

#define UVCROBOTNAME "DEEPLIGHT-L001"
#define SSIDNAME "DEEPLIGHT-TEST001"
#define FIRMWAREVERSIONNAME "2.0.0"
#define ROBOTPASSWORD "123456789"

void LedStatInit();
void wifiConnectionClient();
void BaseMacInit();

int cntrl_states[4];
char *json_unformatted;
void generate_json();
void CheckingPressence(void *pvParameters);
int set_relay_state(int relay, uint32_t level);

#define delay(ms) (vTaskDelay(ms/portTICK_RATE_MS))

uint8_t strContains(char* string, char* toFind);

bool UVCThreadState;
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
	char FirmwareVersion[7];
	char FLASH_MEMORY[3];
} UnitConfig_Typedef;

extern UnitConfig_Typedef UnitCfg;

void Default_saving();
int InitLoadCfg();
int SaveNVS(UnitConfig_Typedef *data);
