
# Embed the server root certificate into the final binary

idf_component_register(SRCS "scanwifi.c" "sntpservice.c" "adc.c" "app_gpio.c" "autolight.c" "i2c.c" "lightcontrol.c" 
                    "base_mac_address.c" "bluetooth.c" "main.c" "unitcfg.c" "webservice.c" "sntpservice.c"
                    INCLUDE_DIRS "")
#register_component()

