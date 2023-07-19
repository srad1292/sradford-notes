import 'package:sradford_notes/modules/note/note.dart';
import 'package:sradford_notes/modules/note/note_dao.dart';

class NoteService {

  NoteService();

  Future<bool> addOrUpdateNote(Note note) async {
    NoteDao noteDao = new NoteDao();
    int? rowCount = await noteDao.addOrUpdateNote(note);
    return (rowCount ?? 0) > 0;
  }

  Future<Note?> getNoteById(int noteId) async {
    NoteDao noteDao = new NoteDao();
    return await noteDao.getNoteById(noteId: noteId);
  }

  Future<List<Note>?> getAllNotes({String noteSearch = ''}) async {
    NoteDao noteDao = new NoteDao();
    return await noteDao.getAllNotes(noteSearch: noteSearch);
  }
}