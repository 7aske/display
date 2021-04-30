#include <Arduino.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#define MAX_MESSAGE_LENGTH 16
#define LCD_ID 0x27
#define LCD_ROWS 0x2
#define LCD_COLS 0x16

static const char* wlcm_msg = "Hello World!";

LiquidCrystal_I2C lcd(LCD_ID, LCD_COLS, LCD_ROWS);

void setup() {
  Serial.begin(9600);
  lcd.begin();
  lcd.backlight();
  lcd.clear();
  lcd.print(wlcm_msg);
  delay(1000);
  lcd.clear();
}

void lcd_write(char* message, int row) {
  if (row == 0)
    lcd.clear();
  lcd.setCursor(0, row);
  lcd.print(message);
}

void loop() {
  char input = 0;
  int row = 0;
  static char message[MAX_MESSAGE_LENGTH + 1];
  static unsigned int pos = 0;

  while (Serial.available() > 0) {
    input = Serial.read();
    if (input != '\n' && (pos <= MAX_MESSAGE_LENGTH)) {
      if (input == '\r') continue;
      message[pos++] = input;
    } else {
      message[pos] = '\0';
      pos = 0;
      lcd_write(message, row++);
      if (row > 1) row = 0;
    }
  }
}
