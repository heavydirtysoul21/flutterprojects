import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import '../listsdemo.dart';
import 'audio_recorder_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Listsdemo extends StatelessWidget {
  Listsdemo({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<News>>(
      future: fetchData(http.Client()),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);

        return snapshot.hasData
            ? NewsList(news: snapshot.data)
            : Center(
                child:
                    CircularProgressIndicator(backgroundColor: Colors.white));
      },
    );
  }
}

class NewsList extends StatefulWidget {
  final List<News> news;
  const NewsList({Key key, this.news}) : super(key: key);
  @override
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.news.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return ListTile(
              title: new Text('${widget.news[index].email}'),
              dense: false,
              leading: Icon(Icons.keyboard_voice),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
              onTap: () {
                Navigator.of(context).pushNamed('/recording_page',
                    arguments: widget.news[index].email);
                print(index);
              });
        });
  }
}

class RecordingPage extends StatefulWidget {
  @override
  _RecordingPageState createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Recording Page"),
        ),
        body: RecordingPageW());
  }
}

class RecordingPageW extends StatefulWidget {
  final List<News> news;
  RecordingPageW({this.news});
  @override
  _RecordingPageWState createState() => _RecordingPageWState();
}

class _RecordingPageWState extends State<RecordingPageW> {
  @override
  Widget build(BuildContext context) {
    final textIndex = ModalRoute.of(context).settings.arguments as String;
    _save() async {
      final prefs = await SharedPreferences.getInstance();
      final key = 'txtkey';
      final value = textIndex;
      prefs.setString(key, value);
      print('saved $value');
    }

    _save();
    return SingleChildScrollView(
      child: Column(children: <Widget>[
        
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Center(
            child: Text(
              textIndex,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
        Container(height: MediaQuery.of(context).size.height * 0.5, child: AudioRecorderScreen())
      ]),
    );
  }
}
