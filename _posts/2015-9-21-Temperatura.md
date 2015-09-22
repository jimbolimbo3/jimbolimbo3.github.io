---
layout: post
title: Home Temperature and Humidity
---

<div align=center><iframe src="http://n.numerousapp.com/e/1bou1sfzbjtxx?borderColor=F4F4F4" width="250" height="250" frameBorder="0" seamless scrolling="no"></iframe>

<iframe src="http://n.numerousapp.com/e/dcja29zibvzi?borderColor=F4F4F4" width="250" height="250" frameBorder="0" seamless scrolling="no"></iframe> </div>


---
# How to?

First, you need:
- [Particle Photon/Core](https://store.particle.io/)
- Wires
- One 3,5 K\Ohm Resistance
- Breadboard
- One [DTH22](http://it.aliexpress.com/item/DHT22-Digital-Temperature-And-Humidity-Sensor-Free-Shipping-Dropshipping/1738714600.html) Temperature/Humidity sensor
- 30 minutes of time

**The circuit:**

![Photon and DHT22]({{site.baseurl}}/images/photon-dht22.png)

Download [here]({{site.baseurl}}/Particle-Photon-DHT22.fzz) the circuit design for Fritzing.

Connect you Photon/Core and go to https://build.particle.io/build
Insert this code, adding as well the library *"PietteTech_DHT/PietteTech_DHT.h"*.

Code for **Arduino/Particle Spark**:

``` c++
#include "PietteTech_DHT/PietteTech_DHT.h"
#include "math.h"

#define DHTTYPE  DHT22       // Sensor type DHT11/21/22/AM2301/AM2302
#define DHTPIN   3           // Digital pin for communications
//#define NUM_TRACES 2 //There will be 4 data traces in the stream

//declaration
void dht_wrapper(); // must be declared before the lib initialization


// Lib instantiate
PietteTech_DHT DHT(DHTPIN, DHTTYPE, dht_wrapper);
int n;      // counter
double temp;  //temperatura era double  
double umid;  //umidità  era double
double t;   //mi serve per approx

void dht_wrapper() {
    DHT.isrCallback();
}



void setup()
{
    Serial.begin(9600);

    Serial.println("Device starting...");

    //while (!Serial.available()) {
    //    Serial.println("Press any key to start.");
    //    delay (1000);
    //}
    Serial.println("DHT Example program using DHT.acquireAndWait");
    Serial.print("LIB version: ");
    Serial.println(DHTLIB_VERSION);
    Serial.println("---------------");
}

// This wrapper is in charge of calling
// must be defined like this for the lib work


//void dht_wrapper() {
//    DHT.isrCallback();
//}

void loop()
{
    Serial.print("\n");
    Serial.print(n);
    Serial.print(": Retrieving information from sensor: ");
    Serial.print("Read sensor: ");
    //delay(100);

    int result = DHT.acquireAndWait();

    switch (result) {
        case DHTLIB_OK:
            Serial.println("OK");
            break;
        case DHTLIB_ERROR_CHECKSUM:
            Serial.println("Error\n\r\tChecksum error");
            break;
        case DHTLIB_ERROR_ISR_TIMEOUT:
            Serial.println("Error\n\r\tISR time out error");
            break;
        case DHTLIB_ERROR_RESPONSE_TIMEOUT:
            Serial.println("Error\n\r\tResponse time out error");
            break;
        case DHTLIB_ERROR_DATA_TIMEOUT:
            Serial.println("Error\n\r\tData time out error");
            break;
        case DHTLIB_ERROR_ACQUIRING:
            Serial.println("Error\n\r\tAcquiring");
            break;
        case DHTLIB_ERROR_DELTA:
            Serial.println("Error\n\r\tDelta time to small");
            break;
        case DHTLIB_ERROR_NOTSTARTED:
            Serial.println("Error\n\r\tNot started");
            break;
        default:
            Serial.println("Unknown error");
            break;
    }


    //codice funzionante con le cifre al posto giusto
    /* Serial.print("Humidity (%): ");
    Serial.println(DHT.getHumidity(), 2);

    umid=DHT.getHumidity();
    Spark.variable("Humidity", &umid, DOUBLE); //write the value on the cloud variable called "Humidity"

    Serial.print("Temperature (oC): ");
    Serial.println(DHT.getCelsius(), 2);

    temp=DHT.getCelsius();
    Spark.variable("Temperature", &temp, DOUBLE); //write the value on the cloud variable called "Temperature"

    Serial.print("Temperature (oF): ");
    Serial.println(DHT.getFahrenheit(), 2);

    Serial.print("Temperature (K): ");
    Serial.println(DHT.getKelvin(), 2);

    Serial.print("Dew Point (oC): ");
    Serial.println(DHT.getDewPoint());

    Serial.print("Dew Point Slow (oC): ");
    Serial.println(DHT.getDewPointSlow());
    */


    //fine codice funzionante


    //codice per approssimare alla seconda cifra decimale
    /* t=n-floor(n);
      if (t>=0.5)    
      {
              n*=10;//where n is the multi-decimal float
              ceil(n);
              n/=10;
              }
      else
      {
              n*=10;//where n is the multi-decimal float
              floor(n);
              n/=10;
              }
      return n;
     */
    //fine codice per approssimare


    Serial.print("Humidity (%): ");
    Serial.println(DHT.getHumidity(), 2);

    umid=DHT.getHumidity();


    //approssimo l'umidità
    t=umid-floor(umid); //solo la parte decimale
    t=t*100; //moltiplico per 100 la parte decimale, ottengo xx.xxxxxxxxx
    t=floor(t); //taglio la parte decimale della parte decimale: ho solo due cifre, ottengo yy
    umid=floor(umid)+(t/100);

    Spark.variable("Umidita", &umid, DOUBLE); //write the value on the cloud variable called "Humidity"

    Serial.print("Temperature (oC): ");
    Serial.println(DHT.getCelsius(), 2);

    temp=DHT.getCelsius();

    //approssimo la temperatura
    t=temp-floor(temp); //solo la parte decimale
    t=t*100; //moltiplico per 100 la parte decimale, ottengo xx.xxxxxxxxx
    t=floor(t); //taglio la parte decimale della parte decimale: ho solo due cifre, ottengo yy
    temp=floor(temp)+(t/100);

    Spark.variable("Temperatura", &temp, DOUBLE); //write the value on the cloud variable called "Temperature"

    Serial.print("Temperature (oF): ");
    Serial.println(DHT.getFahrenheit(), 2);

    Serial.print("Temperature (K): ");
    Serial.println(DHT.getKelvin(), 2);

    Serial.print("Dew Point (oC): ");
    Serial.println(DHT.getDewPoint());

    Serial.print("Dew Point Slow (oC): ");
    Serial.println(DHT.getDewPointSlow());

    n++;
    delay(30000);
}
```

Then I used this recipe to take variables from Particle Spark to my Numerous account:

<a href="https://ifttt.com/view_embed_recipe/326961-take-a-particle-photon-variable-to-numerous-number" target = "_blank" class="embed_recipe embed_recipe-l_50" id= "embed_recipe-326961"><img src= 'https://ifttt.com/recipe_embed_img/326961' alt="IFTTT Recipe: Take a Particle Photon Variable to Numerous Number connects particle to numerous" width="370px" style="max-width:100%"/></a><script async type="text/javascript" src= "//ifttt.com/assets/embed_recipe.js"></script>

That's all!

**Note that the Particle Variable are case sensitive.**
