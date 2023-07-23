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

  Future<List<Note>?> getSelectedNotes({required List<int> noteIds}) async {
    if(noteIds.isEmpty) { return []; }
    try {
      Database? db = await DBProvider.db.database;
      String joinedIds = List.filled(noteIds.length, '?').join(',');
      List<Map<String, dynamic>>? dbNotes = await db?.query(DatabaseTable.Note,
          where: '${DatabaseColumn.NoteId} IN ($joinedIds)',
          whereArgs: noteIds
      );
      if(dbNotes != null && dbNotes.length > 0) {
        return List.generate(dbNotes.length, (index) {
          return Note.fromPersistence(dbNotes[index]);
        });
      } else {
        return [];
      }
    } on Exception catch (e) {
      print("Note Dao: Error in getSelectedNotes");
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

  Future<int> deleteNote({int noteId = -1}) async {
    if(noteId <= 0) { return -1; }

    Database? db = await DBProvider.db.database;
    try {
      int? deletedCount = await db?.delete(DatabaseTable.Note, where: "${DatabaseColumn.NoteId} = ?", whereArgs: [noteId]);
      if(deletedCount != null && deletedCount > 0) {
        print("Count of deleted notes: $deletedCount");
      }
      return deletedCount ?? 0;
    } on Exception catch (e) {
      print("Error deleting note with id: $noteId");
      print(e);
      return -1;
    }

  }

  Future<int> bulkDelete({required List<int> noteIds}) async {
    if(noteIds.isEmpty) { return -1; }
    try {
      Database? db = await DBProvider.db.database;
      String joinedIds = List.filled(noteIds.length, '?').join(',');
      int? deletedCount = await db?.delete(DatabaseTable.Note,
          where: '${DatabaseColumn.NoteId} IN ($joinedIds)',
          whereArgs: noteIds);
      return deletedCount ?? 0;
    } on Exception catch (e) {
      print("Note Dao: Error in bulk delete");
      print(e.toString());
      return -1;
    }
  }


}