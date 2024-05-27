import processing.serial.*;
import java.util.ArrayList;

Serial BTSerial;
ArrayList<ArrayList<Integer>> map; // 2D ArrayList to represent the map
int gridSize = 20; // Size of each grid cell in pixels (adjust as needed)
int rows, cols; // Number of rows and columns in the grid
int sensorRange = 200; // Maximum range of the ultrasonic sensors in cm
int robotX, robotY; // Robot's position on the map

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
  
  // Initialize the robot's position (in the center of the grid)
  robotX = cols / 2;
  robotY = rows / 2;
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
  // Save the previous map
  ArrayList<ArrayList<Integer>> previousMap = new ArrayList<ArrayList<Integer>>();
  for (ArrayList<Integer> row : map) {
    previousMap.add(new ArrayList<Integer>(row));
  }
  
  // Clear the current map
  initializeMap();
  
  // Map obstacles within the grid
  int x = cols / 2;
  int y = rows / 2;
  
  if (distanceFront < sensorRange && distanceFront <= 30) {
    int frontIndex = y - distanceFront / gridSize;
    if (frontIndex >= 0 && frontIndex < rows) {
      map.get(frontIndex).set(x, 1); // Mark obstacle in front
    }
  }
  
  if (distanceRight < sensorRange && distanceRight <= 30) {
    int rightIndex = x + distanceRight / gridSize;
    if (rightIndex >= 0 && rightIndex < cols) {
      map.get(y).set(rightIndex, 1); // Mark obstacle on right side
    }
  }
  
  if (distanceLeft < sensorRange && distanceLeft <= 30) {
    int leftIndex = x - distanceLeft / gridSize;
    if (leftIndex >= 0 && leftIndex < cols) {
      map.get(y).set(leftIndex, 1); // Mark obstacle on left side
    }
  }
  
  // Draw the map with obstacle boundaries
  drawMap(previousMap);
}

void drawMap(ArrayList<ArrayList<Integer>> previousMap) {
  // Clear the canvas
  background(255);
  
  // Draw each grid cell
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      if (map.get(i).get(j) == 1) {
        fill(0); // Set obstacle color to black
      } else {
        fill(255); // Set empty space color to white
      }
      rect(j * gridSize, i * gridSize, gridSize, gridSize); // Draw each grid cell
    }
  }
  
  // Restore the previous map
  map = previousMap;
}
