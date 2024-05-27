import processing.serial.*;

Serial myPort;
String data = "";
int frontDistance = 0;
int rightDistance = 0;
int leftDistance = 0;

void setup() {
  size(500, 400);
  String portName = Serial.list()[0];  // Adjust the port index as necessary
  myPort = new Serial(this, "COM4", 9600);
}

void draw() {
  background(200);
  fill(0);
  textSize(16);
  text("Front Distance: " + frontDistance + " cm", 50, 50);
  text("Right Distance: " + rightDistance + " cm", 50, 80);
  text("Left Distance: " + leftDistance + " cm", 50, 110);

  if (myPort.available() > 0) {
    data = myPort.readStringUntil('\n');
    if (data != null) {
      parseData(data);
    }
  }
}

void keyPressed() {
  if (key == 'w' || key == 'W') {
    sendCommand('F'); // Forward
  } else if (key == 's' || key == 'S') {
    sendCommand('B'); // Backward
  } else if (key == 'a' || key == 'A') {
    sendCommand('L'); // Left
  } else if (key == 'd' || key == 'D') {
    sendCommand('R'); // Right
  }
}

void keyReleased() {
  // Stop the rover when any key is released
  sendCommand('S'); // Stop
}

void sendCommand(char command) {
  myPort.write(command);
}

void parseData(String data) {
  data = data.trim();
  if (data.startsWith("F")) {
    int indexF = data.indexOf("F");
    int indexR = data.indexOf("R");
    int indexL = data.indexOf("L");
    if (indexF != -1 && indexR != -1 && indexL != -1) {
      frontDistance = int(data.substring(indexF + 1, indexR));
      rightDistance = int(data.substring(indexR + 1, indexL));
      leftDistance = int(data.substring(indexL + 1));
    }
  }
}
