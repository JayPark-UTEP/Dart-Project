import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() {
  //start the server
  Controller().start();
}

class Controller {
  start() async {
    var ui = consoleUI(); // console object
    ui.showMessage("Welcome to Omok!");

    //url string from the user
    var url = ui.askServerURL();
    ui.showMessage('Obtaining server information...');

    //web client object
    var wb = WebClient();
    //get the game information form the server
    //return Info object(size,strategies)
    var info = await wb.getInfo(url);
    var pid = await ui.askStrategy();
    var board = Board(15);
    board.showBoard();
    makeMove(pid, board);
  }

  void checkHasWon(pid, board, response) {
    if (jsonDecode(response.body)["ack_move"] == null) {
      var computerWon = jsonDecode(response.body)["move"]["isWin"];
      print("uh-oh, computer won :(");
      var row = jsonDecode(response.body)["move"]["row"];
      board.updateWin(row);
    } else if (jsonDecode(response.body)["move"] == null) {
      var playerWon = jsonDecode(response.body)["ack_move"]["isWin"];
      print("Congrats! You have won :)");
      var row = jsonDecode(response.body)["ack_move"]["row"];
      board.updateWin(row);
    }
  }

  void makeMove(pid, board) async {
    //The exclamation mark makes sure the input isnt null
    var ui = consoleUI();
    ui.printMoveDirections();
    var xandy = stdin.readLineSync()!.split(" ");
    try {
      if (xandy.length != 2) {
        throw FormatException();
      }
      if (int.parse(xandy[0]) > 15 ||
          int.parse(xandy[0]) < 1 ||
          int.parse(xandy[1]) > 15 ||
          int.parse(xandy[1]) < 1) {
        throw FormatException();
      } else {
        var x = int.parse(xandy[0]);
        var y = int.parse(xandy[1]);
        var uri = Uri.parse(
            "https://www.cs.utep.edu/cheon/cs3360/project/omok/play/?pid=$pid&x=$x&y=$y");
        var response = await http.get(uri);
        var statusCode = response.statusCode;
        if (statusCode < 200 || statusCode > 400) {
          print('Server connection failed ($statusCode).');
        } else {
          //Here we need to check if the move worked on the server. If so we need to update the board and display it. If not we let user know it was invalid and dont display the board
          var serverRespnse = jsonDecode(response.body)["response"];

          //If the response is true then we need to update the move with x and y
          if (serverRespnse) {
            if (jsonDecode(response.body)["move"] == null) {
              var computerHasWon = jsonDecode(
                  jsonEncode(jsonDecode(response.body)["ack_move"]["isWin"]));
              if (computerHasWon) {
                checkHasWon(pid, board, response);
              }
            } else if (jsonDecode(response.body)["ack_move"] == null) {
              var personHasWon = jsonDecode(
                  jsonEncode(jsonDecode(response.body)["move"]["isWin"]));
              if (personHasWon) {
                checkHasWon(pid, board, response);
              }
            } else {
              var computer_x = jsonDecode(
                  jsonEncode(jsonDecode(response.body)["move"]))["x"];
              var computer_y = jsonDecode(
                  jsonEncode(jsonDecode(response.body)["move"]))["y"];
              board.updateBoard(x - 1, y - 1, computer_x, computer_y);
              board.showBoard();
              makeMove(pid, board);
            }
          } else {
            print("Sorry, that place is taken :(");
            board.showBoard();
            makeMove(pid, board);
          }
        }
      }
    } on FormatException {
      print("Invalid format, please follow the example given");
      print("");
      board.showBoard();
      makeMove(pid, board);
    }
  }
}

class consoleUI {
  void showMessage(String message) {
    print(message);
  }

  askServerURL() {
    print(
        'Enter server URL (defualt:https://www.cs.utep.edu/cheon/cs3360/project/omok/): ');
    var url = stdin.readLineSync();
    return url;
  }

  askStrategy() async {
    var web = WebClient();
    print('select the server strategy: 1. smart 2. random [default: 1]');
    var userStrategy = stdin.readLineSync()!;
    return await web.createGame(userStrategy);
  }

  void printMoveDirections() {
    print("Player: O, Server: X (and *)");
    print("Enter x and y for your move (1-15, e.g., 8 10): ");
  }
}

class Board {
  var _size;
  var line = List.generate(15, (i) => List.filled(15, '. ', growable: false));

  Board(this._size);

  void showBoard() {
    var indexes = List<int>.generate(_size, (i) => (i + 1) % 10).join('  ');
    print(' x $indexes');
    print('y - - - - - - - - - - - - - - - - - - - - - - -');
    for (var i = 0; i < _size; i++) {
      stdout.write('${(i + 1) % 10}| ');
      print(line[i].join(' '));
    }
  }

  void updateWin(row) {
    for (var i = 0; i < row.length; i += 2) {
      var x = row[i];
      var y = row[i + 1];
      line[y - 1][x - 1] = 'W';
    }
    showBoard();
  }

  void updateBoard(x, y, computerX, computerY) {
    if (line[y][x] == '. ') {
      line[y][x] = 'O';
    }
    if (line[computerY][computerX] == '. ') {
      line[computerY][computerX] = 'X';
    }
  }
}

class WebClient {
  getInfo(url) async {
    var infoUrl = url + 'info';
    var response = await http.get(Uri.parse(infoUrl));
    var statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400) {
      print('Server connection failed ($statusCode).');
    } else {
      // print('Response body: ${response.body}');
      var info = json.decode(response.body);
      return Info(info['size'], info['strategies']);
    }
  }

  createGame(userStrategy) async {
    var ui = consoleUI();
    try {
      var selection = int.parse(userStrategy);

      if (selection == 1 || selection == 2) {
        print('creating a new game...');
        var strategy = '';
        if (selection == 1) {
          strategy = 'Smart';
        }
        if (selection == 2) {
          strategy = 'Random';
        }
        var uri = Uri.parse(
            "https://www.cs.utep.edu/cheon/cs3360/project/omok/new/?strategy=$strategy");
        var response = await http.get(uri);
        var statusCode = response.statusCode;
        if (statusCode < 200 || statusCode > 400) {
          print(jsonDecode(response.body)["reason"]);
        } else {
          if (jsonDecode(response.body)["response"] == true) {
            var pid = jsonDecode(response.body)["pid"];

            return pid;
          }
        }
      } else {
        print('Invalid selection: $selection');
        ui.askStrategy();
      }
    } on FormatException {
      print('Format error $userStrategy');
      ui.askStrategy();
    }
  }
}

class Info {
  var _size;
  var _staregies;

  Info(this._size, this._staregies);
}
