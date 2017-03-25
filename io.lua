relayState = 0
buttonStateDown = 0
ttp223StatDown = 0

function ioInterrupt(type)
    if type == "ttp223" then
        pin = config.io.ttp223_pin
        pin_state_active = gpio.HIGH
        delay_short = config.io.ttp223_delay_short_click_us
        delay_long = config.io.ttp223_delay_long_click_us
        stateDown = ttp223StatDown
    else
        pin = config.io.button_pin
        pin_state_active = gpio.LOW        
        delay_short = config.io.button_delay_short_click_us
        delay_long = config.io.button_delay_long_click_us
        stateDown = buttonStateDown
    end

    print("IO interrupt: " .. type)
    if (stateDown == 0 and gpio.read(pin) == pin_state_active) then
        if type == "ttp223" then
            buttonStateDown = 1
        else
            ttp223StatDown = 1
        end
        tmr.delay(delay_short)
        print("Short delay complete: " .. type)
        if (gpio.read(pin) == pin_state_active) then
            local clickType = 1
            tmr.delay(delay_long)
            print("Long delay complete: " .. type)
            if (gpio.read(pin) == pin_state_active) then
                clickType = 2
            end
            mqttMessage(config.mqtt.topic_button, clickType)
            if (clickType == 2 and config.io.relay_on_long_click == 1) or
               (clickType == 1 and config.io.relay_on_short_click == 1)
            then
                ioRelaySwitch()
            end
        end

        if type == "ttp223" then
            ioTTP223Up()
        else
            ioButtonUp()
        end
    end
end

function ioInterruptButton()
    ioInterrupt("button")
end

function ioInterruptTTP223()
    ioInterrupt("ttp223")
end

function ioButtonUp(doContinue)
    if doContinue == nil then
        tmr.alarm(config.io.button_up_tmr_alarmd_id, config.io.button_up_check_ms, tmr.ALARM_AUTO, function()
            ioButtonUp(true)
        end)
    end
    if gpio.read(config.io.button_pin) ~= gpio.LOW then
        buttonStateDown = 0
        tmr.unregister(config.io.button_up_tmr_alarmd_id)
    end
end

function ioTTP223Up(doContinue)
    if doContinue == nil then
        tmr.alarm(config.io.ttp223_up_tmr_alarmd_id, config.io.ttp223_up_check_ms, tmr.ALARM_AUTO, function()
            ioTTP223Up(true)
        end)
    end
    if gpio.read(config.io.ttp223_pin) ~= gpio.HIGH then
        ttp223StatDown = 0
        tmr.unregister(config.io.button_up_tmr_alarmd_id)
    end
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
gpio.trig(config.io.button_pin, "down", ioInterruptButton)

gpio.mode(config.io.ttp223_pin, gpio.INT)
gpio.trig(config.io.ttp223_pin, "up", ioInterruptTTP223)
