#include <AFMotor.h>
#include <Servo.h>

#define EchoFront A1
#define TrigFront A0
#define EchoRight A3
#define TrigRight A2
#define EchoLeft A5
#define TrigLeft A4
#define motor 10
#define DefaultSpeed 170

char value;
int Speed = DefaultSpeed;

AF_DCMotor M1(1);
AF_DCMotor M2(2);
AF_DCMotor M3(3);
AF_DCMotor M4(4);

unsigned long previousMillis = 0;
const long interval = 100; // Read sensors every 100 milliseconds

int distanceFront = 0;
int distanceRight = 0;
int distanceLeft = 0;

void setup() {
  Serial.begin(9600);
  pinMode(TrigFront, OUTPUT);
  pinMode(EchoFront, INPUT);
  pinMode(TrigRight, OUTPUT);
  pinMode(EchoRight, INPUT);
  pinMode(TrigLeft, OUTPUT);
  pinMode(EchoLeft, INPUT);

  M1.setSpeed(DefaultSpeed);
  M2.setSpeed(DefaultSpeed);
  M3.setSpeed(DefaultSpeed);
  M4.setSpeed(DefaultSpeed);
}

void loop() {
  unsigned long currentMillis = millis();
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    distanceFront = ultrasonic(TrigFront, EchoFront);
    distanceRight = ultrasonic(TrigRight, EchoRight);
    distanceLeft = ultrasonic(TrigLeft, EchoLeft);

    Serial.print("F");
    Serial.print(distanceFront);
    Serial.print("R");
    Serial.print(distanceRight);
    Serial.print("L");
    Serial.println(distanceLeft);
  }

  Bluetoothcontrol();
}

void Bluetoothcontrol() {
  if (Serial.available() > 0) {
    value = Serial.read();
    if (value != -1) {
      Serial.println(value);
      processCommand(value);
    } else {
      Serial.println("Error reading from serial port");
    }
  }
}

void processCommand(char command) {
  if (command == 'F') {
    forward();
  } else if (command == 'B') {
    backward();
  } else if (command == 'L') {
    left();
  } else if (command == 'R') {
    right();
  } else if (command == 'S') {
    Stop();
  } else {
    Serial.println("Unknown command received");
  }
}

int ultrasonic(int trigPin, int echoPin) {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  long duration = pulseIn(echoPin, HIGH, 30000); // 30ms timeout
  if (duration == 0 || duration >= 30000) {
    return -1; // Return -1 for invalid readings
  }
  int distance = duration * 0.034 / 2; // Convert to centimeters
  if (distance < 0) {
    return -1; // Return -1 for negative readings
  }
  return distance;
}

void forward() {
  M1.run(FORWARD);
  M2.run(FORWARD);
  M3.run(FORWARD);
  M4.run(FORWARD);
}

void backward() {
  M1.run(BACKWARD);
  M2.run(BACKWARD);
  M3.run(BACKWARD);
  M4.run(BACKWARD);
}

void left() {
  M1.run(BACKWARD);
  M2.run(BACKWARD);
  M3.run(FORWARD);
  M4.run(FORWARD);
}

void right() {
  M1.run(FORWARD);
  M2.run(FORWARD);
  M3.run(BACKWARD);
  M4.run(BACKWARD);
}

void Stop() {
  M1.run(RELEASE);
  M2.run(RELEASE);
  M3.run(RELEASE);
  M4.run(RELEASE);
}
