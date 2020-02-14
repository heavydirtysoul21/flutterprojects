import 'dart:io';

import 'package:audiosender/widgets/audio_play_widget.dart';
import 'package:flutter/material.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:path/path.dart' as p;

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permissions_plugin/permissions_plugin.dart';
import '../save_dialog.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorderScreen extends StatefulWidget {
  AudioRecorderScreen({Key key}) : super(key: key);

  @override
  AudioRecorderScreenState createState() {
    return new AudioRecorderScreenState();
  }
}

class AudioRecorderScreenState extends State<AudioRecorderScreen> {
  Recording _recording;
  bool _isRecording = false;
  bool _doQuerySave = false;

  String tempFilename = "Recording";
  File defaultAudioFile;

  stopRecording() async {
    var recording = await AudioRecorder.stop();
    bool isRecording = await AudioRecorder.isRecording;

    Directory docDir = await getApplicationDocumentsDirectory();

    setState(() {
      _isRecording = isRecording;
      _doQuerySave = true;
      defaultAudioFile = File(p.join(docDir.path, this.tempFilename + '.m4a'));
    });
  }

  startRecording() async {
    try {
      Directory docDir = await getApplicationDocumentsDirectory();
      String newFilePath = p.join(docDir.path, this.tempFilename);
      File tempAudioFile = File(newFilePath + '.m4a');
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("Recording."),
        duration: Duration(milliseconds: 1400),
      ));
      if (await tempAudioFile.exists()) {
        await tempAudioFile.delete();
      }
      if (await AudioRecorder.hasPermissions) {
        await AudioRecorder.start(
            path: newFilePath, audioOutputFormat: AudioOutputFormat.AAC);
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text("Error! Audio recorder lacks permissions.")));
        requestPermissions();
      }
      bool isRecording = await AudioRecorder.isRecording;
      setState(() {
        _recording = new Recording(duration: new Duration(), path: newFilePath);
        _isRecording = isRecording;
        defaultAudioFile = tempAudioFile;
      });
    } catch (e) {
      print(e);
    }
  }

  _deleteCurrentFile() async {
    if (defaultAudioFile != null) {
      setState(() {
        _isRecording = false;
        _doQuerySave = false;
        defaultAudioFile.delete();
      });
    } else {
      print("Error! defaultAudioFile is $defaultAudioFile");
    }
    Navigator.pop(context);
  }

  AlertDialog _deleteFileDialogBuilder() {
    return AlertDialog(
        title: Text("Delete current recording?"),
        actions: <Widget>[
          new FlatButton(
            child: const Text("YES"),
            onPressed: () => _deleteCurrentFile(), //
          ),
          new FlatButton(
            child: const Text("NO"),
            onPressed: () => Navigator.pop(context),
          )
        ]);
  }

  requestPermissions() async {
    Map<Permission, PermissionState> permission =
        await PermissionsPlugin.requestPermissions([
      Permission.RECORD_AUDIO,
      Permission.WRITE_EXTERNAL_STORAGE,
      Permission.READ_EXTERNAL_STORAGE
    ]);
    return permission;
  }

  _showSaveDialog() async {
    File newFile = await showDialog(
        context: context,
        builder: (context) => SaveDialog(
              defaultAudioFile: defaultAudioFile,
            ));

    if (newFile != null) {
      String basename = p.basename(newFile.path);
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("Saved file $basename"),
        duration: Duration(milliseconds: 1400),
      ));

      setState(() {
        _isRecording = false;
        _doQuerySave = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: AudioRecorder.isRecording, builder: audioCardBuilder);
  }

  Widget audioCardBuilder(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.waiting:
        return Container();
      default:
        if (snapshot.hasError) {
          return new Text('Error: ${snapshot.error}');
        } else {
          bool isRecording = snapshot.data;
          _isRecording = isRecording;

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  height: 140,
                  child: _isRecording
                      ? SpinKitRipple(
                          color: Colors.redAccent,
                          size: 140,
                        )
                      : Container()),
              Container(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(children: [
                    _doQuerySave
                        ? Text(
                            "Delete",
                            textScaleFactor: 1.2,
                          )
                        : Container(),
                    Container(height: 12.0),
                    new FloatingActionButton(
                      child: _doQuerySave ? new Icon(Icons.cancel) : null,
                      disabledElevation: 0.0,
                      backgroundColor:
                          _doQuerySave ? Colors.blueAccent : Colors.transparent,
                      onPressed: _doQuerySave
                          ? (() => showDialog(
                                context: context,
                                builder: (context) =>
                                    _deleteFileDialogBuilder(),
                              ))
                          : null,
                      mini: true,
                    ),
                  ]),
                  Container(width: 38.0),
                  Column(children: [
                    _isRecording
                        ? new Text('Stop', textScaleFactor: 1.5)
                        : new Text('Record', textScaleFactor: 1.5),
                    Container(height: 12.0),
                    new FloatingActionButton(
                        child: _isRecording
                            ? new Icon(Icons.stop, size: 36.0)
                            : new Icon(Icons.mic, size: 36.0),
                        disabledElevation: 0.0,
                        onPressed:
                            // _isRecording ? stopRecording : startRecording,
                            () {
                          if (_isRecording) {
                            stopRecording();
                          } else {
                            if (_doQuerySave)
                              Scaffold.of(context).showSnackBar(new SnackBar(
                                content: new Text("Save or Delete first."),
                                duration: Duration(milliseconds: 1400),
                              ));
                            else {
                              startRecording();
                            }
                          }
                        }),
                  ]),
                  Container(width: 38.0),
                  Column(children: [
                    _doQuerySave
                        ? Text(
                            "Save",
                            textScaleFactor: 1.2,
                          )
                        : Container(),
                    Container(height: 12.0),
                    FloatingActionButton(
                      child: _doQuerySave
                          ? new Icon(Icons.check_circle)
                          : Container(),
                      backgroundColor:
                          _doQuerySave ? Colors.blueAccent : Colors.transparent,
                      disabledElevation: 0.0,
                      mini: true,
                      onPressed: _doQuerySave ? _showSaveDialog : null,
                    ),
                  ]),
                ],
              ),
              Container(
                height: 20,
              ),
              FloatingActionButton(
                child: _doQuerySave
                    ? Icon(
                        Icons.play_arrow,
                        size: 36,
                      )
                    : Container(),
                backgroundColor:
                    _doQuerySave ? Colors.blueAccent : Colors.transparent,
                disabledElevation: 0.0,
                onPressed: _doQuerySave
                    ? () {
                        showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return AudioPlayBar(file: defaultAudioFile);
                            });
                      }
                    : null,
              ),
            ],
          );
        }
    }
  }
}
