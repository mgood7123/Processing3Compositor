Window w1, w2, w3, w4;

void setup() {
  size(400, 400, P3D);
  w1 = new Window(200, 200);
  w2 = new Window(200, 200);
  w3 = new Window(200, 200);
  w4 = new Window(200, 200);
  w1.attach(new Cube());
  w2.attach(new Cube());
  w3.attach(new Cube());
  w4.attach(new Cube());
  w1.setup();
  w2.setup();
  w3.setup();
  w4.setup();
}

void draw() {
  background(0);
  w1.draw();
  w2.draw();
  w3.draw();
  w4.draw();
  image(w1.graphics, 0, 0);
  image(w2.graphics, 200, 0);
  image(w3.graphics, 0, 200);
  image(w4.graphics, 200, 200);
}
