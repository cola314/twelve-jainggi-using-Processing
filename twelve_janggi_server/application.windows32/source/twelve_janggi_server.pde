import processing.net.*;
import javax.swing.*;

//-------------------image variable-------------------//

PImage img;
String ip;


//--------------------game variable--------------------------//

String[] screen_bd = new String[12];
String[] screen_p1 = new String[6];
String[] screen_p2 = new String[6];
GAME game;
int turn, myturn;

//--------------------server variable------------------------//
Server myServer;
//Client myClient;

//-----------------main loop-----------------------------------//

void setup() {
  size(486, 665);
  textSize(50);
  text("Waiting ...", 20, 50);
  
  myServer = new Server(this, 5204);
  //ip = JOptionPane.showInputDialog("ip Address : ");
  //println("IP : " + ip);
  //myClient = new Client(this, ip, 5204);
  
  //init();
  //refresh();
}

void init() {
  myturn = GAME.PLAYER1;
  game = new GAME();
  turn = GAME.PLAYER1;
  game.set_turn(turn);
}
  
void draw() {
  Client myClient = myServer.available();
  if(myClient != null) {
    String msg = myClient.readString();
    String[] token = msg.split(" ");
    int cmd = Integer.parseInt(token[0]);
    if(cmd == 0) {
      button_yx(Integer.parseInt(token[1]), Integer.parseInt(token[2]));
    }
    else if(cmd == 1) {
      button_player1(Integer.parseInt(token[1]));
    }
    else if(cmd == 2) {
      button_player2(Integer.parseInt(token[1]));
    }
    else {
      background(204, 204, 204);
      init();
      refresh();
    }
    refresh();
    println(msg);
  }
}

void sendData(String msg) {
  myServer.write(msg);
}

void mouseClicked() {
  if(game == null) return;
  if(myturn != turn) return;
  int mx = mouseX, my = mouseY;
  for(int i=0; i<4; i++) {
    for(int j=0; j<3; j++) {
      int x = 67 + 117 * j, y = 105 + 117 * i, sz = 111;
      
      if(x <= mx && mx <= x + sz && y <= my && my <= y + sz) {
          button_yx(i, j);
          sendData("0 " + i + " " + j);
      }
    }
  }
  for(int i=0; i<6; i++) {
    int x = 55 + 63 * i, y = 105 + 117 * 4 + 10, sz = 58;
    
    if(x <= mx && mx <= x + sz && y <= my && my <= y + sz) {
        button_player1(i);
        sendData("1 " + i);
    }
  }
  for(int i=0; i<6; i++) {
    int x = 55 + 63 * i, y = 105 - 58 - 10, sz = 58;
    
    if(x <= mx && mx <= x + sz && y <= my && my <= y + sz) {
        button_player2(i);
        sendData("2 " + i);
    }
  }
  
  refresh();
  screenReload();
}


//------------------------button click process--------------------------//

void button_player1(int x) {
    game.button_click(GAME.PLAYER1, new POS(GAME.HAVING, x, 0));
}

void button_player2(int x) {
    game.button_click(GAME.PLAYER2, new POS(GAME.HAVING, x, 0));
}

void button_yx(int y, int x) {
    if(game.button_click(turn, new POS(GAME.BOARD, y, x)) == GAME.MOVED) {
        if(turn == GAME.PLAYER1) turn = GAME.PLAYER2;
        else if(turn == GAME.PLAYER2) turn = GAME.PLAYER1;
        game.set_turn(turn);
    }
    if(game.state == GAME.PLAYER1) {
        JOptionPane.showMessageDialog(null, "플레이어 1 승리", "Winner", JOptionPane.PLAIN_MESSAGE);
        println("플레이어 1 승리");
        game.init_game();
        turn = GAME.PLAYER1;
        
        if(myturn == GAME.PLAYER1) myturn = GAME.PLAYER2;
        else myturn = GAME.PLAYER1;
    }
    else if(game.state == GAME.PLAYER2) {
      JOptionPane.showMessageDialog(null, "플레이어 2 승리", "Winner", JOptionPane.PLAIN_MESSAGE);
        println("플레이어 2 승리");
        game.init_game();
        turn = GAME.PLAYER1;
        
        if(myturn == GAME.PLAYER1) myturn = GAME.PLAYER2;
        else myturn = GAME.PLAYER1;
    }
}


//---------------about screen--------------------------//

void screenReload() {
  for(int i=0; i<4; i++) {
    for(int j=0; j<3; j++) {
      rect(67 + 117 * j, 105 + 117 * i, 111, 111);
      img = loadImage(screen_bd[j+i*3]);
      image(img, 67 + 117 * j, 105 + 117 * i, 111, 111);
    }
  }
  for(int i=0; i<6; i++) {
    rect(55 + 63 * i, 105 + 117 * 4 + 10, 58, 58);
    img = loadImage(screen_p1[i]);
    image(img, 55 + 63 * i, 105 + 117 * 4 + 10, 58, 58);
  }
  for(int i=0; i<6; i++) {
    rect(55 + 63 * i, 105 - 58 - 10, 58, 58);
    img = loadImage(screen_p2[i]);
    image(img, 55 + 63 * i, 105 - 58 - 10, 58, 58);
  }
}

void refresh() {
    MAL[] p1 = game.get_having(GAME.PLAYER1);
    MAL[] p2 = game.get_having(GAME.PLAYER2);
    MAL[][] bd = game.get_board();

    for (int i = 0; i < 6; i++) {
        screen_p1[i] = "images/" + mal_str(p1[i]) + ".png";
        screen_p2[i] = "images/" + mal_str(p2[i]) + ".png";
    }
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 3; j++) {
            
            screen_bd[i * 3 + j] = "images/" + mal_str(bd[i][j]) + ".png";
        }
    }
    screenReload();
}

String mal_str(MAL mal) {
    String ret = "";
    if (mal == null) return "빈칸";
    if (mal.player == GAME.NOTHING) {
        if (mal.pos.y == 0) ret = "빨빈";
        else if (mal.pos.y == 3) ret = "초빈";
        else {
            if(mal.highlighted) return "빈칸선";
            return "빈칸";
        }
    }
    else {
        if (mal.player == GAME.PLAYER1) ret = "초";
        else if (mal.player == GAME.PLAYER2) ret = "빨";

        if (mal.type == GAME.Ja) ret += "자";
        else if (mal.type == GAME.Jang) ret += "장";
        else if (mal.type == GAME.Sang) ret += "상";
        else if (mal.type == GAME.Wang) ret += "왕";
        else if (mal.type == GAME.Hu) ret += "후";
    }
    if (mal.highlighted) ret += "선";
    else ret += "무";
    return ret;
}



//------------------twelve-janggi-api.java------------------//

class GAME {
    static final int NOTHING = 0;
    static final int PLAYER1 = 1;
    static final int PLAYER2 = 2;

    static final int BOARD = 0;
    static final int HAVING = 1;

    static final int Wang = 0;
    static final int Sang = 1;
    static final int Jang = 2;
    static final int Ja = 3;
    static final int Hu = 4;
    static final int Mu = 5;

    static final int SELECTED = 1;
    static final int MOVED = 2;

    final int[][][] MAL_DIR = {
        {{1, -1}, {1, 0}, {1, 1}, {0, -1}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}},
        {{1, 1}, {1, -1}, {-1, 1}, {-1, -1}},
        {{1, 0}, {-1, 0}, {0, 1}, {0, -1}},
        {{-1, 0}},
        {{-1, -1}, {-1, 0}, {-1, 1}, {0, 1}, {0, -1}, {1, 0}},
        {}
    };

    int turn;
    int state;
    MAL[] player1 = new MAL[6];
    MAL[] player2 = new MAL[6];
    MAL[][] board = new MAL[4][3];
    MAL selected;

    GAME() {
        init_game();
    }
    
    void init_game() {
        this.turn = PLAYER1;
        this.state = 0;
        for(int i=0; i<6; i++) {
            player1[i] = null;
            player2[i] = null;
        }
        this.selected = null;

        this.board[0][0] = new MAL(PLAYER2, Jang, new POS(BOARD, 0, 0), false);
        this.board[0][1] = new MAL(PLAYER2, Wang, new POS(BOARD, 0, 1), false);
        this.board[0][2] = new MAL(PLAYER2, Sang, new POS(BOARD, 0, 2), false);
        this.board[1][0] = new MAL(NOTHING, Mu, new POS(BOARD, 1, 0), false);
        this.board[1][1] = new MAL(PLAYER2, Ja, new POS(BOARD, 1, 1), false);
        this.board[1][2] = new MAL(NOTHING, Mu, new POS(BOARD, 1, 2), false);
        this.board[2][0] = new MAL(NOTHING, Mu, new POS(BOARD, 2, 0), false);
        this.board[2][1] = new MAL(PLAYER1, Ja, new POS(BOARD, 2, 1), false);
        this.board[2][2] = new MAL(NOTHING, Mu, new POS(BOARD, 2, 2), false);
        this.board[3][0] = new MAL(PLAYER1, Sang, new POS(BOARD, 3, 0), false);
        this.board[3][1] = new MAL(PLAYER1, Wang, new POS(BOARD, 3, 1), false);
        this.board[3][2] = new MAL(PLAYER1, Jang, new POS(BOARD, 3, 2), false);
    }

    void set_turn(int player) {
        this.turn = player;
    }

    MAL[][] get_board() {
        return this.board;
    }

    MAL[] get_having(int player) {
        if (player == PLAYER1) return this.player1;
        else if (player == PLAYER2) return this.player2;
        return null;
    }

    int button_click(int player, POS pos) {
        if (player != this.turn) return 0;
        if (pos.from == HAVING) {
            if (player == PLAYER1) {
                this.selected = this.player1[pos.y];
                clear_highlighted(this.board);
                for (int i = 1; i < 4; i++) {
                    for (int j = 0; j < 3; j++) {
                        if (this.board[i][j].type == Mu) {
                            this.board[i][j].highlighted = true;
                        }
                    }
                }
            }
            else if (player == PLAYER2) {
                this.selected = this.player2[pos.y];
                clear_highlighted(this.board);
                for (int i = 0; i < 3; i++) {
                    for (int j = 0; j < 3; j++) {
                        if (this.board[i][j].type == Mu) {
                            this.board[i][j].highlighted = true;
                        }
                    }
                }
            }
            return SELECTED;
        }
        else if (pos.from == BOARD) {
            if (this.board[pos.y][pos.x].highlighted) {
                if (this.board[pos.y][pos.x].type == Wang) {
                    this.state = player;
                }
                else if (this.board[pos.y][pos.x].type != Mu) {
                    MAL[] this_player = (player == PLAYER1 ? this.player1 : this.player2);
                    for (int i = 0; i < 6; i++) {
                        if (this_player[i] == null) {
                            this_player[i] = new MAL(player, this.board[pos.y][pos.x].type, new POS(HAVING, i, 0), false);
                            //Hu -> Ja
                            if(this_player[i].type == Hu) {
                                this_player[i].type = Ja;
                            }
                            break;
                        }
                    }
                }
    
                if (this.selected.pos.from == BOARD) this.board[this.selected.pos.y][this.selected.pos.x] = new MAL(NOTHING, Mu, new POS(BOARD, this.selected.pos.y, this.selected.pos.x), false);
                else if (this.selected.pos.from == HAVING) {
                    MAL[] this_player = (player == PLAYER1 ? this.player1 : this.player2);
                    for (int i = this.selected.pos.y; i < 5; i++) {
                        if(this_player[i + 1] != null) {
                            this_player[i] = new MAL(player, this_player[i+1].type, new POS(HAVING, i, 0), false);
                            //Hu -> Ja
                            if(this_player[i].type == Hu) {
                                this_player[i].type = Ja;
                            }
                        }
                        else this_player[i] = null;
                    }
                    this_player[5] = null;
                }
                this.board[pos.y][pos.x] = new MAL(player, this.selected.type, new POS(BOARD, pos.y, pos.x), false);
                if (this.board[pos.y][pos.x].type == Ja && (player == PLAYER1 && pos.y == 0 || player == PLAYER2 && pos.y == 3)) {
                    this.board[pos.y][pos.x].type = Hu;
                }
                clear_highlighted(this.board);
    
                if (player == PLAYER1) {
                    for (int i = 0; i < 3; i++) {
                        if (this.board[3][i].type == Wang && this.board[3][i].player == PLAYER2) {
                            this.state = PLAYER2;
                        }
                    }
                }
                else if (player == PLAYER2) {
                    for (int i = 0; i < 3; i++) {
                        if (this.board[0][i].type == Wang && this.board[0][i].player == PLAYER1) {
                            this.state = PLAYER1;
                        }
                    }
                }
                return MOVED;
            }
            else if (this.board[pos.y][pos.x].player == player) {
                this.selected = this.board[pos.y][pos.x];
                clear_highlighted(this.board);
                for (int i = 0; i < MAL_DIR[this.selected.type].length; i++) {
                    int y = pos.y + (player == PLAYER1 ? 1 : -1) * MAL_DIR[this.selected.type][i][0];
                    int x = pos.x + MAL_DIR[this.selected.type][i][1];
                    if (0 <= x && x < 3 && 0 <= y && y < 4 && this.board[y][x].player != player) {
                        this.board[y][x].highlighted = true;
                    }
                }
                return SELECTED;
            }
        }
        return NOTHING;
    }

    private void clear_highlighted(MAL[][] board) {
        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 3; j++) {
                board[i][j].highlighted = false;
            }
        }
    }
}

class MAL {
    int player;
    int type;
    POS pos;
    boolean highlighted;

    MAL(int player, int type, POS pos, boolean highlighted) {
        this.player = player;
        this.type = type;
        this.pos = pos;
        this.highlighted = highlighted;
    }
}

class POS {
    int from;
    int x;
    int y;
    
    POS(int from, int y, int x) {
        this.from = from;
        this.y = y;
        this.x = x;
    }
}
