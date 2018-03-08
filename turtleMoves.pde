enum Instruction { //<>// //<>//
  FORWARD, 
    BACKWARD, 
    ROTATE, 
    NROTATE;
};
int turtleStep = 40;
float rotStep = 90;
class Turtle {
  Turtle(int _hs) {
    path = new ArrayList<PVector>();
    goBackToInit();
    hs = _hs;
    img = loadImage("turtle.png");
    img.resize(2*hs, 2*hs);
    
  }

  void drawImg() {
    rotate(radians(-90));
    image(img, -hs, -hs);
  }
/*
  void drawProcessing() {
    ellipseMode(CENTER);
    ellipse(0, 0, hs, hs/2);
    ellipse(hs/2, 0, hs/4, hs/4);
  }*/
  void draw() {

    fill(0, 255, 0);
    pushMatrix();
    translate(x, y);
    rotate(PI/180*rot);
    drawImg();
    popMatrix();
  }
  
  void drawPath(){
    fill(255,0,0,255);
    for(int i = 0 ; i < path.size() ; i++){
      PVector p = path.get(i);
      rect(p.x-hs,p.y-hs,2*hs,2*hs);
    }
  }
  void setInitPos(int _x, int _y) {
    xInit = _x;
    yInit = _y;
  }
  void gotoPos(int _x, int _y) {
    x= _x;
    y=_y;
  }
  void goBackToInit() {
    gotoPos(xInit, yInit);
    setRotation(0);
    path.clear();
    path. add(new PVector(xInit,yInit));
  }
  void setRotation(float _r) {
    rot = _r;
  }

  void executeInstruction(Instruction i) {
    switch(i) {
    case FORWARD:
      x+=cos(PI/180.0*rot)*turtleStep;
      y+=sin(PI/180.0*rot)*turtleStep;
      
      break;
    case BACKWARD:
      x-=cos(PI/180*rot)*turtleStep;
      y-=sin(PI/180*rot)*turtleStep;
      break;
    case ROTATE:
      rot-=rotStep;
      break;
    case NROTATE:
      rot+=rotStep;
      break;
    }
    // force grid pos
    x = round(x/turtleStep)*turtleStep;
    y = round(y/turtleStep)*turtleStep;
    
    if(i==Instruction.FORWARD || i==Instruction.BACKWARD){path.add(new PVector(x,y));}
  }

  int x, y, xInit, yInit;
  float rot;
  int hs;
  PImage img;
  ArrayList<PVector> path;
};


class Game {
  Game(PApplet parent) {
    turtle = new Turtle(turtleStep/2-1);
    turtle.setInitPos(parent.width/2, parent.height/2);
    turtle.goBackToInit();
    app = parent;
    startPTime = 0;
    reset();
  }

  void addInstruction(Instruction i) {
    instructions.add(i);
  }

  void removeLastInstruction() {
    if (instructions.size()>0)
      instructions.remove(instructions.size()-1);
  }

  void reset() {
    stop();
    clearInstructions();
    turtle.goBackToInit();
  }
  void clearInstructions() {
    instructions = new ArrayList<Instruction>();
  }

  void play(boolean p) {
    isPlaying = p;
    if (p) startPTime = millis();
  }
  void togglePlay() {
    play(!isPlaying);
  }

  void stop() {
    curI = -1;
    isPlaying = false;
  }

void save(){
  PrintWriter output = createWriter("instructions.txt");
  for(int i = 0 ; i < instructions.size() ; i++){
    output.println(instructionToString(instructions.get(i)));
  }
  output.flush();
  output.close();
}

void load(String p){
  if(p.length()==0)p="instructions.txt";
   BufferedReader reader = createReader("instructions.txt");
  String line = null;
  try {
    reset();
    
    while ((line = reader.readLine()) != null) {
      line = line.trim();
      if(line.length()>0){
      try{
      Instruction i = instructionFromString(line);
      addInstruction(i);
      } catch (Exception e) {
          e.printStackTrace();
          break;
      }
      }
    }
    reader.close();
  } catch (IOException e) {
    e.printStackTrace();
  }
  
}
String instructionToString(Instruction i){
  switch(i){
    case FORWARD:return "avance";
    case BACKWARD:return "recule";
    case ROTATE:return "tourne_gauche";
    case NROTATE:default:return "tourne_droite";
  }
}

Instruction instructionFromString(String s) throws Exception{
  if(s.equals("avance")){return Instruction.FORWARD;}
  if(s.equals("recule")){return Instruction.BACKWARD;}
  if(s.equals("tourne_gauche")){return Instruction.ROTATE;}
  if(s.equals("tourne_droite")){return Instruction.NROTATE;}
  else{
    throw new Exception(":"+s+ ": (not supported)");
  }
}
  
  void playPendingInstructions() {
    int nextI = (int)((millis()-startPTime)/timeStep);
    for (int i = curI+1; i <= min(instructions.size()-1, nextI); i++) {
      turtle.executeInstruction(instructions.get(i));
    }

    if (nextI>=instructions.size()) {
      stop();
    } else {
      curI = nextI;
    }
  }
  void update() {
    if (isPlaying) {
      playPendingInstructions();
    }
  }

  void draw() {
    update();
    fill(0);
    stroke(0);
    rect(0, 0, app.width, app.height);
    drawGrid();
    turtle.drawPath();
    turtle.draw();
    drawInstructions();
  }

  void drawGrid() {
    stroke(100, 100, 100);
    int pad = turtleStep/2;
    for (int i = turtle.xInit+pad; i < app.width; i+=turtleStep) {
      line(i, 0, i, app.height);
    }
    for (int i = turtle.xInit+pad; i >0; i-=turtleStep) {
      line(i, 0, i, app.height);
    }
    for (int j = turtle.yInit+pad; j < app.height; j+=turtleStep) {
      line(0, j, app.width, j);
    }
    for (int j = turtle.yInit+pad; j >0; j-=turtleStep) {
      line(0, j, app.width, j);
    }
  }

  void drawInstructions() {

    int maxS = 40;
    float pad = 10;
    float size = min(maxS, max(10, (app.width-2*pad)/(instructions.size()+0.1)));
    float curX = 0;
    float curY = app.height - maxS;

    stroke(255, 0, 0);
    fill(0, 0, 0, 255);
    rect(pad, curY-size/2, app.width-2*pad, size);

    fill(0, 0, 0, 0);

    for (int i = 0; i < instructions.size(); i++) {
      if (i==curI) {
        fill(255, 255, 255, 255);
        rect(curX+pad, curY-size/2, size-pad, size);
        noFill();
      }
      Instruction ii = instructions.get(i);

      switch(ii) {
      case FORWARD: 
        drawArrow(curX+pad, curY, size-pad, false);
        break;
      case BACKWARD: 
        drawArrow(curX+pad, curY, size-pad, true);
        break;
      case ROTATE: 
        drawCurvedArrow(curX+pad, curY, size-pad, false);
        break;
      case NROTATE: 
        drawCurvedArrow(curX+pad, curY, size-pad, true);
        break;
      }

      curX+=size;
    }
  }

  ArrayList<Instruction> instructions;
  Turtle turtle;
  PApplet app;
  int timeStep = 800;
  boolean isPlaying;
  long  startPTime;
  int curI = -1;
};

void drawArrow(float cx, float cy, float len, boolean sym) {
  pushMatrix();
  translate(cx+len/2, cy);
  rotate(radians(sym?180:0));
  translate(-len/2, 0);
  line(0, 0, len, 0);
  int w = (int)len/2;
  line(len, 0, len - w, -w);
  line(len, 0, len - w, w);
  popMatrix();
}

void drawCurvedArrow(float cx, float cy, float len, boolean sym ) {
  pushMatrix();
  translate(cx+len/2, cy);


  arc(0, 0, len, len, sym?0:-PI/2, sym?PI/2:0);
  PVector p1 = new PVector(0, sym?len/2:-len/2);
  PVector p2 = new PVector(len/4, sym?len/4:-len/4);
  PVector p3 = new PVector(len/3, sym?len/2:-len/2);
  line(p1.x, p1.y, p2.x, p2.y);
  line(p1.x, p1.y, p3.x, p3.y);
  popMatrix();
}