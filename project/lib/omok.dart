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
    print(info);
    ui.askStrategy();

    ui.showBoard();
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

  askStrategy() {
    print('select the server strategy: 1. smart 2. random [default: 1]');
    var userStrategy = stdin.readLineSync()!;
    checkSelection(userStrategy);
  }

  checkSelection(userStrategy) {
    try {
      var selection = int.parse(userStrategy);

      if (selection == 1 || selection == 2) {
        print('creating a new game...');
      } else {
        print('Invalid selection: $selection');
        askStrategy();
      }
    } on FormatException {
      print('Format error $userStrategy');
      askStrategy();
    }
  }

  void showBoard() {
    var board = Board(15);

    var indexes =
        List<int>.generate(board._size, (i) => (i + 1) % 10).join(' ');
    print('x $indexes');
    print('y--------------------------------');
    // for (var row in board._rows) {
    //   var line = row.map((player) => player.stone).join('n');
    //   stdout.writeln('${y % 10}| $line');
    // }
  }
}

class Board {
  var _size;
  // var _rows;
  Board(this._size);
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
}

class Info {
  var _size;
  var _staregies;

  Info(this._size, this._staregies);
}
