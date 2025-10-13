import 'package:shared_preferences/shared_preferences.dart';

/*

    THIS FILE IS MAINLY USED FOR SAVING THE USER CREDENTIALS
    AND RETRIEVING THE USER CREDENTIALS

*/

//Saving the user credentials
Future<void> saveUserCredentials({
  required String username,
  required String email,
  required String password,
}) async {
  final pref = await SharedPreferences.getInstance();

  final String? dbUsername = pref.getString('username');
  final String? dbEmail = pref.getString('email');
  final String? dbPassword = pref.getString('password');

  if (dbUsername != username) {
    pref.setString('username', username);
  }

  if (dbEmail != email) {
    pref.setString('email', email);
  }

  if (dbPassword != password) {
    pref.setString('password', password);
  }
}

//Retrieving the credentials
Future<({String? email, String? password, String? username})>
getUserCredentials() async {
  final pref = await SharedPreferences.getInstance();
  final username = pref.getString('username');
  final email = pref.getString('email');
  final password = pref.getString('password');

  return (username: username, email: email, password: password);
}
