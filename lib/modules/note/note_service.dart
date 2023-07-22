import 'package:sradford_notes/modules/note/note.dart';
import 'package:sradford_notes/modules/note/note_dao.dart';

class NoteService {

  NoteService();

  Future<int> addOrUpdateNote(Note note) async {
    NoteDao noteDao = new NoteDao();
    int? insertedId = await noteDao.addOrUpdateNote(note);
    return insertedId ?? -1;
  }

  Future<Note?> getNoteById(int noteId) async {
    NoteDao noteDao = new NoteDao();
    return await noteDao.getNoteById(noteId: noteId);
  }

  Future<List<Note>?> getAllNotes({String noteSearch = ''}) async {
    NoteDao noteDao = new NoteDao();
    return await noteDao.getAllNotes(noteSearch: noteSearch);
  }

  Future<int> deleteNote({int noteId = -1}) async {
    NoteDao noteDao = new NoteDao();
    return await noteDao.deleteNote(noteId: noteId);
  }

  Future<int> bulkDeleteNotes({required List<int> noteIds}) async {
    NoteDao noteDao = new NoteDao();
    return await noteDao.bulkDelete(noteIds: noteIds);
  }
}