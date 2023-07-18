import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';


class EditorPage extends StatefulWidget {
  const EditorPage({Key? key}) : super(key: key);

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {

  QuillController _controller = QuillController.basic();
  TextEditingController _titleController = new TextEditingController();

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
          onPressed: printContent,
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

  printContent() {
    print("PLAIN TEXT");
    print(_controller.document.getPlainText(0, _controller.document.length));
    print("JSON");
    print(_controller.document.toDelta().toJson());
  }
}
