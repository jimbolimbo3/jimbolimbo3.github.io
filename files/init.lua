OSS = 1 -- oversampling setting (0-3)
SDA_PIN = 2 -- sda pin, GPIO2 ovvero il D2 (Bisogna metterlo qua)
SCL_PIN = 3 -- scl pin, GPIO0 ovvero il D3

--
--wifi.setmode(wifi.STATION)
--wifi.sta.config(Vodafone-jimbo,A1B2C3D4E5)
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
                       conn:send("GET /trigger/node/with/key/d2ffjOyM5BgiAHrbX1GF4B?value1="
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


-- function sendDataT()
-- bmp180 = require("bmp180")
-- bmp180.init(SDA_PIN, SCL_PIN)
-- bmp180.read(OSS)

-- t = bmp180.getTemperature()
-- p = bmp180.getPressure()
-- print("Temperature: "..(t/10))--"."..(t%10).." deg C")
-- -- release module
-- bmp180 = nil
-- package.loaded["bmp180"]=nil
  
-- --connection to Maker Channel IFTTT

-- conn = net.createConnection(net.TCP, 0) 
-- -- show the retrieved web page

-- conn:on("receive", function(conn, payload) 
                       -- success = true
                       -- print(payload) 
                       -- end) 

-- -- once connected, request page (send parameters to a php script)
-- --send temperature
-- conn:on("connection", function(conn, payload) 
                       -- print('\nConnected') 
                       -- conn:send("GET /trigger/temperatura/with/key/d2ffjOyM5BgiAHrbX1GF4B?value1="
                        -- ..t
						-- .." HTTP/1.1\r\n" 
                        -- .."Host: maker.ifttt.com\r\n" 
                        -- .."Connection: close\r\n"
                        -- .."Accept: */*\r\n" 
                        -- .."User-Agent: Mozilla/4.0 "
                        -- .."(compatible; esp8266 Lua; "
                        -- .."Windows NT 5.1)\r\n" 
                        -- .."\r\n")
                       -- end)   

-- -- when disconnected, let it be known
-- conn:on("disconnection", function(conn, payload) print('\nDisconnected') end)				
-- end  --end della function sendDataT


-- send data every X ms to maker channel
tmr.alarm(0, 15000, 1, function() sendData() end )

