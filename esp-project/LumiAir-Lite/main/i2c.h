#ifndef MAIN_I2C_H_
#define MAIN_I2C_H_

#define DATA_LENGTH                         512              /*!<Data buffer length for test buffer*/
#define RW_TEST_LENGTH                      129              /*!<Data length for r/w test, any value from 0-DATA_LENGTH*/
#define DELAY_TIME_BETWEEN_ITEMS_MS         1000             /*!< delay time between different test items */

#define I2C_MASTER_SCL_IO             		2                /*!< gpio number for I2C master clock */
#define I2C_MASTER_SDA_IO          			15               /*!< gpio number for I2C master data  */
#define I2C_MASTER_NUM             			I2C_NUM_1        /*!< I2C port number for master dev */
#define I2C_MASTER_TX_BUF_DISABLE  			0                /*!< I2C master do not need buffer */
#define I2C_MASTER_RX_BUF_DISABLE  			0                /*!< I2C master do not need buffer */
#define I2C_MASTER_FREQ_HZ        			10000            /*!< I2C master clock frequency */

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

#define MCP7940_CLOCK_ADDR              	0x6F             /*!< slave address for MCP7940 */
#define MCP7940_REG_RTCSEC					0x00             /*!< Register Address: Time Second */
#define MCP7940_REG_RTCMIN   				0x01			 /*!< Register Address: Time Minute */
#define MCP7940_REG_RTCHOUR					0x02             /*!< Register Address: Time Hour */
#define MCP7940_REG_RTCWKDAY          		0x03             /*!< Register Address: Time Day of Week */
#define MCP7940_REG_RTCDATE  				0x04             /*!< Register Address: Time Day */
#define MCP7940_REG_RTCMTH   				0x05			 /*!< Register Address: Time Month */
#define MCP7940_REG_RTCYEAR  				0x06             /*!< Register Address: Time Year */
#define MCP7940_CON_CONFIG				    0x07			 /*!< Register Address: Config */

#define WRITE_BIT                           I2C_MASTER_WRITE  /*!< I2C master write */
#define READ_BIT                            I2C_MASTER_READ   /*!< I2C master read */
#define ACK_CHECK_EN                        0x1               /*!< I2C master will check ack from slave*/
#define ACK_CHECK_DIS                       0x0               /*!< I2C master will not check ack from slave */
#define ACK_VAL                             0x0               /*!< I2C ack value */
#define NACK_VAL                            0x1               /*!< I2C nack value */

#define I2C_DEATH_SWITCH_GPIO 			    GPIO_NUM_4

#define ENABLE_OPT3001
#define ENABLE_HDC1080
#define ENABLE_IAQ_CORE_C
#define ENABLE_MCP7940

typedef struct {
	float result;
	uint16_t raw_result;
	uint16_t config;
	uint16_t low_limit;
	uint16_t hight_limit;
	uint16_t manif_id;
	uint16_t device_id;
	uint8_t initDone;
} OPT3001_Typedef;

typedef struct {
	uint16_t pred;
	uint8_t status;
	int32_t resistance;
	uint16_t Tvoc;
} IAQ_CORE_Typedef;

typedef struct {
	uint8_t osillater_start;
	uint8_t osillater_status;
	uint8_t squareWaveEnabled;
	uint8_t squareWaveSelect;
	uint8_t alarmOneEnabled;
	uint8_t alarmTwoEnabled;
	uint8_t coarseTrimEnabled;
	uint8_t twelve_or_24;
	uint8_t powerFailure_state;
	uint8_t vBat_en;
	uint8_t leap_year;
	uint8_t second;
	uint8_t minute;
	uint8_t hour;
	uint8_t day_of_week;
	uint8_t day;
	uint8_t month;
	uint8_t year;
} MCP7940_Time_Typedef;

typedef struct {
	uint16_t temp_raw;
	uint16_t humidity_raw;
	uint16_t Config;
	float temp_result;
	float humidity_result;

} HDC1080_Typedef;

extern MCP7940_Time_Typedef MCP7940_time;
extern OPT3001_Typedef OPT3001_HoldReg;
extern IAQ_CORE_Typedef iaq_data;
extern HDC1080_Typedef HDC1080_data;
extern bool saveTimeOnBattery;

int TXD_PIN;
int RED_PIN;

void I2c_Init();

#endif /* MAIN_I2C_H_ */
