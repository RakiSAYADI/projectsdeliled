
# Embed the server root certificate into the final binary
idf_component_register(SRCS "adc.c" "app_gpio.c" "autolight.c" "emailclient.c" "ftpclient.c" "gatt_server.c" "i2c.c" 
                    "lightcontrol.c" "main.c" "mqttclient.c" "ota_check.c" "ota_client.c" "sntp_client.c" "udp_client.c" "unitcfg.c" "webservice.c"
                    INCLUDE_DIRS "." 
                    EMBED_TXTFILES ${project_dir}/server_certs/ca_cert.pem)

#register_component()
