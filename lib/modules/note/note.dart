import 'package:sradford_notes/persistance/database_column.dart';

class Note {
  String content = '';
  String createdAt = '';
  String noteId = '';
  String raw = '';
  String title = '';
  String updatedAt = '';

  Note.empty();

  Note.full({content, createdAt, noteId, raw, title, updatedAt});

  Note.now({content, noteId, raw, title}) {
    this.content = content;
    this.noteId = noteId;
    this.raw = raw;
    this.title = title;
    createdAt = new DateTime.now().toIso8601String();
    updatedAt = new DateTime.now().toIso8601String();
  }

  Note.fromNote(Note original) {
    content = original.content;
    createdAt = original.createdAt;
    noteId = original.noteId;
    raw = original.raw;
    title = original.title;
    updatedAt = original.updatedAt;
  }

  Note.fromPersistence(Map<String, dynamic> json) {
    content = json[DatabaseColumn.Content];
    createdAt = json[DatabaseColumn.CreatedAt];
    noteId = json[DatabaseColumn.NoteId];
    raw = json[DatabaseColumn.Raw];
    title = json[DatabaseColumn.Title];
    updatedAt = json[DatabaseColumn.UpdatedAt];
  }

  void setUpdatedAtToNow() {
    updatedAt = new DateTime.now().toIso8601String();
  }
}