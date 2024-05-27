import processing.serial.*;
import java.util.ArrayList;

Serial BTSerial;
ArrayList<ArrayList<Integer>> map; // 2D ArrayList to represent the map
int gridSize = 20; // Size of each grid cell in pixels (adjust as needed)
int rows, cols; // Number of rows and columns in the grid
int sensorRange = 200; // Maximum range of the ultrasonic sensors in cm
int robotX, robotY; // Robot's position on the map
int obstacleX, obstacleY; // Position of detected obstacle

void setup() {
  // Open serial port for communication with Arduino
  BTSerial = new Serial(this, "COM4", 9600); // Replace "COM4" with the appropriate port
  
  // Set the size of the canvas
  size(500, 500);
  
  // Calculate the number of rows and columns based on canvas size and grid size
  rows = height / gridSize;
  cols = width / gridSize;
  
  // Initialize the map with zeros (no obstacles)
  initializeMap();
  
  // Initialize the robot's position (in the center of the canvas)
  robotX = width / 2;
  robotY = height / 2;
}

void draw() {
  // Read data from Arduino
  if (BTSerial.available() > 0) {
    String data = BTSerial.readStringUntil('\n');
    if (data != null && data.length() >= 4) { // Check if data is not null and has enough characters
      data = data.trim();
      if (data.startsWith("F")) {
        int distanceFront = int(data.substring(1, data.indexOf('R')));
        int distanceRight = int(data.substring(data.indexOf('R') + 1, data.indexOf('L')));
        int distanceLeft = int(data.substring(data.indexOf('L') + 1));

        // Map obstacles based on ultrasonic sensor readings
        mapObstacles(distanceFront, distanceRight, distanceLeft);
      }
    }
  }
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

void initializeMap() {
  map = new ArrayList<ArrayList<Integer>>();
  for (int i = 0; i < rows; i++) {
    ArrayList<Integer> row = new ArrayList<Integer>();
    for (int j = 0; j < cols; j++) {
      row.add(0); // Add an empty space
    }
    map.add(row);
  }
}

void mapObstacles(int distanceFront, int distanceRight, int distanceLeft) {
  // Clear the map
  background(255);
  
  // Draw obstacles if detected
  if (distanceFront < sensorRange && distanceFront <= 30) {
    obstacleX = robotX;
    obstacleY = robotY - distanceFront;
    fill(255, 0, 0); // Red color for obstacles
    ellipse(obstacleX, obstacleY, 10, 10); // Draw obstacle
  }
  
  if (distanceRight < sensorRange && distanceRight <= 30) {
    obstacleX = robotX + distanceRight;
    obstacleY = robotY;
    fill(255, 0, 0); // Red color for obstacles
    ellipse(obstacleX, obstacleY, 10, 10); // Draw obstacle
  }
  
  if (distanceLeft < sensorRange && distanceLeft <= 30) {
    obstacleX = robotX - distanceLeft;
    obstacleY = robotY;
    fill(255, 0, 0); // Red color for obstacles
    ellipse(obstacleX, obstacleY, 10, 10); // Draw obstacle
  }
  
  // Draw the robot in the center
  fill(255, 255, 0); // Yellow color for the robot
  ellipse(robotX, robotY, 20, 20); // Draw robot
  
  // Draw lines indicating the front direction of the robot
  strokeWeight(2); // Set line thickness
  stroke(0, 0, 255); // Blue color for lines
  float frontX = robotX + cos(radians(0)) * 10;
  float frontY = robotY + sin(radians(0)) * 10;
  line(robotX, robotY, frontX, frontY); // Draw line
  line(frontX, frontY, frontX + cos(radians(-30)) * 5, frontY + sin(radians(-30)) * 5); // Draw line
  line(frontX, frontY, frontX + cos(radians(30)) * 5, frontY + sin(radians(30)) * 5); // Draw line
}
