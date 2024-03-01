int n = 10_000;
int m = 10;
final float dt = 0.02;
final float frictionHalfLife = 0.040;
float rMax = 0.025;
float partilcleDiameter = width*rMax*.05;
float[][] matrix;

boolean zoomIn = false;
boolean zoomOut = false;
boolean panUp = false;
boolean panDown = false;
boolean panLeft = false;
boolean panRight = false;

float panX = 0;
float panY = 0;
float zoomLevel = 1.0;

final float frictionFactor = pow(0.5, dt / frictionHalfLife);
float forceFactor = 10;

float[] colors = new float[n];
float[] positionsX = new float[n];
float[] positionsY = new float[n];
float[] velocitiesX = new float[n];
float[] velocitiesY = new float[n];
float[] betas = new float[n];

boolean showQuadTree = false;
boolean wrap = true;
boolean pause = false;

int capacity = 5;

Rectangle boundary = new Rectangle(.5, .5, .5, .5);
QuadTree quadTree;

SliderWindow sliderWindow;

void setup() {
  size(640, 640);
  surface.setResizable(true);
  frameRate(100);

  colorMode(RGB);

  sliderWindow = new SliderWindow(0, 50, 500, color(50), "Config");
  sliderWindow.addSlider(new Slider(20, 10, 25000, n, color(0, 127, 200), "n", 0));
  sliderWindow.addSlider(new Slider(20, 1, 1000, m, color(200, 0, 127), "m", 0));
  sliderWindow.addSlider(new Slider(20, .01, .5, rMax, color(127, 200, 0), "rMax", 1));
  sliderWindow.addSlider(new Slider(20, 0, 200, forceFactor, color(255, 0, 0), "forceFactor", 1));

  colorMode(HSB);

  matrix = makeRandomMatrix();
  colors = new float[n];
  positionsX = new float[n];
  positionsY = new float[n];
  velocitiesX = new float[n];
  velocitiesY = new float[n];
  betas = new float[n];

  partilcleDiameter = width*rMax*.05;

  for (int i = 0; i < n; i++) {
    colors[i] = floor(random(1.0) * m);
    positionsX[i] = random(1.0);
    positionsY[i] = random(1.0);
    velocitiesX[i] = 0;
    velocitiesY[i] = 0;
    betas[i] = random(1.0);
  }

  windowResized();
}

float[][] makeRandomMatrix() {
  float[][] rows = new float[m][m];
  for (int i = 0; i < m; i++) {
    float[] row = new float[m];
    for (int j = 0; j < m; j++) {
      row[j] = random(1.0) * 2 - 1;
    }
    rows[i] = row;
  }
  return rows;
}

//float force(float r, float a) {
//  final float beta = 0.3;
//  if (r < beta)
//    return r / beta - 1;
//  else if (r > beta && r < 1)
//    return a * (1 - abs(2 * r - 1 - beta) / (1 - beta));
//  else
//    return 0;
//}

float force(float r, float a, float beta) {
  //final float beta = 0.5;
  if (r < .1)
    return -3;
  else
    if (r < beta)
      //return r / beta - 1;
      //return -1 / r;
      return -(beta-r) / ((3*r)/beta);
    else if (r > beta && r < 1)
      return a * (1 - abs(2 * r - 1 - beta) / (1 - beta));
    else
      return 0;
}

void updateParticles() {
  float startTime = millis();

  float scaledForceFactor = rMax * forceFactor;

  for (int i = 0; i < n; i++) {
    float totalForceX = 0;
    float totalForceY = 0;

    //for (int j = 0; j < n; j++) {
    //  if (j == i)
    //    continue;

    //  float rx = positionsX[j] - positionsX[i];
    //  float ry = positionsY[j] - positionsY[i];

    //  if (rx > 0.5) rx -= 1.0;
    //  else if (rx < -0.5) rx += 1.0;
    //  if (ry > 0.5) ry -= 1.0;
    //  else if (ry < -0.5) ry += 1.0;

    //  float r = sqrt(pow(rx, 2) + pow(ry, 2));
    //  if (r > 0 && r < rMax) {
    //    float f = force(r / rMax, matrix[int(colors[i])][int(colors[j])]);
    //    totalForceX += rx / r * f;
    //    totalForceY += ry / r * f;
    //  }
    //}

    ArrayList<Rectangle> queryRanges = new ArrayList<>();
    ArrayList<Point> points = new ArrayList<>();

    // Add the main query range
    queryRanges.add(new Rectangle(positionsX[i] - rMax, positionsY[i] - rMax, rMax * 2, rMax * 2));

    // Add wrap-around queries if wrap is enabled
    if (wrap) {
      if (positionsX[i] - rMax < 0) {
        queryRanges.add(new Rectangle(positionsX[i] - rMax + 1, positionsY[i] - rMax, rMax * 2, rMax * 2));
      }
      if (positionsX[i] + rMax > 1) {
        queryRanges.add(new Rectangle(positionsX[i] - rMax - 1, positionsY[i] - rMax, rMax * 2, rMax * 2));
      }
      if (positionsY[i] - rMax < 0) {
        queryRanges.add(new Rectangle(positionsX[i] - rMax, positionsY[i] - rMax + 1, rMax * 2, rMax * 2));
      }
      if (positionsY[i] + rMax > 1) {
        queryRanges.add(new Rectangle(positionsX[i] - rMax, positionsY[i] - rMax - 1, rMax * 2, rMax * 2));
      }
    }

    points = quadTree.multiQuery(queryRanges, points);

    for (Point p : points) {

      if (p.index == i)
        continue;

      float rx = p.x - positionsX[i];
      float ry = p.y - positionsY[i];

      if (wrap) {
        if (rx > 0.5) rx -= 1.0;
        else if (rx < -0.5) rx += 1.0;
        if (ry > 0.5) ry -= 1.0;
        else if (ry < -0.5) ry += 1.0;
      }

      float r = sqrt(rx*rx + ry*ry);
      if (r > 0 && r/rMax < .1) {
        velocitiesX[i] *= frictionFactor;
        velocitiesY[i] *= frictionFactor;
        totalForceX += rx / r * -3;
        totalForceY += ry / r * -3;
        continue;
      }
      else
      if (r > 0 && r < rMax) {
        float f = force(r / rMax, matrix[int(colors[i])][int(colors[p.index])], betas[i]);
        totalForceX += rx / r * f;
        totalForceY += ry / r * f;
      }
    }

    totalForceX *= scaledForceFactor;
    totalForceY *= scaledForceFactor;

    velocitiesX[i] *= frictionFactor;
    velocitiesY[i] *= frictionFactor;

    velocitiesX[i] += totalForceX * dt;
    velocitiesY[i] += totalForceY * dt;
  }

  for (int i = 0; i < n; i++) {
    positionsX[i] += velocitiesX[i] * dt;
    positionsY[i] += velocitiesY[i] * dt;

    positionsX[i] = (positionsX[i] + 1) % 1;
    positionsY[i] = (positionsY[i] + 1) % 1;
  }

  float endTime = millis();
  println("Updating time: " + (endTime - startTime) + " ms");
}

void updateQuadTree(QuadTree quadTree) {
  for (int i = 0; i < n; i++) {
    quadTree.insert(new Point(positionsX[i], positionsY[i], i));
  }
}

void drawHUD() {
  fill(255);
  float size = 16;
  float paddingFactor = 1.5;
  textAlign(LEFT);
  textSize(size);

  text(
    //"FPS: " +
    frameRate, 10, size*paddingFactor*1);
  //text("n: " + n, 10, size*paddingFactor*2);
  //text("m: " + m, 10, size*paddingFactor*3);
  //text("rMax: " + rMax, 10, size*paddingFactor*4);
  //text("forceFactor: " + forceFactor, 10, size*paddingFactor*5);

  sliderWindow.display();
}

void applyTransformations() {
  if (zoomIn) {
    zoomLevel *= 1.02;
  }

  if (zoomOut) {
    zoomLevel /= 1.01;
  }

  if (panUp) {
    panY += 10;
  }

  if (panDown) {
    panY -= 10;
  }

  if (panLeft) {
    panX += 10;
  }

  if (panRight) {
    panX -= 10;
  }

  // Apply transformations
  scale(zoomLevel);
  translate(panX, panY);
}

void draw() {
  background(0);

  float minSize = min(width, height);

  if (!sliderWindow.isDragging) {
    if (n != int(sliderWindow.getSliderValue(0))) {
      n = int(sliderWindow.getSliderValue(0));
      setup();
    }
    if (m != int(sliderWindow.getSliderValue(1))) {
      m = int(sliderWindow.getSliderValue(1));
      setup();
    }
  }

  if (rMax != int(sliderWindow.getSliderValue(2))) {
    rMax = sliderWindow.getSliderValue(2);
    partilcleDiameter = minSize*rMax*.1;
  }
  forceFactor = sliderWindow.getSliderValue(3);

  println();

  float startTime = millis();
  quadTree = new QuadTree(boundary, capacity);
  updateQuadTree(quadTree);

  float endTime = millis();
  println("QuadTree Generating time: " + (endTime - startTime) + " ms");

  updateParticles();

  startTime = millis();

  noStroke();

  pushMatrix();
  applyTransformations();
  translate(minSize == height ? (width-height)/2.0 : 0, minSize == width ? (height-width)/2.0 : 0);

  for (int i = 0; i < n; i++) {
    //fill(255 * (colors[i] / m), 255, 255);
    fill(255 * (colors[i] / m), 255, 255);
    circle(positionsX[i] * minSize, positionsY[i] * minSize, partilcleDiameter+.5);
  }

  if (showQuadTree)
    quadTree.draw(quadTree);
  popMatrix();

  drawHUD();

  endTime = millis();
  println("Drawing time: " + (endTime - startTime) + " ms");
}

void keyPressed() {
  if (key == 'r')
    setup();
  if (key == '-') {
    n -= 1000;
    setup();
  }
  if (key == '=') {
    n += 1000;
    setup();
  }
  if (key == ',') {
    m -= 1;
    setup();
  }
  if (key == '.') {
    m += 1;
    setup();
  }
  if (keyCode == UP) {
    rMax -= 0.005;
    partilcleDiameter = width*rMax*.05;
  }
  if (keyCode == DOWN) {
    rMax += 0.005;
    partilcleDiameter = width*rMax*.05;
  }
  if (keyCode == LEFT) {
    forceFactor -= 5;
  }
  if (keyCode == RIGHT) {
    forceFactor += 5;
  }

  if (key == 'q')
    showQuadTree = !showQuadTree;

  if (key == 't')
    wrap = !wrap;

  if (key == 'p') {
    pause = !pause;
    if (pause) noLoop();
    else loop();
  }

  if (key == 'w' || key == 'W') {
    panUp = true;
  } else if (key == 's' || key == 'S') {
    panDown = true;
  } else if (key == 'a' || key == 'A') {
    panLeft = true;
  } else if (key == 'd' || key == 'D') {
    panRight = true;
  } else if (key == 'z' || key == 'Z') {
    zoomIn = true;
  } else if (key == 'x' || key == 'X') {
    zoomOut = true;
  }

  rMax = constrain(rMax, 0, 1);
  forceFactor = constrain(forceFactor, 0, 100);
}

void keyReleased() {
  if (key == 'w' || key == 'W') {
    panUp = false;
  } else if (key == 's' || key == 'S') {
    panDown = false;
  } else if (key == 'a' || key == 'A') {
    panLeft = false;
  } else if (key == 'd' || key == 'D') {
    panRight = false;
  } else if (key == 'z' || key == 'Z') {
    zoomIn = false;
  } else if (key == 'x' || key == 'X') {
    zoomOut = false;
  }
}

void mousePressed() {
  sliderWindow.mousePressed();
}

void mouseReleased() {
  sliderWindow.mouseReleased();
}

void mouseDragged() {
  sliderWindow.mouseDragged();
}

void windowResized() {
  partilcleDiameter = width*rMax*.05;

  // Reposition the SliderWindow to stay sticky to the top right corner
  sliderWindow.position(width - sliderWindow.w - 20, 20);
}
