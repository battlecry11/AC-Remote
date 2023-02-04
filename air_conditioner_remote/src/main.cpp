#include <Arduino.h>
#include <EEPROM.h>
#include <IRremote.hpp>
#include "ESPAsyncWebServer.h"
#include "DHT.h"
#include "ArduinoJson.h"
#include "AsyncJson.h"

#define DHTPIN 4
#define DHTTYPE DHT11

#define IR_RECEIVE_PIN 15
#define SENDING_REPEATS 1
#define IR_SEND_PIN 5
#define ENABLE_LED_FEEDBACK false

IPAddress staticIP(192, 168, 4, 1);
IPAddress gateway(192, 168, 0, 1);
IPAddress subnet(255, 255, 0, 0);
IPAddress dns(192, 168, 1, 1);

DHT dht(DHTPIN, DHTTYPE);

int ledpin = 2;
const int buffer_size = 100;
char recieved_codes[buffer_size];
char str[50];
char code_word[10] = "command:";
int char_index = 0;
bool enableConfig = false;

// // the credentials of your home wifi
// const char *ssid = "TP-LINK_734704";
// const char *password = "01527551";

int param_index = 0;
// struct to save button parameters
struct settings
{
  char on_off[10];
  char fan[10];
  char mode[10];
  char up[10];
  char down[10];
  char swing[10];
} user_settings = {};

// Create AsyncWebServer object on port 80
AsyncWebServer server(80);

void send_message(const char message[])
{
  unsigned long code = strtoul(message, NULL, 16);
  Serial.print("Sending code:");
  Serial.println(message);

  // // // the receiver has to be disabled to send messages
  // IrReceiver.stop();

  IrSender.sendNECRaw(code, SENDING_REPEATS);

  // // restarts the reciever

  IrReceiver.start();
}
void check_recieved()
{

  if (IrReceiver.decode())
  {
    if (IrReceiver.decodedIRData.decodedRawData != 0)
    {
      IrReceiver.printIRResultShort(&Serial);
      if (IrReceiver.decodedIRData.decodedRawData == 0xFFFFFFFF)
      {
        Serial.println("...");
      }
      else
      {
        Serial.println();
        Serial.println(IrReceiver.decodedIRData.decodedRawData, HEX);

        sprintf(str, "%X", IrReceiver.decodedIRData.decodedRawData);
        Serial.print("gor data: ");
        Serial.println(str);
        switch (param_index)
        {
        case 0:
          strncpy(user_settings.on_off, str, sizeof(user_settings.on_off));
          break;
        case 1:
          strncpy(user_settings.fan, str, sizeof(user_settings.fan));
          break;
        case 2:
          strncpy(user_settings.mode, str, sizeof(user_settings.mode));
          break;
        case 3:
          strncpy(user_settings.up, str, sizeof(user_settings.up));
          break;
        case 4:
          strncpy(user_settings.down, str, sizeof(user_settings.down));
          break;
        case 5:
          strncpy(user_settings.swing, str, sizeof(user_settings.swing));
          EEPROM.put(0, user_settings);
          EEPROM.commit();
          Serial.println("remote parameters has been saved on EEPROM memory ");
          enableConfig = false;
          break;

        default:
          break;
        }
        param_index++;
      }
    }
    IrReceiver.resume(); // Enable receiving of the next value
  }
}
String readTemperature()
{
  // Read temperature as Celsius (the default)
  float t = dht.readTemperature();
  Serial.print(F(" Temperature: "));
  Serial.print(t);
  Serial.println(F("°C "));
  return String(t);
}
String readHumidity()
{
  float h = dht.readHumidity();
  Serial.print(F("Humidity: "));
  Serial.print(h);
  Serial.println(F("% "));

  return String(h);
}
void setup()
{
  pinMode(ledpin, OUTPUT);
  Serial.begin(115200);
  Serial.println();
  Serial.println("Air_Conditioner_Remote");
  dht.begin();
  IrReceiver.begin(IR_RECEIVE_PIN, ENABLE_LED_FEEDBACK, USE_DEFAULT_FEEDBACK_LED_PIN);
  IrSender.begin(IR_SEND_PIN, ENABLE_LED_FEEDBACK);
  // get user settings from EEPROM memory
  EEPROM.begin(sizeof(struct settings));
  EEPROM.get(0, user_settings);
  // print all parameters
  Serial.println("COMMANDS: ");
  Serial.println("ON/OFF: " + String(user_settings.on_off));
  Serial.println("FAN: " + String(user_settings.fan));
  Serial.println("MODE: " + String(user_settings.mode));
  Serial.println("UP: " + String(user_settings.up));
  Serial.println("DOWN: " + String(user_settings.down));
  Serial.println("SWING: " + String(user_settings.swing));
  // agi ratomgac ar xodavs :(
  // Configures static IP address
  // if (WiFi.config(staticIP, gateway, subnet, dns, dns) == false)
  // {
  //   Serial.println("Configuration failed.");
  // }

  // // print hardcoded wifi credentials
  // Serial.println("Wifi SSID: " + String(ssid) + " Wifi Password: " + password);
  // // start wifi communication
  // WiFi.mode(WIFI_STA);
  // WiFi.begin(ssid, password);
  // // trying to connect to Wifi if not start soft access point
  // byte tries = 0;
  // while (WiFi.status() != WL_CONNECTED)
  // {
  //   delay(1000);
  //   if (tries++ > 10)
  //   {
  //     WiFi.mode(WIFI_AP);
  //     Serial.println("Can't connect to Wifi: " + String(ssid));
  //     Serial.println("incorrect credentials");
  //     break;
  //   }
  // }
  // // if connected to WiFi print IP address and start UDP
  // if (WiFi.status() == WL_CONNECTED)
  // {
  //   Serial.print("Connected to :");
  //   Serial.println(WiFi.SSID()); // Tell us what network we're connected to
  //   IPAddress ip = WiFi.localIP();
  //   Serial.printf("Now listening at IP %s", ip.toString().c_str());
  // }

  // Init WiFi as Station, start SmartConfig
  WiFi.mode(WIFI_AP_STA);
  WiFi.beginSmartConfig();

  // Wait for SmartConfig packet from mobile
  Serial.println("Waiting for SmartConfig.");
  while (!WiFi.smartConfigDone())
  {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("SmartConfig received.");

  // Wait for WiFi to connect to AP
  Serial.println("Waiting for WiFi");
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }

  Serial.println("WiFi Connected.");

  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  // turn on configuration
  server.on("/onconfig", HTTP_GET, [](AsyncWebServerRequest *request)
            { 
              digitalWrite(ledpin,HIGH);
              param_index=0;
              enableConfig=true;
              request->send(200, "application/json", "{\"message\":\"enable config\"}"); });
  // turn off configuration
  server.on("/offconfig", HTTP_GET, [](AsyncWebServerRequest *request)
            { 
              digitalWrite(ledpin,LOW);
              enableConfig=false;
              request->send(200, "application/json", "{\"message\":\"disable config\"}"); });
  // turn on/off device
  server.on("/on", HTTP_GET, [](AsyncWebServerRequest *request)
            { send_message(user_settings.on_off);
                  request->send(200, "application/json", "{\"message\":\"on/off device\"}"); });
  // set fan speed
  server.on("/fan", HTTP_GET, [](AsyncWebServerRequest *request)
            { 
              send_message(user_settings.fan);
              request->send(200, "application/json", "{\"message\":\"fan control\"}"); });
  // set device mode
  server.on("/mode", HTTP_GET, [](AsyncWebServerRequest *request)
            { 
              send_message(user_settings.mode);
              request->send(200, "application/json", "{\"message\":\"switch mode\"}"); });
  // set temperature up
  server.on("/up", HTTP_GET, [](AsyncWebServerRequest *request)
            { send_message(user_settings.up);
                  request->send(200, "application/json", "{\"message\":\"temperature up\"}"); });
  // set temperature down
  server.on("/down", HTTP_GET, [](AsyncWebServerRequest *request)
            { 
              send_message(user_settings.down);
              request->send(200, "application/json", "{\"message\":\"temperature down\"}"); });
  // change swing mode
  server.on("/swing", HTTP_GET, [](AsyncWebServerRequest *request)
            { 
              send_message(user_settings.swing);
              request->send(200, "application/json", "{\"message\":\"set swing mode\"}"); });
  server.on("/data", HTTP_GET, [](AsyncWebServerRequest *request)
            {
    StaticJsonDocument<200> data;

    data["temperature"] = readTemperature();
    data["humidity"] = readHumidity();  

    String response;
    serializeJson(data, response);
    request->send(200, "application/json", response); });
  // Start server
  server.begin();
}

void loop()
{
  if (enableConfig && param_index < 6)
    check_recieved();
  // readHumidity();
  // readTemperature();
  delay(10);
}