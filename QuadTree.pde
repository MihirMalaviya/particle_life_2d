// Point class
class Point {
  float x, y;
  int index;

  Point(float x, float y, int i) {
    this.x = x;
    this.y = y;
    this.index = i;
  }
}

// Rectangle class
class Rectangle {
  float x, y, w, h;

  Rectangle(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  boolean contains(Point point) {
    return (point.x >= this.x - this.w && point.x <= this.x + this.w &&
      point.y >= this.y - this.h && point.y <= this.y + this.h);
  }

  boolean intersects(Rectangle range) {
    return !(range.x - range.w > this.x + this.w ||
      range.x + range.w < this.x - this.w ||
      range.y - range.h > this.y + this.h ||
      range.y + range.h < this.y - this.h);
  }
}

//// Circle class
//class Circle {
//  float x, y, r, rSquared;

//  Circle(float x, float y, float r) {
//    this.x = x;
//    this.y = y;
//    this.r = r;
//    this.rSquared = this.r * this.r;
//  }

//  boolean contains(Point point) {
//    float d = pow((point.x - this.x), 2) + pow((point.y - this.y), 2);
//    return d <= this.rSquared;
//  }

//  boolean intersects(Rectangle range) {
//    float xDist = abs(range.x - this.x);
//    float yDist = abs(range.y - this.y);
//    float r = this.r;
//    float w = range.w;
//    float h = range.h;
//    float edges = pow((xDist - w), 2) + pow((yDist - h), 2);

//    if (xDist > (r + w) || yDist > (r + h))
//      return false;

//    if (xDist <= w || yDist <= h)
//      return true;

//    return edges <= this.rSquared;
//  }
//}

// QuadTree class
class QuadTree {
  Rectangle boundary;
  int capacity;
  ArrayList<Point> points;
  boolean divided;
  QuadTree northeast, northwest, southeast, southwest;

  QuadTree(Rectangle boundary, int capacity) {
    if (boundary == null || capacity < 1) {
      throw new IllegalArgumentException("Invalid parameters");
    }
    this.boundary = boundary;
    this.capacity = capacity;
    this.points = new ArrayList<Point>();
    this.divided = false;
  }

  void subdivide() {
    float x = this.boundary.x;
    float y = this.boundary.y;
    float w = this.boundary.w / 2;
    float h = this.boundary.h / 2;

    Rectangle ne = new Rectangle(x + w, y - h, w, h);
    this.northeast = new QuadTree(ne, this.capacity);
    Rectangle nw = new Rectangle(x - w, y - h, w, h);
    this.northwest = new QuadTree(nw, this.capacity);
    Rectangle se = new Rectangle(x + w, y + h, w, h);
    this.southeast = new QuadTree(se, this.capacity);
    Rectangle sw = new Rectangle(x - w, y + h, w, h);
    this.southwest = new QuadTree(sw, this.capacity);

    this.divided = true;
  }

  boolean insert(Point point) {
    if (!this.boundary.contains(point)) {
      return false;
    }

    if (this.points.size() < this.capacity) {
      this.points.add(point);
      return true;
    }

    if (!this.divided) {
      this.subdivide();
    }

    return this.northeast.insert(point) || this.northwest.insert(point) ||
      this.southeast.insert(point) || this.southwest.insert(point);
  }

  ArrayList<Point> query(Rectangle range, ArrayList<Point> found) {
    if (found == null) {
      found = new ArrayList<Point>();
    }

    if (!range.intersects(this.boundary)) {
      return found;
    }

    for (Point p : this.points) {
      if (range.contains(p)) {
        found.add(p);
      }
    }
    if (this.divided) {
      this.northwest.query(range, found);
      this.northeast.query(range, found);
      this.southwest.query(range, found);
      this.southeast.query(range, found);
    }

    return found;
  }
  
  ArrayList<Point> multiQuery(ArrayList<Rectangle> ranges, ArrayList<Point> found) {
    if (found == null) {
      found = new ArrayList<>();
    }

    boolean intersectsAnyRange = false;

    for (Rectangle range : ranges) {
      if (range.intersects(this.boundary)) {
        intersectsAnyRange = true;
        break;
      }
    }

    if (!intersectsAnyRange) {
      return found;
    }

    for (Point p : this.points) {
      for (Rectangle range : ranges) {
        if (range.contains(p)) {
          found.add(p);
          // Assuming a point can only be in one range, you may break out of the inner loop here
          // if you want to prevent adding the same point multiple times.
          // break;
        }
      }
    }

    if (this.divided) {
      this.northwest.multiQuery(ranges, found);
      this.northeast.multiQuery(ranges, found);
      this.southwest.multiQuery(ranges, found);
      this.southeast.multiQuery(ranges, found);
    }

    return found;
  }
  
  
  void draw(QuadTree quadTree) {
    float minSize = min(width, height);
  
    stroke(70, 255, 255, 255/2.0);
    noFill();
    rectMode(CENTER);
    rect(quadTree.boundary.x*minSize, quadTree.boundary.y*minSize, quadTree.boundary.w * 2*minSize, quadTree.boundary.h * 2*minSize);
    if (quadTree.divided) {
      draw(quadTree.northeast);
      draw(quadTree.northwest);
      draw(quadTree.southeast);
      draw(quadTree.southwest);
    }
  }
}
