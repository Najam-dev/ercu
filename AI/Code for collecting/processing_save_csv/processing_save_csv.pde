import processing.serial.*;

Serial myPort; // Declare the Serial object

PrintWriter output;
String data = "";
int frontDistance = 0;
int rightDistance = 0;
int leftDistance = 0;
char action = ' '; // Variable to store the corresponding action

void setup() {
  size(500, 400);
  
  // Initialize the Serial object
  String[] portList = Serial.list();
  if (portList.length > 0) {
    myPort = new Serial(this, portList[0], 9600); // Adjust baud rate as necessary
  } else {
    println("No serial ports available");
    exit(); // Exit the sketch if no serial ports are available
  }
  
  output = createWriter("Square.csv"); // Create CSV file
  output.println("Front,Right,Left,Action"); // Write header
}

void draw() {
  background(200);
  fill(0);
  textSize(16);
  text("Front Distance: " + frontDistance + " cm", 50, 50);
  text("Right Distance: " + rightDistance + " cm", 50, 80);
  text("Left Distance: " + leftDistance + " cm", 50, 110);
  text("Action: " + action, 50, 140);

  if (myPort != null && myPort.available() > 0) {
    data = myPort.readStringUntil('\n');
    if (data != null) {
      parseData(data);
      output.println(frontDistance + "," + rightDistance + "," + leftDistance + "," + action); // Write sensor readings and action to CSV
      output.flush(); // Flush the buffer
    }
  }
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

void keyPressed() {
  if (key == 'w' || key == 'W') {
    action = 'W'; // Forward
    sendCommand('F'); // Forward
  } else if (key == 's' || key == 'S') {
    action = 'S'; // Backward
    sendCommand('B'); // Backward
  } else if (key == 'a' || key == 'A') {
    action = 'A'; // Left
    sendCommand('L'); // Left
  } else if (key == 'd' || key == 'D') {
    action = 'D'; // Right
    sendCommand('R'); // Right
  }
}

void keyReleased() {
  action = ' '; // Stop
  sendCommand('S'); // Stop
}

void sendCommand(char command) {
  myPort.write(command);
}

void stop() {
  output.flush(); // Flush the buffer
  output.close(); // Close the file
  super.stop();
}
