
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

Servo backRightServo; // Declare a Servo object for the back right tire

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

  backRightServo.attach(10); // Attach the servo to servo1 on the Adafruit Motor Shield
}

void loop() {
  int distanceFront = ultrasonic(TrigFront, EchoFront);
  int distanceRight = ultrasonic(TrigRight, EchoRight);
  int distanceLeft = ultrasonic(TrigLeft, EchoLeft);

  Serial.print("F"); // Send forward command
  Serial.print(distanceFront); // Send front distance
  Serial.print("R"); // Send right command
  Serial.print(distanceRight); // Send right distance
  Serial.print("L"); // Send left command
  Serial.println(distanceLeft); // Send left distance

  Bluetoothcontrol();
}

void Bluetoothcontrol() {
  if (Serial.available() > 0) {
    value = Serial.read();
    if (value != -1) {
      Serial.println(value);
      processCommand(value);
    } else {
      // Handle read error
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
  } else if (command == 'G') {
    setSpeed(90);
  } else if (command == 'H') {
    setSpeed(150);
  } else if (command == 'K') {
    setSpeed(225);
  } else if (command == 'M') { // Move servo to a specific position
    moveServo(); 
  } else {
    // Handle unknown command
    Serial.println("Unknown command received");
  }
}

void setSpeed(int newSpeed) {
  Speed = newSpeed;
  M1.setSpeed(newSpeed);
  M2.setSpeed(newSpeed);
  M3.setSpeed(newSpeed);
  M4.setSpeed(newSpeed);
}

// Ultrasonic sensor distance reading function
int ultrasonic(int trigPin, int echoPin) {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  long duration = pulseIn(echoPin, HIGH);
  int distance = duration * 0.034 / 2;  // Convert to centimeters
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

void right() {
  M1.run(BACKWARD);
  M2.run(BACKWARD);
  M3.run(FORWARD);
  M4.run(FORWARD);
}

void left() {
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

void moveServo() {
  // Move servo to a specific position using Adafruit Motor Shield library
  backRightServo.write(90); // 90 degrees
}
