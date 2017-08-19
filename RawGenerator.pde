int sW = 640;
int sH = 480;
String inFileName = "sample.txt";

float minX, maxX, minY, maxY, minZ, maxZ;

Data rawData;
PVector[] raw, rawScaled, rawScaledDisplay;

float[] sortedX, sortedY, sortedZ;

float xMin, xMax, yMin, yMax, zMin, zMax;

PImage img;
byte[] out;
Settings settings;

void setup() {
  settings = new Settings("settings.txt");
  size(50,50,P3D);
  surface.setSize(sW,sH);

  rawData = new Data();
  
  img = createImage(sW,sH,RGB);
  out = new byte[sW*sH*2]; //each int needs 2 bytes.
  
  try {
    println("* Attempting to load text...");
    rawData.load(inFileName);
  } catch(Exception e) {
    println("* text loading failed.");
    exit();
  }

  println("* Parsing text...");
  
  raw = new PVector[rawData.data.length];
  rawScaled = new PVector[rawData.data.length];
  rawScaledDisplay = new PVector[rawData.data.length];
  sortedX = new float[rawData.data.length];
  sortedY = new float[rawData.data.length];
  sortedZ = new float[rawData.data.length];
  
  for (int i=0; i<rawData.data.length; i++) {
    raw[i] = parseRaw(rawData.data[i]);
    rawScaled[i] = new PVector(0,0,0);
    rawScaledDisplay[i] = new PVector(0,0,0);
    sortedX[i] = raw[i].x;
    sortedY[i] = raw[i].y;
    sortedZ[i] = raw[i].z;
  }
  
  sortedX = sort(sortedX);
  sortedY = sort(sortedY);
  sortedZ = sort(sortedZ);
  
  xMin = sortedX[0];
  xMax = sortedX[sortedX.length-1];
  yMin = sortedY[0];
  yMax = sortedY[sortedY.length-1];
  zMin = getPosMin(sortedZ);
  zMax = sortedZ[sortedZ.length-1];

  println("...still working...");

  img.loadPixels();
  
  for (int i=0; i<raw.length; i++) {
    if(raw[i].z < zMin) raw[i].z = zMin;
    
    rawScaled[i].x = map(raw[i].x, xMin, xMax, 0, sW);
    rawScaled[i].y = map(raw[i].y, yMin, yMax, 0, sH);
    rawScaled[i].z = map(raw[i].z, zMin, zMax, 0, 65535); //16-bit grayscale

    rawScaledDisplay[i].x = rawScaled[i].x;
    rawScaledDisplay[i].y = rawScaled[i].y;
    rawScaledDisplay[i].z = map(raw[i].z, zMin, zMax, 0, 255); //8-bit grayscale
    
    int loc = int(rawScaledDisplay[i].x) + int(rawScaledDisplay[i].y) * sW;
    if (loc < 0) loc = 0;
    if (loc > img.pixels.length-1) loc = img.pixels.length-1;
    img.pixels[loc] = color(int(rawScaledDisplay[i].z));
    
    out[loc*2]=byte(int(rawScaled[i].z)&255); // only the first 8 bits.
    out[loc*2+1]=byte(int(rawScaled[i].z)>>8); // the upper 8 bits.
    
    /*
    //alternate draw method
    noFill();
    stroke(color(int(rawScaled[i].z)));
    strokeWeight(1);
    point(int(rawScaled[i].x),int(rawScaled[i].y));
    */
  }

  img.updatePixels();
  
  println("* ...parsing complete.");
  println("x range: " + xMin + " - " + xMax + ", y range: " + yMin + " - " + yMax + ", z range: " + zMin + " - " + zMax);
  
}

void draw() {
  image(img,0,0);
}

void keyPressed(){
  saveImg();
}

void mousePressed(){
  saveImg();
}

void saveImg(){
  String outFileName1 = "render/output_8bit.png";
  saveFrame(outFileName1);

  String outFileName2 = "render/output_16bit.raw";
  saveBytes(outFileName2, out);

  println("Saved " + outFileName1 + " " + outFileName2);
  exit();
}

float getPosMin(float[] _f) {
  int counter = 0;
  while (_f[counter] < 0) counter++;
  return _f[counter];
}

PVector parseRaw(String _s) {
    PVector endPVector = new PVector(0,0,0);
    int spaceCounter=0;
    
    String sx = "";
    String sy = "";  
    String sz = "";
    
    float x = 0;
    float y = 0;
    float z = 0;

    for (int i=0;i<_s.length();i++) {
        if (_s.charAt(i)==char(' ')) {
            spaceCounter++;
        } else {
          if (spaceCounter==0) sx += _s.charAt(i);
          if (spaceCounter==1) sy += _s.charAt(i);
          if (spaceCounter==2) sz += _s.charAt(i); 
        }
    }

    if (sx!="" && sy!="" && sz!="") {
      x = float(sx);
      y = float(sy);
      z = float(sz);
      endPVector = new PVector(x,y,z);
    }
      return endPVector;
}