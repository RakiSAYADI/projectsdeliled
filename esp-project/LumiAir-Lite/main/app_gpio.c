#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"
#include "driver/ledc.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_log.h"
#include "esp_event.h"

#include "lwip/err.h"
#include "lwip/sys.h"

#include "sdkconfig.h"

#include "app_gpio.h"
#include "webservice.h"

/* Commente ceci si les led s'allume à l'envers */
#define INVERT_GPIO

#ifdef INVERT_GPIO
#define LED_GREEN GPIO_NUM_14
#define LED_RED GPIO_NUM_12
#else
#define LED_GREEN GPIO_NUM_12
#define LED_RED GPIO_NUM_14
#endif

#define BP_GPIO GPIO_NUM_26
#define GPIO_INPUT_PIN_SEL (1ULL << BP_GPIO)

#define LEDC_HS_TIMER LEDC_TIMER_0
#define LEDC_HS_MODE LEDC_HIGH_SPEED_MODE
#define LEDC_HS_CH0_GPIO (LED_GREEN)
#define LEDC_HS_CH0_CHANNEL LEDC_CHANNEL_0
#define LEDC_HS_CH1_GPIO (LED_RED)
#define LEDC_HS_CH1_CHANNEL LEDC_CHANNEL_1

#define LEDC_TEST_CH_NUM (2)
#define LEDC_TEST_DUTY (4000)
#define LEDC_TEST_FADE_TIME (1000)

#define LEDC_GREEN_DUTY (50)
#define LEDC_RED_DUTY (20)
#define LEDC_GREEN_ORANGE_DUTY (50)
#define LEDC_RED_ORANGE_DUTY (20)

#define LED_CA 1

UnitStatDef UnitStat = UNIT_STATUS_LOADING;
UnitStatDef LastUnitStat = UNIT_STATUS_NONE;

bool LedStateLocked = false;

void LockStatus(bool s)
{
	if (s)
	{
		LedStateLocked = true;
	}
	else
	{
		LedStateLocked = false;
	}
}

void GREEN_ON()
{
	ledc_set_duty(LEDC_HIGH_SPEED_MODE, LEDC_HS_CH0_CHANNEL, LEDC_GREEN_DUTY);
	ledc_update_duty(LEDC_HIGH_SPEED_MODE, LEDC_HS_CH0_CHANNEL);
}
void GREEN_OFF()
{
	ledc_set_duty(LEDC_HIGH_SPEED_MODE, LEDC_HS_CH0_CHANNEL, 0);
	ledc_update_duty(LEDC_HIGH_SPEED_MODE, LEDC_HS_CH0_CHANNEL);
}
void RED_ON()
{
	ledc_set_duty(LEDC_HIGH_SPEED_MODE, LEDC_HS_CH1_CHANNEL, LEDC_RED_DUTY);
	ledc_update_duty(LEDC_HIGH_SPEED_MODE, LEDC_HS_CH1_CHANNEL);
}
void RED_OFF()
{
	ledc_set_duty(LEDC_HIGH_SPEED_MODE, LEDC_HS_CH1_CHANNEL, 0);
	ledc_update_duty(LEDC_HIGH_SPEED_MODE, LEDC_HS_CH1_CHANNEL);
}
void ORANGE_ON()
{
	ledc_set_duty(LEDC_HIGH_SPEED_MODE, LEDC_HS_CH0_CHANNEL, LEDC_GREEN_ORANGE_DUTY);
	ledc_update_duty(LEDC_HIGH_SPEED_MODE, LEDC_HS_CH0_CHANNEL);
	ledc_set_duty(LEDC_HIGH_SPEED_MODE, LEDC_HS_CH1_CHANNEL, LEDC_RED_ORANGE_DUTY);
	ledc_update_duty(LEDC_HIGH_SPEED_MODE, LEDC_HS_CH1_CHANNEL);
}

void ORANGE_OFF()
{
	ledc_set_duty(LEDC_HIGH_SPEED_MODE, LEDC_HS_CH0_CHANNEL, 0);
	ledc_update_duty(LEDC_HIGH_SPEED_MODE, LEDC_HS_CH0_CHANNEL);
	ledc_set_duty(LEDC_HIGH_SPEED_MODE, LEDC_HS_CH1_CHANNEL, 0);
	ledc_update_duty(LEDC_HIGH_SPEED_MODE, LEDC_HS_CH1_CHANNEL);
}

void UnitSetStatus(UnitStatDef NewStat)
{
	if ((LedStateLocked) && (NewStat != UNIT_STATUS_WIFI_GOT_IP))
		return;
	if (NewStat == UnitStat)
		return;

	LastUnitStat = UnitStat;
	UnitStat = NewStat;

	GREEN_OFF();
	RED_OFF();
}

xQueueHandle gpio_evt_queue = NULL;

void gpio_task(void *arg)
{
	uint32_t io_num;
	for (;;)
	{
		if (xQueueReceive(gpio_evt_queue, &io_num, portMAX_DELAY))
		{
			printf("GPIO[%d] intr, val: %d\n", io_num, gpio_get_level(io_num));
		}
	}
}

uint32_t Wifi_Got_Ip_Counter = 0;
uint8_t Loading_Counter = 0;

void LedStatusTask()
{

	gpio_config_t io_conf;
	//Enable interrupt on both rising and falling edges
	io_conf.intr_type = GPIO_INTR_POSEDGE;
	//bit mask of the pins
	io_conf.pin_bit_mask = GPIO_INPUT_PIN_SEL;
	//set as input mode
	io_conf.mode = GPIO_MODE_INPUT;
	//enable pull-up mode
	io_conf.pull_up_en = 1;

	gpio_config(&io_conf);

	//create a queue to handle gpio event
	gpio_evt_queue = xQueueCreate(10, sizeof(uint32_t));
	//start gpio task
	//xTaskCreatePinnedToCore(gpio_task, "gpio_task", 2048,NULL, 2, NULL, 1);

	int ch;

	/*
	 * Prepare and set configuration of timers
	 * that will be used by LED Controller
	 */
	ledc_timer_config_t ledc_timer = {
		.duty_resolution = LEDC_TIMER_13_BIT, // resolution of PWM duty
		.freq_hz = 8000,					  // frequency of PWM signal
		.speed_mode = LEDC_HS_MODE,			  // timer mode
		.timer_num = LEDC_HS_TIMER			  // timer index
	};
	// Set configuration of timer0 for high speed channels
	ledc_timer_config(&ledc_timer);

	ledc_channel_config_t ledc_channel[LEDC_TEST_CH_NUM] = {
		{.channel = LEDC_HS_CH0_CHANNEL, .duty = 0, .gpio_num = LEDC_HS_CH0_GPIO, .speed_mode = LEDC_HS_MODE, .hpoint = 0, .timer_sel = LEDC_HS_TIMER},
		{.channel =
			 LEDC_HS_CH1_CHANNEL,
		 .duty = 0,
		 .gpio_num = LEDC_HS_CH1_GPIO,
		 .speed_mode = LEDC_HS_MODE,
		 .hpoint = 0,
		 .timer_sel = LEDC_HS_TIMER},
	};

	for (ch = 0; ch < LEDC_TEST_CH_NUM; ch++)
	{
		ledc_channel_config(&ledc_channel[ch]);
	}

	while (1)
	{
		switch (UnitStat)
		{

		case UNIT_STATUS_NONE:
			GREEN_OFF();
			RED_OFF();
			vTaskDelay(100 / portTICK_PERIOD_MS);
			break;

		case UNIT_STATUS_LOADING:

			LockStatus(true);

			GREEN_ON();
			vTaskDelay(100 / portTICK_PERIOD_MS);
			ORANGE_ON();
			vTaskDelay(100 / portTICK_PERIOD_MS);
			ORANGE_OFF();

			Loading_Counter++;

			if (Loading_Counter > 5)
			{
				LockStatus(false);
				UnitSetStatus(UNIT_STATUS_NORMAL);
				Loading_Counter = 0;
			}
			break;

		case UNIT_STATUS_ERROR:
			RED_ON();
			vTaskDelay(100 / portTICK_PERIOD_MS);
			RED_OFF();
			vTaskDelay(100 / portTICK_PERIOD_MS);
			break;

		case UNIT_STATUS_WIFI_GOT_IP:

			LockStatus(true);

			GREEN_ON();
			vTaskDelay(500 / portTICK_PERIOD_MS);
			GREEN_OFF();
			vTaskDelay(500 / portTICK_PERIOD_MS);
			Wifi_Got_Ip_Counter++;

			if (Wifi_Got_Ip_Counter > 10)
			{
				LockStatus(false);
				UnitSetStatus(UNIT_STATUS_NORMAL);
				Wifi_Got_Ip_Counter = 0;
			}

			break;

		case UNIT_STATUS_NORMAL:
			GREEN_ON();
			vTaskDelay(100 / portTICK_PERIOD_MS);
			break;

		case UNIT_STATUS_WARNING_CO2:
			ORANGE_ON();
			vTaskDelay(100 / portTICK_PERIOD_MS);
			break;

		case UNIT_STATUS_ALERT_CO2:
			RED_ON();
			vTaskDelay(100 / portTICK_PERIOD_MS);
			break;

		default:
			UnitSetStatus(UNIT_STATUS_NONE);
			break;
		}

		if ((WifiConnectedFlag == false) && (LedStateLocked == false))
		{
			//printf("hello");
			ORANGE_OFF();
			vTaskDelay(100 / portTICK_PERIOD_MS);
		}
	}
}

uint8_t strContains(char *string, char *toFind)
{
	uint8_t slen = strlen(string);
	uint8_t tFlen = strlen(toFind);
	uint8_t found = 0;

	if (slen >= tFlen)
	{
		for (uint8_t s = 0, t = 0; s < slen; s++)
		{
			do
			{

				if (string[s] == toFind[t])
				{
					if (++found == tFlen)
						return 1;
					s++;
					t++;
				}
				else
				{
					s -= found;
					found = 0;
					t = 0;
				}

			} while (found);
		}
		return 0;
	}
	else
		return -1;
}

void LedStatInit()
{
	xTaskCreatePinnedToCore(&LedStatusTask, "LedStatusTask", configMINIMAL_STACK_SIZE * 3, NULL, 1, NULL, 1);
}
