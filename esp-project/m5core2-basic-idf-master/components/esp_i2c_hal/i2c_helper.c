/*

SPDX-License-Identifier: MIT

MIT License

Copyright (c) 2019-2020 Mika Tuupola

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

#include <driver/i2c.h>
#include <esp_log.h>
#include <freertos/FreeRTOS.h>
#include <stdint.h>

#include "i2c_helper.h"

static const char* TAG = "i2c_helper";
static const uint8_t ACK_CHECK_EN = 1;

int32_t i2c_init() {
    ESP_LOGI(TAG, "Starting I2C master at port %d.", I2C_HAL_MASTER_NUM);

    i2c_config_t conf;
    conf.mode = I2C_MODE_MASTER;
    conf.sda_io_num = I2C_HAL_MASTER_SDA;
    conf.sda_pullup_en = GPIO_PULLUP_DISABLE;
    conf.scl_io_num = I2C_HAL_MASTER_SCL;
    conf.scl_pullup_en = GPIO_PULLUP_DISABLE;
    conf.master.clk_speed = I2C_HAL_MASTER_FREQ_HZ;

    ESP_ERROR_CHECK(i2c_param_config(I2C_HAL_MASTER_NUM, &conf));
    ESP_ERROR_CHECK(
        i2c_driver_install(
            I2C_HAL_MASTER_NUM,
            conf.mode,
            I2C_HAL_MASTER_RX_BUF_LEN,
            I2C_HAL_MASTER_TX_BUF_LEN,
            0
        )
    );

    return ESP_OK;
}

int32_t i2c_read(uint8_t address, uint8_t reg, uint8_t *buffer, uint16_t length) {

    esp_err_t result;
    i2c_cmd_handle_t cmd = i2c_cmd_link_create();

    if (reg) {
        /* When reading specific register set the address pointer first. */
        i2c_master_start(cmd);
        i2c_master_write_byte(cmd, (address << 1) | I2C_MASTER_WRITE, ACK_CHECK_EN);
        i2c_master_write(cmd, &reg, 1, ACK_CHECK_EN);
        ESP_LOGI(TAG, "Reading address 0x%02x register 0x%02x", address, reg);
    } else {
        ESP_LOGE(TAG, "Reading address 0x%02x", address);
    }

    /* Read length bytes from the current pointer. */
    i2c_master_start(cmd);
    i2c_master_write_byte(
        cmd,
        (address << 1) | I2C_MASTER_READ,
        ACK_CHECK_EN
    );
    if (length > 1) {
        i2c_master_read(cmd, buffer, length - 1, I2C_MASTER_ACK);
    }
    i2c_master_read_byte(cmd, buffer + length - 1, I2C_MASTER_NACK);
    i2c_master_stop(cmd);

    result = i2c_master_cmd_begin(
        I2C_HAL_MASTER_NUM,
        cmd,
        1000 / portTICK_RATE_MS
    );
    i2c_cmd_link_delete(cmd);

    ESP_LOG_BUFFER_HEX_LEVEL(TAG, buffer, length, ESP_LOG_DEBUG);
    ESP_ERROR_CHECK_WITHOUT_ABORT(result);

    return result;
}

int32_t i2c_write(uint8_t address, uint8_t reg, const uint8_t *buffer, uint16_t size)
{
    esp_err_t result;
    i2c_cmd_handle_t cmd = i2c_cmd_link_create();

    ESP_LOGI(TAG, "Writing address 0x%02x register 0x%02x", address, reg);
    ESP_LOG_BUFFER_HEX_LEVEL(TAG, buffer, size, ESP_LOG_DEBUG);

    i2c_master_start(cmd);
    i2c_master_write_byte(cmd, (address << 1) | I2C_MASTER_WRITE, ACK_CHECK_EN);
    i2c_master_write_byte(cmd, reg, ACK_CHECK_EN);
    i2c_master_write(cmd, (uint8_t *)buffer, size, ACK_CHECK_EN);
    i2c_master_stop(cmd);
    result = i2c_master_cmd_begin(I2C_HAL_MASTER_NUM, cmd, 1000 / portTICK_RATE_MS);
    i2c_cmd_link_delete(cmd);

    ESP_ERROR_CHECK_WITHOUT_ABORT(result);

    return result;
}

int32_t i2c_close() {
    ESP_LOGI(TAG, "Closing I2C master at port %d", I2C_HAL_MASTER_NUM);
    return i2c_driver_delete(I2C_HAL_MASTER_NUM);
}