Compositor compositor;

void settings() {
    size(400, 400, P3D);
}

void setup() {
  compositor = new Compositor(400, 400);
  // what, width, height
  compositor.add(new DraggableExample(), 200, 200);
  compositor.setLocation(0 ,0);
  compositor.add(new Cube(), 200, 200);
  compositor.setLocation(0, 200);
  compositor.add(new Cube(), 200, 200);
  compositor.setLocation(200, 0);
  compositor.add(new Cube(), 200, 200);
  compositor.setLocation(200, 200);
  compositor.setup();
}

void draw() {
  compositor.draw();
}

void mousePressed() {
  compositor.mousePressed();
}

void mouseDragged() {
  compositor.mouseDragged();
}

void mouseReleased() {
  compositor.mouseReleased();
}
