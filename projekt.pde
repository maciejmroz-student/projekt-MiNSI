import controlP5.*;

ControlP5 cp5;
boolean rozpocznij = false;

int liczbaOsobnikow = 100;
int liczbaPokolen = 200;
int liczbaSledzonych = 0;
float wspolczynnikMutacji = 0.1;
float zakresMin = -5.12;
float zakresMax = 5.12;
boolean srednia = false;

float[][] populacja;
float[][] historiaPrzystosowania;
float[][] przystosowanieSledzonych;
int[] indeksySledzonych;
int pokolenie = 0;
ArrayList<float[]> historiaPozycji = new ArrayList<float[]>();

void setup() {
  size(1000, 600);
  cp5 = new ControlP5(this);

  cp5.addTextfield("Populacja")
     .setPosition(100, 90)
     .setSize(200, 30)
     .setText(str(liczbaOsobnikow))
     .setAutoClear(false);

  cp5.addTextfield("Pokolenia")
     .setPosition(100, 150)
     .setSize(200, 30)
     .setText(str(liczbaPokolen))
     .setAutoClear(false);

  cp5.addButton("Start")
     .setPosition(100, 200)
     .setSize(80, 30);
     
       cp5.addToggle("Pokaz_srednia")
     .setLabel("Pokaż średnią")
     .setPosition(100, 250)
     .setSize(50, 20)
     .setValue(false);  // domyślnie nieaktywne
     
     cp5.addTextlabel("OpisCheckbox")
   .setText("Srednia przystosowania.")
   .setPosition(150, 255)
   .setColorValue(color(0));
   
     // Etykiety opisujące pola tekstowe
  cp5.addTextlabel("PopulacjaLabel")
     .setText("Liczba osobnikow w populacji:")
     .setPosition(95, 75)
     .setColorValue(color(0));

  cp5.addTextlabel("PokoleniaLabel")
     .setText("Liczba pokolen:")
     .setPosition(95, 135)
     .setColorValue(color(0));
}

void Start() {
  liczbaOsobnikow = int(cp5.get(Textfield.class, "Populacja").getText());
  liczbaPokolen = int(cp5.get(Textfield.class, "Pokolenia").getText());

  historiaPrzystosowania = new float[liczbaPokolen][liczbaOsobnikow];
  przystosowanieSledzonych = new float[liczbaPokolen][liczbaSledzonych];
  indeksySledzonych = new int[liczbaSledzonych];

  populacja = new float[liczbaOsobnikow][2];
  inicjalizujPopulacje();

  for (int i = 0; i < liczbaSledzonych; i++) {
    indeksySledzonych[i] = int(random(liczbaOsobnikow));
  }

  rozpocznij = true;
  // Ukryj interfejs wejściowy
  cp5.get(Textfield.class, "Populacja").hide();
  cp5.get(Textfield.class, "Pokolenia").hide();
  cp5.getController("Start").hide();
  cp5.getController("Pokaz_srednia").hide();
  cp5.getController("OpisCheckbox").hide();
    cp5.getController("PopulacjaLabel").hide();
  cp5.getController("PokoleniaLabel").hide();

  // Dodaj przycisk "Nowy wykres" na ekranie z wykresem
  cp5.addButton("Nowy_wykres")
     .setLabel("Nowy wykres")
     .setPosition(width - 160, 5)
     .setSize(120, 30);
  frameRate(20);

}


void Nowy_wykres() {
  rozpocznij = false;
  pokolenie = 0;

  // Przywróć panel wejściowy
  cp5.get(Textfield.class, "Populacja").show();
  cp5.get(Textfield.class, "Pokolenia").show();
  cp5.getController("Start").show();
  cp5.getController("Pokaz_srednia").show();
  cp5.getController("OpisCheckbox").show();
    cp5.getController("PopulacjaLabel").show();
  cp5.getController("PokoleniaLabel").show();

  // Usuń przycisk z ekranu wykresu
  cp5.getController("Nowy_wykres").remove();

  historiaPrzystosowania = null;
  przystosowanieSledzonych = null;
  populacja = null;
      historiaPozycji = new ArrayList<float[]>();
  populacja = new float[liczbaOsobnikow][2];
}

void Pokaz_srednia(boolean val) {
  srednia = val;
}

void draw() {
  background(255);

  if (!rozpocznij) {
    fill(0);
    return;
  }

  if (pokolenie < liczbaPokolen) {
    ewoluuj();
    zapiszPrzystosowanie();
    pokolenie++;
  }

  
  rysujWykres();               // po lewej u góry
  rysujWykresEwaluacji();     // po lewej na dole
  rysujWykresPrzestrzenny();  // po prawej

}

void inicjalizujPopulacje() {
  for (int i = 0; i < liczbaOsobnikow; i++) {
    populacja[i][0] = random(zakresMin, zakresMax);
    populacja[i][1] = random(zakresMin, zakresMax);
  }
}

float rastrigin(float x, float y) {
  return 20 + (x * x - 10 * cos(TWO_PI * x)) + (y * y - 10 * cos(TWO_PI * y));
}

void ewoluuj() {
  float[][] nowaPopulacja = new float[liczbaOsobnikow][2];
  for (int i = 0; i < liczbaOsobnikow; i++) {
    float[] rodzic1 = selekcja();
    float[] rodzic2 = selekcja();
    float[] potomek = krzyzowanie(rodzic1, rodzic2);
    mutacja(potomek);
    nowaPopulacja[i] = potomek;
  }
  populacja = nowaPopulacja;
}

float[] selekcja() {
  int najlepszy = int(random(liczbaOsobnikow));
  for (int i = 0; i < 4; i++) {
    int rywal = int(random(liczbaOsobnikow));
    if (rastrigin(populacja[rywal][0], populacja[rywal][1]) <
        rastrigin(populacja[najlepszy][0], populacja[najlepszy][1])) {
      najlepszy = rywal;
    }
  }
  return populacja[najlepszy];
}

float[] krzyzowanie(float[] a, float[] b) {
  return new float[] {
    (a[0] + b[0]) / 2.0,
    (a[1] + b[1]) / 2.0
  };
}

void mutacja(float[] osobnik) {
  float krokMutacji = 0.1 + 0.4 * (1.0 - (float)pokolenie / liczbaPokolen);
  if (random(1) < wspolczynnikMutacji) osobnik[0] += random(-krokMutacji, krokMutacji);
  if (random(1) < wspolczynnikMutacji) osobnik[1] += random(-krokMutacji, krokMutacji);
  osobnik[0] = constrain(osobnik[0], zakresMin, zakresMax);
  osobnik[1] = constrain(osobnik[1], zakresMin, zakresMax);
}

void zapiszPrzystosowanie() {
  for (int i = 0; i < liczbaOsobnikow; i++) {
    historiaPrzystosowania[pokolenie][i] = rastrigin(populacja[i][0], populacja[i][1]);
  }

  for (int i = 0; i < liczbaSledzonych; i++) {
    int idx = indeksySledzonych[i];
    przystosowanieSledzonych[pokolenie][i] = rastrigin(populacja[idx][0], populacja[idx][1]);
  }
  for (int i = 0; i < liczbaOsobnikow; i++) {
  float[] pos = new float[] {populacja[i][0], populacja[i][1]};
  historiaPozycji.add(pos);
}
}

void rysujWykres() {
  pushMatrix();
  float marginesX = 40;
  float marginesY = 40;
  float szerokoscWykresu = width / 2 - 2 * marginesX;
  float wysokoscWykresu = height / 2 - 2 * marginesY;
  translate(marginesX, marginesY + wysokoscWykresu + 10);  // górny lewy róg

  float maxFitness = 0;
  for (int g = 0; g < pokolenie; g++) {
    for (int i = 0; i < liczbaOsobnikow; i++) {
      maxFitness = max(maxFitness, historiaPrzystosowania[g][i]);
    }
  }
  maxFitness = ceil(max(maxFitness, 1));  // zaokrąglone w górę do pełnej jednostki

  // Osie
  stroke(0);
  line(0, 0, szerokoscWykresu, 0);
  line(0, 0, 0, -wysokoscWykresu);

  fill(0);
  textAlign(CENTER);
  textSize(12);
  text("Pokolenie", szerokoscWykresu / 2, 30);
  pushMatrix();
  rotate(-HALF_PI);
  text("Przystosowanie", 100, -30);  popMatrix();

  // === Podziałki X: co 10 pokoleń ===
  int krokX = 10;
  for (int px = 0; px <= liczbaPokolen; px += krokX) {
    float x = map(px, 0, liczbaPokolen, 0, szerokoscWykresu);
    stroke(200);
    line(x, 0, x, -wysokoscWykresu);
    fill(0);
    textSize(10);
    textAlign(CENTER);
    text(px, x, 14);
  }

  // === Podziałki Y: co 1.0 jednostki przystosowania ===

float krokY = 10;
for (float py = 0; py <= maxFitness; py += krokY) {
  float y = map(py, 0, maxFitness, 0, wysokoscWykresu);
  stroke(200);
  line(0, -y, szerokoscWykresu, -y);
  fill(0);
  textAlign(RIGHT);
  textSize(10);
  text(int(py), -5, -y + 4);  // ← tu bez przecinka
}

  // Punkty osobników
  noStroke();
  for (int g = 0; g < pokolenie; g++) {
    for (int i = 0; i < liczbaOsobnikow; i++) {
      float fit = historiaPrzystosowania[g][i];
      float x = map(g, 0, liczbaPokolen, 0, szerokoscWykresu);
      float y = map(fit, 0, maxFitness, 0, wysokoscWykresu);
      fill(map(fit, 0, maxFitness, 50, 255), 0, 200);
      ellipse(x, -y, 3, 3);
    }
  }

  // Średnia przystosowania
  if (srednia) {
    stroke(200, 0, 0);
    strokeWeight(2);
    noFill();
    beginShape();
    for (int g = 0; g < pokolenie; g++) {
      float suma = 0;
      for (int i = 0; i < liczbaOsobnikow; i++) {
        suma += historiaPrzystosowania[g][i];
      }
      float sr = suma / liczbaOsobnikow;
      float x = map(g, 0, liczbaPokolen, 0, szerokoscWykresu);
      float y = map(sr, 0, maxFitness, 0, wysokoscWykresu);
      vertex(x, -y);
    }
    endShape();
  }

  popMatrix();
}
void rysujWykresEwaluacji() {
  pushMatrix();
  float marginesX = 40;
  float marginesY = 40;
  float szerokoscWykresu = width / 2 - 2 * marginesX;
  float wysokoscWykresu = height / 2 - 2 * marginesY;
  translate(40, height - 40);  // prawa połowa

  float maxFitness = 0;
  for (int g = 0; g < pokolenie; g++) {
    for (int i = 0; i < liczbaOsobnikow; i++) {
      maxFitness = max(maxFitness, historiaPrzystosowania[g][i]);
    }
  }
  maxFitness = ceil(max(maxFitness, 1));

  stroke(0);
  line(0, 0, szerokoscWykresu, 0);
  line(0, 0, 0, -wysokoscWykresu);

  fill(0);
  textAlign(CENTER);
  textSize(12);
  text("Ewaluacje", szerokoscWykresu / 2, 30);
  pushMatrix();
  rotate(-HALF_PI);
  text("Przystosowanie", 100, -30);
  popMatrix();

  int maxEval = liczbaPokolen * liczbaOsobnikow;
  int krokX = 2000;
  for (int eval = 0; eval <= maxEval; eval += krokX) {
    float x = map(eval, 0, maxEval, 0, szerokoscWykresu);
    stroke(200);
    line(x, 0, x, -wysokoscWykresu);
    fill(0);
    textSize(10);
    textAlign(CENTER);
    text(eval, x, 14);
  }

  float krokY = 10;
  for (float py = 0; py <= maxFitness; py += krokY) {
    float y = map(py, 0, maxFitness, 0, wysokoscWykresu);
    stroke(200);
    line(0, -y, szerokoscWykresu, -y);
    fill(0);
    textAlign(RIGHT);
    textSize(10);
    text(int(py), -5, -y + 4);
  }

  // Punkty
  noStroke();
  for (int g = 0; g < pokolenie; g++) {
    int evalOffset = g * liczbaOsobnikow;
    for (int i = 0; i < liczbaOsobnikow; i++) {
      float fit = historiaPrzystosowania[g][i];
      float x = map(evalOffset + i, 0, maxEval, 0, szerokoscWykresu);
      float y = map(fit, 0, maxFitness, 0, wysokoscWykresu);
      fill(map(fit, 0, maxFitness, 50, 255), 0, 200);
      ellipse(x, -y, 3, 3);
    }
  }

  // Średnia
  if (srednia) {
    stroke(200, 0, 0);
    strokeWeight(2);
    noFill();
    beginShape();
    for (int g = 0; g < pokolenie; g++) {
      float suma = 0;
      for (int i = 0; i < liczbaOsobnikow; i++) {
        suma += historiaPrzystosowania[g][i];
      }
      float sr = suma / liczbaOsobnikow;
      float x = map(g * liczbaOsobnikow + liczbaOsobnikow / 2, 0, maxEval, 0, szerokoscWykresu);
      float y = map(sr, 0, maxFitness, 0, wysokoscWykresu);
      vertex(x, -y);
    }
    endShape();
  }

  popMatrix();
}

void rysujWykresPrzestrzenny() {

  pushMatrix();
  float marginesX = 40;
  float marginesY = 40;
  float szer = width / 2 - 2 * marginesX;
  float wys = height - 2 * marginesY;
  translate(width / 2 + marginesX, marginesY);

  // Tło i ramka
  stroke(0);
  noFill();
  rect(0, 0, szer, wys);

  // Podziałki stałe co 2 jednostki
  float krok = 2.0;

// Podziałki X (pionowe linie)
for (int xv = ceil(zakresMin); xv <= floor(zakresMax); xv++) {
  float x = map(xv, zakresMin, zakresMax, 0, szer);
  stroke(220);
  line(x, 0, x, wys);
  fill(0);
  textSize(10);
  textAlign(CENTER);
  text(xv, x, wys + 12);
}

// Podziałki Y (poziome linie)
for (int yv = ceil(zakresMin); yv <= floor(zakresMax); yv++) {
  float y = map(yv, zakresMin, zakresMax, wys, 0);
  stroke(220);
  line(0, y, szer, y);
  fill(0);
  textAlign(RIGHT);
  textSize(10);
  text(yv, -5, y + 4);
}

  // Linie osi: x1 = 0 (pionowa) i x2 = 0 (pozioma)
  stroke(0);
  float zeroX = map(0, zakresMin, zakresMax, 0, szer);
  float zeroY = map(0, zakresMin, zakresMax, wys, 0);
  strokeWeight(2);
  line(zeroX, 0, zeroX, wys);   // x1 = 0
  line(0, zeroY, szer, zeroY); // x2 = 0
  strokeWeight(1);

  // Etykiety osi
  fill(0);
  textAlign(CENTER);
  textSize(12);
  text("x1", szer / 2, wys + 30);
  pushMatrix();
  translate(-30, wys / 2);
  rotate(-HALF_PI);
  text("x2", 0, 0);
  popMatrix();

  // Punkty z historii wszystkich pokoleń
noStroke();
fill(100, 100, 250, 75);
for (float[] pos : historiaPozycji) {
  float x = map(pos[0], zakresMin, zakresMax, 0, szer);
  float y = map(pos[1], zakresMin, zakresMax, wys, 0);
  ellipse(x, y, 4, 4);
}

  // Punkty osobników
  noStroke();
  fill(100, 0, 250, 250);
  for (int i = 0; i < liczbaOsobnikow; i++) {
    float x1 = populacja[i][0];
    float x2 = populacja[i][1];
    float x = map(x1, zakresMin, zakresMax, 0, szer);
    float y = map(x2, zakresMin, zakresMax, wys, 0);
    ellipse(x, y, 5, 5);
  }
  


  popMatrix();
}
