/* i2c */


#include <stdio.h>
#include <sys/time.h>
#include "driver/i2c.h"
#include "sdkconfig.h"
#include "lwip/apps/sntp.h"
#include <esp_log.h>

#include "i2c.h"
#include "unitcfg.h"
#include "sntp_client.h"

#define TAG "I2C"

OPT3001_Typedef OPT3001_HoldReg={0,0,0,0,0,0,0,0};
IAQ_CORE_Typedef iaq_data;
HDC1080_Typedef HDC1080_data;

#ifdef ENABLE_OPT3001

static esp_err_t i2c_read_OPT3001(i2c_port_t i2c_num, uint8_t reg, uint16_t *data)
{
    int ret;
    uint8_t lb,hb;

    i2c_cmd_handle_t cmd = i2c_cmd_link_create();
    i2c_master_start(cmd);
    i2c_master_write_byte(cmd, OPT3001_SENSOR_ADDR << 1 | WRITE_BIT, ACK_CHECK_EN);
    i2c_master_write_byte(cmd, reg, ACK_CHECK_EN);
    i2c_master_stop(cmd);
    ret = i2c_master_cmd_begin(i2c_num, cmd, 1000 / portTICK_RATE_MS);
    i2c_cmd_link_delete(cmd);
    if (ret != ESP_OK) {
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

    *data=(hb<<8)+lb;

    return ret;
}

static esp_err_t i2c_write_OPT3001(i2c_port_t i2c_num, uint8_t reg,uint16_t data)
{
    int ret;

    i2c_cmd_handle_t cmd = i2c_cmd_link_create();
    i2c_master_start(cmd);
    i2c_master_write_byte(cmd, OPT3001_SENSOR_ADDR << 1 | WRITE_BIT, ACK_CHECK_EN);
    i2c_master_write_byte(cmd, reg, ACK_CHECK_EN);
    i2c_master_write_byte(cmd, (uint8_t)(data>>8), ACK_VAL);
    i2c_master_write_byte(cmd, (uint8_t)(data&0xFF), ACK_VAL);
    i2c_master_stop(cmd);
    ret = i2c_master_cmd_begin(i2c_num, cmd, 1000 / portTICK_RATE_MS);
    i2c_cmd_link_delete(cmd);

    return ret;
}
#endif


#ifdef ENABLE_IAQ_CORE_C


static esp_err_t i2c_read_IAQ_CORE_C(i2c_port_t i2c_num, IAQ_CORE_Typedef* data)
{
    int ret=0;
    //uint8_t *p=(uint8_t *)data;
    uint8_t tmp[9];

    i2c_cmd_handle_t cmd = i2c_cmd_link_create();
    i2c_master_start(cmd);
    i2c_master_write_byte(cmd, IAQ_CORE_C_SENSOR_ADDR << 1 | READ_BIT, ACK_CHECK_EN);

    i2c_master_read(cmd, tmp,8, ACK_VAL);
    i2c_master_read_byte(cmd, tmp+8, NACK_VAL);

    i2c_master_stop(cmd);
    ret = i2c_master_cmd_begin(i2c_num, cmd, 1000 / portTICK_RATE_MS);
    i2c_cmd_link_delete(cmd);

    data->pred=(tmp[0]<<8)+tmp[1];
    data->status=tmp[2];
    data->resistance=(tmp[3]<<24)+(tmp[4]<<16)+(tmp[5]<<8)+(tmp[6]);
    data->Tvoc=(tmp[7]<<8)+tmp[8];

    return ret;
}

#endif


#ifdef ENABLE_HDC1080
static esp_err_t i2c_read_HDC1080(i2c_port_t i2c_num,uint8_t reg,  uint16_t *data)
{
    int ret;
    uint8_t lb=0,hb=0;
    i2c_cmd_handle_t cmd = i2c_cmd_link_create();
    i2c_master_start(cmd);
    i2c_master_write_byte(cmd, HDC1080_SENSOR_ADDR << 1 | WRITE_BIT, ACK_CHECK_EN);
    i2c_master_write_byte(cmd, reg, ACK_CHECK_EN);
    i2c_master_stop(cmd);
    ret = i2c_master_cmd_begin(i2c_num, cmd, 1000 / portTICK_RATE_MS);
    i2c_cmd_link_delete(cmd);
    if (ret != ESP_OK) {
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

    *data=(hb<<8)+lb;

    return ret;
}

static esp_err_t i2c_write_HDC1080(i2c_port_t i2c_num, uint8_t reg,uint16_t data)
{
    int ret;

    i2c_cmd_handle_t cmd = i2c_cmd_link_create();
    i2c_master_start(cmd);
    i2c_master_write_byte(cmd, HDC1080_SENSOR_ADDR << 1 | WRITE_BIT, ACK_CHECK_EN);
    i2c_master_write_byte(cmd, reg, ACK_CHECK_EN);
    i2c_master_write_byte(cmd, (uint8_t)(data>>8), ACK_VAL);
    i2c_master_write_byte(cmd, (uint8_t)(data&0xFF), ACK_VAL);
    i2c_master_stop(cmd);
    ret = i2c_master_cmd_begin(i2c_num, cmd, 1000 / portTICK_RATE_MS);
    i2c_cmd_link_delete(cmd);

    return ret;
}
#endif

/**
 * @brief i2c master initialization
 */
static void i2c_master_init()
{
    int i2c_master_port = I2C_MASTER_NUM;
    i2c_config_t conf;
    conf.mode = I2C_MODE_MASTER;
    conf.sda_io_num = I2C_MASTER_SDA_IO;
    conf.sda_pullup_en = GPIO_PULLUP_ENABLE;
    conf.scl_io_num = I2C_MASTER_SCL_IO;
    conf.scl_pullup_en = GPIO_PULLUP_ENABLE;
    conf.master.clk_speed = I2C_MASTER_FREQ_HZ;
    i2c_param_config(i2c_master_port, &conf);
    i2c_driver_install(i2c_master_port, conf.mode,
                       I2C_MASTER_RX_BUF_DISABLE,
                       I2C_MASTER_TX_BUF_DISABLE, 0);
}

static void i2c_slave_init()
{
	int ret;
	uint16_t tmp=0;

#ifdef ENABLE_OPT3001

	/* OPT3001 */
	OPT3001_HoldReg.config = 0xCE10;
    ret = i2c_write_OPT3001( I2C_MASTER_NUM,OPT3001_CONFIG_REG, OPT3001_HoldReg.config);
    ret = i2c_read_OPT3001( I2C_MASTER_NUM,OPT3001_CONFIG_REG,&tmp);

    if(ret == ESP_ERR_TIMEOUT) {
    	ESP_LOGE(TAG,"I2C OPT3001 timeout\n");
    } else if(ret == ESP_OK) {
    	if(tmp==OPT3001_HoldReg.config)
    		ESP_LOGI(TAG,"I2C MASTER Write SENSOR( OPT3001 ) : 0x%04X \r\n",tmp);
    	else
    		ESP_LOGE(TAG,"I2C OPT3001 Write error %04X / %04X\n",tmp,OPT3001_HoldReg.config);
    } else {
    	ESP_LOGE(TAG,"OPT3001: No ack, sensor not connected...skip...\n");
    }


#endif

#ifdef ENABLE_HDC1080
    HDC1080_data.Config = 0x1000;

    ret = i2c_write_HDC1080( I2C_MASTER_NUM,HDC1080_CONFIG, HDC1080_data.Config);
    ret = i2c_read_HDC1080( I2C_MASTER_NUM,HDC1080_CONFIG,&tmp);

    if(ret == ESP_ERR_TIMEOUT) {
    	ESP_LOGE(TAG,"I2C HDC1080 timeout\n");
    } else if(ret == ESP_OK) {
    	if(tmp==HDC1080_data.Config)
    		ESP_LOGI(TAG,"I2C MASTER Write SENSOR( HDC1080 ) : 0x%04X \r\n",tmp);
    	else
    		ESP_LOGE(TAG,"I2C HDC1080 Write error %04X / %04X\n",tmp,HDC1080_data.Config);
    } else {
    	ESP_LOGE(TAG,"HDC1080: No ack, sensor not connected...skip...\n");
    }

    ret = i2c_write_HDC1080( I2C_MASTER_NUM,0, 0);
#endif
}


int32_t power(int32_t x,uint32_t n)
{
	int32_t res=1;

	if (n==0) return(1);

	for (uint32_t i=0;i<n;i++)
	{
		res*=x;
	}

	return(res);
}


static void i2c_test_task(void* arg)
{
    int ret;
    uint32_t task_idx = (uint32_t) arg;

    while (1) {

#ifdef ENABLE_OPT3001
    	/* i2c_read_OPT3001 */
        ret = i2c_read_OPT3001( I2C_MASTER_NUM,OPT3001_RESULT_REG, &OPT3001_HoldReg.raw_result);
        //ret = i2c_read_OPT3001( I2C_MASTER_NUM,OPT3001_CONFIG_REG, &OPT3001_HoldReg.config);
        if(ret == ESP_ERR_TIMEOUT) {
        	ESP_LOGE(TAG,"I2C OPT3001 timeout\n");
        } else if(ret == ESP_OK) {

        	uint8_t exp=OPT3001_HoldReg.raw_result>>12;
        	uint16_t frc=OPT3001_HoldReg.raw_result&0x0FFF;

        	OPT3001_HoldReg.result=0.01*power(2,exp)*frc;

            //printf("I2C MASTER READ SENSOR( OPT3001 ) : lux %0.2f config %04X\r\n",OPT3001_HoldReg.result,OPT3001_HoldReg.config);
        } else {
        	ESP_LOGE(TAG,"OPT3001: No ack, sensor not connected...skip...\n");
        }

        vTaskDelay(1 / portTICK_RATE_MS);
#endif

#ifdef ENABLE_HDC1080
        /* i2c_read HDC1080 */

        ret = i2c_read_HDC1080( I2C_MASTER_NUM,HDC1080_CONFIG, &HDC1080_data.Config);
        ret = i2c_read_HDC1080( I2C_MASTER_NUM,HDC1080_TEMP, &HDC1080_data.temp_raw);
        ret = i2c_read_HDC1080( I2C_MASTER_NUM,HDC1080_TEMP, &HDC1080_data.humidity_raw);
        if(ret == ESP_ERR_TIMEOUT) {
        	ESP_LOGE(TAG,"I2C HDC1080 timeout\n");
        } else if(ret == ESP_OK) {
        	HDC1080_data.temp_result = ((HDC1080_data.temp_raw/65536.0)*165)-40;
        	HDC1080_data.humidity_result = (HDC1080_data.humidity_raw/65536.0)*100;

            //printf("I2C MASTER READ SENSOR( HDC1080 ) : Config %04X Temp %0.2f Humidty %0.2f \r\n",HDC1080_data.Config,HDC1080_data.temp_result,HDC1080_data.humidity_result);
        } else {
        	ESP_LOGE(TAG,"HDC1080: No ack, sensor not connected...skip...\n");
        }

        vTaskDelay(1 / portTICK_RATE_MS);
#endif

#ifdef ENABLE_IAQ_CORE_C
        /* i2c_read IAQ_CORE_C */

        ret = i2c_read_IAQ_CORE_C( I2C_MASTER_NUM,&iaq_data);
        if(ret == ESP_ERR_TIMEOUT) {
        	ESP_LOGE(TAG,"I2C IAQ_CORE_C timeout\n");
        } else if(ret == ESP_OK) {
            //printf("I2C MASTER READ SENSOR( IAQ_CORE_C ) : PRED %u , status %02X, resistance %d, Tvox %u\r\n",iaq_data.pred,iaq_data.status,iaq_data.resistance,iaq_data.Tvoc);
        } else {
        	ESP_LOGE(TAG,"IAQ_CORE_C: No ack, sensor not connected...skip...\n");
        }

#endif

        time(&UnitData.UpdateTime);
        //UnitData.Temp = HDC1080_data.temp_result;
        UnitData.Humidity = HDC1080_data.humidity_result;
        UnitData.Als = OPT3001_HoldReg.result;
        UnitData.aq_Co2Level = iaq_data.pred;
        UnitData.aq_Tvoc = iaq_data.Tvoc;
        UnitData.aq_status = iaq_data.status;

        vTaskDelay(( DELAY_TIME_BETWEEN_ITEMS_MS * ( task_idx + 1 ) ) / portTICK_RATE_MS);
    }
}

void I2c_Init()
{
	gpio_pad_select_gpio(I2C_DEATH_SWITCH_GPIO);
	gpio_set_direction(I2C_DEATH_SWITCH_GPIO, GPIO_MODE_OUTPUT);
	gpio_set_level(I2C_DEATH_SWITCH_GPIO, 1);

	vTaskDelay(1000 / portTICK_RATE_MS);
	i2c_master_init();
	vTaskDelay(1 / portTICK_RATE_MS);
	i2c_slave_init();
	xTaskCreatePinnedToCore(i2c_test_task, "i2c_test_task_0", 1024 * 2, (void* ) 0, 1, NULL,1);
}

