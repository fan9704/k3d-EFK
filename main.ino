#include <ESP8266WiFi.h>
#include <PubSubClient.h>

// WiFi 設定
const char* ssid = "WIFI_ID";
const char* password = "WIFI_PASSWORD";

// MQTT 設定
const char* mqtt_server = "IP_ENDPOINT";
const int mqtt_port = 1883;

WiFiClient espClient;
PubSubClient client(espClient);

#define DEVICE_NUMBER 3  // 設定設備數量

void setup_wifi() {
    delay(10);
    Serial.println();
    Serial.print("Connecting to ");
    Serial.println(ssid);

    WiFi.begin(ssid, password);

    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }

    Serial.println("\nWiFi connected");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
}

void reconnect() {
    while (!client.connected()) {
        Serial.print("Attempting MQTT connection...");
        String clientID = "ArduinoD1Mini";
        if (client.connect(clientID.c_str())) {
            Serial.println("connected");
        } else {
            Serial.print("failed, rc=");
            Serial.print(client.state());
            Serial.println(" try again in 5 seconds");
            delay(5000);
        }
    }
}

void setup() {
    Serial.begin(115200);
    setup_wifi();
    client.setServer(mqtt_server, mqtt_port);
}

void loop() {
    if (!client.connected()) {
        reconnect();
    }
    client.loop();

    for (int i = 1; i <= DEVICE_NUMBER; i++) {
        int payload = random(0, 31);
        String clientID = "ArduinoTest0" + String(i);
        String topic = "home/" + clientID;
        Serial.print("[");
        Serial.print(clientID);
        Serial.print("]: 現在溫度：");
        Serial.println(payload);
        client.publish(topic.c_str(), String(payload).c_str());
    }
    delay(2000);
}
