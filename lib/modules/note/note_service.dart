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

  Future<List<Note>?> getSelectedNotes({required List<int> noteIds}) async {
    NoteDao noteDao = new NoteDao();
    return await noteDao.getSelectedNotes(noteIds: noteIds);
  }

  Future<List<Note>?> getAllNotes({String? orderBy, String noteSearch = ''}) async {
    NoteDao noteDao = new NoteDao();
    return await noteDao.getAllNotes(noteSearch: noteSearch, orderBy: orderBy);
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