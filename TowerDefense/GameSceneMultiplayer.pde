public class GameSceneMultiplayer extends Scene {

  private RhythmGame miniGame = null;

  private Player player1 = new Player();
  private Player player2 = new Player();


  private boolean isBuildingState;
  private boolean isMiniGame = false;
  private final int healthBarLength = 100;

  private final float MAX_BUILD_TIME = 20;
  private float buildTimeLeft = MAX_BUILD_TIME;

  private final float MAX_RHYTHM_TIME = 13;
  private float rhythmTimeLeft = MAX_RHYTHM_TIME;
  
  private int startingColorIndex = 0;

  private int[][] world = {
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
    {0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
  };
  
  private Tile[][] worldTiles = new Tile[10][20];


  public Scene update() {
    if (isMiniGame) {
      miniGame.draw();
      if (rhythmTimeLeft <= 0) {
        onMiniGameEnd();
      } else rhythmTimeLeft -= Time.deltaTime;
    } else {
      mapUpdate();
      if (isBuildingState) {
        buildingUpdate();
      } else {
        for (int i = player1.creeps.size() - 1; i >= 0; --i) {
          Creep c = player1.creeps.get(i);
          if(c.timeToLeave <= 0) c.update();
          else c.timeUpdate(); 
          
          if (c.isDead)
            player1.creeps.remove(i);
        }

        for (int i = player2.creeps.size() - 1; i >= 0; --i) {
          Creep c = player2.creeps.get(i);
          if(c.timeToLeave <= 0) c.update();
          else c.timeUpdate(); 
          
          if (c.isDead)
            player2.creeps.remove(i);
        }

        if (player1.creeps.isEmpty() && player2.creeps.isEmpty()) {
          isBuildingState = true;
        }
      }
    }
    return null;
  }

  

  public void onSceneEnter() {
    // start background music
    for (int i = 0; i < worldRows; ++i)
    {
      for (int j = 0; j < worldCols; ++j) {
        if ((i >= 3 && i <= 6) && (j == 0 || j == 19)) {
          world[i][j] = 5;
          instantiate(i,j);
        } else {
          instantiate(i,j);
        }
      }
    }
      
    setDanceFloor();
    isBuildingState = true;
  }
  
  public void setDanceFloor() {
    int index = startingColorIndex;
    for(int i = 0; i < worldRows; ++i) {
      for(int j = i, k = 0; j >=0 && k < worldCols; --j, ++k) {
        changeTile(j,k,index);
      }
      index = (index + 1) % 5;
    }
      
      for(int i = 1; i < worldCols; ++i) {
        for(int j = 9, k = i; j >= 0 && k < worldCols; --j, ++k) {
          changeTile(j,k,index);
        }
        index = (index + 1) % 5;
      }
  }
  
  public void changeTile(int j, int k, int index) {
    if(world[j][k] > 5) {
      worldTiles[j][k].setBackgroundTile(index);
    } else {
      if (!(j >= 3 && j <= 6) || !(k == 0 || k == 19)) {
        world[j][k] = index;
        instantiate(j,k);
      }
    }
  }

  public void onSceneExit() {
  }

  private void setupScene() {
    //initializing fans and health
    textAlign(LEFT);
    //health bar area
    fill(0, 0, 0, 150);
    noStroke();
    rect(0, 0, 1000, 120);
    //player 1 text
    fill(255);
    text("You: ", 40, 30);
    //enemy text
    text("Enemy: ", 750, 30);
    //player 1 health bar
    fill(0, 200, 0);
    rect(100, 15, healthBarLength * player1.healthPercent(), 25);
    //enemy health bar
    fill(0, 200, 0);
    rect(825, 15, healthBarLength * player2.healthPercent(), 25);
    //fan icon placeholder
    fill(0, 255, 255);
    rect(250, 15, 40, 30);
    rect(610, 15, 40, 30);
    //fan count
    fill(255);
    text(player1.fans, 310, 34); // p1
    text(player2.fans, 670, 34); //p2
    //dj tower 1
    fill(255);
    rect(10, 170, 90, 280);
    //dj tower 2
    rect(900, 170, 90, 280);
  }

  public void onMousePressed() {

    if (isBuildingState) {
      startMiniGame();
    }
  }

  public void onKeyPressed() {
    if (isMiniGame) {
      miniGame.onKeyPressed();
    }
  }

  public void mapUpdate() {
    setupScene();
    for (int i = 0; i < worldRows; ++i)
    {
      for (int j = 0; j < worldCols; ++j) {
        worldTiles[i][j].display();
      }   
    }
  }
  
  private void instantiate(int i, int j) {
    worldTiles[i][j] = tiles.get(world[i][j]).getInstance();
    worldTiles[i][j].pos = tileToCorner(new PVector(j,i));
  }

  public void buildingUpdate() {
    fill(255);
    text("Building State", 465, 20);

    float startAngle = HALF_PI * -1;
    colorMode(HSB);
    int fillColor = 0;
    float percent = buildTimeLeft / MAX_BUILD_TIME;
    fillColor = (percent > .5 ? 100 : (percent > .25 ? 25 : 5));
    fill(fillColor, 255, 255);
    arc(500, 70, 60, 60, startAngle, startAngle + TWO_PI * percent);  
    colorMode(RGB);
    if (buildTimeLeft <= 0) {
      startMiniGame();
    } else buildTimeLeft -= Time.deltaTime;
  }

  public void startMiniGame() {
    isBuildingState = false;
    buildTimeLeft = MAX_BUILD_TIME;
    isMiniGame = true;
    miniGame = new RhythmGame(player1, player2, 0);
    //pause background music
  }
  
  public void onMiniGameEnd() {
    rhythmTimeLeft = MAX_RHYTHM_TIME;
    miniGame.player.pause();
    isMiniGame = false;
    // resume background music
    
    //remake map for pathfinder
    for(int i = 0; i < worldRows; ++i) {
      for(int j = 0; j < worldCols; ++j) {
        PathTile pt = new PathTile();
        Tile t = tiles.get(world[i][j]);
        
        pt.cost = t.cost;
        pt.x = j;
        pt.y = i;
        
        Pathfinder.worldTiles[i][j] = pt;
      }
    }
    
    for(int i = 0; i < worldRows; ++i) {
      for(int j = 0; j < worldCols; ++j) {
        Pathfinder.worldTiles[i][j].setNeighbors();
      }
    }
    
    // find paths
    for (int i = 0; i < player1.creeps.size(); ++i) {
      player1.creeps.get(i).findPath();
    }

    for (int i = 0; i < player2.creeps.size(); ++i) {
      player2.creeps.get(i).findPath();
    }
  }
}
