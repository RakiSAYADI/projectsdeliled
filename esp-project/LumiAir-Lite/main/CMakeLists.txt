
# Embed the server root certificate into the final binary

idf_component_register(SRCS "scanwifi.c" "sntpservice.c" "adc.c" "app_gpio.c" "autolight.c" "i2c.c" "lightcontrol.c" 
                    "base_mac_address.c" "bluetooth.c" "main.c" "unitcfg.c" "webservice.c" "https_ota.c"
                    INCLUDE_DIRS "." 
                    EMBED_TXTFILES ${project_dir}/server_certs/ca_cert.pem)
#register_component()

