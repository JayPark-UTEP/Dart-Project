import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

void main(List<String> arguments) {
  Controller().start();
}

class Controller {
  void start() {
    var ui = ConsoleUI();
    //Welcome user
    ui.showMessage("Welcome to Omok!");
    //Can provide default server
    var url = ui.askServerUrl();
    //Oonce we have the url we connect to web service. Create a new class to handle this
    ui.showMessage("Obtaining server inforations...");

    var net = WebServiceInterface(url);
    var info = net.getInfo();
    var strategy = info.strategies;
    var smart = strategy[0];
    var random = strategy[1];
    // print(strategy);

    // var value = true;

    // while (value) {
    //   var selection = ui.askStrategy(smart, random);
    //   if (selection == 1 || selection == 2) {
    //     ui.showMessage('creating a new game...');
    //     value = false;
    //   } else {
    //     print("can not start a new game");
    //   }
    // }

    // ui.promptMove();
  }
}

class Board {
  var size;
  Board(this.size);
}

class ConsoleUI {
  void showMessage(String message) {
    print(message);
  }

  promptMove() {
    var isEmpty = false;
    while (!isEmpty) {
      print("Enter x and y (1 - 15, e.g., 8, 10): ");
      var userMove = stdin.readLineSync();
      List<String>? move = userMove?.split(",");
      try {
        var x = int.parse(move![0]);
        var y = int.parse(move[1]);
        isEmpty = true;
      } catch (e) {
        print('Invalid index!');
      }
    }
  }

  askServerUrl() {
    stdout.write("Enter server URL (default): ");
    stdout.flush();
    var url = stdin.readLineSync()!;
    //to do: check and if invalid, repeat
    return url;
  }

  askStrategy(String strategy, String strategy2) {
    print(
        'select the server strategy: 1. $strategy 2. $strategy2 [default: 1]');
    var line = stdin.readLineSync()!;
    return int.parse(line);
  }
}

class WebServiceInterface {
  var serverUrl;
  WebServiceInterface(this.serverUrl);

  getInfo() {
    // var response = await http.get(Uri.parse(serverUrl));
    // var info = json.decode(response.body);
    // var strategy = info["strategies"];
    // var size = info["size"];
    // var smart = strategy[0];
    // var random = strategy[1];

    // return Info(size, <String>[smart, random]);
    return Info(15, <String>["Smart", "Random"]);
  }
}

class Info {
  var strategies;
  var size;
  Info(this.size, this.strategies);
}
