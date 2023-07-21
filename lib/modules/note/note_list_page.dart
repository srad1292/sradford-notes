import 'dart:async';
import 'dart:math';

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

  final TextEditingController _searchController = new TextEditingController();
  Timer? _debounce;
  String _noteSearchText = '';

  late NoteService _noteService;

  List<Note> _notes = [];
  bool _loaded = false;
  bool _notesFailed = false;
  bool _notesExist = false;

  @override
  void initState() {
    super.initState();
    _noteService = serviceLocator.get<NoteService>();
    _searchController.addListener(noteSearchHandler);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _loadNotes();
    });
  }

  void noteSearchHandler() {
    if(_searchController.text == _noteSearchText) {
      return;
    }

    setState(() {
      _noteSearchText = _searchController.text;
    });

    if(_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _noteSearchText = _searchController.text;
        _loadNotes(search: _noteSearchText);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditorPage(),
            ),
          );
          _loadNotes();
        },
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: !_loaded ? _buildInitializingView() :
        _notesFailed ? _buildNotesFailedView() :
        _notes.isEmpty && !_notesExist ? _buildEmptyNoteList() : _buildNoteList(),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search"
            ),
          ),
        ),
        SizedBox(height: 8),
        if(_notes.isEmpty)
          Center(
            child: Text("No notes match."),
          ),
        if(_notes.isNotEmpty)
          Expanded(
            child: ListView.separated(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                String title = _notes[index].title;
                String subtitle = _notes[index].getPreview();

                return ListTile(
                  title: Text(title),
                  subtitle: Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditorPage(note: _notes[index]),
                      ),
                    );
                    _loadNotes();
                  },
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  thickness: 2.0,
                );
              },
          ),
          ),
      ],
    );
  }

  Future<void> _loadNotes({String search = ''}) async {
    List<Note>? startingNotes = await _noteService.getAllNotes(noteSearch: search);
    if(startingNotes == null) {
      setState(() {
        _loaded = true;
        _notesFailed = true;
        _notes = [];
      });
    } else {
      setState(() {
        _loaded = true;
        _notesFailed = false;
        _notes = new List.from(startingNotes);
        _notesExist = true;
      });
    }
  }
}
