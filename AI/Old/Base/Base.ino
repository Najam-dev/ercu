
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
#define NUM_READINGS 5

char value;
int Speed = DefaultSpeed;

AF_DCMotor M1(1);
AF_DCMotor M2(2);
AF_DCMotor M3(3);
AF_DCMotor M4(4);


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
  int distanceFront = ultrasonic(TrigFront, EchoFront);
  int distanceRight = ultrasonic(TrigRight, EchoRight);
  int distanceLeft = ultrasonic(TrigLeft, EchoLeft);
  
if (distanceFront != -1) {
    Serial.print("F");
    Serial.print(distanceFront);
  } else {
    Serial.print("F");
    Serial.print("NA"); // Indicate no valid reading
  }

  if (distanceRight != -1) {
    Serial.print("R");
    Serial.print(distanceRight);
  } else {
    Serial.print("R");
    Serial.print("NA");
  }

  if (distanceLeft != -1) {
    Serial.print("L");
    Serial.print(distanceLeft);
  } else {
    Serial.print("L");
    Serial.print("NA");
  }
  
  Serial.println();
/* old serial update of us
  Serial.print("F"); // Send forward command
  Serial.print(distanceFront); // Send front distance
  Serial.print("R"); // Send right command
  Serial.print(distanceRight); // Send right distance
  Serial.print("L"); // Send left command
  Serial.println(distanceLeft); // Send left distance
*/
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
  } else {
    // Handle unknown command
    Serial.println("Unknown command received");
  }
}


// Ultrasonic sensor distance reading function
// Updated ultrasonic function with averaging and timeout
int ultrasonic(int trigPin, int echoPin) {
  long totalDuration = 0;
  int validReadings = 0;
  
  for (int i = 0; i < NUM_READINGS; i++) {
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);
    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW);
    
    long duration = pulseIn(echoPin, HIGH, 30000); // 30ms timeout
    if (duration > 0) {
      totalDuration += duration;
      validReadings++;
    }
    delay(10); // Short delay between readings
  }
  
  if (validReadings > 0) {
    long averageDuration = totalDuration / validReadings;
    int distance = averageDuration * 0.034 / 2; // Convert to centimeters
    return distance;
  } else {
    return -1; // Indicate no valid reading
  }
}

/*old ultra sonic code without taking avaerage 
int ultrasonic(int trigPin, int echoPin) {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  long duration = pulseIn(echoPin, HIGH);
  int distance = duration * 0.034 / 2;  // Convert to centimeters
  return distance;
}*/


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

