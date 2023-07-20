import 'package:sqflite/sqflite.dart';
import 'package:sradford_notes/persistance/database_column.dart';

import '../../persistance/database.dart';
import '../../persistance/database_table.dart';
import 'note.dart';

class NoteDao {

  NoteDao();

  Future<int?> addOrUpdateNote(Note note) async {
    try {
      Database? db = await (DBProvider.db.database);
      int? insertedId = await db?.insert(DatabaseTable.Note, note.toPersistence(), conflictAlgorithm: ConflictAlgorithm.replace);
      return insertedId;
    } on Exception catch (e) {
      print("Error adding or replacing note");
      print(e.toString());
      return -1;
    }
  }

  Future<Note?> getNoteById({int noteId = 0}) async {
    if(noteId <= 0) { return null; }

    Database? db = await DBProvider.db.database;
    try {
      List<Map<String, dynamic>>? dbNote = await db?.query(DatabaseTable.Note, where: "${DatabaseColumn.NoteId} = ?", whereArgs: [noteId], limit: 1);
      if(dbNote != null && dbNote.length > 0) {
        return Note.fromPersistence(dbNote[0]);
      } else {
        return null;
      }
    } on Exception catch (e) {
      print("Error getting note by ID: $noteId");
      print(e.toString());
      return null;
    }
  }

  Future<List<Note>?> getAllNotes({String noteSearch = ''}) async {
    Database? db = await DBProvider.db.database;
    try {
      List<Map<String, dynamic>>? dbNotes = await db?.query(
          DatabaseTable.Note,
          where: "${DatabaseColumn.Title} like ?",
          whereArgs: ["%${noteSearch.toLowerCase()}%"]
      );
      if(dbNotes != null && dbNotes.length > 0) {
        return List.generate(dbNotes.length, (index) {
          return Note.fromPersistence(dbNotes[index]);
        });
      } else {
        return [];
      }
    } catch(error) {
      print("Error in get all notes");
      print(error.toString());
      return null;
    }

  }
}