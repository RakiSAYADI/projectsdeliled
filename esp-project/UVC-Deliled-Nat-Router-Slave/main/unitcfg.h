
#ifndef MAIN_UNITCFG_H_
#define MAIN_UNITCFG_H_

#define UVCROBOTNAME "DEEPLIGHT-Z001"
#define FIRMWAREVERSIONNAME "2.0.0"

#define delay(ms) (vTaskDelay(ms/portTICK_RATE_MS))

typedef struct {
	char UnitName[64];
	char Company[64];
	char OperatorName[64];
	char RoomName[64];
	uint32_t DisinfictionTime;
	uint32_t ActivationTime;
	char FirmwareVersion[7];
	char FLASH_MEMORY[3];
} UnitConfig_Typedef;

extern UnitConfig_Typedef UnitCfg;

void Default_saving();
bool InitLoadCfg();
bool SaveNVS(UnitConfig_Typedef *data);

#endif /* MAIN_UNITCFG_H_ */
