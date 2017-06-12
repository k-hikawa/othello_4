//評価値=盤面評価値+返せる石の数
//自分の石選択あり

final int SIZE = 50;
final int STONE_SIZE = (int)(SIZE*0.7);
final int NONE = 0;
final int BLACK = 1;
final int WHITE = 2;

int[][] field;
int[][] value;
boolean black_turn = true;
boolean left,right,top,under,left_top,left_under,right_top,right_under;
boolean gameover = false;
boolean selection = false;
boolean self_black = true;
int max_i=-1,max_j=-1;
int wait = 0;

void setup(){
  size(400, 400);//8*SIZE,8*SIZE);
  field = new int[8][8];
  value = new int[8][8];
  initialization();
  println("Black is 0. White is 1");
}
 
void initialization(){
  
  for(int i=0;i<8;i++){
    for(int j=0;j<8;j++){
      field[i][j] = NONE;
    }
  }

  field[3][3] = BLACK;
  field[3][4] = WHITE;
  field[4][3] = WHITE;
  field[4][4] = BLACK;
  
  
  
  
}
void draw(){
  
  background(0,128,0);
  
  // lines
  stroke(0);
  for(int i=1; i<8; ++i){
    line(i*SIZE,0,i*SIZE,height);
    line(0, i*SIZE, width, i*SIZE);
  }
 
 
  // draw stones
  noStroke();
  for(int i=0; i<8; i++){
    for(int j=0; j<8; j++){
      if(field[i][j]==BLACK){
        fill(0);  //color black        
      }else if(field[i][j]==WHITE){
        fill(255); // color white        
      }
      if(i == max_i && j == max_j){ // 最後に置いた石を赤で囲む
        stroke(255,0,0);
      }else{
        noStroke();
      }
      if(field[i][j] != NONE){
        ellipse((i*2+1)*SIZE/2,(j*2+1)*SIZE/2, STONE_SIZE, STONE_SIZE);
      }
      
      if(my_turn()){
        if(self_black){
          fill(0,50);
        }else{
          fill(255,50);
        }
        if(selection){
          if(can_put_here(i,j)){ // おける場所を提示
            ellipse((i*2+1)*SIZE/2,(j*2+1)*SIZE/2, STONE_SIZE, STONE_SIZE);
            fill(0);
            text(reverse_Count(i,j),(i*2+1)*SIZE/2,(j*2+1)*SIZE/2); //返せる数を提示
          }
        }
      }
    }
  }
  
  if(!gameover && my_turn() && selection){
    if(self_black){
      fill(0);
    }else{
      fill(255);
    }
    stroke(0, 0, 255);
    ellipse(mouseX, mouseY, STONE_SIZE, STONE_SIZE);
  }
  if(!my_turn()){
    if(wait == 60){ // 白は1秒待ってから打つ
      auto_play();
      wait = 0;
    }else{
      wait++;
    }
  }
}
 

void mousePressed(){
  if(gameover){ //ゲーム終了時にクリックでリスタート
    initialization();
    black_turn = true;
    gameover = false;
  }else if(selection){ //色選択が終わったらゲーム開始
    if(my_turn()){
      int x = mouseX/SIZE;
      int y = mouseY/SIZE;
      if(field[x][y]==NONE){
        if(can_put_here(x, y)){
          field[x][y] = get_current_stone();
          max_i = x; //最後に置いた石を赤く囲むため
          max_j = y;
          reverse_stone(x, y);
          set_value();
          black_turn = !black_turn;
          wait = 0;
        }
      }
    }
  }
}

void keyPressed(){
  if(!selection){
    if(keyCode == 48){
      self_black = true;
      selection = true;
      println("You're black");
      println("Start!");
    }else if(keyCode == 49){
      self_black = false;
      selection = true;
      println("You're white");
      println("Start!");
    }
  }
}

boolean my_turn(){
  if(self_black == true){
    if(black_turn){
      return true;
    }
  }else{
    if(!black_turn){
      return true;
    }
  }
  return false;
}

int get_current_stone(){//現在のターンの自分の色を返す関数
  if(black_turn){
    return BLACK;
  }else{
    return WHITE;
  }
}

int get_other_stone(){//現在のターンの相手の色を返す関数
  if(black_turn){
    return WHITE;
  }else{
    return BLACK;
  }
}


boolean can_put_here(int x,int y){//クリックした場所におけるかのチェック
  boolean puttable = false;
  
  if(field[x][y] != NONE){//コマが置かれていたら
    return false;
  }else{
    left = check_direction(x, y, -1, 0, false);
    right = check_direction(x, y, 1, 0, false);
    top = check_direction(x, y, 0, -1, false);
    under = check_direction(x, y, 0, 1, false);
    left_top = check_direction(x, y, -1, -1, false);
    left_under = check_direction(x, y, -1, 1, false);
    right_top = check_direction(x, y, 1, -1, false);
    right_under = check_direction(x, y, 1, 1, false);
    
    if(left || right || top || under || left_top || left_under || right_top || right_under){
      puttable = true;
    }
    
    return puttable;
  }
}
  
  
boolean check_direction(int x, int y, int vecx, int vecy, boolean least){//指定された方向の状態をチェックする
  boolean in = inside(x+vecx, y+vecy);
  if(!in){
    return false;
  }else {
    if(field[x+vecx][y+vecy] == get_current_stone()){//隣が同色だったら
      if(least){
        return true;
      }else{//置いたマスのすぐ隣が同色なら置けない
        return false;
      }
    }else if(field[x+vecx][y+vecy] == NONE){
      return false;
    }else if(field[x+vecx][y+vecy] == get_other_stone()){
      least = true;//一回ここを通ったかの判定
      return check_direction(x+vecx, y+vecy, vecx, vecy, least);
    }else{
      return false;
    }
  }
}

void reverse_stone(int x, int y){
  if(left) reverse_stone_sub(x, y, -1, 0);
  if(right) reverse_stone_sub(x, y, 1, 0);
  if(top) reverse_stone_sub(x, y, 0, -1);
  if(under) reverse_stone_sub(x, y, 0, 1);
  if(left_top) reverse_stone_sub(x, y, -1, -1);
  if(left_under) reverse_stone_sub(x, y, -1, 1);
  if(right_top) reverse_stone_sub(x, y, 1, -1);
  if(right_under) reverse_stone_sub(x, y, 1, 1);
}

void reverse_stone_sub(int x, int y, int vecx, int vecy){
  if(field[x+vecx][y+vecy] == get_other_stone()){
    field[x+vecx][y+vecy] = get_current_stone();
    reverse_stone_sub(x+vecx, y+vecy, vecx, vecy);
  }else if(field[x+vecx][y+vecy] == get_current_stone()){
    //end
  }
}



boolean inside(int x, int y){//端の処理
  if(x < 0 || x > 7 || y < 0 || y > 7 ){
    return false;
  }else{
    return true;
  }
}

boolean check_pass(){
  boolean puttable = false;
  for(int i=0;i<8;i++){
    for(int j=0;j<8;j++){
      if(can_put_here(i,j)){
        puttable = true;
      }
    }
  }
  return puttable;
}

void draw_result(){
  int black_count = 0;
  int white_count = 0;
  String result;
   for(int i=0;i<8;i++){
    for(int j=0;j<8;j++){
      if(field[i][j] == BLACK){
        black_count++;
      }else if(field[i][j] == WHITE){
        white_count++;
      }
    }
   }
   if(black_count > white_count){
     result = "  Black is win : White is loose";
   }else if( black_count < white_count){
     result = "  Black is loose : White is win";
   }else{
     result = "  draw";
   }
   println(black_count + ":" + white_count + result);
}

void auto_play(){
  int max_value = -99;
  max_i = -1;
  max_j = -1;
  boolean passpass = false;
  for(int i=0;i<8;i++){
    for(int j=0;j<8;j++){
      boolean put = can_put_here(i,j);
      if(put){ //置ける場所のvalueを見る
        if(value[i][j] == max_value){ 
          if((int)random(2)==0){ //同じ値だったらランダムで選ぶ
            max_i = i;
            max_j = j;
          }
        }else if(value[i][j] > max_value){ // 一番valueが大きいfieldを保存しておく
          max_value = value[i][j];
          max_i = i;
          max_j = j;
        }
      }
    }
  }
  if(max_i == -1){
    if(self_black){
      println("White is pass"); //自分のパス1回目
    }else{
      println("Black is pass");
    }
    passpass = true;
  }else{
    can_put_here(max_i, max_j);
    field[max_i][max_j] = get_current_stone();
    reverse_stone(max_i, max_j);
    set_value();
  }
  
  black_turn = !black_turn;
  if(!check_pass()){ //黒のパス1回目
    if(passpass){
      println("Gameover"); //白のパス2回目 ゲーム終了
      draw_result();
      gameover = true;
    }else{
      if(self_black){
        println("Black is pass"); 
      }else{
        println("White is pass");
      }
      black_turn = !black_turn;
    }
  }
}


void set_value(){
  for(int i=0;i<8;i++){
    for(int j=0;j<8;j++){
      value[i][j] = 1;
    }
  }
  
  //角
  value[0][0] = 8;
  value[7][0] = 8;
  value[0][7] = 8;
  value[7][7] = 8;
  
  //角の周り
  value[1][0] = -2;
  value[0][1] = -2;
  
  value[6][0] = -2;
  value[7][1] = -2;
  
  value[0][6] = -2;
  value[1][7] = -2;
  
  value[7][6] = -2;
  value[6][7] = -2;
  
  for(int i=2;i<=5;i++){
    value[i][0] = 3;
    value[0][i] = 3;
    value[7][i] = 3;
    value[i][7] = 3;
    
    value[i][1] = 2;
    value[1][i] = 2;
    value[6][i] = 2;
    value[i][6] = 2;
  }
  
  if(selection){
    change_value();
  }
}

void change_value(){
  for(int i=0; i<8; i++){
    for(int j=0; j<8; j++){
      if(can_put_here(i,j)){
        value[i][j] += reverse_Count(i,j);
      }
    }
  }
    
}

int reverse_Count(int x, int y){
  int count = 0;
  count += check_direction2(x, y, -1, 0, false, 0);
  count += check_direction2(x, y, 1, 0, false, 0);
  count += check_direction2(x, y, 0, -1, false, 0);
  count += check_direction2(x, y, 0, 1, false, 0);
  count += check_direction2(x, y, -1, -1, false, 0);
  count += check_direction2(x, y, -1, 1, false, 0);
  count += check_direction2(x, y, 1, -1, false, 0);
  count += check_direction2(x, y, 1, 1, false, 0);
  return count;
}

int check_direction2(int x, int y, int vecx, int vecy, boolean least, int count){//指定された方向の返せる数を返す
  boolean in = inside(x+vecx, y+vecy);
  if(!in){
    return 0;
  }else {
    if(field[x+vecx][y+vecy] == get_current_stone()){//隣が同色だったら
      if(least){
        return count;
      }else{//置いたマスのすぐ隣が同色なら置けない
        return 0;
      }
    }else if(field[x+vecx][y+vecy] == NONE){
      return 0;
    }else if(field[x+vecx][y+vecy] == get_other_stone()){
      least = true;//一回ここを通ったかの判定
      count++;
      return check_direction2(x+vecx, y+vecy, vecx, vecy, least, count);
    }else{
      return 0;
    }
  }
}