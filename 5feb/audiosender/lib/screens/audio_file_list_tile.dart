import 'dart:io';
import 'package:audiosender/widgets/audio_play_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';

class AudioFileListTile extends StatefulWidget {
  final FileSystemEntity file;
  AudioFileListTile({Key key, this.file}) : super(key: key);

  @override
  AudioFileListTileState createState() {
    return new AudioFileListTileState(file);
  }
}

class AudioFileListTileState extends State<AudioFileListTile> {
  FileSystemEntity file;
  String filePath;
  String fileName;

  @override
  AudioFileListTileState(FileSystemEntity file) {
    this.file = file;
    initFileAttributes();
  }

  initFileAttributes() {
    // Init some convenience variables
    this.filePath = file.path;
    this.fileName = this.filePath.split("/").last.split('.').first;
    print("New " + fileName);
  }

  void postRqst() async {
    final uploader = FlutterUploader();
    final taskId = await uploader.enqueue(
        url: "https://heavydirtysoul21.pythonanywhere.com/myapp/", //required: url to upload to
        files: [
          FileItem(filename: '', savedDir: this.file.path, fieldname: "file")
        ], // required: list of files that you want to upload
        method: UploadMethod.POST, // HTTP method  (POST or PUT or PATCH)
        headers: {"apikey": "api_123456", "userkey": "userkey_123456"},
        data: {
          "name": "john",
          "result": "${file.path}"
        }, // any data you want to send in upload request
        showNotification:
            false, // send local notification (android only) for upload status
        tag: "upload 1");
       // unique tag for upload task
  }

  _deleteFile(File file) {
    // Delete a file and rebuild this widget parent!
    setState(() => file.deleteSync());
    print("Deleted file $fileName");
    Navigator.pop(context);
  }

  AlertDialog _openQueryDeleteDialog() {
    return AlertDialog(
        title: Text("Delete"),
        content: Text("$fileName ?"),
        actions: <Widget>[
          new FlatButton(
            child: const Text("YES"),
            onPressed: () {
              _deleteFile(this.file);
            },
          ),
          new FlatButton(
            child: const Text("NO"),
            onPressed: () => Navigator.pop(context),
          )
        ]);
  }

  Row createTrailingButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            onSelected: (value) {},
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                      value: 'Rename',
                      child: ListTile(
                          leading: Icon(Icons.send),
                          title: Text('Send'),
                          onTap: () {
                            postRqst();
                          })),
                  PopupMenuDivider(),
                  PopupMenuItem<String>(
                      value: 'Delete',
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Delete'),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (_) => _openQueryDeleteDialog(),
                          );
                          setState(() {});
                        },
                      ))
                ])
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!file.existsSync()) {
      return Container(width: 0.0, height: 0.0);
    }
    return new ListTile(
        title: new Text(fileName),
        dense: false,
        leading: Icon(Icons.play_circle_outline),
        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
        trailing: createTrailingButtons(),
        onTap: () {
          showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return AudioPlayBar(file: file);
              });
        });
  }
}
