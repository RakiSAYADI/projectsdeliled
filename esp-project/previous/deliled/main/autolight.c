/*
 * autolight.c
 *
 *  Created on: Feb 12, 2019
 *      Author: mdt
 */

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_log.h"
#include "driver/uart.h"
#include "driver/gpio.h"
#include "soc/uart_struct.h"
#include "string.h"
#include <stdio.h>
#include <string.h>
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <esp_log.h>
#include <esp_err.h>
#include <esp_system.h>
#include <esp_event_loop.h>
#include "esp_wifi.h"
#include <nvs.h>
#include <nvs_flash.h>
#include <driver/gpio.h>
#include <tcpip_adapter.h>
#include "sdkconfig.h"
#include "esp_system.h"
#include <stdlib.h>
#include <driver/dac.h>
#include <time.h>
#include <sys/time.h>
#include "math.h"

#include "sdkconfig.h"
#include "autolight.h"
#include "lightcontrol.h"
#include "unitcfg.h"
#include "adc.h"
#include "i2c.h"
#include "emailclient.h"
#include "webservice.h"
#include "app_gpio.h"
#include "unitcfg.h"

#define TAG "AUTOREG"


void Brightness_Light_Controller();
void Pir_MonitorTask();
void NoticeTimeoutRoutine();
void ColorTemp_Controller();
uint8_t Test_lum(uint8_t val);
uint8_t check_seuil(uint8_t val);
void checking_time();


AutoLightStateDef AutoLightState=AUTOL_STATE_OFF;
uint8_t SubStateIndex=0;

bool AutoBrightTaskExit=false;
bool AutoCCTaskExit=false;


int8_t days =0;
char days_previous[8];
time_t CurrentTime=0;

bool DacLightStatOn=false;
bool ManLightStatOn=false;

void SM_MoveToState(AutoLightStateDef ns,uint8_t sm)
{
	SubStateIndex=sm;
	AutoLightState=ns;
}

char txt0[64];
char txt1[64];
char txt2[64];
struct timeval tv;

struct tm now ={0};
struct tm trigtimeinfo ={0};
struct tm stoptimeinfo ={0};

uint8_t Curday;

TaskHandle_t BlcTaskHandler=NULL;
TaskHandle_t CcTaskHandler=NULL;

void checking_time()
{
	while(1)
		{
			vTaskDelay(1000 / portTICK_RATE_MS);
			printf("Info : Now %d @ %s start at : %s to %s our current time is %ld \n",Curday,txt0,txt1,txt2,CurrentTime);
		}
	vTaskDelete(NULL);
}

void AutoLightStateMachine()
{
	// Init Light Stat

	//Radio
	//MilightHandler(LCMD_SWITCH_ON_OFF,LSUBCMD_SWITCH_OFF,15);

	//0-10V
	dac_output_voltage(DAC_CHANNEL_1, 0);
	DacLightStatOn=false;
	SM_MoveToState(AUTOL_STATE_OFF,0);

	UnitData.unitStatus=UNIT_STAT_OFF;

	xTaskCreatePinnedToCore(&Pir_MonitorTask, "Pir_MonitorTask", 1024*2, NULL, 10, NULL,1);
	//xTaskCreatePinnedToCore(&checking_time, "checking_time", 1024*2, NULL, 2, NULL,1);
	
	if ((UnitCfg.state==UNIT_STAT_OFF)||(UnitCfg.state==UNIT_STAT_REG_AUTO))
	{
		SM_MoveToState(AUTOL_STATE_OFF,0);
	}
	else
	{
		SM_MoveToState(PROFILE_OFF_STATE,0);
	}

	while(1)
	{
		gettimeofday(&tv, NULL);

		//tv.tv_sec += (UnitCfg.UnitTimeZone*3600);

		//time(&CurrentTime);

		//CurrentTime=CurrentTime%(3600*24)+(UnitCfg.UnitTimeZone*3600);

		localtime_r(&tv.tv_sec, &now);
		strftime(txt0, sizeof(txt0), "%R", &now);

		gmtime_r(&UnitCfg.UserLcProfile.AutoTrigTime, &trigtimeinfo);
		gmtime_r(&UnitCfg.UserLcProfile.AutoStopTime, &stoptimeinfo);

		strftime(txt1, sizeof(txt1), "%R", &trigtimeinfo);
		strftime(txt2, sizeof(txt2), "%R", &stoptimeinfo);

		uint32_t cparttime=now.tm_hour*3600+now.tm_min*60;
		uint32_t trigparttime=trigtimeinfo.tm_hour*3600+trigtimeinfo.tm_min*60;
		uint32_t stopparttime=stoptimeinfo.tm_hour*3600+stoptimeinfo.tm_min*60;

		time(&CurrentTime);
		localtime_r(&CurrentTime, &now);
		Curday=now.tm_wday;

		uint16_t veille_trig_days =  strtol(UnitCfg.UserLcProfile.Veille_days,NULL,16);

		bool AutoTrigSameDay=false;

		//printf("Info : Now %d @ %s start at : %s to %s\n",Curday,txt0,txt1,txt2);

		if ((veille_trig_days&0x01)&&(Curday==0)) AutoTrigSameDay=true;
		if ((veille_trig_days&0x02)&&(Curday==6)) AutoTrigSameDay=true;
		if ((veille_trig_days&0x04)&&(Curday==5)) AutoTrigSameDay=true;
		if ((veille_trig_days&0x08)&&(Curday==4)) AutoTrigSameDay=true;
		if ((veille_trig_days&0x10)&&(Curday==3)) AutoTrigSameDay=true;
		if ((veille_trig_days&0x20)&&(Curday==2)) AutoTrigSameDay=true;
		if ((veille_trig_days&0x40)&&(Curday==1)) AutoTrigSameDay=true;



		switch(AutoLightState)
		{
			case  AUTOL_STATE_OFF :

				if (SubStateIndex==0)
				{
					UnitData.unitStatus=UNIT_STAT_OFF;
					ManLightStatOn = false;
					LumTestEnb = false;
					SubStateIndex++;

					if (BlcTaskHandler!=NULL) {vTaskDelete(BlcTaskHandler);BlcTaskHandler=NULL;}
					if (CcTaskHandler!=NULL) {vTaskDelete(CcTaskHandler);CcTaskHandler=NULL;}
				}
				else if (SubStateIndex==1)
				{
					if (UnitCfg.UserLcProfile.VeilleBrEnb)
					{
						if ((cparttime>=trigparttime)&&(cparttime<stopparttime)&&(AutoTrigSameDay==true))
							{
								PirDetectionOverride = true;

								uint16_t veille_zone_int =  strtol(UnitCfg.UserLcProfile.veille_zone,NULL,16);

								//radio
								MilightHandler(LCMD_SWITCH_ON_OFF,LSUBCMD_SWITCH_ON,veille_zone_int&0x0F);
								vTaskDelay(10 / portTICK_RATE_MS);
								MilightHandler(LCMD_SET_WHITE,0,veille_zone_int&0x0F);

								//0-10
								if (veille_zone_int&0x0010)
								{
									DacLightStatOn=true;
								}

								printf("AutoTrigger Timer Switch light on\n");
								printf("Info : Now %d @ %s start at : %s to %s\n",Curday,txt0,txt1,txt2);
								SM_MoveToState(AUTOL_STATE_REG,0);
							}
							else
							{
								if (PirOutCmd==1)
								{

									uint16_t veille_zone_int =  strtol(UnitCfg.UserLcProfile.veille_zone,NULL,16);

									//radio
									MilightHandler(LCMD_SWITCH_ON_OFF,LSUBCMD_SWITCH_ON,veille_zone_int&0x0F);
									vTaskDelay(10 / portTICK_RATE_MS);
									MilightHandler(LCMD_SET_WHITE,0,veille_zone_int&0x0F);
									vTaskDelay(10 / portTICK_RATE_MS);
									MilightHandler(LCMD_SET_BRIGTHNESS,50,veille_zone_int&0x0F);

									//0-10
									if (veille_zone_int&0x0010)
									{
										uint16_t dac_out=(50*255)/100;
										dac_output_voltage(DAC_CHANNEL_1, dac_out);
										DacLightStatOn=true;
									}

									printf("PIR Switch light on\n");
									SM_MoveToState(AUTOL_STATE_REG,0);
								}
							}
					}
				}

				break;

			case  AUTOL_STATE_REG :

				if (SubStateIndex==0)
				{
					ManLightStatOn = true;
					xTaskCreatePinnedToCore(&Brightness_Light_Controller, "Brightness_Light_Controller", 2048, NULL, 10, &BlcTaskHandler,1);
					xTaskCreatePinnedToCore(&ColorTemp_Controller, "ColorTemp_Controller", 2048, NULL, 10, &CcTaskHandler,1);
					SubStateIndex = 1;
				}
				else if (SubStateIndex == 1)
				{
					if (UnitCfg.UserLcProfile.VeilleBrEnb)
					{
						UnitData.unitStatus=UNIT_STAT_REG_AUTO;

						// stop by PIR
						if ((PirOutCmd==0)&&(PirDetectionOverride==false))
						{
							printf("PIR Timeout Switch to OFF\n");
							//Radio
							MilightHandler(LCMD_SWITCH_ON_OFF,LSUBCMD_SWITCH_OFF,15);
							//0-10V
							dac_output_voltage(DAC_CHANNEL_1, 0);
							DacLightStatOn=false;
							SM_MoveToState(AUTOL_STATE_OFF,0);
						}

						// stop by autostop timer
						if (((cparttime<trigparttime)||(cparttime>=stopparttime)||(AutoTrigSameDay==false))&&(PirDetectionOverride==true))
						{
							printf("Autostop pass hand to PIR\n");
							PirDetectionOverride=false;
						}
					}
				}

				break;

			case  MANL_STATE_OFF :

				if (SubStateIndex==0)
				{
					if (BlcTaskHandler!=NULL) {vTaskDelete(BlcTaskHandler);BlcTaskHandler=NULL;}
					if (CcTaskHandler!=NULL) {vTaskDelete(CcTaskHandler);CcTaskHandler=NULL;}

					UnitData.unitStatus=UNIT_STAT_OFF;
					SubStateIndex = 1;
				}
				else
				{
					if (ManLightStatOn==true)
						{
							SM_MoveToState(MANL_STATE_ON,0);
						}
				}

			break;

			case  MANL_STATE_ON :

				if (SubStateIndex==0)
				{
					xTaskCreatePinnedToCore(&Brightness_Light_Controller, "Brightness_Light_Controller", 2048, NULL, 10, &BlcTaskHandler,1);
					xTaskCreatePinnedToCore(&ColorTemp_Controller, "ColorTemp_Controller", 2048, NULL, 10, &CcTaskHandler,1);
					UnitData.unitStatus=UNIT_STAT_REG_MAN;
					SubStateIndex = 1;
				}
				else
				{
					if (ManLightStatOn==false)
						{
							SM_MoveToState(MANL_STATE_OFF,0);
						}
				}

			break;

			case  PROFILE_OFF_STATE :

				if (ManLightStatOn==false)
					{
						UnitData.unitStatus=UNIT_STAT_OFF;
					}
				else
					{
						UnitData.unitStatus=UNIT_STAT_REG_MAN;
					}

			break;


			default :
					printf("Light Switch to OFF\n");
					SM_MoveToState(AUTOL_STATE_OFF,0);
				break;
		}


		vTaskDelay(100 / portTICK_RATE_MS);
	}
}

// Brigthness Control routine

const uint8_t PID_Step=1;
int8_t PID_Out=100;
bool LumTestEnb=false;
uint8_t zone_lum=0;

uint8_t Test_lum(uint8_t val)
{
	if (val>100) return val=100;
	if (val<1) return val=1;
	return val;
}
uint8_t check_seuil(uint8_t val)
{
	if ((UnitCfg.UserLcProfile.seuil_eclairage)&&(val<20)){ return val=20;}
	else{return val;}
}


void Brightness_Light_Controller()
{
	AutoBrightTaskExit = false;

	while(AutoBrightTaskExit==false)
	{
		// alc
		if (UnitCfg.UserLcProfile.AutoBrEnb==true)
		{

			zone_lum = strtol(UnitCfg.UserLcProfile.Zone_lum,NULL,16);



			if ((zone_lum/16)==1)
			{
				if (OPT3001_HoldReg.result>UnitCfg.UserLcProfile.AutoBrRef)
				{ UnitCfg.UserLcProfile.FixedBrLevel_zone_010v-=PID_Step;uint16_t dac_out=(UnitCfg.UserLcProfile.FixedBrLevel_zone_010v*255)/100;dac_output_voltage(DAC_CHANNEL_1, dac_out); }
				if (OPT3001_HoldReg.result<UnitCfg.UserLcProfile.AutoBrRef)
				{ UnitCfg.UserLcProfile.FixedBrLevel_zone_010v+=PID_Step;uint16_t dac_out=(UnitCfg.UserLcProfile.FixedBrLevel_zone_010v*255)/100;dac_output_voltage(DAC_CHANNEL_1, dac_out); }
			}
			if (((zone_lum%16)/8)==1)
			{
				//MilightHandler(LCMD_SET_WHITE,UnitCfg.UserLcProfile.FixedBrLevel_zone4,4);
				if (OPT3001_HoldReg.result>UnitCfg.UserLcProfile.AutoBrRef)
				{ UnitCfg.UserLcProfile.FixedBrLevel_zone4-=PID_Step; MilightHandler(LCMD_SET_BRIGTHNESS,UnitCfg.UserLcProfile.FixedBrLevel_zone4,8);}
				if (OPT3001_HoldReg.result<UnitCfg.UserLcProfile.AutoBrRef)
				{ UnitCfg.UserLcProfile.FixedBrLevel_zone4+=PID_Step; MilightHandler(LCMD_SET_BRIGTHNESS,UnitCfg.UserLcProfile.FixedBrLevel_zone4,8);}
			}
			if (((zone_lum%8)/4)==1)
			{
				//MilightHandler(LCMD_SET_WHITE,UnitCfg.UserLcProfile.FixedBrLevel_zone3,3);
				if (OPT3001_HoldReg.result>UnitCfg.UserLcProfile.AutoBrRef)
				{ UnitCfg.UserLcProfile.FixedBrLevel_zone3-=PID_Step; MilightHandler(LCMD_SET_BRIGTHNESS,UnitCfg.UserLcProfile.FixedBrLevel_zone3,4);}
				if (OPT3001_HoldReg.result<UnitCfg.UserLcProfile.AutoBrRef)
				{ UnitCfg.UserLcProfile.FixedBrLevel_zone3+=PID_Step; MilightHandler(LCMD_SET_BRIGTHNESS,UnitCfg.UserLcProfile.FixedBrLevel_zone3,4);}
			}
			if (((zone_lum%4)/2)==1)
			{
				//MilightHandler(LCMD_SET_WHITE,UnitCfg.UserLcProfile.FixedBrLevel_zone2,2);
				if (OPT3001_HoldReg.result>UnitCfg.UserLcProfile.AutoBrRef)
				{ UnitCfg.UserLcProfile.FixedBrLevel_zone2-=PID_Step; MilightHandler(LCMD_SET_BRIGTHNESS,UnitCfg.UserLcProfile.FixedBrLevel_zone2,2);}
				if (OPT3001_HoldReg.result<UnitCfg.UserLcProfile.AutoBrRef)
				{ UnitCfg.UserLcProfile.FixedBrLevel_zone2+=PID_Step; MilightHandler(LCMD_SET_BRIGTHNESS,UnitCfg.UserLcProfile.FixedBrLevel_zone2,2);}
			}
			if ((zone_lum%2)==1)
			{
				//MilightHandler(LCMD_SET_WHITE,UnitCfg.UserLcProfile.FixedBrLevel_zone1,1);
				if (OPT3001_HoldReg.result>UnitCfg.UserLcProfile.AutoBrRef)
				{ UnitCfg.UserLcProfile.FixedBrLevel_zone1-=PID_Step; MilightHandler(LCMD_SET_BRIGTHNESS,UnitCfg.UserLcProfile.FixedBrLevel_zone1,1);}
				if (OPT3001_HoldReg.result<UnitCfg.UserLcProfile.AutoBrRef)
				{ UnitCfg.UserLcProfile.FixedBrLevel_zone1+=PID_Step; MilightHandler(LCMD_SET_BRIGTHNESS,UnitCfg.UserLcProfile.FixedBrLevel_zone1,1);}
			}

			UnitCfg.UserLcProfile.FixedBrLevel_zone_010v=Test_lum(UnitCfg.UserLcProfile.FixedBrLevel_zone_010v);
			UnitCfg.UserLcProfile.FixedBrLevel_zone4=Test_lum(UnitCfg.UserLcProfile.FixedBrLevel_zone4);
			UnitCfg.UserLcProfile.FixedBrLevel_zone3=Test_lum(UnitCfg.UserLcProfile.FixedBrLevel_zone3);
			UnitCfg.UserLcProfile.FixedBrLevel_zone2=Test_lum(UnitCfg.UserLcProfile.FixedBrLevel_zone2);
			UnitCfg.UserLcProfile.FixedBrLevel_zone1=Test_lum(UnitCfg.UserLcProfile.FixedBrLevel_zone1);

			UnitCfg.UserLcProfile.FixedBrLevel_zone_010v=check_seuil(UnitCfg.UserLcProfile.FixedBrLevel_zone_010v);
			UnitCfg.UserLcProfile.FixedBrLevel_zone4=check_seuil(UnitCfg.UserLcProfile.FixedBrLevel_zone4);
			UnitCfg.UserLcProfile.FixedBrLevel_zone3=check_seuil(UnitCfg.UserLcProfile.FixedBrLevel_zone3);
			UnitCfg.UserLcProfile.FixedBrLevel_zone2=check_seuil(UnitCfg.UserLcProfile.FixedBrLevel_zone2);
			UnitCfg.UserLcProfile.FixedBrLevel_zone1=check_seuil(UnitCfg.UserLcProfile.FixedBrLevel_zone1);

			ESP_LOGI(TAG, "BLC TASK %0.0f,%d,%d,%d,%d,%d,%d",OPT3001_HoldReg.result,UnitCfg.UserLcProfile.AutoBrRef,
					UnitCfg.UserLcProfile.FixedBrLevel_zone1,UnitCfg.UserLcProfile.FixedBrLevel_zone2,
					UnitCfg.UserLcProfile.FixedBrLevel_zone3,UnitCfg.UserLcProfile.FixedBrLevel_zone4,
					UnitCfg.UserLcProfile.FixedBrLevel_zone_010v);

			UnitData.auto_zone_1=UnitCfg.UserLcProfile.FixedBrLevel_zone1;
			UnitData.auto_zone_2=UnitCfg.UserLcProfile.FixedBrLevel_zone2;
			UnitData.auto_zone_3=UnitCfg.UserLcProfile.FixedBrLevel_zone3;
			UnitData.auto_zone_4=UnitCfg.UserLcProfile.FixedBrLevel_zone4;
			UnitData.auto_zone_010V=UnitCfg.UserLcProfile.FixedBrLevel_zone_010v;
		}

		vTaskDelay(1200 / portTICK_RATE_MS);
	}

	ESP_LOGI(TAG, "BLC TASK EXIT");
	vTaskDelete(NULL);
}


// Color temp Control routine

int8_t CtempOut=0;

CCTestStruct_Typedef CCTestStruct;

void ColorTemp_Controller()
{

	float h1=0,h2=0,h3=0;
	float t1=0,t2=0,t3=0;

	float a1=0,b1=0;
	float a2=0,b2=0;

	time_t now=0;

	CCTestStruct.CcEnb=false;
	AutoCCTaskExit = false;

	while(AutoCCTaskExit==false)
	{

		if ((UnitCfg.UserLcProfile.CcEnb==true)&&(CCTestStruct.CcEnb==false))
		{

			time(&now);
			now=now%(3600*24)+(UnitCfg.UnitTimeZone*3600);

			h1=UnitCfg.UserLcProfile.Ccp[0].CcTime;
			h2=UnitCfg.UserLcProfile.Ccp[1].CcTime;
			h3=UnitCfg.UserLcProfile.Ccp[2].CcTime;

			t1=UnitCfg.UserLcProfile.Ccp[0].CcLevel;
			t2=UnitCfg.UserLcProfile.Ccp[1].CcLevel;
			t3=UnitCfg.UserLcProfile.Ccp[2].CcLevel;

			if (h2!=h1)
				{
					a1=(t2-t1)/(h2-h1);
					b1=t1-(a1*h1);
				}
			else
				{
					a1=0;
					b1=t1=UnitCfg.UserLcProfile.Ccp[0].CcLevel;
				}

			if (h3!=h2)
				{
					a2=(t3-t2)/(h3-h2);
					b2=t2-(a2*h2);
				}
			else
				{
					a2=0;
					b2=UnitCfg.UserLcProfile.Ccp[1].CcLevel;
				}

			// actc
			if (UnitCfg.UserLcProfile.CcEnb==true)
			{
				if ((now>=h1)&&(now<h2))
				{
					CtempOut=a1*now+b1;
					if (CtempOut>100) CtempOut = 100;
					if (CtempOut<0) CtempOut = 0;
				}
				else if ((now>h2)&&(now<=h3))
				{
					CtempOut=a2*now+b2;
					if (CtempOut>100) CtempOut = 100;
					if (CtempOut<0) CtempOut = 0;
				}
				else
				{
					CtempOut=UnitCfg.UserLcProfile.Ccp[2].CcLevel;
				}
			}
			else
			{
				CtempOut = 0;
			}

			ESP_LOGI(TAG, "ACTC Level %d @ %ld",CtempOut,now);
			/*printf("ACTC Level %d @ %ld h1 %d h2 %d h3 %d t1 %d t2 %d t3 %d a1 %f b1 %f a2 %f b2 %f \n"
					     ,CtempOut,now,(uint32_t)h1,(uint32_t)h2,(uint32_t)h3,(uint32_t)t1,(uint32_t)t2,(uint32_t)t3,a1,b1,a2,b2);*/

			uint16_t cc_zone_int =  strtol(UnitCfg.UserLcProfile.ZoneCc,NULL,16);

			MilightHandler(LCMD_SWITCH_ON_OFF,LSUBCMD_SWITCH_ON,cc_zone_int);

			MilightHandler(LCMD_SET_BRIGTHNESS,100,cc_zone_int);

			MilightHandler(LCMD_SET_TEMP,(uint8_t) CtempOut,cc_zone_int);
		}

		if (CCTestStruct.CcEnb==true)
		{
			h1=CCTestStruct.Ccp[0].CcTime;
			h2=CCTestStruct.Ccp[1].CcTime;
			h3=CCTestStruct.Ccp[2].CcTime;

			now=h1+(((h3-h1)*CCTestStruct.SimTime)/100.0);


			t1=CCTestStruct.Ccp[0].CcLevel;
			t2=CCTestStruct.Ccp[1].CcLevel;
			t3=CCTestStruct.Ccp[2].CcLevel;

			if (h2!=h1)
				{
					a1=(t2-t1)/(h2-h1);
					b1=t1-(a1*h1);
				}
			else
				{
					a1=0;
					b1=t1=CCTestStruct.Ccp[0].CcLevel;
				}

			if (h3!=h2)
				{
					a2=(t3-t2)/(h3-h2);
					b2=t2-(a2*h2);
				}
			else
				{
					a2=0;
					b2=CCTestStruct.Ccp[1].CcLevel;
				}

			// actc
			if (CCTestStruct.CcEnb==true)
			{
				if ((now>h1)&&(now<h2))
				{
					CtempOut=a1*now+b1;
					if (CtempOut>100) CtempOut = 100;
					if (CtempOut<0) CtempOut = 0;
				}
				else if ((now>h2)&&(now<h3))
				{
					CtempOut=a2*now+b2;
					if (CtempOut>100) CtempOut = 100;
					if (CtempOut<0) CtempOut = 0;
				}
				else
				{
					CtempOut=CCTestStruct.Ccp[2].CcLevel;
				}
			}
			else
			{
				ESP_LOGI(TAG, "INIT out cycle \n");
				CtempOut = 0;
			}

			ESP_LOGI(TAG, "ACTC Test Level %d @ %ld",CtempOut,now);
			/*printf("ACTC Test Level %d @ %ld h1 %d h2 %d h3 %d t1 %d t2 %d t3 %d a1 %f b1 %f a2 %f b2 %f \n"
					,CtempOut,now,(uint32_t)h1,(uint32_t)h2,(uint32_t)h3,(uint32_t)t1,(uint32_t)t2,(uint32_t)t3,a1,b1,a2,b2);*/

			uint16_t cc_zone_int =  strtol(CCTestStruct.ZoneCc,NULL,16);

			MilightHandler(LCMD_SET_TEMP,(uint8_t) CtempOut,cc_zone_int&0x0F);
		}

			vTaskDelay(1000 / portTICK_RATE_MS);
	}

	ESP_LOGI(TAG, "ACTC TASK EXIT");
	vTaskDelete(NULL);
}

// PIR Low level Handler
/*
bool NoticeTimeoutTask=false;
time_t NoticeTimeout=0;

void NoticeTimeoutRoutine()
{
	NoticeTimeoutTask=true;
	NoticeTimeout=UnitCfg.UserLcProfile.NoticeTimeout;
	ESP_LOGI(TAG, "Notice TimerTask +%ld",NoticeTimeout);

	while((NoticeTimeout>0)&&(NoticeTimeoutTask==true))
	{
		NoticeTimeout--;
		vTaskDelay(1000 / portTICK_RATE_MS);
	}

	ESP_LOGI(TAG, "Notice TimerTask Exit %ld %d",NoticeTimeout,NoticeTimeoutTask);
	NoticeTimeoutTask=false;
	vTaskDelete(NULL);
}
*/
bool PirTimeoutTask=false;
time_t PirTimeout=0;
bool PirOutCmd=false;
bool PirDetectionOverride=false;

void PirTimeoutRoutine()
{
	PirTimeoutTask=true;
	PirOutCmd=true;

	while(PirTimeout>0)
	{
		PirTimeout--;
		vTaskDelay(1000 / portTICK_RATE_MS);
	}

	PirOutCmd=false;
	PirTimeoutTask=false;
	vTaskDelete(NULL);
}


void Pir_MonitorTask()
{
	//pir
	while(1)
	{
		if (PirFlag==1)
		{
			PirFlag=0;
			PirTimeout=UnitCfg.UserLcProfile.NoticeTimeout;
			if (PirTimeout==0) {PirTimeout=5;}
			//ESP_LOGI(TAG, "PIR Triggered + %ld",PirTimeout);
			if (PirTimeoutTask==false)
				{
				xTaskCreatePinnedToCore(&PirTimeoutRoutine, "PirTimeoutRoutine", 2048, NULL, 1, NULL,1);
				}
		}

		vTaskDelay(1000 / portTICK_RATE_MS);
	}
}



// CO2
uint8_t zone =0;
bool co2_alert_enable=false;
bool co2_triger_alert=false;

void Co2_MonitorTask()
{

	while(1)
	{
		zone = strtol(UnitCfg.Co2LevelSelect,NULL,16);
		//co2
		if (UnitCfg.Co2LevelWarEnb==true)
		{
			if ((iaq_data.pred>UnitCfg.Co2LevelWar)&&(co2_alert_enable==0))
			{
				co2_alert_enable=1;
				co2_triger_alert=true;
				MilightHandler(LCMD_SWITCH_ON_OFF,LSUBCMD_SWITCH_ON,0);
				MilightHandler(LCMD_SET_MODE,6,zone);
				printf("Co2 Warning triggered\r\n");
		        //email
				if (WifiConnectedFlag==true)
				{
					xTaskCreatePinnedToCore(&email_task, "email_task",16000 , NULL, 1, NULL,1);
				}
			}

			if ((iaq_data.pred<UnitCfg.Co2LevelWar)&&(co2_alert_enable==1))
			{
				printf("Co2 Warning off\r\n");
				co2_alert_enable=0;
				MilightHandler(LCMD_SET_WHITE,0,zone&0x0F);
				co2_triger_alert=false;
			}

			if (iaq_data.pred<1700)
			{
				UnitSetStatus(UNIT_STATUS_NORMAL);
			}
			else if (iaq_data.pred<2000)
			{
				UnitSetStatus(UNIT_STATUS_WARNING_CO2);
			}
			else
			{
				UnitSetStatus(UNIT_STATUS_ALERT_CO2);
			}
		}
		vTaskDelay(1000 / portTICK_RATE_MS);
	}
}

