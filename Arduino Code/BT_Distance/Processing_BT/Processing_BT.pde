import processing.serial.*;

Serial BTSerial;
int distanceFront = 0, distanceRight = 0, distanceLeft = 0;

void setup() {
  size(400, 200);
  BTSerial = new Serial(this, "COM4", 9600); // Replace "COMx" with your Arduino's COM port
}

void draw() {
  background(255);
  
  while (BTSerial.available() > 0) {  // Read all available serial data
    String data = BTSerial.readStringUntil('\n');
    if (data != null) {
      data = data.trim();
      if (data.startsWith("F")) {
        int indexR = data.indexOf('R');
        int indexL = data.indexOf('L');
        if (indexR != -1 && indexL != -1) {
          distanceFront = Integer.parseInt(data.substring(1, indexR));
          distanceRight = Integer.parseInt(data.substring(indexR + 1, indexL));
          distanceLeft = Integer.parseInt(data.substring(indexL + 1));
          println("Front: " + distanceFront + " | Right: " + distanceRight + " | Left: " + distanceLeft);
        } else {
          println("Invalid data format received: " + data);
        }
      }
    }
  }
  
  fill(0);
  textSize(16);
  text("Front Distance: " + distanceFront, 20, 30);
  text("Right Distance: " + distanceRight, 20, 60);
  text("Left Distance: " + distanceLeft, 20, 90);
}

void keyPressed() {
  if (keyCode == UP) {
    BTSerial.write('F'); // Move forward
  } else if (keyCode == DOWN) {
    BTSerial.write('B'); // Move backward
  } else if (keyCode == LEFT) {
    BTSerial.write('L'); // Turn left
  } else if (keyCode == RIGHT) {
    BTSerial.write('R'); // Turn right
  } else if (key == 'g' || key == 'G') {
    BTSerial.write('G'); // Set speed to 90
  } else if (key == 'h' || key == 'H') {
    BTSerial.write('H'); // Set speed to 150
  } else if (key == 'k' || key == 'K') {
    BTSerial.write('K'); // Set speed to 225
  } else if (key == 'm' || key == 'M') {
    BTSerial.write('M'); // Move servo
  }
}

void keyReleased() {
  if (keyCode == UP || keyCode == DOWN || keyCode == LEFT || keyCode == RIGHT) {
    BTSerial.write('S'); // Stop when key is released
  }
}
