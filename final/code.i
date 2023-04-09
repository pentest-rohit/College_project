#include <Wire.h>
#include <LiquidCrystal.h>

//Initialize LCD
LiquidCrystal lcd(7, 6, 5, 4, 3, 2);

//Initialize pH Sensor
float calibration_value = 19.20;
int phval = 0; 
unsigned long int avgval; 
int buffer_arr[10],temp;

//Initialize Turbidity Sensor
int sensorPin = A2;
float volt;
float turbidity;

void setup() {
  //Initialize Serial Monitor
  Serial.begin(9600);

  //Initialize LCD
  lcd.begin(16, 2);

  //Initialize Turbidity Sensor
  pinMode(sensorPin, INPUT);
}

void loop() {
  //Read pH Sensor
  for(int i = 0; i < 10; i++) { 
    buffer_arr[i] = analogRead(A1);
    delay(30);
  }
  
  for(int i = 0; i < 9; i++) {
    for(int j = i + 1; j < 10; j++) {
      if(buffer_arr[i] > buffer_arr[j]) {
        temp = buffer_arr[i];
        buffer_arr[i] = buffer_arr[j];
        buffer_arr[j] = temp;
      }
    }
  }
  
  avgval = 0;
  for(int i = 2; i < 8; i++)
    avgval += buffer_arr[i];
    
  float volt_pH = (float) avgval * 5.0 / 1023 / 6;
  float pH_act = -5.70 * volt_pH + calibration_value;
  
  //Print pH value to Serial Monitor and Virtual Terminal
  Serial.print("pH Value: ");
  Serial.println(pH_act);
  Serial.flush();
 /* Serial.print("pH Value: ");
  Serial.println(pH_act);
  Serial.flush();
*/
  //Read Turbidity Sensor
  volt = 0;
  for(int i = 0; i < 800; i++) {
    volt += ((float) analogRead(sensorPin) / 1023) * 5;
  }
  
  volt = volt / 800;
  volt = round_to_dp(volt, 2);
  
  if(volt < 2.5) {
    turbidity = 3000;
  } else {
    turbidity = -1120.4 * square(volt) + 5742.3 * volt - 4353.8; 
  }

  //Read Temperature sensor

  int value = analogRead(A0);
  float mv= (value/1024.0)*5000;
  float cal= mv/10;

  //Print temperatue on lcd and virtual terminal;

  Serial.print("Temp Vaule: ");
  Serial.println(cal);



  //Print Turbidity value to Serial Monitor and Virtual Terminal
  Serial.print("Turbidity Value: ");
  Serial.println(turbidity);
  Serial.flush();
 /* Serial.print("Turbidity Value: ");
  Serial.println(turbidity);
  Serial.flush();
*/
  //Display pH and Turbidity values on LCD
  lcd.clear();
lcd.setCursor(0, 0);
lcd.print("pH:");
lcd.print(pH_act);
delay(100);  // Display pH for 5 seconds

lcd.clear();
lcd.setCursor(0, 0);
lcd.print("Temp:");
lcd.print(cal);
delay(100);  // Display temperature for 5 seconds

lcd.clear();
lcd.setCursor(0, 0);
lcd.print("Tur:");
lcd.print(turbidity);
delay(100);  // Display turbidity for 5 seconds

}

float round_to_dp(float in_value, int decimal_place) {
  float multiplier = powf(10.0f, decimal_place);
  in_value = roundf(in_value * multiplier) / multiplier;
  return in_value;
}
