  #include <DHT.h>
  #include <ESP8266WiFi.h>
  #include <PubSubClient.h>
  #include <ESP8266mDNS.h>
  #include "config.h"

  // Variables
  DHT dht_sensor(DHT_SENSOR_PIN, DHT_SENSOR_TYPE);
  WiFiClient espClient;
  PubSubClient client(espClient);
  String hubIp;
  int mqttPort = 1883;

  void setup() {
    Serial.begin(9600);

    // Initialize sensor
    dht_sensor.begin();
    
    // Connect to WiFi
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.print(".");
    }
    Serial.println("Connected to WiFi");

    // Initialize mDNS
    if (!MDNS.begin("WasteSorter")) {
      Serial.println("Error starting mDNS");
      return;
    }
  }

  void loop() {
    // Discover mDNS service if hubIp is empty
    if (hubIp.isEmpty() || mqttPort == -1) {
      discoverMDNSService();
    }

    // Connect to MQTT broker if hubIp is found and client is not connected
    if (!hubIp.isEmpty() && mqttPort != -1 && !client.connected()) {
      reconnectMQTT();
    }

    // MQTT loop
    client.loop();

    // Read from sensor
    float temperature = dht_sensor.readTemperature();
    float humidity = dht_sensor.readHumidity();

    // Check whether the reading is successful or not
    if (isnan(temperature) || isnan(humidity)) {
      Serial.println("Failed to read from DHT sensor!");
    } else {
      // Define topic for messages
      String topic = String(MQTT_TOPIC_PREFIX) + DEVICE_ID;
      
      // Publish temperature and humidity message
      String thermo_humid_message = "{\"temperature\":\"" + String(temperature) + "\", \"humidity\":\"" + String(humidity) + "\"}";
      client.publish(topic.c_str(), thermo_humid_message.c_str());

      // Print for debug
      Serial.print("Thermo Humid message: ");
      Serial.println(thermo_humid_message.c_str());
    }

    // Wait a 60 seconds between readings
    delay(60000);
  }

  void discoverMDNSService() {
    int n = MDNS.queryService("_http", "_tcp");
    if (n == 0) {
      Serial.println("No mDNS services found");
    } else {
      Serial.print(n);
      Serial.println(" service(s) found");
      for (int i = 0; i < n; i++) {
        String newHubHostname = MDNS.hostname(i);
        String newHubIp = MDNS.IP(i).toString();
        int newHubPort = MDNS.port(i);
        
        if (newHubHostname.endsWith(".local")) {
          newHubHostname = newHubHostname.substring(0, newHubHostname.length() - 6);
        }
        if (newHubHostname == HUB_SERVICE_NAME) {
          Serial.print("Service Name: ");
          Serial.println(newHubHostname);
          Serial.print("Service Type: ");
          Serial.println("_http._tcp");
          Serial.print("Host IP: ");
          Serial.println(newHubIp);
          Serial.print("Port: ");
          Serial.println(newHubPort);

          hubIp = newHubIp;
          client.setServer(newHubIp.c_str(), mqttPort);
          break;
        }
      }
    }
  }

  void reconnectMQTT() {
    while (!client.connected()) {
      if (client.connect(DEVICE_ID)) {
        Serial.println("Connected to MQTT broker");
      } else {
        Serial.print("Failed to connect, rc=");
        Serial.print(client.state());
        delay(2000);
      }
    }
  }
