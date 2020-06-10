Compositor compositor;

void settings() {
  //fullScreen(P3D);
  size(400, 400, P3D);
}

void addApplications() {
  compositor.add(new Applications_DraggableExample(), 200, 200);
  compositor.setLocation(0 ,0);
  compositor.add(new Applications_Cube(), 200, 200);
  compositor.setLocation(0, 200);
  compositor.add(new Applications_XCursor_Decoder_Example(), 200, 200);
  compositor.setLocation(200, 0);
  compositor.add(new Applications_Cube(), 200, 200);
  compositor.setLocation(200, 200);
}

void setup() {
  compositor = new Compositor(width, height);
  compositor.displayFPS = true;
  compositor.displayWindowFPS = true;
  compositor.debug = false;
  addApplications();
  compositor.setup();
}

void draw() {
  compositor.draw(); //<>// //<>// //<>//
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

void mouseMoved() {
  compositor.mouseMoved();
}
