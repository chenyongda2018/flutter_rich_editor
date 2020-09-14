import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:notus/notus.dart';
import 'package:quill_delta/quill_delta.dart';

import 'rich_editor/widgets/controller.dart';
import 'rich_editor/widgets/editor.dart';
import 'rich_editor/widgets/mode.dart';
import 'rich_editor/widgets/scaffold.dart';

class RichTextEditPage extends StatefulWidget {
  @override
  _RichTextEditPageState createState() => _RichTextEditPageState();
}

class _RichTextEditPageState extends State<RichTextEditPage> {
  ZefyrController _controller;
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _loadDocument().then((document) {
      setState(() {
        _controller = ZefyrController(document);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = (_controller == null)
        ? Center(child: CircularProgressIndicator())
        : ZefyrScaffold(
            child: ZefyrEditor(
              padding: EdgeInsets.all(16),
              controller: _controller,
              focusNode: _focusNode,
              mode: ZefyrMode.edit,
//        imageDelegate: MyAppZefyrImageDelegate(),
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: Text("Editor page"),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.save),
              onPressed: () => _saveDocument(context),
            ),
          )
        ],
      ),
      body: body,
    );
  }

  Future<NotusDocument> _loadDocument() async {
    final file = File(Directory.systemTemp.path + "/quick_start.json");
    if (await file.exists()) {
      final contents = await file.readAsString();
      return NotusDocument.fromJson(jsonDecode(contents));
    }
    final Delta delta = Delta()..insert("\n");
    return NotusDocument.fromDelta(delta);
  }

  void _saveDocument(BuildContext context) {
    // Notus documents can be easily serialized to JSON by passing to
    // `jsonEncode` directly
    final contents = jsonEncode(_controller.document);
    print(contents);
    // For this example we save our document to a temporary file.
    final file = File(Directory.systemTemp.path + "/quick_start.json");
    print(file.path);
    // And show a snack bar on success.
    file.writeAsString(contents).then((_) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Saved.")));
    });
  }
}
