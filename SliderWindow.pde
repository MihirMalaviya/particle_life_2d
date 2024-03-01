class SliderWindow {
  float x, y;          // Position of the window
  float w, h;          // Width and height of the window
  int bgColor;         // Background color of the window
  String windowLabel;  // Label for the window
  ArrayList<Slider> sliders;  // ArrayList to store sliders
  float sliderYMargin;  // Margin between sliders
  float sliderPadding;   // Padding within each slider
  float textSpace = 20;
  boolean isDragging;   // Flag to check if any slider is being dragged

  SliderWindow(float x, float y, float w, int bgColor, String windowLabel) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = 10;
    this.bgColor = bgColor;
    this.windowLabel = windowLabel;
    this.sliders = new ArrayList<Slider>();
    this.sliderYMargin = 10;
    this.sliderPadding = 10;
    this.isDragging = false;
  }

  void addSlider(Slider slider) {
    // Calculate position for the new slider
    float sliderX = x + sliderPadding;
    float sliderY = y + sliders.size() * (slider.h + sliderYMargin) + sliderPadding + textSpace;

    // Set the position for the added slider
    slider.position(sliderX, sliderY);

    // Add the slider to the list
    sliders.add(slider);

    // Adjust the window height
    h = sliders.size() * (slider.h + sliderYMargin) + sliderPadding + textSpace;

    size(w, h);
  }

  void display() {
    noStroke();
    rectMode(CORNER);
    
    // Draw window background
    fill(bgColor);
    rect(x, y, w, h);

    // Display window label
    fill(255);
    textAlign(LEFT, CENTER);
    text(windowLabel, x + sliderPadding, y + textSpace/2 + sliderPadding/2);

    // Display sliders
    for (Slider slider : sliders) {
      slider.display();
    }
  }

  void mousePressed() {
    // Check if mouse is pressed inside the window
    if (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h) {
      // Propagate mousePressed to all sliders
      for (Slider slider : sliders) {
        slider.mousePressed();
      }
      isDragging = true;
    }
  }

  void mouseReleased() {
    // Reset dragging flag for all sliders
    for (Slider slider : sliders) {
      slider.mouseReleased();
    }
    isDragging = false;
  }

  void mouseDragged() {
    // Update all sliders when the mouse is dragged
    if (isDragging) {
      for (Slider slider : sliders) {
        slider.update(mouseX);
      }
    }
  }

  void position(float x, float y) {
    // Adjust the position of the window and all sliders
    float xOffset = x - this.x;
    float yOffset = y - this.y;

    this.x = x;
    this.y = y;

    for (Slider slider : sliders) {
      slider.position(slider.x + xOffset, slider.y + yOffset);
    }
  }

  void size(float w, float h) {
    // Adjust the size of the window and all sliders
    this.w = w;
    this.h = h;

    for (Slider slider : sliders) {
      slider.size(w - 2 * sliderPadding, slider.h);
    }
  }
  
  float getSliderValue(int index) {
    if (index >= 0 && index < sliders.size()) {
      return sliders.get(index).getValue();
    }
    return 0.0;
  }
}
