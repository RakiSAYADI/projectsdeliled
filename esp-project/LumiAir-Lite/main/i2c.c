#include <stdio.h>
#include <sys/time.h>
#include "driver/i2c.h"
#include "sdkconfig.h"
#include "lwip/apps/sntp.h"
#include <esp_log.h>
#include <time.h>

#include "i2c.h"
#include "unitcfg.h"
#include "sntpservice.h"
#include "app_gpio.h"
#include "webservice.h"

#define TAG "I2C"

void I2cRestart();

OPT3001_Typedef OPT3001_HoldReg = {0, 0, 0, 0, 0, 0, 0, 0}; // light meter
IAQ_CORE_Typedef iaq_data;									// CO2 TVOC
HDC1080_Typedef HDC1080_data;								// temperature Humidity
MCP7940_Time_Typedef time_MCP7940;							// battery Timer

bool clockSavorEnabled = false;
bool saveTimeOnBattery = false;
bool saveTimeBattery = false;

time_t i2c_now = 0;
struct tm i2c_timeinfo = {0};
char strftime_buf[64];

#ifdef ENABLE_OPT3001

esp_err_t i2c_read_OPT3001(i2c_port_t i2c_num, uint8_t reg, uint16_t *data)
{
	int ret;
	uint8_t lb, hb;

	i2c_cmd_handle_t cmd = i2c_cmd_link_create();
	i2c_master_start(cmd);
	i2c_master_write_byte(cmd, OPT3001_SENSOR_ADDR << 1 | WRITE_BIT, ACK_CHECK_EN);
	i2c_master_write_byte(cmd, reg, ACK_CHECK_EN);
	i2c_master_stop(cmd);
	ret = i2c_master_cmd_begin(i2c_num, cmd, 1000 / portTICK_RATE_MS);
	i2c_cmd_link_delete(cmd);
	if (ret != ESP_OK)
	{
		return 0;
	}
	vTaskDelay(30 / portTICK_RATE_MS);
	cmd = i2c_cmd_link_create();
	i2c_master_start(cmd);
	i2c_master_write_byte(cmd, OPT3001_SENSOR_ADDR << 1 | READ_BIT, ACK_CHECK_EN);
	i2c_master_read_byte(cmd, &hb, ACK_VAL);
	i2c_master_read_byte(cmd, &lb, NACK_VAL);
	i2c_master_stop(cmd);
	ret = i2c_master_cmd_begin(i2c_num, cmd, 1000 / portTICK_RATE_MS);
	i2c_cmd_link_delete(cmd);

	*data = (hb << 8) + lb;

	return ret;
}

esp_err_t i2c_write_OPT3001(i2c_port_t i2c_num, uint8_t reg, uint16_t data)
{
	int ret;

	i2c_cmd_handle_t cmd = i2c_cmd_link_create();
	i2c_master_start(cmd);
	i2c_master_write_byte(cmd, OPT3001_SENSOR_ADDR << 1 | WRITE_BIT, ACK_CHECK_EN);
	i2c_master_write_byte(cmd, reg, ACK_CHECK_EN);
	i2c_master_write_byte(cmd, (uint8_t)(data >> 8), ACK_VAL);
	i2c_master_write_byte(cmd, (uint8_t)(data & 0xFF), ACK_VAL);
	i2c_master_stop(cmd);
	ret = i2c_master_cmd_begin(i2c_num, cmd, 1000 / portTICK_RATE_MS);
	i2c_cmd_link_delete(cmd);

	return ret;
}
#endif

#ifdef ENABLE_IAQ_CORE_C

esp_err_t i2c_read_IAQ_CORE_C(i2c_port_t i2c_num, IAQ_CORE_Typedef *data)
{
	int ret = 0;
	uint8_t tmp[9];

	i2c_cmd_handle_t cmd = i2c_cmd_link_create();
	i2c_master_start(cmd);
	i2c_master_write_byte(cmd, IAQ_CORE_C_SENSOR_ADDR << 1 | READ_BIT, ACK_CHECK_EN);

	i2c_master_read(cmd, tmp, 8, ACK_VAL);
	i2c_master_read_byte(cmd, tmp + 8, NACK_VAL);

	i2c_master_stop(cmd);
	ret = i2c_master_cmd_begin(i2c_num, cmd, 1000 / portTICK_RATE_MS);
	i2c_cmd_link_delete(cmd);

	/*printf("\n");

	for (int i = 0; i < 9; i++)
	{
		printf("tmp (%d) = %x, ", i, tmp[i]);
	}*/

	// printf("\n");

	if (ret == ESP_OK)
	{
		data->pred = (tmp[0] << 8) + tmp[1];
		data->status = tmp[2];
		data->resistance = (tmp[3] << 24) + (tmp[4] << 16) + (tmp[5] << 8) + (tmp[6]);
		data->Tvoc = (tmp[7] << 8) + tmp[8];
	}
	else
	{
		data->pred = 500;
		data->status = 0;
		data->resistance = 0;
		data->Tvoc = 250;
	}

	// printf("CO2 : %u, State : %02X, resistance : %d , TVOC : %u \n", data->pred, data->status, data->resistance, data->Tvoc);
	// printf("\n");

	return ret;
}

#endif

#ifdef ENABLE_HDC1080
esp_err_t i2c_read_HDC1080(i2c_port_t i2c_num, uint8_t reg, uint16_t *data)
{
	int ret;
	uint8_t lb = 0, hb = 0;
	i2c_cmd_handle_t cmd = i2c_cmd_link_create();
	i2c_master_start(cmd);
	i2c_master_write_byte(cmd, HDC1080_SENSOR_ADDR << 1 | WRITE_BIT, ACK_CHECK_EN);
	i2c_master_write_byte(cmd, reg, ACK_CHECK_EN);
	i2c_master_stop(cmd);
	ret = i2c_master_cmd_begin(i2c_num, cmd, 1000 / portTICK_RATE_MS);
	i2c_cmd_link_delete(cmd);
	if (ret != ESP_OK)
	{
		return ret;
	}
	vTaskDelay(30 / portTICK_RATE_MS);
	cmd = i2c_cmd_link_create();
	i2c_master_start(cmd);
	i2c_master_write_byte(cmd, HDC1080_SENSOR_ADDR << 1 | READ_BIT, ACK_CHECK_EN);
	i2c_master_read_byte(cmd, &hb, ACK_VAL);
	i2c_master_read_byte(cmd, &lb, NACK_VAL);
	i2c_master_stop(cmd);
	ret = i2c_master_cmd_begin(i2c_num, cmd, 1000 / portTICK_RATE_MS);
	i2c_cmd_link_delete(cmd);

	*data = (hb << 8) + lb;

	return ret;
}

esp_err_t i2c_write_HDC1080(i2c_port_t i2c_num, uint8_t reg, uint16_t data)
{
	int ret;

	i2c_cmd_handle_t cmd = i2c_cmd_link_create();
	i2c_master_start(cmd);
	i2c_master_write_byte(cmd, HDC1080_SENSOR_ADDR << 1 | WRITE_BIT, ACK_CHECK_EN);
	i2c_master_write_byte(cmd, reg, ACK_CHECK_EN);
	i2c_master_write_byte(cmd, (uint8_t)(data >> 8), ACK_VAL);
	i2c_master_write_byte(cmd, (uint8_t)(data & 0xFF), ACK_VAL);
	i2c_master_stop(cmd);
	ret = i2c_master_cmd_begin(i2c_num, cmd, 1000 / portTICK_RATE_MS);
	i2c_cmd_link_delete(cmd);

	return ret;
}
#endif

#ifdef ENABLE_MCP7940

esp_err_t i2c_read_MCP7940(i2c_port_t i2c_num, uint8_t reg, MCP7940_Time_Typedef *time)
{
	int ret;
	uint8_t tmp;
	uint8_t middle = 0;

	i2c_cmd_handle_t cmd = i2c_cmd_link_create();
	i2c_master_start(cmd);
	i2c_master_write_byte(cmd, MCP7940_CLOCK_ADDR << 1 | WRITE_BIT, ACK_CHECK_EN);
	i2c_master_write_byte(cmd, reg, ACK_CHECK_EN);
	i2c_master_stop(cmd);
	ret = i2c_master_cmd_begin(i2c_num, cmd, 1000 / portTICK_RATE_MS);
	i2c_cmd_link_delete(cmd);
	if (ret != ESP_OK)
	{
		return ret;
	}
	vTaskDelay(30 / portTICK_RATE_MS);
	cmd = i2c_cmd_link_create();
	i2c_master_start(cmd);
	i2c_master_write_byte(cmd, MCP7940_CLOCK_ADDR << 1 | READ_BIT, ACK_CHECK_EN);
	i2c_master_read_byte(cmd, &tmp, NACK_VAL);
	i2c_master_stop(cmd);
	ret = i2c_master_cmd_begin(i2c_num, cmd, 1000 / portTICK_RATE_MS);
	i2c_cmd_link_delete(cmd);
	if (ret == ESP_OK)
	{
		switch (reg)
		{
		case MCP7940_REG_RTCSEC:
			middle = (uint8_t)(tmp & 0x7F);
			time->second = (uint8_t)(middle & 0xF) + (uint8_t)(((middle >> 4) & 0xF) * 10);
			time->osillater_start = (uint8_t)tmp >> 7;
			break;
		case MCP7940_REG_RTCMIN:
			time->minute = (uint8_t)(tmp & 0xF) + (uint8_t)(((tmp >> 4) & 0xF) * 10);
			break;
		case MCP7940_REG_RTCHOUR:
			time->twelve_or_24 = (uint8_t)tmp >> 6;
			middle = (uint8_t)(tmp & 0x3F);
			time->hour = (uint8_t)(middle & 0xF) + (uint8_t)(((middle >> 4) & 0xF) * 10);
			break;
		case MCP7940_REG_RTCWKDAY:
			time->day_of_week = (uint8_t)(tmp & 0x07);
			time->vBat_en = (uint8_t)(tmp & 0x0F) >> 3;
			time->powerFailure_state = (uint8_t)(tmp & 0x10) >> 4;
			time->osillater_status = (uint8_t)tmp >> 5;
			break;
		case MCP7940_REG_RTCDATE:
			time->day = (uint8_t)(tmp & 0xF) + (uint8_t)(((tmp >> 4) & 0xF) * 10);
			break;
		case MCP7940_REG_RTCMTH:
			middle = (uint8_t)(tmp & 0x1F);
			time->month = (uint8_t)(middle & 0xF) + (uint8_t)(((middle >> 4) & 0xF) * 10);
			time->leap_year = (uint8_t)tmp >> 5;
			break;
		case MCP7940_REG_RTCYEAR:
			time->year = (uint8_t)(tmp & 0xF) + (uint8_t)(((tmp >> 4) & 0xF) * 10);
			break;
		case MCP7940_CON_CONFIG:
			time->squareWaveSelect = (uint8_t)(tmp & 0x03);
			time->coarseTrimEnabled = (uint8_t)(tmp & 0x07) >> 2;
			time->alarmOneEnabled = (uint8_t)(tmp & 0x10) >> 4;
			time->alarmTwoEnabled = (uint8_t)(tmp & 0x20) >> 5;
			time->squareWaveEnabled = (uint8_t)(tmp & 0x40) >> 6;
			break;
		}
	}
	vTaskDelay(1 / portTICK_RATE_MS);
	return ret;
}

esp_err_t i2c_write_MCP7940(i2c_port_t i2c_num, uint8_t reg, MCP7940_Time_Typedef *time)
{
	int ret;
	uint8_t data = 0;

	i2c_cmd_handle_t cmd = i2c_cmd_link_create();
	i2c_master_start(cmd);
	i2c_master_write_byte(cmd, MCP7940_CLOCK_ADDR << 1 | WRITE_BIT, ACK_CHECK_EN);

	switch (reg)
	{
	case MCP7940_REG_RTCSEC:
		data = (uint8_t)((time->second / 10) << 4) + (uint8_t)(time->second % 10);
		data = data + (uint8_t)(time->osillater_start << 7);
		break;
	case MCP7940_REG_RTCMIN:
		data = (uint8_t)((time->minute / 10) << 4) + (uint8_t)(time->minute % 10);
		break;
	case MCP7940_REG_RTCHOUR:
		data = (uint8_t)((time->hour / 10) << 4) + (uint8_t)(time->hour % 10);
		data = data + (uint8_t)(time->twelve_or_24 << 6);
		break;
	case MCP7940_REG_RTCWKDAY:
		data = (uint8_t)(time->day_of_week);
		data = data + (uint8_t)(time->vBat_en << 3);
		data = data + (uint8_t)(time->powerFailure_state << 4);
		data = data + (uint8_t)(time->osillater_status << 5);
		break;
	case MCP7940_REG_RTCDATE:
		data = (uint8_t)((time->day / 10) << 4) + (uint8_t)(time->day % 10);
		break;
	case MCP7940_REG_RTCMTH:
		data = (uint8_t)((time->month / 10) << 4) + (uint8_t)(time->month % 10);
		data = data + (uint8_t)(time->leap_year << 5);
		break;
	case MCP7940_REG_RTCYEAR:
		data = (uint8_t)((time->year / 10) << 4) + (uint8_t)(time->year % 10);
		break;
	case MCP7940_CON_CONFIG:
		data = (uint8_t)(time->squareWaveSelect);
		data = data + (uint8_t)(time->coarseTrimEnabled << 2);
		data = data + (uint8_t)(time->alarmOneEnabled << 4);
		data = data + (uint8_t)(time->alarmTwoEnabled << 5);
		data = data + (uint8_t)(time->squareWaveEnabled << 6);
		break;
	}
	i2c_master_write_byte(cmd, reg, ACK_CHECK_EN);
	i2c_master_write_byte(cmd, data, ACK_VAL);

	i2c_master_stop(cmd);
	ret = i2c_master_cmd_begin(i2c_num, cmd, 1000 / portTICK_RATE_MS);
	i2c_cmd_link_delete(cmd);
	vTaskDelay(1 / portTICK_RATE_MS);
	return ret;
}

esp_err_t saveTimeInsideBattery(struct tm timeinfo)
{
	int ret;
	time_MCP7940.second = timeinfo.tm_sec;
	time_MCP7940.minute = timeinfo.tm_min;
	time_MCP7940.hour = timeinfo.tm_hour;
	time_MCP7940.twelve_or_24 = 0;
	time_MCP7940.day_of_week = timeinfo.tm_wday;
	time_MCP7940.day = timeinfo.tm_mday;
	time_MCP7940.month = timeinfo.tm_mon;
	time_MCP7940.year = timeinfo.tm_year;
	time_MCP7940.vBat_en = 1;
	time_MCP7940.osillater_start = 1;
	ret = i2c_write_MCP7940(I2C_MASTER_NUM, MCP7940_REG_RTCSEC, &time_MCP7940);
	ESP_ERROR_CHECK(ret);
	ret = i2c_write_MCP7940(I2C_MASTER_NUM, MCP7940_REG_RTCMIN, &time_MCP7940);
	ESP_ERROR_CHECK(ret);
	ret = i2c_write_MCP7940(I2C_MASTER_NUM, MCP7940_REG_RTCHOUR, &time_MCP7940);
	ESP_ERROR_CHECK(ret);
	ret = i2c_write_MCP7940(I2C_MASTER_NUM, MCP7940_REG_RTCDATE, &time_MCP7940);
	ESP_ERROR_CHECK(ret);
	ret = i2c_write_MCP7940(I2C_MASTER_NUM, MCP7940_REG_RTCWKDAY, &time_MCP7940);
	ESP_ERROR_CHECK(ret);
	ret = i2c_write_MCP7940(I2C_MASTER_NUM, MCP7940_REG_RTCMTH, &time_MCP7940);
	ESP_ERROR_CHECK(ret);
	ret = i2c_write_MCP7940(I2C_MASTER_NUM, MCP7940_REG_RTCYEAR, &time_MCP7940);
	ESP_ERROR_CHECK(ret);
	ESP_LOGI(TAG, "Time saved to MCP7940 !");
	return ret;
}

#endif

/**
 * @brief i2c master initialization
 */
void i2c_master_init()
{
	int i2c_master_port = I2C_MASTER_NUM;
	i2c_config_t conf;
	conf.mode = I2C_MODE_MASTER;
	conf.sda_io_num = I2C_MASTER_SDA_IO;
	conf.sda_pullup_en = GPIO_PULLUP_ENABLE;
	conf.scl_io_num = I2C_MASTER_SCL_IO;
	conf.scl_pullup_en = GPIO_PULLUP_ENABLE;
	conf.master.clk_speed = I2C_MASTER_FREQ_HZ;
	conf.clk_flags = 0;
	i2c_param_config(i2c_master_port, &conf);
	i2c_driver_install(i2c_master_port, conf.mode, I2C_MASTER_RX_BUF_DISABLE, I2C_MASTER_TX_BUF_DISABLE, 0);
	int error = i2c_set_timeout(I2C_NUM_1, 100000);
	if (error != ESP_OK)
	{
		ESP_LOGI(TAG, "Failed set timeout for i2c bus: %s", esp_err_to_name(error));
		return;
	}
}

void i2c_slave_init()
{
	int ret;
	uint16_t tmp = 0;

#ifdef ENABLE_OPT3001

	/* OPT3001 */
	OPT3001_HoldReg.config = 0xCE10;
	ret = i2c_write_OPT3001(I2C_MASTER_NUM, OPT3001_CONFIG_REG, OPT3001_HoldReg.config);
	ret = i2c_read_OPT3001(I2C_MASTER_NUM, OPT3001_CONFIG_REG, &tmp);

	if (ret == ESP_ERR_TIMEOUT)
	{
		ESP_LOGE(TAG, "I2C OPT3001 timeout\n");
	}
	else if (ret == ESP_OK)
	{
		if (tmp == OPT3001_HoldReg.config)
			ESP_LOGI(TAG, "I2C MASTER Write SENSOR( OPT3001 ) : 0x%04X \r\n", tmp);
		else
			ESP_LOGE(TAG, "I2C OPT3001 Write error %04X / %04X\n", tmp, OPT3001_HoldReg.config);
	}
	else
	{
		ESP_LOGE(TAG, "OPT3001: No ack, sensor not connected...skip...\n");
	}

#endif

#ifdef ENABLE_HDC1080
	HDC1080_data.Config = 0x1000;

	ret = i2c_write_HDC1080(I2C_MASTER_NUM, HDC1080_CONFIG, HDC1080_data.Config);
	ret = i2c_read_HDC1080(I2C_MASTER_NUM, HDC1080_CONFIG, &tmp);

	if (ret == ESP_ERR_TIMEOUT)
	{
		ESP_LOGE(TAG, "I2C HDC1080 timeout\n");
	}
	else if (ret == ESP_OK)
	{
		if (tmp == HDC1080_data.Config)
			ESP_LOGI(TAG, "I2C MASTER Write SENSOR( HDC1080 ) : 0x%04X \r\n", tmp);
		else
			ESP_LOGE(TAG, "I2C HDC1080 Write error %04X / %04X\n", tmp, HDC1080_data.Config);
	}
	else
	{
		ESP_LOGE(TAG, "HDC1080: No ack, sensor not connected...skip...\n");
	}

	ret = i2c_write_HDC1080(I2C_MASTER_NUM, 0, 0);
#endif

#ifdef ENABLE_MCP7940

	ret = i2c_read_MCP7940(I2C_MASTER_NUM, MCP7940_REG_RTCSEC, &time_MCP7940);

	if (ret == ESP_ERR_TIMEOUT)
	{
		ESP_LOGE(TAG, "I2C MCP7940 timeout\n");
	}
	else if (ret == ESP_OK)
	{
		ESP_LOGI(TAG, "MCP7940 is detected ,this is NEW card !\n");
		TXD_PIN = GPIO_NUM_18;
		RED_PIN = GPIO_NUM_27;
		clockSavorEnabled = true;
	}
	else
	{
		ESP_LOGE(TAG, "MCP7940: No ack, sensor not connected...skip...\n");
		ESP_LOGI(TAG, "MCP7940 is not detected ,this is OLD card !\n");
		TXD_PIN = GPIO_NUM_13;
		RED_PIN = GPIO_NUM_12;
		clockSavorEnabled = false;
	}

#endif
}

#define CO2ArraySize 5
uint8_t i2cReadCounter = 0;

uint16_t middleCO2 = 450;
uint16_t lastMiddleCO2 = 450;
uint16_t CO2Array[CO2ArraySize];
uint16_t i2cHourRestart = 0;

uint32_t normalCO2Counter = 0;
uint32_t badCO2Counter = 0;

int32_t power(int32_t x, uint32_t n)
{
	int32_t res = 1;

	if (n == 0)
		return (1);

	for (uint32_t i = 0; i < n; i++)
	{
		res *= x;
	}

	return (res);
}

uint16_t find_minimum(uint16_t a[], uint8_t n)
{
	uint16_t min = 0;
	uint8_t c = 0;

	min = a[c];

	for (c = 1; c < n; c++)
	{
		if (a[c] < min)
		{
			min = a[c];
		}
	}

	if (min == 0)
	{
		return 450;
	}

	return min;
}

void i2c_test_task(void *arg)
{
	int ret;
	uint32_t task_idx = (uint32_t)arg;

	while (1)
	{

#ifdef ENABLE_OPT3001
		/* i2c_read_OPT3001 */
		ret = i2c_read_OPT3001(I2C_MASTER_NUM, OPT3001_RESULT_REG, &OPT3001_HoldReg.raw_result);
		if (ret == ESP_ERR_TIMEOUT)
		{
			ESP_LOGE(TAG, "I2C OPT3001 timeout\n");
		}
		else if (ret == ESP_OK)
		{

			uint8_t exp = OPT3001_HoldReg.raw_result >> 12;
			uint16_t frc = OPT3001_HoldReg.raw_result & 0x0FFF;

			OPT3001_HoldReg.result = 0.01 * power(2, exp) * frc;

			// printf("I2C MASTER READ SENSOR( OPT3001 ) : lux %0.2f config %04X\r\n",OPT3001_HoldReg.result,OPT3001_HoldReg.config);
		}
		else
		{
			ESP_LOGE(TAG, "OPT3001: No ack, sensor not connected...skip...\n");
		}

		vTaskDelay(10 / portTICK_RATE_MS);
#endif

#ifdef ENABLE_HDC1080
		/* i2c_read HDC1080 */

		ret = i2c_read_HDC1080(I2C_MASTER_NUM, HDC1080_CONFIG, &HDC1080_data.Config);
		ret = i2c_read_HDC1080(I2C_MASTER_NUM, HDC1080_TEMP, &HDC1080_data.temp_raw);
		ret = i2c_read_HDC1080(I2C_MASTER_NUM, HDC1080_TEMP, &HDC1080_data.humidity_raw);
		if (ret == ESP_ERR_TIMEOUT)
		{
			ESP_LOGE(TAG, "I2C HDC1080 timeout\n");
		}
		else if (ret == ESP_OK)
		{
			HDC1080_data.temp_result = ((HDC1080_data.temp_raw / 65536.0) * 165) - 40;
			HDC1080_data.humidity_result = (HDC1080_data.humidity_raw / 65536.0) * 100;

			// printf("I2C MASTER READ SENSOR( HDC1080 ) : Config %04X Temp %0.2f Humidty %0.2f \r\n",HDC1080_data.Config,HDC1080_data.temp_result,HDC1080_data.humidity_result);
		}
		else
		{
			ESP_LOGE(TAG, "HDC1080: No ack, sensor not connected...skip...\n");
		}

		vTaskDelay(10 / portTICK_RATE_MS);
#endif

#ifdef ENABLE_IAQ_CORE_C
		/* i2c_read IAQ_CORE_C */

		ret = i2c_read_IAQ_CORE_C(I2C_MASTER_NUM, &iaq_data);
		if (ret == ESP_ERR_TIMEOUT)
		{
			ESP_LOGE(TAG, "I2C IAQ_CORE_C timeout\n");
		}
		else if (ret == ESP_OK)
		{
			CO2Array[i2cReadCounter] = iaq_data.pred;
			i2cReadCounter++;
			if (i2cReadCounter == 5)
			{
				middleCO2 = find_minimum(CO2Array, CO2ArraySize);
				middleCO2 = (middleCO2 + lastMiddleCO2) / 2;
				lastMiddleCO2 = middleCO2;
				i2cReadCounter = 0;
			}
			if (middleCO2 > 1000 && middleCO2 < 1999)
			{
				normalCO2Counter++;
			}
			else if (middleCO2 > 1999)
			{
				middleCO2 = 2000;
				badCO2Counter++;
			}
			time(&i2c_now);
			i2c_now = i2c_now % (3600 * 24) + (UnitCfg.timeZone * 3600);
			if (normalCO2Counter > 180 || badCO2Counter > 30 || (i2c_now >= 0 && i2c_now <= 3) || i2cHourRestart == 360)
			{
				i2cReadCounter = 0;
				normalCO2Counter = 0;
				badCO2Counter = 0;
				i2cHourRestart = 0;
				break;
			}
			i2cHourRestart++;
			// ESP_LOGI(TAG, "(IAQ_CORE_C READ) time %ld ", i2c_now);
			// ESP_LOGI(TAG, "(IAQ_CORE_C READ) CO2Array[0] %d, CO2Array[1] %d, CO2Array[2] %d, CO2Array[3] %d, CO2Array[4] %d", CO2Array[0], CO2Array[1], CO2Array[2], CO2Array[3], CO2Array[4]);
			// ESP_LOGI(TAG, "(IAQ_CORE_C READ) middleCO2 %d, lastMiddleCO2 %d, i2cReadCounter %d, normalCO2Counter %d, badCO2Counter %d", middleCO2, lastMiddleCO2, i2cReadCounter, normalCO2Counter, badCO2Counter);
			// ESP_LOGI(TAG, "(IAQ_CORE_C READ) PRED %u , status %02X, resistance %d, Tvox %u\r\n", iaq_data.pred, iaq_data.status, iaq_data.resistance, iaq_data.Tvoc);
		}
		else
		{
			ESP_LOGE(TAG, "IAQ_CORE_C: No ack, sensor not connected...skip...\n");
		}

		vTaskDelay(10 / portTICK_RATE_MS);
#endif

#ifdef ENABLE_MCP7940

		if (clockSavorEnabled)
		{
			ret = i2c_read_MCP7940(I2C_MASTER_NUM, MCP7940_REG_RTCSEC, &time_MCP7940);
			ret = i2c_read_MCP7940(I2C_MASTER_NUM, MCP7940_REG_RTCMIN, &time_MCP7940);
			ret = i2c_read_MCP7940(I2C_MASTER_NUM, MCP7940_REG_RTCHOUR, &time_MCP7940);
			ret = i2c_read_MCP7940(I2C_MASTER_NUM, MCP7940_REG_RTCDATE, &time_MCP7940);
			ret = i2c_read_MCP7940(I2C_MASTER_NUM, MCP7940_REG_RTCWKDAY, &time_MCP7940);
			ret = i2c_read_MCP7940(I2C_MASTER_NUM, MCP7940_REG_RTCMTH, &time_MCP7940);
			ret = i2c_read_MCP7940(I2C_MASTER_NUM, MCP7940_REG_RTCYEAR, &time_MCP7940);
			ret = i2c_read_MCP7940(I2C_MASTER_NUM, MCP7940_CON_CONFIG, &time_MCP7940);
			if (ret == ESP_ERR_TIMEOUT)
			{
				ESP_LOGE(TAG, "I2C MCP7940 timeout\n");
			}
			else if (ret == ESP_OK)
			{

				time(&i2c_now);
				localtime_r(&i2c_now, &i2c_timeinfo);
				if (time_MCP7940.osillater_start == 0 || time_MCP7940.vBat_en == 0)
				{
					ESP_LOGI(TAG, "time %d", i2c_timeinfo.tm_year);
					if (saveTimeOnBattery)
					{
						ret = saveTimeInsideBattery(i2c_timeinfo);
						ESP_LOGI(TAG, "time of phone");
						ESP_ERROR_CHECK(ret);
						saveTimeOnBattery = false;
					}
				}
				else
				{
					if (!saveTimeBattery)
					{
						if (UnitStat == UNIT_STATUS_WIFI_GOT_IP && sntpTimeSetFlag)
						{
							strftime(strftime_buf, sizeof(strftime_buf), "%c", &i2c_timeinfo);
							ESP_LOGI(TAG, "ESP32 got time from internet: %s", strftime_buf);
							saveTimeBattery = true;
						}
						if (UnitStat == UNIT_STATUS_WIFI_NO_IP)
						{
							struct tm tm;
							tm.tm_year = time_MCP7940.year;
							tm.tm_mon = time_MCP7940.month;
							tm.tm_mday = time_MCP7940.day;
							tm.tm_wday = time_MCP7940.day_of_week;
							tm.tm_hour = time_MCP7940.hour;
							tm.tm_min = time_MCP7940.minute;
							tm.tm_sec = time_MCP7940.second;
							time_t t = mktime(&tm);
							syncTime(t, UnitCfg.UnitTimeZone);
							ESP_LOGI(TAG, "sec : %d, min : %d, hour : %d, weekday : %d, day : %d, month : %d, year : %d\n",
									 tm.tm_sec, tm.tm_min, tm.tm_hour, tm.tm_wday, tm.tm_mday, tm.tm_mon, tm.tm_year);
							ESP_LOGI(TAG, "I2C MASTER Setting time: %s", asctime(&tm));
							strftime(strftime_buf, sizeof(strftime_buf), "%c", &i2c_timeinfo);
							ESP_LOGI(TAG, "I2C MASTER Read TIMER( MCP7940 ) : %d/%d/%d in %d at %d:%d:%d",
									 time_MCP7940.year, time_MCP7940.month, time_MCP7940.day,
									 time_MCP7940.day_of_week, time_MCP7940.hour, time_MCP7940.minute, time_MCP7940.second);
							ESP_LOGI(TAG, "The current date/time in ESP32 is: %s", strftime_buf);
							saveTimeBattery = true;
						}
					}
				}
				strftime(strftime_buf, sizeof(strftime_buf), "%c", &i2c_timeinfo);
				ESP_LOGI(TAG, "I2C MASTER Read TIMER( MCP7940 ) : %d/%d/%d in %d at %d:%d:%d", time_MCP7940.year, time_MCP7940.month, time_MCP7940.day, time_MCP7940.day_of_week, time_MCP7940.hour, time_MCP7940.minute, time_MCP7940.second);
				ESP_LOGI(TAG, "I2C MASTER Read TIMER( MCP7940 ) : osillator %d, battery enable :%d", time_MCP7940.osillater_start, time_MCP7940.vBat_en);
				ESP_LOGI(TAG, "The current date/time in ESP32 is: %s", strftime_buf);
			}
			else
			{
				ESP_LOGE(TAG, "MCP7940: No ack, battery is not connected...skip...\n");
			}
		}

		vTaskDelay(10 / portTICK_RATE_MS);
#endif
		time(&UnitData.UpdateTime);
		UnitData.Temp = HDC1080_data.temp_result;
		UnitData.Humidity = HDC1080_data.humidity_result;
		UnitData.Als = OPT3001_HoldReg.result;
		UnitData.aq_Co2Level = middleCO2;
		UnitData.aq_Tvoc = iaq_data.Tvoc;
		UnitData.aq_status = iaq_data.status;

		vTaskDelay((DELAY_TIME_BETWEEN_ITEMS_MS * (task_idx + 1)) / portTICK_RATE_MS);
	}
	ESP_LOGE(TAG, "Reading I2C Task ended ,Restarting !");
	I2cRestart();
	vTaskDelete(NULL);
}

void I2c_Init()
{
	TXD_PIN = 0;
	RED_PIN = 0;

	gpio_pad_select_gpio(I2C_DEATH_SWITCH_GPIO);
	gpio_set_direction(I2C_DEATH_SWITCH_GPIO, GPIO_MODE_OUTPUT);

	gpio_set_level(I2C_DEATH_SWITCH_GPIO, 0);
	vTaskDelay(1000 / portTICK_RATE_MS);
	gpio_set_level(I2C_DEATH_SWITCH_GPIO, 1);

	vTaskDelay(1000 / portTICK_RATE_MS);
	i2c_master_init();
	vTaskDelay(1 / portTICK_RATE_MS);
	i2c_slave_init();
	xTaskCreatePinnedToCore(i2c_test_task, "i2c_test_task_0", 1024 * 2, (void *)0, 1, NULL, 1);
}

void I2cRestart()
{
	gpio_set_level(I2C_DEATH_SWITCH_GPIO, 0); // I2C OFF
	vTaskDelay(1000 / portTICK_RATE_MS);
	gpio_set_level(I2C_DEATH_SWITCH_GPIO, 1); // I2C ON
	vTaskDelay(1000 / portTICK_RATE_MS);
	i2c_slave_init();
	xTaskCreatePinnedToCore(i2c_test_task, "i2c_test_task_0", 1024 * 2, (void *)0, 1, NULL, 1);
	ESP_LOGI(TAG, "[APP] Free memory: %d bytes", esp_get_free_heap_size());
}