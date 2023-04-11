import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

var defaultUrl = 'https://www.cs.utep.edu/cheon/cs3360/project/omok/info/';
void main() async {
  stdout.write('Enter the server URL [default: $defaultUrl] ');

  var url = stdin.readLineSync()!;
  var response = await http.get(Uri.parse(url));

  var info = json.decode(response.body);
  var strategy = info["strategies"];

  var smart = strategy[0];
  var random = strategy[1];

  stdout.write(info["strategies"]);
  stdout.write('select the server strategy: 1. $smart 2. $random [default: 1]');

  var line = stdin.readLineSync()!;

  try {
    var selection = int.parse(line);

    if (selection == 1 || selection == 2) {
      stdout.write('creating a new game...');
      //Display the board
    } else {
      stdout.write('Invalid selection: $selection');
    }
  } on FormatException {
    stdout.write('Format error $line');
  }
}
