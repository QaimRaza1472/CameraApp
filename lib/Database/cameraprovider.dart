import 'package:sqflite/sqflite.dart'; //sqflite package
import 'package:path_provider/path_provider.dart'; //path_provider package
import 'package:path/path.dart'; //used to join paths
import './cameradb.dart'; //import model class
import 'dart:io';
import 'dart:async';

class camDbProvider {
  Future<Database> init() async {
    Directory directory =
        await getApplicationDocumentsDirectory(); //returns a directory which stores permanent files
    final path = join(directory.path, "cam.db"); //create path to database

    return await openDatabase(
        //open the database or create a database if there isn't any
        path,
        version: 1, onCreate: (Database db, int version) async {
      await db.execute("""
          CREATE TABLE Cam(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          flash INTEGER,
          camindex INTEGER,
          brightness FLOAT,
          colour TEXT)""");
    });
  }

  Future<int> addItem(CameraModel item) async {
    //returns number of items inserted as an integer

    final db = await init(); //open database

    return db.insert(
      "Cam", item.toMap(), //toMap() function from MemoModel
      conflictAlgorithm:
          ConflictAlgorithm.ignore, //ignores conflicts due to duplicate entries
    );
  }

  Future<List<CameraModel>> fetchMemos() async {
    //returns the memos as a list (array)

    final db = await init();
    final maps = await db
        .query("Cam"); //query all the rows in a table as an array of maps

    return List.generate(maps.length, (i) {
      //create a list of memos
      return CameraModel(
        id: maps[i]['id'],
        flash: maps[i]['flash'],
        camindex: maps[i]['camindex'],
        brightness: maps[i]['brightness'],
        colour: maps[i]['colour'],
      );
    });
  }

  Future<int> updateMemo(int id, CameraModel item) async {
    // returns the number of rows updated

    final db = await init();

    int result =
        await db.update("Cam", item.toMap(), where: "id = ?", whereArgs: [id]);
    return result;
  }
}
