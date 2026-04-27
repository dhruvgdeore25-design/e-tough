#include <Wire.h>
#include <Adafruit_ADS1X15.h>
#include <OneWire.h>
#include <DallasTemperature.h>

// -------- ADS1115 --------
Adafruit_ADS1115 ads;

// -------- Temperature --------
#define ONE_WIRE_BUS 4
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

// -------- MQ135 --------
#define MQ135_PIN 34

// -------- Calibration --------
float tdsFactor = 217.0;
float phOffset = 2.39;

int sampleCount = 0;

// -------- Averaging --------
float readVoltage(int ch) {
  float sum = 0;
  for (int i = 0; i < 10; i++) {
    int16_t adc = ads.readADC_SingleEnded(ch);
    float v = adc * 0.1875 / 1000;
    sum += v;
    delay(20);
  }
  return sum / 10;
}

void setup() {
  Serial.begin(115200);
  Wire.begin(21, 22);

  if (!ads.begin(0x48)) {
    Serial.println("ADS not found!");
    while (1);
  }

  ads.setGain(GAIN_ONE);
  sensors.begin();

  pinMode(MQ135_PIN, INPUT);

  // ✅ HEADER PRINTED ONLY ONCE
  Serial.println("Temp,pH,TDS,Turbidity,Copper,MQ135");
}

void loop() {

  if (sampleCount >= 100) {
    Serial.println("DONE");
    while (1);
  }

  // -------- Read Sensors --------
  float v0 = readVoltage(0);
  float v1 = readVoltage(1);
  float v2 = readVoltage(2);
  float v3 = readVoltage(3);

  sensors.requestTemperatures();
  float tempC = sensors.getTempCByIndex(0);

  int mqRaw = analogRead(MQ135_PIN);
  float mqVoltage = mqRaw * (3.3 / 4095.0);

  // -------- Convert --------
  float pH = 7 + ((phOffset - v0) / 0.18);
  float tds = v2 * tdsFactor;
  float turbidity = v3 * 1000;

  // -------- CSV DATA --------
  Serial.print(tempC); Serial.print(",");
  Serial.print(pH, 2); Serial.print(",");
  Serial.print(tds, 1); Serial.print(",");
  Serial.print(turbidity); Serial.print(",");
  Serial.print(v1, 3); Serial.print(",");
  Serial.println(mqVoltage, 3);

  sampleCount++;

  delay(2000);
}
