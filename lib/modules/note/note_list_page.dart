import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sradford_notes/utils/service_locator.dart';

import '../editor/editor-page.dart';
import 'note.dart';
import 'note_service.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({Key? key}) : super(key: key);

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {

  late NoteService _noteService;

  List<Note> _notes = [];
  bool _loaded = false;
  bool _notesFailed = false;

  int retries = 0;

  @override
  void initState() {
    super.initState();
    _noteService = serviceLocator.get<NoteService>();


    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
        centerTitle: true,
      ),
      body: _buildBody(),
      floatingActionButton: !_loaded ? null : FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditorPage(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: !_loaded ? _buildInitializingView() :
        _notesFailed ? _buildNotesFailedView() :
        _notes.isEmpty ? _buildEmptyNoteList() : _buildNoteList(),
    );
  }
  
  Widget _buildInitializingView() {
    return Center(
        child: CircularProgressIndicator(),
    );
  }

  Widget _buildNotesFailedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Failed to load notes.",
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _loadNotes(),
          child: Text(
            "Try Again.",
            style: TextStyle(
              color: Colors.blue
            ),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  Widget _buildEmptyNoteList() {
    return Center(
      child: Text("No Notes Found"),
    );
  }
  
  Widget _buildNoteList() {
    return Placeholder();
  }

  Future<void> _loadNotes() async {
    retries++;
    List<Note>? startingNotes = await _noteService.getAllNotes();
    if(startingNotes == null) {
      setState(() {
        _loaded = true;
        _notesFailed = true;
        _notes = [];
      });
    } else {
      setState(() {
        _loaded = true;
        _notesFailed = retries >= 2 ? false : true;
        _notes = new List.from(startingNotes);
      });
    }
  }
}
