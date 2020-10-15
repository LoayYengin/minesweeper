/*
 * MineSweeper
 *
 * Author: Yengin Loay
 * VERSION: 6 Dec 2019
 * PURPOSE: The objective of the game is to clear the board without clicking on any of the hidden mines
 *          Numbers indicate how many mines are adjacent to that cell's location
 *          Press n to restart the game with an increased number of mines
 */

final int CELLSIZE = 50;
final int NUM_ROWS = 10;
final int NUM_COLS = 12;

//--- generateMines, search and insertMine variables ---
int maxMines = int(random(1, 10));
int extraMines = 1;
int[] mineX = new int[maxMines];
int[] mineY = new int[maxMines];
int[] newMineX;
int[] newMineY;
int col, row;
int mineCounter; 
boolean filled = false;

//--- drawGrid variables ---
int gridX, gridY;

//--- detectMouseCol and detectMouseRow variables ---
int mouseCol, mouseRow;
boolean mineFound = false;

//--- insertNumValue variables ---
int maxNumValues = NUM_ROWS * NUM_COLS - maxMines;
int numValueCounter; // count of numbers populated in array i.e number of guesses
int[] numX = new int[maxNumValues];
int[] numY = new int[maxNumValues];
char[] numValue = new char[maxNumValues];
boolean numValueFound = false;

//--- searchAdjacent variables ---
int numAdjacentMines;
boolean topLeft, top, topRight, left, right, botLeft, bot, botRight = false; 

//--- keep score variables ---
int guessCounter;
boolean gameOver = false;

void setup() {
  size(600, 500); //(NUM_COLS*CELLSIZE) x (NUM_ROWS*CELLSIZE);
  background(123);

  generateMines(maxMines);
  numValueCounter = deleteNumValue(numX, numY, numValueCounter); 
}

void draw() { 
  drawGrid();
  if (!gameOver) {
    drawNums(numX, numY, numValue, maxNumValues); // display number of adjacent mines
    
  }
  if (mineFound && gameOver) {
    drawMines(mineX, mineY, maxMines); // display mines in filled cells
    displayLoseMessage();
  }
  if (numValueCounter == maxNumValues) {
    displayWinMessage();
    gameOver = true;
  }
}

//--- keyPressed - displayWinMessage - displayLoseMessage - newGame ---
void keyPressed() {
  if (key == 'n') {
    background(123);  
    // delete mines in mineX, mineY (set to -1)
    mineCounter = deleteMines(mineX, mineY, mineCounter);
 
    //delete numValues in numx, numY (set to -1)
    numValueCounter = deleteNumValue(numX, numY, numValueCounter);

    if (maxMines < NUM_ROWS * NUM_COLS) {
      // increase size of new array
      newMineX = new int[mineX.length + extraMines];
      newMineY = new int[mineX.length + extraMines];

      // set old array == to new array
      mineX = newMineX;
      mineY = newMineY;

      // increase number of maxMines
      maxMines = maxMines + extraMines;
    }

    generateMines(maxMines);
    maxNumValues = NUM_ROWS * NUM_COLS - maxMines;
    guessCounter = 0;   
    mineFound = false;  
    gameOver = false;
  }
}

// delete numValues in num arrays by setting to -1
int deleteNumValue(int[] x, int[] y, int numValueCounter) {
  for (int i = 0; i < maxNumValues; i++) {
    x[i] = -1;
    y[i] = -1;
  }
  numValueCounter = 0;
  return numValueCounter;
}

//delete mines in mine arrays by setting to -1
int deleteMines(int[] x, int[] y, int mineCounter) {
  for (int i = 0; i < maxMines; i++) {
    x[i] = -1;
    y[i] = -1;
  }
  mineCounter = 0;

  return mineCounter;
}

// displays the losing message when the game is lost
void displayLoseMessage() {
  String loseMessage = "Game over! You lost! \n Press n to play again";

  textSize(24);
  textAlign(CENTER);
  text(loseMessage, width/2, height/2);
}

// displays the winning message when game is won
void displayWinMessage() {
  String winMessage = "Game over! You won with a score of " + guessCounter +"\n Press n to play again";

  textSize(24);
  textAlign(CENTER);
  text(winMessage, width/2, height/2);
}

// --- insertNumValue - searchAdjacent - detectMouseRow - detectMouseCol ---
void mouseClicked() {
  if (!gameOver) {
    if (!mineFound) {
      detectMouseCol();
      detectMouseRow();
      
      mineFound = search(mineX, mineY, mineCounter, mouseCol, mouseRow); // check if a mine is in the cell
      
      if (mineFound) {
        gameOver = true;
      }
      
      numAdjacentMines = searchAdjacent(mineX, mineY, mouseCol, mouseRow); //search adjacent cells for mines, count up number of mines
      numValueFound = search(numX, numY, numValueCounter, mouseCol, mouseRow); // insert that number into numvalue at location numX and numY if no numValue filled yet

      if (!numValueFound && !mineFound) {
        numValueCounter = insertNumValue(numX, numY, numValue, numValueCounter, numAdjacentMines, mouseCol, mouseRow);
        guessCounter++;
      }
    }
  }
}

// assign numValue - the number of adjacent mines to be displayed in the cell
int insertNumValue(int[] numX, int[] numY, char[] numValue, int n, int numAdjacentMines, int mouseCol, int mouseRow) {
  int charValue0 = 48; // ASCII value 
  
  if (n < maxNumValues) {
    numX[n] = mouseCol;
    numY[n] = mouseRow;
    numValue[n] = char(charValue0 + numAdjacentMines); 
    n++;
  }
  return n;
}

// search all cells adjacent to cell where mouse is clicked for a mine - return number of adjacent mines
int searchAdjacent(int[] mineX, int[] mineY, int mouseCol, int mouseRow) {
  int adjacentMineCounter = 0;

  topLeft = search(mineX, mineY, mineCounter, mouseCol -1, mouseRow -1);
  top = search(mineX, mineY, mineCounter, mouseCol, mouseRow -1);
  topRight = search(mineX, mineY, mineCounter, mouseCol +1, mouseRow -1);
  left = search(mineX, mineY, mineCounter, mouseCol -1, mouseRow);
  right = search(mineX, mineY, mineCounter, mouseCol +1, mouseRow);
  botLeft = search(mineX, mineY, mineCounter, mouseCol -1, mouseRow +1);
  bot = search(mineX, mineY, mineCounter, mouseCol, mouseRow +1);
  botRight = search(mineX, mineY, mineCounter, mouseCol +1, mouseRow +1);

  // if a mine is present in a adjacent cell increase adjacentMineCounter by 1
  if (topLeft) {
    adjacentMineCounter++;
  }
  if (top) {
    adjacentMineCounter++;
  }
  if (topRight) {
    adjacentMineCounter++;
  }
  if (left) {
    adjacentMineCounter++;
  }
  if (right) {
    adjacentMineCounter++;
  }
  if (botLeft) {
    adjacentMineCounter++;
  }
  if (bot) {
    adjacentMineCounter++;
  }
  if (botRight) {
    adjacentMineCounter++;
  }
  return adjacentMineCounter;
}

// determine which row the mouse is in
int detectMouseRow() {
  for (int i = 0; i < NUM_ROWS; i++) {
    if (mouseY > CELLSIZE *i && mouseY < CELLSIZE * (i +1)) {
      mouseRow = i;
    }
  }
  return mouseRow;
}

// determine which col the mouse is in
int detectMouseCol() {
  for (int i = 0; i < NUM_COLS; i++) {
    if (mouseX > CELLSIZE *i && mouseX < CELLSIZE * (i +1)) {
      mouseCol = i;
    }
  }
  return mouseCol;
}

// --- generateMines - search - insertMine ---

// generate a randoms set of mines up to maxMines
void generateMines(int maxMines) {
  for (int i = 0; i < maxMines; i++) {
    while (mineCounter != maxMines) {
      col = int(random(NUM_COLS));
      row = int(random(NUM_ROWS));
     
      filled = search(mineX, mineY, mineCounter, col, row); 

      if (!filled) {
        mineCounter = insertMine(mineX, mineY, mineCounter, col, row);
      }      
    }
  }
}

// compare col and row number with respective x and y arrays to determine if there is a matching entry
boolean search(int[] x, int[] y, int n, int col, int row) {
  for (int i = 0; i < n; i++) {
    if (x[i] == col && y[i] == row) {
      filled = true;
      break;
    } else {
      filled = false;
    }
  }
  return filled;
}

// starting from index 0 if there is space available in the array assign a column number to x[] and row number to y[]
int insertMine(int[] x, int[] y, int n, int col, int row) { 
  if (n < maxMines) {
    x[n] = col;
    y[n] = row;
    n++;
  }
  return n;
}

//--- drawGrid - drawMines - drawNums ---

// display the game board
void drawGrid() {  
  for (int i = 0; i < NUM_COLS; i++) {
    for (int j = 0; j < NUM_ROWS; j++) {
      gridX = (CELLSIZE *i);
      gridY = (CELLSIZE *j);

      stroke(0);
      noFill();
      rect(gridX, gridY, CELLSIZE, CELLSIZE);
    }
  }
}

// displays all the mines at their appropriate cell
void drawMines(int[] colNumber, int[] rowNumber, int numMines) {
  for (int i = 0; i < numMines; i++) {
    drawMine(rowNumber[i], colNumber[i]);
  }
}

// displays all the number values for the number of mines adjacent to the cell
void drawNums(int[] colNumber, int[] rowNumber, char[] numValue, int numNums) {
  for (int i = 0; i < numNums; i++) {
    drawNum(rowNumber[i], colNumber[i], numValue[i]);
  }
}

//--- drawMine - drawNum ---
// draws mine graphic
void drawMine(int col, int row) {
  int mineX, mineY;
  int mineDiam = 30;
  int mineDiamSwitch = mineDiam/5;
  int mineDetail = CELLSIZE/2;

  mineX = (CELLSIZE * row) + CELLSIZE/2;
  mineY = (CELLSIZE * col) + CELLSIZE/2;

  line(mineX - mineDetail, mineY, mineX + mineDetail, mineY);
  line(mineX, mineY - mineDetail, mineX, mineY + mineDetail);
  fill(0, 50, 0);
  ellipse(mineX, mineY, mineDiam, mineDiam); 
  noFill();
  stroke(255);
  ellipse(mineX, mineY, mineDiam/2, mineDiam/2); 
  stroke(0);
  fill(255, 0, 0);
  ellipse(mineX, mineY, mineDiamSwitch, mineDiamSwitch);
}

// draws a number graphic
void drawNum(int row, int col, char numValue) {
  int numX, numY;
  int verticalFontOffset = 3; // offSet for vertical alignmnet
  numX = (CELLSIZE * col) + CELLSIZE/2;
  numY = (CELLSIZE * row) + CELLSIZE/2;

  fill(0, 0, 255);
  textSize(24);
  textAlign(CENTER);
  text(numValue, numX, numY + (textAscent() /verticalFontOffset));
}
