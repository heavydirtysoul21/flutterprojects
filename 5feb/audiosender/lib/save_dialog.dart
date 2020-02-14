import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class SaveDialog extends StatefulWidget {
  // The SaveDialog will take the [defaultAudioFile] as input and rename it
  // with a new filename based on [dialogText] if the user presses the "Save" button.
  // If [doLookupLargestIndex] is true, the default new file filename will be
  // automatically numbered based on files already in the appDocumentsDirectory.

  final File defaultAudioFile;
  final String dialogText;
  final bool doLookupLargestIndex;
  String newFilePath;
  SaveDialog({
    Key key,
    this.defaultAudioFile,
    this.dialogText = "Save file?",
    this.doLookupLargestIndex = true,
  }) : super(key: key);

  @override
  SaveDialogState createState() {
    SaveDialogState sDialog =
        SaveDialogState(defaultAudioFile, dialogText, doLookupLargestIndex);
    // Pass along the newFilePath obtained by SaveDialogState
    newFilePath = sDialog.newFilePath;
    return sDialog;
  }
}

class SaveDialogState extends State<SaveDialog> {
  String fileRenametxt;
  File defaultAudioFile;
  String dialogText;
  String newFilePath;
  TextEditingController _textController;
  bool doLookupLargestIndex;

  SaveDialogState(
      this.defaultAudioFile, this.dialogText, this.doLookupLargestIndex);

  @override
  initState() {
    super.initState();
    initTextController(true);
    _read();
  }

  @override
  dispose() {
    super.dispose();
    this._textController.dispose();
  }

  initTextController(bool doRebuildTextController) {
    if (doLookupLargestIndex) {
      initTextControllerWithLargestFileName(
          doRebuildTextController: doRebuildTextController);
    } else {
      initTextControllerWithCurrentFileName(
          doRebuildTextController: doRebuildTextController);
    }
  }

  _read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'txtkey';
    final txtvalue = prefs.getString(key) ?? 'Audio';
    print('read: $txtvalue');
    fileRenametxt = txtvalue;
  }

  Future<Null> initTextControllerWithCurrentFileName(
      {bool doRebuildTextController = true}) async {
    setState(() {
      this.newFilePath = defaultAudioFile.path;
      String defaultFileName =
          defaultAudioFile.path.split('/').last.split('.').first;
      if (doRebuildTextController) {
        this._textController = TextEditingController(text: defaultFileName);
      }
    });
  }

  Future<Null> initTextControllerWithLargestFileName(
      {bool doRebuildTextController = true}) async {
    Directory directory = await getApplicationDocumentsDirectory();

    String fname = fileRenametxt;

    // await _largestNumberedFilename();
    print("new $fname");
    String fpath = p.join(directory.path, fname + '.m4a');
    setState(() {
      this.newFilePath = fpath;
      if (doRebuildTextController) {
        this._textController = TextEditingController(text: fname);
      }
    });
  }

  void _renameAudioFile() async {
    newFilePath =
        p.join(p.dirname(defaultAudioFile.path), _textController.text + '.m4a');
    if (defaultAudioFile != null && newFilePath != null) {
      try {
        print("New file path $newFilePath");
        defaultAudioFile.rename(newFilePath);
        // Do not call initTextControllerState here!
      } catch (e) {
        if (await defaultAudioFile.exists()) {
          //FIXME: add file already exists warning
          print("File $defaultAudioFile already exists");
        } else {
          print('Error renaming file');
        }
      }
    } else {
      print("File $defaultAudioFile is null!");
    }
    // Close the save dialog and return a newFilePath which can be passed to
    // the Widget that called showDialog() <Does this really work>?
    Navigator.pop(context, File(newFilePath)); // what does this do?
  }

  @override
  Widget build(BuildContext context) {
    //FIXME: This should be done with a SharedAudioFile context

    print("Building");
    return AlertDialog(
        title: Text(dialogText),
        content: TextFormField(
          controller: _textController,
          decoration: InputDecoration(
            labelText: "Filename:",
            hintText: "Enter a filename with no extension.",
          ),
          validator: (value) {
            if (value.isEmpty) {
              return "Please enter a filename";
            }
          },
        ),
        actions: <Widget>[
          new FlatButton(
            child: const Text("SAVE"),
            onPressed: () => _renameAudioFile(),
          ),
          new FlatButton(
            child: const Text("CANCEL"),
            onPressed: () => Navigator.pop(
                context, null), //Pass null to the Widget that called showDialog
          )
        ]);
  }
}
