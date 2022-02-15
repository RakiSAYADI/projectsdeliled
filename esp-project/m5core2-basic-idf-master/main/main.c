// SPDX: MIT
// Copyright 2021 Brian Starkey <stark3y@gmail.com>
// Portions from lvgl example: https://github.com/lvgl/lv_port_esp32/blob/master/main/main.c

#include <stdio.h>
#include "sdkconfig.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/semphr.h"
#include "esp_system.h"
#include "esp_spi_flash.h"
#include "esp_log.h"

#include "lvgl.h"
#include "lvgl_helpers.h"

#include "main.h"

#define LV_TICK_PERIOD_MS true

#define TAG "MAIN"

enum toggle_id
{
	TOGGLE_LED = 0,
	TOGGLE_VIB,
	TOGGLE_5V,
};

static void toggle_event_cb(lv_obj_t *toggle, lv_event_t event)
{
	if (event == LV_EVENT_VALUE_CHANGED)
	{
		bool state = lv_switch_get_state(toggle);
		enum toggle_id *id = lv_obj_get_user_data(toggle);

		// Note: This is running in the GUI thread, so prolonged i2c
		// comms might cause some jank
		switch (*id)
		{
		case TOGGLE_LED:
			ESP_LOGI(TAG, "we have a click on LED SWITCH %s", state ? "true" : "false");
			break;
		case TOGGLE_VIB:
			ESP_LOGI(TAG, "we have a click on VIB SWITCH %s", state ? "true" : "false");
			break;
		case TOGGLE_5V:
			ESP_LOGI(TAG, "we have a click on 5V SWITCH %s", state ? "true" : "false");
			break;
		}
	}
}

static void layout_event_click(lv_obj_t *toggle, lv_event_t event)
{
	if (event == LV_EVENT_CLICKED)
	{
		enum toggle_id *id = lv_obj_get_user_data(toggle);
		switch (*id)
		{
		case TOGGLE_LED:
			ESP_LOGI(TAG, "we have a click on LED");
			break;
		case TOGGLE_VIB:
			ESP_LOGI(TAG, "we have a click on VIB");
			break;
		case TOGGLE_5V:
			ESP_LOGI(TAG, "we have a click on 5V");
			break;
		}
	}
}

static void gui_timer_tick(void *arg)
{
	// Unused
	(void)arg;

	lv_tick_inc(LV_TICK_PERIOD_MS);
}

static void gui_thread(void *pvParameter)
{
	(void)pvParameter;

	ESP_LOGI(TAG, "Start Application !");

	static lv_color_t bufs[2][DISP_BUF_SIZE];
	static lv_disp_buf_t disp_buf;
	uint32_t size_in_px = DISP_BUF_SIZE;

	// Set up the frame buffers
	lv_disp_buf_init(&disp_buf, &bufs[0], &bufs[1], size_in_px);

	// Set up the display driver
	lv_disp_drv_t disp_drv;
	lv_disp_drv_init(&disp_drv);
	disp_drv.flush_cb = disp_driver_flush;
	disp_drv.buffer = &disp_buf;
	lv_disp_drv_register(&disp_drv);

	// Register the touch screen. All of the properties of it
	// are set via the build config
	lv_indev_drv_t indev_drv;
	lv_indev_drv_init(&indev_drv);
	indev_drv.read_cb = touch_driver_read;
	indev_drv.type = LV_INDEV_TYPE_POINTER;
	lv_indev_drv_register(&indev_drv);

	// Timer to drive the main lvgl tick
	const esp_timer_create_args_t periodic_timer_args = {
		.callback = &gui_timer_tick,
		.name = "periodic_gui"};
	esp_timer_handle_t periodic_timer;
	ESP_ERROR_CHECK(esp_timer_create(&periodic_timer_args, &periodic_timer));
	ESP_ERROR_CHECK(esp_timer_start_periodic(periodic_timer, LV_TICK_PERIOD_MS * 1000));

	static lv_style_t img_style;
	lv_style_init(&img_style);
	lv_style_set_bg_opa(&img_style, LV_STATE_DEFAULT, LV_OPA_TRANSP);
	lv_style_set_bg_color(&img_style, LV_STATE_DEFAULT, LV_COLOR_BLACK);

	LV_IMG_DECLARE(background);
	lv_obj_t *img_src = lv_img_create(lv_scr_act(), NULL); /*Create an image object*/
	lv_img_set_src(img_src, &background);				   /*Set the created file as image (a red flower)*/
	lv_obj_set_pos(img_src, 0, 0);						   /*Set the positions*/
	lv_obj_set_drag(img_src, true);
	lv_obj_add_style(img_src, LV_OBJ_PART_MAIN, &img_style);
	lv_obj_set_click(img_src, false);

	// Full screen root container
	lv_obj_t *root = lv_cont_create(img_src, NULL);
	lv_obj_set_size(root, 480, 320);
	lv_cont_set_layout(root, LV_LAYOUT_CENTER);
	lv_obj_add_style(root, LV_OBJ_PART_MAIN, &img_style);
	// Don't let the containers be clicked on
	lv_obj_set_click(root, false);

	lv_obj_t *switchers = lv_cont_create(root, NULL);
	lv_obj_set_auto_realign(switchers, true);
	lv_cont_set_layout(switchers, LV_LAYOUT_ROW_MID);
	lv_obj_align_origo(switchers, NULL, LV_ALIGN_CENTER, 0, 0); /*This parametrs will be sued when realigned*/
	lv_cont_set_fit(switchers, LV_FIT_TIGHT);
	lv_style_set_border_opa(&img_style, LV_STATE_DEFAULT, LV_OPA_TRANSP);
	lv_obj_add_style(switchers, LV_OBJ_PART_MAIN, &img_style);
	lv_obj_set_click(switchers, false);

	lv_obj_t *img2 = lv_img_create(root, NULL);
	lv_img_set_src(img2, LV_SYMBOL_OK "Accept");

	// Create rows of switches for different functions
	struct
	{
		const char *label;
		bool init;
		enum toggle_id id;
	} switches[] = {
		{"LED", true, TOGGLE_LED},
		{"Vibrate", false, TOGGLE_VIB},
		{"5V Bus", false, TOGGLE_5V},
	};
	lv_style_t style_obj;
	lv_style_t style_swt_on;
	lv_style_t style_swt_off;
	lv_style_t style_text;
	for (int i = 0; i < sizeof(switches) / sizeof(switches[0]); i++)
	{
		lv_obj_t *row = lv_cont_create(switchers, NULL);
		lv_cont_set_layout(row, LV_LAYOUT_COLUMN_MID);
		lv_obj_set_size(row, 100, 0);
		lv_cont_set_fit2(row, LV_FIT_NONE, LV_FIT_TIGHT);
		// Don't let the containers be clicked on
		lv_obj_set_click(row, true);
		lv_obj_set_user_data(row, &switches[i].id);
		lv_obj_set_event_cb(row, layout_event_click);
		lv_style_init(&style_obj);
		lv_style_set_radius(&style_obj, LV_STATE_DEFAULT, 10);
		lv_style_set_bg_color(&style_obj, LV_STATE_DEFAULT, LV_COLOR_BLACK);
		lv_style_set_bg_color(&style_obj, LV_STATE_FOCUSED, LV_COLOR_BLUE);
		lv_obj_add_style(row, LV_OBJ_PART_MAIN, &style_obj);

		lv_obj_t *toggle = lv_switch_create(row, NULL);
		if (switches[i].init)
		{
			lv_switch_on(toggle, LV_ANIM_OFF);
		}

		lv_obj_set_user_data(toggle, &switches[i].id);
		lv_obj_set_event_cb(toggle, toggle_event_cb);

		lv_style_init(&style_swt_on);
		lv_style_set_bg_color(&style_swt_on, LV_STATE_DEFAULT, LV_COLOR_GREEN);
		lv_obj_add_style(toggle, LV_SWITCH_PART_INDIC, &style_swt_on);
		lv_style_init(&style_swt_off);
		lv_style_set_bg_color(&style_swt_off, LV_STATE_DEFAULT, LV_COLOR_RED);
		lv_obj_add_style(toggle, LV_SWITCH_PART_BG, &style_swt_off);

		lv_obj_t *label = lv_label_create(row, NULL);
		lv_label_set_text(label, switches[i].label);
		lv_style_init(&style_text);
		lv_style_set_text_color(&style_text, LV_STATE_DEFAULT, LV_COLOR_WHITE);
		lv_obj_add_style(label, LV_LABEL_PART_MAIN, &style_text);
	}

	while (1)
	{
		delay(10);
		/*if (true) {
			break;
		}*/
		lv_task_handler();
	}
	delete (NULL);
}

void app_main(void)
{
	ESP_LOGI(TAG, "Hello world!");

	/* Print chip information */
	esp_chip_info_t chip_info;
	esp_chip_info(&chip_info);
	ESP_LOGI(TAG, "This is %s chip with %d CPU cores, WiFi%s%s, ",
			 CONFIG_IDF_TARGET,
			 chip_info.cores,
			 (chip_info.features & CHIP_FEATURE_BT) ? "/BT" : "",
			 (chip_info.features & CHIP_FEATURE_BLE) ? "/BLE" : "");
	ESP_LOGI(TAG, "silicon revision %d, ", chip_info.revision);
	ESP_LOGI(TAG, "%dMB %s flash", spi_flash_get_chip_size() / (1024 * 1024),
			 (chip_info.features & CHIP_FEATURE_EMB_FLASH) ? "embedded" : "external");
	ESP_LOGI(TAG, "Free heap: %d", esp_get_free_heap_size());

	lv_init();
	lvgl_driver_init();

	delay(100);
	touch_driver_init();
	disp_driver_init();

	// prepare style design

	// initStyles();

	// Start display User Interface
	// Needs to be pinned to a core
	xTaskCreatePinnedToCore(gui_thread, "gui", 4096 * 2, NULL, 0, NULL, 1);

	ESP_LOGI(TAG, "Running...");

	for (;;)
	{
		vTaskDelay(portMAX_DELAY);
	}
	ESP_LOGI(TAG, "Restarting now.");
	esp_restart();
}
