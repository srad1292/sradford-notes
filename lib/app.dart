import 'package:flutter/material.dart';
import 'package:sradford_notes/modules/note/note_list_page.dart';
import 'package:sradford_notes/utils/style/app_theme.dart';


class SradfordNotesApp extends StatefulWidget {
  @override
  _SradfordNotesAppState createState() => _SradfordNotesAppState();
}

class _SradfordNotesAppState extends State<SradfordNotesApp> {

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          return OrientationBuilder(
              builder: (context, orientation) {
                return MaterialApp(
                  title: 'Sradford Notes',
                  theme: AppTheme.lightTheme,
                  home: NoteListPage(),
                );
              }
          );
        }
    );
  }
}
