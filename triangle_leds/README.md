# triangle_leds
Code and note for working with the NodeMCU ESP8266 and WS2812B LEDs

# triangle_leds
Code and notes for working with the NodeMCU ESP8266 and WS2812B LEDs

### Linux
```
arduino-cli config init
# edit the config file add 8266 and allow download from github
arduino-cli core update-index
arduino-cli core install esp8266:esp8266
arduino-cli lib install --git-url https://github.com/adafruit/Adafruit_NeoPixel
arduino-cli lib install --git-url https://github.com/kitesurfer1404/WS2812FX
arduino-cli compile -v --upload --build-path /home/pi/arduino_work --library /home/pi/triangle_leds/ws2812fx --port /dev/ttyUSB0 --fqbn esp8266:esp8266:nodemcuv2 triangle_led_app/triangle_led_app.ino
```

### Windows
```
arduino-cli.exe config init --config-file .\arduino_cli_config.yaml --overwrite
arduino-cli.exe --config-file .\arduino-cli.yaml board list
arduino-cli.exe --config-file .\arduino-cli.yaml core update-index
arduino-cli.exe --config-file .\arduino-cli.yaml core install esp8266:esp8266
arduino-cli.exe --config-file .\arduino-cli.yaml lib install --git-url https://github.com/adafruit/Adafruit_NeoPixel
arduino-cli.exe --config-file .\arduino-cli.yaml lib install --git-url https://github.com/kitesurfer1404/WS2812FX
arduino-cli.exe --config-file .\arduino-cli.yaml compile -v -b esp8266:esp8266:nodemcuv2 --build-path C:\Users\tommy\source\triangle_leds\build triangle_led_app
arduino-cli.exe upload .\triangle_led_app\triangle_led_app.ino --fqbn esp8266:esp8266:nodemcuv2 --port COM3
```
