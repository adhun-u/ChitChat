import 'dart:io';
import 'package:chitchat/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static Store? obxStore;
  //Initializing hive and object box to save chat
  static Future<void> initDatabase() async {
    //Getting a directory for saving the chat
    final Directory dir = await getApplicationDocumentsDirectory();
    obxStore = await openStore(directory: "${dir.path}/chatDB");
  }
}
