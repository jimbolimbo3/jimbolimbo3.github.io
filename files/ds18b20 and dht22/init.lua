    require('ds18b20')
	dht=require("dht")
    status,temp,humi,temp_decimial,humi_decimial = dht.read(2)
        if( status == dht.OK ) then
            --temperature = temp.."."..(temp_decimial) --/100
            --humidity = humi.."."..(humi_decimial) --/100
            --print("Temperature: "..temperature.." deg C")
            --print("Humidity: "..humidity.."%")
			print("Temperatura:" ..temp.." C")
			print("Umidità: " ..humi.."%")
        elseif( status == dht.ERROR_CHECKSUM ) then          
            print( "DHT Checksum error" )
            temperature=-1 --TEST
        elseif( status == dht.ERROR_TIMEOUT ) then
            print( "DHT Time out" )
            temperature=-2 --TEST
        end
		
		port = 80

-- ESP-01 GPIO Mapping
gpio0, gpio2 = 3, 4

ds18b20.setup(gpio2)

srv=net.createServer(net.TCP)
srv:listen(port,
     function(conn)
          conn:send("HTTP/1.1 200 OK\nContent-Type: text/html\nRefresh: 5\n\n" ..
              "<!DOCTYPE HTML>" ..
              "<html><body>" ..
              "<b>ESP8266</b></br>" ..
              "Temperature : " .. temp .. "<br>" ..
			  "Humidity : " .. humi .. "<br>" ..
			  "External Temperature : " .. ds18b20.read() .. "<br>" ..
              "Node ChipID : " .. node.chipid() .. "<br>" ..
              "Node MAC : " .. wifi.sta.getmac() .. "<br>" ..
              "Node Heap : " .. node.heap() .. "<br>" ..
              "Timer Ticks : " .. tmr.now() .. "<br>" ..
              "</html></body>")          
          conn:on("sent",function(conn) conn:close() end)
     end
)

    -- Release module
    dht=nil
    package.loaded["dht"]=nil