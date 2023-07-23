import 'dart:math';

import 'package:sradford_notes/persistance/database_column.dart';

class Note {
  String content = '';
  String createdAt = '';
  int? noteId;
  String raw = '';
  String title = '';
  String updatedAt = '';

  Note.empty();

  Note.full({content, createdAt, noteId, raw, title, updatedAt});

  Note.now({content = '', raw = '', title = ''}) {
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

  Map<String, dynamic> toPersistence() =>
  {
    DatabaseColumn.Content: content,
    DatabaseColumn.CreatedAt: createdAt,
    DatabaseColumn.NoteId: noteId,
    DatabaseColumn.Raw: raw,
    DatabaseColumn.Title: title,
    DatabaseColumn.UpdatedAt: updatedAt,
  };

  Note.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    createdAt = json['createdAt'];
    raw = json['raw'];
    title = json['title'];
    updatedAt = json['updatedAt'];
  }

  Map toJson() => {
    'content': content,
    'createdAt': createdAt,
    'raw': raw,
    'title': title,
    'updatedAt': updatedAt
  };

  void setUpdatedAtToNow() {
    updatedAt = new DateTime.now().toIso8601String();
  }

  String getPreview() {
    return raw.substring(0, min(raw.length, 60)).replaceAll('\n', ' ');
  }
}