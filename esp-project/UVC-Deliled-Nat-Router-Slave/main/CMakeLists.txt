
# Embed the server root certificate into the final binary

idf_component_register(SRCS 
                        "app_gpio.c" 
                        "base_mac_address.c" 
                        "uvc_task.c" 
                        "udp_client.c"
                        "system_init.c" 
                        "main.c" 
                        "unitcfg.c" 
                              INCLUDE_DIRS "")
# register_component()