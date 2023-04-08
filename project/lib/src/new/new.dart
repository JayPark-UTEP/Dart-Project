import 'package:http/http.dart' as http;

void main() async {
  var url = 'https://www.cs.utep.edu/cheon/cs3360/project/omok/new/';
  var strategy = 'Smart';
  var uri = Uri.parse('$url?strategy=$strategy');
  var response = await http.get(uri);
  var statusCode = response.statusCode;
  if (statusCode < 200 || statusCode > 400) {
    print('Server connection failed ($statusCode).');
  } else {
    print('Response body: ${response.body}');
  }
}
