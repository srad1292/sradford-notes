import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';


class EditorPage extends StatefulWidget {
  const EditorPage({Key? key}) : super(key: key);

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {

  QuillController _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Expanded(
            child: Container(
                color: Colors.white,
                child: Column(
                  children: [
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
                )
            ),
          )

      ),

    );
  }
}
