relayState = 0
ttp223LastClick = 0

function ioButtonInterrupt()
    print("Interrupt")
    if (gpio.read(config.io.button_pin) == gpio.LOW) then
        tmr.delay(config.io.button_delay_short_click_us)
        print("Short delay complete")
        if (gpio.read(config.io.button_pin) == gpio.LOW) then
            local clickType = 1
            tmr.delay(config.io.button_delay_long_click_us)
            print("Long delay complete")
            if (gpio.read(config.io.button_pin) == gpio.LOW) then
                clickType = 2
            end
            mqttMessage(config.mqtt.topic_button, clickType)
            if (clickType == 2 and config.io.relay_on_long_click == 1) or
               (clickType == 1 and config.io.relay_on_short_click == 1)
            then
                mqttMessage(config.mqtt.topic_button, clickType)
                ioRelaySwitch()
            end
        end
        while gpio.read(config.io.button_pin) == gpio.LOW do
            tmr.delay(config.io.button_delay_debounce_us)
        end
    end
end

function ioButtonInterruptTTP223()
    print("TTP223 interrupt")
    if (tmr.now() - ttp223LastClick < config.io.ttp223_delay_dbl_click_us) then
        mqttMessage(config.mqtt.topic_button, 2)
    else
        mqttMessage(config.mqtt.topic_button, 1)
        ioRelaySwitch()
    end
    ttp223LastClick = tmr.now()
end

function ioRelaySwitch(state)
    local state = state or 2;
    assert(state >= 0 and state <= 2, "state := 0..2")
    local gpioLevel = gpio.LOW
    if state == 1 or (state == 2 and relayState == 0) then
        relayState = 1
        gpioLevel = gpio.HIGH
    else
        relayState = 0
        gpioLevel = gpio.LOW
    end
    gpio.write(config.io.relay_pin, gpioLevel)
    gpio.write(config.io.led_green_pin, gpioLevel == gpio.LOW and gpio.HIGH or gpio.LOW)
    mqttMessage(config.mqtt.topic_relay, gpioLevel == gpio.HIGH and 'ON' or 'OFF')
end

gpio.mode(config.io.relay_pin, gpio.OUTPUT)
gpio.write(config.io.relay_pin, gpio.LOW)

gpio.mode(config.io.led_green_pin, gpio.OUTPUT)
gpio.write(config.io.led_green_pin, gpio.HIGH)

gpio.mode(config.io.button_pin, gpio.INT, gpio.PULLUP)
gpio.trig(config.io.button_pin, "down", ioButtonInterrupt)

gpio.mode(config.io.ttp223_pin, gpio.INT, gpio.PULLUP)
gpio.trig(config.io.ttp223_pin, "down", ioButtonInterruptTTP223)
