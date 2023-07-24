import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:sradford_notes/modules/import_export/import_export_service.dart';
import 'package:sradford_notes/modules/note/note_service.dart';
import 'package:sradford_notes/modules/shared/enum/info_dialog_type.dart';
import 'package:sradford_notes/modules/shared/widgets/my_confirmation_dialog.dart';
import 'package:sradford_notes/modules/shared/widgets/my_info_dialog.dart';
import 'package:sradford_notes/utils/service_locator.dart';

import '../note/note.dart';
import '../shared/class/result.dart';


class EditorPage extends StatefulWidget {
  final Note? note;

  const EditorPage({Key? key, this.note}) : super(key: key);

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {

  final _saveButtonFocusNode = new FocusNode();
  final QuillController _controller = QuillController.basic();
  final TextEditingController _titleController = new TextEditingController();

  late NoteService _noteService;
  late ImportExportService _importExportService;
  late Note workingNote;

  String title = '';

  @override
  void initState() {
    super.initState();
    _noteService = serviceLocator.get<NoteService>();
    _importExportService = serviceLocator.get<ImportExportService>();

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
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _controller.dispose();
    _titleController.dispose();
    _saveButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.save),
          focusNode: _saveButtonFocusNode,
          onPressed: saveNote,
        ),
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              switch (value) {
                case "cancel":
                  return Navigator.of(context).pop();
                case 'export':
                  return _exportNote();
                case 'delete':
                  return _deleteNote();
                default:
                  throw UnimplementedError();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: "cancel",
                // onTap: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              if(workingNote.noteId != null)
                PopupMenuItem<String>(
                  value: "export",
                  // onTap: _exportNote,
                  child: Text('Export'),
                ),
              if(workingNote.noteId != null)
                PopupMenuItem<String>(
                  value: "delete",
                  child: Text('Delete', style: TextStyle(color: Colors.redAccent),),
                ),
            ],
          )
        ],
      ),
      body: SafeArea(
        child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: "Title"
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    child: QuillToolbar.basic(
                      controller: _controller,
                      color: Colors.white,
                      showColorButton: false,
                      showBackgroundColorButton: false,
                      showClearFormat: false,
                      showLink: false,
                      showSuperscript: false,
                      showSubscript: false,
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
    // TODO: Note if you press save while keyboard is not open, you have to tap input multiple times
    // to be able to see the cursor.  You can still type, just without seeing a visible cursor.
    // I want the keyboard to close when save is pressed, but to also fix this issue.
    FocusScope.of(context).requestFocus(_saveButtonFocusNode);

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
        setState(() {
          title = "Saved!";
        });
        Timer(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              title = '';
            });
          }
        });

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

  Future<void> _exportNote() async {
    if(workingNote.noteId == null) {
      showMyInfoDialog(context: context, dialogType: InfoDialogType.Warning, body: "Must save the note before you can export it.");
      return;
    }

    try {
      List<int> noteIds = [workingNote.noteId!];

      Result exportResult = await _importExportService.ExportNotes(context: context, noteIds: noteIds);
      if(exportResult.succeeded == false && exportResult.showedDialog == false) {
        showMyInfoDialog(context: context, dialogType: InfoDialogType.Error, body: "Failed to export note");
      } else if(exportResult.succeeded) {
        showMyInfoDialog(context: context, dialogType: InfoDialogType.Info, body: "Exported current note");
      }
    } catch(e) {
      print("Editor Page Export Failed");
      print(e.toString());
      showMyInfoDialog(context: context, dialogType: InfoDialogType.Error, body: "Unexpected error occurred while exporting note");
    }


  }

  Future<void> _deleteNote() async {
    print("I am inside delete note");
    bool confirmed = await showMyConfirmationDialog(context: context, body: "Are you sure you want to delete this note?");
    if(confirmed == true) {
      try {
        int deletedCount = await _noteService.deleteNote(noteId: workingNote.noteId ?? -1);
        if(deletedCount == 0) {
          showMyInfoDialog(
            context: context,
            dialogType: InfoDialogType.Warning,
            body: "Note was not deleted."
          );
        } else if(deletedCount == -1) {
          _showDeleteErrorDialog();
        } else {
          Navigator.of(context).pop();
        }
      } on Exception catch (e) {
        _showDeleteErrorDialog();
        print("Something went wrong while deleting note");
        print(e.toString());
      }
    }
  }

  void _showDeleteErrorDialog() {
    showMyInfoDialog(
        context: context,
        dialogType: InfoDialogType.Error,
        body: "Something went wrong while trying to delete the note."
    );
  }


}
