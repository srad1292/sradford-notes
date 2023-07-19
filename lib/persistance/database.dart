import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sradford_notes/persistance/database_column.dart';

import 'database_table.dart';

const int DB_VERSION = 1;

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  Database? _database;

  Future<Database?> get database async {
    if(_database != null) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  initDB() async {
    String path = join(await getDatabasesPath(), 'sradford_notes_app_database.db');
    return await openDatabase(path,
        version: DB_VERSION,
        onOpen: (db) {},
        onCreate: _createCallback,
        //onUpgrade: _updateCallback
    );
  }

  void _createCallback(Database db, int version) async {
    print("calling create");
    await db.execute(_getNoteScheme());
  }

  void _updateCallback(Database db, int oldVersion, int newVersion) {
    if(oldVersion == 1) {
      // db.execute("ALTER TABLE ${DatabaseTable.Note} ADD COLUMN some_new_column TEXT;");
    }

  }


  String _getNoteScheme() {
    return "CREATE TABLE ${DatabaseTable.Note} ("
        "${DatabaseColumn.NoteId} INTEGER PRIMARY KEY,"
        "${DatabaseColumn.Content} TEXT,"
        "${DatabaseColumn.CreatedAt} TEXT,"
        "${DatabaseColumn.Raw} TEXT,"
        "${DatabaseColumn.Title} TEXT,"
        "${DatabaseColumn.UpdatedAt} TEXT"
        ");";
  }

}