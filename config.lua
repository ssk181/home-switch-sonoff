config = {
    network = {
        ssid         = "MyWiFiRouter",
        password     = "Password",
        tmr_alarm_id = 0,
        tmr_retry_ms = 20000
    },
    collectgarbage = {
        ticks = 10
    },
    dht = {
        pin = nil -- GPIO pin index or nil if disabled (5 for SONOFF)
    },
    io = {
        relay_on_short_click        = 1,
        relay_on_long_click         = 1,
        button_pin                  = 3,
        relay_pin                   = 6,
        led_green_pin               = 7,
        button_delay_short_click_us = 20000,
        button_delay_long_click_us  = 500000,
        button_up_tmr_alarmd_id     = 3,
        button_up_check_ms          = 500
    },
    mqtt = {
        broker_ip      = "192.168.182.2",
        port           = 1883,
        user           = "",
        password       = "",
        keep_alive_sec = 60,
        tmr_alarm_id   = 2,
        tmr_retry_ms   = 3000,
        queue_ttl_sec  = 3600,
        queue_max_size = 50,
        topic_online   = "online",
        topic_button   = "button",
        topic_relay    = "relay",
        topic_climate_temp     = "climate/temp",
        topic_climate_humidity = "climate/humidity",
        topic_state_uptime     = "state/uptime",
        topic_state_memory     = "state/memory",
        topic_state_relay      = "state/relay",
        topic          = "/home/iot",
        dir_in         = "in",
        dir_out        = "out",
        msg_on         = "ON",
        msg_off        = "OFF",
        msg_invert     = "INVERT",
        climate_cache_sec = 15
    }
}
