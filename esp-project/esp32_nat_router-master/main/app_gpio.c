#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"
#include "driver/ledc.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include <pthread.h>

#include "sdkconfig.h"

#include "app_gpio.h"
#include "nat_router.h"

const char *GPIO_TAG = "GPIO";

// On board LED
#define BLINK_GPIO GPIO_NUM_14

void *led_status_thread(void *p)
{
	gpio_reset_pin(BLINK_GPIO);
	gpio_set_direction(BLINK_GPIO, GPIO_MODE_OUTPUT);

	while (true)
	{
		gpio_set_level(BLINK_GPIO, AP_CONNECT);

		for (int i = 0; i < CONNECT_COUNT; i++)
		{
			gpio_set_level(BLINK_GPIO, 1 - AP_CONNECT);
			vTaskDelay(50 / portTICK_PERIOD_MS);
			gpio_set_level(BLINK_GPIO, AP_CONNECT);
			vTaskDelay(50 / portTICK_PERIOD_MS);
		}

		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}
}

void LedStatInit()
{
	pthread_t t1;
	pthread_create(&t1, NULL, led_status_thread, NULL);
}
