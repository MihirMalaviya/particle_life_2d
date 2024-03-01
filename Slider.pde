class Slider {
  float x, y;      // Position of the slider
  float w, h;      // Width and height of the slider
  int fillColor;   // Color when slider is filled
  int emptyColor;  // Color when slider is empty
  String label;    // Label for the slider
  float value;     // Current value of the slider
  float minValue;  // Minimum value of the slider
  float maxValue;  // Maximum value of the slider
  int mode;        // 0 for integer mode, 1 for float mode
  boolean isDragging;  // Flag to check if the slider is being dragged

  Slider(float x, float y, float w, float h, float minValue, float maxValue, float startValue, int fillColor, String label, int mode) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.fillColor = fillColor;
    this.emptyColor = color(255, 255 * 0.25);
    this.label = label;
    this.mode = mode;
    this.minValue = minValue;
    this.maxValue = maxValue;
    this.value = constrain(startValue, minValue, maxValue);  // Initial value within the range
    this.isDragging = false;
  }
  
  Slider(float w, float h, float minValue, float maxValue, float startValue, int fillColor, String label, int mode) {
    this.x = 0;
    this.y = 0;
    this.w = w;
    this.h = h;
    this.fillColor = fillColor;
    this.emptyColor = color(255, 255 * 0.25);
    this.label = label;
    this.mode = mode;
    this.minValue = minValue;
    this.maxValue = maxValue;
    this.value = constrain(startValue, minValue, maxValue);  // Initial value within the range
    this.isDragging = false;
  }
  
  Slider(float h, float minValue, float maxValue, float startValue, int fillColor, String label, int mode) {
    this.x = 0;
    this.y = 0;
    this.w = 0;
    this.h = h;
    this.fillColor = fillColor;
    this.emptyColor = color(255, 255 * 0.25);
    this.label = label;
    this.mode = mode;
    this.minValue = minValue;
    this.maxValue = maxValue;
    this.value = constrain(startValue, minValue, maxValue);  // Initial value within the range
    this.isDragging = false;
  }

  void position(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void size(float w, float h) {
    this.w = w;
    this.h = h;
  }

  void display() {
    noStroke();

    // Draw empty background
    fill(emptyColor);
    rect(x, y, w, h);

    // Draw filled portion based on the current value
    fill(fillColor);
    float filledWidth = map(value, minValue, maxValue, 0, w);
    rect(x, y, filledWidth, h);

    // Display label
    fill(255);
    textAlign(LEFT, CENTER);
    text(label + " =", x + 5, y + h/2);

    // Display current value
    textAlign(CENTER, CENTER);
    String valueText = (mode == 0) ? str(int(value)) : nf(value, 1, 2);
    text(valueText, x + w / 2, y + h / 2);
  }

  float getValue() {
    return value;
  }

  void update(float mx) {
    // Update value only if dragging is in progress
    if (isDragging) {
      // Update value based on mouse position
      float newValue = map(constrain((mx - x), 0, w), 0, w, minValue, maxValue);
      if (mode == 0) {
        value = round(newValue);  // Integer mode
      } else {
        value = newValue;         // Float mode
      }
    }
  }

  void mousePressed() {
    // Check if mouse is pressed inside the slider
    if (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h) {
      isDragging = true;
    }
  }

  void mouseReleased() {
    // Reset dragging flag when mouse is released
    isDragging = false;
  }
}
