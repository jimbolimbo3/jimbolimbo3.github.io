---
layout: post
title: Home Temperature and Pressure on your phone with NodeMCU, BMP180, IFTTT and Numerous app
---



<iframe src="http://n.numerousapp.com/e/iiohyve4p7w7?borderColor=F4F4F4" width="250" height="250" frameBorder="0" seamless scrolling="no"></iframe>


<iframe src="http://n.numerousapp.com/e/tn42h1irilpk?borderColor=F4F4F4" width="250" height="250" frameBorder="0" seamless scrolling="no"></iframe>

Download [bmp180.lua]({{site.baseurl}}/files/bmp180.lua) and [init.lua]({{site.baseurl}}/files/init.lua)

Recently I built a simple sensor reader with a NodeMCU (ESP8266) and Bosch BMP180, both bought on AliExpress. [Here](http://www.aliexpress.com/item/New-Wireless-module-NodeMcu-Lua-WIFI-Internet-of-Things-development-board-based-ESP8266-with-pcb-Antenna/32299982691.html) you find the NodeMCU and [here](http://www.aliexpress.com/item/Free-Shipping-GY-68-1PCS-BMP180-Digital-Barometric-Pressure-Sensor-Board-Module-compatible-with-BMP085/1821004301.html) you find the BMP180 I bought.

---
## How to?


First, you need to flash the firmware to NodeMCU, a light one that you can build on this site, because the library of BMP180 has some problem with memory. If you want you can use with [ESP8266Flasher]({{site.baseurl}}/files/ESP8266Flasher.exe) [this firmware(nodemcu-master-9-modules-2015-12-06-15-30-14-float.bin)]({{site.baseurl}}/files/nodemcu-master-9-modules-2015-12-06-15-30-14-float.bin) I built the 6th of December.
Connect the 3v3 pin of BMP180 to the **3v3 pin** of NodeMCU (it's 5v tollerant, but I didn't try it), connect the ground, and use **D2 for sda** and **D3 for scl**.
Flashed the firmware open either LUALoader or ESPlorer and flash BMP180.lua, the library, and init.lua, the script, to the NodeMCU: you can download here [bmp180.lua]({{site.baseurl}}/files/bmp180.lua) and [init.lua]({{site.baseurl}}/files/init.lua).

![NodeMCU-BMP180]({{site.baseurl}}/images/NodeMCU-BMP180_bb.png)



``` Lua
OSS = 1 -- oversampling setting (0-3)
SDA_PIN = 2 -- sda pin, GPIO2 that is D2 (Put your sensor here, for example on pin 1 and 2 doesn't work, who knows why)
SCL_PIN = 3 -- scl pin, GPIO0 that is D3

--
--wifi.setmode(wifi.STATION)
--wifi.sta.config(SSID,password)
wifi.sta.connect()
tmr.alarm(1, 5000, 1, function() 
    if wifi.sta.getip()== nil then
        print('IP unavaiable, waiting...') 
    else
        tmr.stop(1)
        print('IP is '..wifi.sta.getip())
    end
 end)


port = 80
gpio.mode(1, gpio.OUTPUT)

function sendData()
bmp180 = require("bmp180")
bmp180.init(SDA_PIN, SCL_PIN)
bmp180.read(OSS)

t = bmp180.getTemperature()/10
p = bmp180.getPressure()/100

--press = p/100
-- temperature in degrees Celsius  and Farenheit
--print("Temperature: "..(t/10))--"."..(t%10).." deg C")
--print("Temperature: "..(9 * t / 50 + 32).."."..(9 * t / 5 % 10).." deg F")
--print(..(t / 10)..)
-- pressure in differents units
--print("Pressure: "..(p).." Pa")
--print("Pressure: "..(p / 100).."."..(p % 100).." hPa")
--print("Pressure: "..(p / 100))--"."..(p % 100).." mbar")
--print(..(p / 100)..)
print(p)
print(t)
--print("Pressure: "..(p * 75 / 10000).."."..((p * 75 % 10000) / 1000).." mmHg")

-- release module
bmp180 = nil
package.loaded["bmp180"]=nil
  
--connection to Maker Channel IFTTT

conn = net.createConnection(net.TCP, 0) 
-- show the retrieved web page

conn:on("receive", function(conn, payload) 
                       success = true
                       print(payload) 
                       end) 

-- once connected, request page (send parameters to a php script)
--send pressure
conn:on("connection", function(conn, payload) 
                       print('\nConnected') 
                       conn:send("GET /trigger/MakerEvent/with/key/YOURKEY?value1="
                        ..p
						.."&value2="
						..t
						.." HTTP/1.1\r\n" 
                        .."Host: maker.ifttt.com\r\n" 
                        .."Connection: close\r\n"
                        .."Accept: */*\r\n" 
                        .."User-Agent: Mozilla/4.0 "
                        .."(compatible; esp8266 Lua; "
                        .."Windows NT 5.1)\r\n" 
                        .."\r\n")
                       end) 

-- when disconnected, let it be known
conn:on("disconnection", function(conn, payload) print('\nDisconnected') end)	   
conn:connect(80,'maker.ifttt.com') 
end  --end della function sendData

-- send data every X ms to maker channel
tmr.alarm(0, 15000, 1, function() sendData() end )
```

The script read the pressure and the temperature every 15 seconds and send them to the Maker Channel of IFTTT, that you can set up at this [link](https://ifttt.com/maker), just add your Maker Event and your key to the script.
