import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:sradford_notes/modules/note/note_service.dart';
import 'package:sradford_notes/utils/service_locator.dart';

import '../note/note.dart';


class EditorPage extends StatefulWidget {
  final Note? note;

  const EditorPage({Key? key, this.note}) : super(key: key);

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {

  final QuillController _controller = QuillController.basic();
  final TextEditingController _titleController = new TextEditingController();

  late NoteService _noteService;
  late Note workingNote;

  bool _isCreate = true;

  @override
  void initState() {
    super.initState();
    _noteService = serviceLocator.get<NoteService>();
    _isCreate = widget.note == null;
    workingNote = widget.note == null ? Note.empty() : Note.fromNote(widget.note!);
    if(workingNote.title.isNotEmpty) {
      _titleController.text = workingNote.title;
    }
    if(workingNote.content.isNotEmpty) {
      _controller.document = Document.fromJson(jsonDecode(workingNote.content));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.save),
          onPressed: saveNote,
        ),
      ),
      body: SafeArea(
        child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "Title"
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    child: QuillToolbar.basic(
                      controller: _controller,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: QuillEditor.basic(
                        controller: _controller,
                        readOnly: false, // true for view only mode
                      ),
                    ),
                  )
                ],
              ),
            )
        ),
      )
    );
  }

  Future<void> saveNote() async {
    Note noteToSave = workingNote.noteId == null ? Note.now() : Note.fromNote(workingNote);
    noteToSave.title = _titleController.text.trim().isEmpty ? 'Untitled Note' : _titleController.text;
    noteToSave.setUpdatedAtToNow();
    noteToSave.content = jsonEncode(_controller.document.toDelta().toJson());
    noteToSave.raw = _controller.document.getPlainText(0, _controller.document.length);


    try {
      int savedId = await _noteService.addOrUpdateNote(noteToSave);
      if(savedId == -1) {
        print("Saving note returned invalid id");
      } else {
        noteToSave.noteId = savedId;
        workingNote = Note.fromNote(noteToSave);
      }
    } on Exception catch (e) {
      print("Saving note failed");
      print(e.toString());
    }

  }

  printContent() {
    print("PLAIN TEXT");
    print(_controller.document.getPlainText(0, _controller.document.length));
    print("JSON");
    print(_controller.document.toDelta().toJson());
  }
}
