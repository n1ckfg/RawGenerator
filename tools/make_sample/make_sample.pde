float xMin = 0;
float xMax = 640;
float yMin = 0;
float yMax = 480;
float zMin = 0;
float zMax = 65535;

Data sample;

void setup() {
  sample = new Data();
  int counter = 0;
  
  sample.beginSave();
  
  while (counter < xMax * yMax) {
    sample.add(random(xMin,xMax) + " " + random(yMin,yMax) + " " +random(zMin,zMax));
    counter++; 
  }
  
  sample.endSave("sample.txt");
  exit();
}
