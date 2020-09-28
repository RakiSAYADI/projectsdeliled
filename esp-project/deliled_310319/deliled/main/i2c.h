/*
 * i2c.h
 *
 *  Created on: Jul 3, 2018
 *      Author: mdt
 */

#ifndef MAIN_I2C_H_
#define MAIN_I2C_H_


#define DATA_LENGTH                        512              /*!<Data buffer length for test buffer*/
#define RW_TEST_LENGTH                     129              /*!<Data length for r/w test, any value from 0-DATA_LENGTH*/
#define DELAY_TIME_BETWEEN_ITEMS_MS        1000             /*!< delay time between different test items */

#define I2C_MASTER_SCL_IO          2               /*!< gpio number for I2C master clock */
#define I2C_MASTER_SDA_IO          15               /*!< gpio number for I2C master data  */
#define I2C_MASTER_NUM             I2C_NUM_1        /*!< I2C port number for master dev */
#define I2C_MASTER_TX_BUF_DISABLE  0                /*!< I2C master do not need buffer */
#define I2C_MASTER_RX_BUF_DISABLE  0                /*!< I2C master do not need buffer */
#define I2C_MASTER_FREQ_HZ         10000           /*!< I2C master clock frequency */

#define OPT3001_SENSOR_ADDR                 0x44             /*!< slave address for OPT3001 sensor */
#define OPT3001_DEVICE_ID                   0x7F             /*!< slave Device ID */
#define OPT3001_RESULT_REG					0x00
#define OPT3001_CONFIG_REG					0x01

#define IAQ_CORE_C_SENSOR_ADDR              0x5A             /*!< slave address for IAQ_CORE_C sensor */
#define IAQ_CORE_C_REGISTER                	0xB5             /*!< slave Device ID */

#define HDC1080_SENSOR_ADDR              	0x40             /*!< slave address for HDC1080 sensor */
#define HDC1080_TEMP						0x00             /*!< Temperature */
#define HDC1080_CONFIG						0x02			 /* Config */
#define HDC1080_HUMID						0x01             /*!< Humidity */
#define HDC1080_DEVICE_ID               	0xFF             /*!< slave Device ID */

#define WRITE_BIT                          I2C_MASTER_WRITE /*!< I2C master write */
#define READ_BIT                           I2C_MASTER_READ  /*!< I2C master read */
#define ACK_CHECK_EN                       0x1              /*!< I2C master will check ack from slave*/
#define ACK_CHECK_DIS                      0x0              /*!< I2C master will not check ack from slave */
#define ACK_VAL                            0x0              /*!< I2C ack value */
#define NACK_VAL                           0x1              /*!< I2C nack value */

#define I2C_DEATH_SWITCH_GPIO 			   GPIO_NUM_4



#define ENABLE_OPT3001
#define ENABLE_HDC1080
#define ENABLE_IAQ_CORE_C


typedef struct
{
	float result;
	uint16_t raw_result;
	uint16_t config;
	uint16_t low_limit;
	uint16_t hight_limit;
	uint16_t manif_id;
	uint16_t device_id;
	uint8_t initDone;
}OPT3001_Typedef;

typedef struct
{
	uint16_t pred;
	uint8_t status;
	int32_t resistance;
	uint16_t Tvoc;
}IAQ_CORE_Typedef;


typedef struct
{
	uint16_t temp_raw;
	uint16_t humidity_raw;
	uint16_t Config;
	float temp_result;
	float humidity_result;

}HDC1080_Typedef;

extern OPT3001_Typedef OPT3001_HoldReg;
extern IAQ_CORE_Typedef iaq_data;
extern HDC1080_Typedef HDC1080_data;

void I2c_Init();


#endif /* MAIN_I2C_H_ */
