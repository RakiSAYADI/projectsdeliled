#set(COMPONENT_SRCS "main.c")
#set(COMPONENT_ADD_INCLUDEDIRS ".")
idf_component_register(SRCS "autolight.c" "base_mac_address.c" "bluetooth.c" "lightcontrol.c" "main.c"
                         "pwm_capture.c" "scanwifi.c" "system_init.c" "unitcfg.c" "wificonnect.c"
                    INCLUDE_DIRS "")
#register_component()
