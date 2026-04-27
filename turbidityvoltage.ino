#include <Wire.h>
#include <Adafruit_ADS1X15.h>

Adafruit_ADS1115 ads;

// -------- Averaging Function --------
float readTurbidity() {
  float sum = 0;
  for (int i = 0; i < 20; i++) {
    int16_t adc = ads.readADC_SingleEnded(3);  // A3
    float v = adc * (4.096 / 32768.0);         // correct conversion
    sum += v;
    delay(10);
  }
  return sum / 20;
}

void setup() {
  Serial.begin(115200);
  Wire.begin(21, 22);

  if (!ads.begin(0x48)) {
    Serial.println("ADS not found!");
    while (1);
  }

  ads.setGain(GAIN_ONE);  // ±4.096V range

  Serial.println("Turbidity Sensor (A3) Final Test");
}

void loop() {

  float voltage = readTurbidity();

  Serial.print("Turbidity Voltage: ");
  Serial.print(voltage, 4);
  Serial.println(" V");

  delay(1000);
}