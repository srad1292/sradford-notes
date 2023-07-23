import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sradford_notes/modules/import_export/import_export_service.dart';
import 'package:sradford_notes/modules/shared/class/result.dart';
import 'package:sradford_notes/modules/shared/enum/info_dialog_type.dart';
import 'package:sradford_notes/modules/shared/widgets/my_confirmation_dialog.dart';
import 'package:sradford_notes/modules/shared/widgets/my_info_dialog.dart';
import 'package:sradford_notes/utils/service_locator.dart';

import '../editor/editor-page.dart';
import 'enums/note_list_action.dart';
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
  late ImportExportService _importExportService;

  List<Note> _notes = [];
  List<bool> _selected = [];
  bool _loaded = false;
  bool _notesFailed = false;
  bool _notesExist = false;

  bool _isSelectionMode = false;

  int selectedCount = 0;

  @override
  void initState() {
    super.initState();
    _noteService = serviceLocator.get<NoteService>();
    _importExportService = serviceLocator.get<ImportExportService>();

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
        leading: _isSelectionMode ? IconButton(
          onPressed: _exitSelectionMode,
          icon: Icon(Icons.arrow_back)
        ) : null,
        title: Text(
          _isSelectionMode ? "$selectedCount Selected" : "Notes"
        ),
        centerTitle: true,
        actions: [
          _buildActionsMenu()
        ],
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

  Widget _buildActionsMenu() {
    return PopupMenuButton(
      onSelected: (value) async {
        switch (value) {
          case NoteListAction.Select:
            return _enterSelectionMode();
          case NoteListAction.Import:
          // handle import
          case NoteListAction.Export:
            return _exportSelected();
          case NoteListAction.Delete:
            return _deleteSelected();
          default:
            throw UnimplementedError();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if(!_isSelectionMode)
          PopupMenuItem<String>(
            value: NoteListAction.Select,
            child: Text(NoteListAction.Select),
          ),
        if(!_isSelectionMode)
          PopupMenuItem<String>(
            value: NoteListAction.Import,
            child: Text(NoteListAction.Import),
          ),
        if(_isSelectionMode)
          PopupMenuItem<String>(
            value: NoteListAction.Export,
            child: Text(NoteListAction.Export),
          ),
        if(_isSelectionMode)
          PopupMenuItem<String>(
            value: NoteListAction.Delete,
            child: Text(NoteListAction.Delete, style: TextStyle(color: Colors.redAccent),),
          ),
      ],
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
            enabled: !_isSelectionMode,
            decoration: InputDecoration(
              hintText: "Search"
            ),
          ),
        ),
        SizedBox(height: 8),

        if(_isSelectionMode)
          GestureDetector(
            onTap: quickSelectionToggle,
            child: Text(
              selectedCount == 0 ? "Select All" : "Deselect All",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500
              )
            ),
          ),

        if(_isSelectionMode)
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
                if(_isSelectionMode) {
                  print("Is $index selected: ${_selected[index]}");
                }
                return ListTile(
                  leading: _isSelectionMode ?
                    Icon(
                      _selected[index] ? Icons.circle : Icons.circle_outlined,
                      color: _selected[index] ? Colors.lightBlueAccent : Colors.black45
                    )
                    : null,
                  title: Text(title),
                  subtitle: Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () async {
                    if(_isSelectionMode) {
                      setState(() {
                        if(_selected[index] == true) {
                          selectedCount--;
                        } else {
                          selectedCount++;
                        }
                        _selected[index] = !_selected[index];
                      });
                    } else {
                      _goToNote(_notes[index]);
                    }

                  },
                  onLongPress: () {
                    if(_isSelectionMode) {
                      _exitSelectionMode();
                    } else {
                      _enterSelectionMode();
                    }
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

  void quickSelectionToggle() {
    setState(() {
      _selected.forEachIndexed((index, element) {
        _selected[index] = selectedCount == 0;
      });
      selectedCount = selectedCount == 0 ? _selected.length : 0;
    });
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

  void _goToNote(Note note) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditorPage(note: note),
      ),
    );
    _loadNotes();
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selected = new List.generate(_notes.length, (index) => false);
      selectedCount = 0;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selected = [];
      selectedCount = 0;
    });
  }

  Future<void> _deleteSelected() async {
    if(selectedCount == 0) {
      showMyInfoDialog(context: context, dialogType: InfoDialogType.Info, body: "You must select at least one note first.");
      return;
    }

    bool confirmDelete = await showMyConfirmationDialog(context: context, body: "Are you sure you want to delete these notes?");
    if(confirmDelete != true) {
      return;
    }

    try {
      List<int> noteIds = [];
      _selected.forEachIndexed((index, element) {
        if(element == true) {
          noteIds.add(_notes[index].noteId!);
        }
      });
      int deletedCount = await _noteService.bulkDeleteNotes(noteIds: noteIds);
      if(deletedCount == 0) {
        showMyInfoDialog(context: context, dialogType: InfoDialogType.Info, body: "No notes deleted.");
      } else {
        _exitSelectionMode();
        _loadNotes(search: _searchController.text);
      }
    } catch(e) {
      showMyInfoDialog(context: context, dialogType: InfoDialogType.Error, body: "Bulk delete failed.");
    }
  }

  Future<void> _exportSelected() async {
    if(selectedCount == 0) {
      showMyInfoDialog(context: context, dialogType: InfoDialogType.Info, body: "You must select at least one note first.");
      return;
    }

    try {
      List<int> noteIds = [];
      _selected.forEachIndexed((index, element) {
        if(element == true) {
          noteIds.add(_notes[index].noteId!);
        }
      });

      Result exportResult = await _importExportService.ExportNotes(context: context, noteIds: noteIds);
      if(exportResult.succeeded == false && exportResult.showedDialog == false) {
        showMyInfoDialog(context: context, dialogType: InfoDialogType.Error, body: "Failed to export notes");
      } else if(exportResult.succeeded) {
        showMyInfoDialog(context: context, dialogType: InfoDialogType.Info, body: "Exported ${noteIds.length} notes");
      }
    } catch(e) {
      print("Note List Export Failed");
      print(e.toString());
      showMyInfoDialog(context: context, dialogType: InfoDialogType.Error, body: "Unexpected error occurred while exporting notes");
    }


  }


}
