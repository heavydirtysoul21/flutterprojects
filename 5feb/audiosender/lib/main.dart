import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permissions_plugin/permissions_plugin.dart';

import 'screens/demolist_screen.dart';
import 'screens/file_recorder_page.dart';

// Run the app
void main() {
  runApp(new AudioSenderApp());
}

class _Page {
  const _Page({this.icon, this.text});
  final IconData icon;
  final String text;
}

//Set up list of pages for tab navigation
const List<_Page> _allPages = const <_Page>[
  // const _Page(icon: Icons.mic, text: 'RECORD'),

  const _Page(icon: Icons.list, text: 'Lists'),
  const _Page(icon: Icons.folder, text: 'FILES'),
];

class AudioSenderApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return new MaterialApp(
      title: 'SimpleFlutterAudioRecorder',
      theme: new ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: new HomePage(
        title: 'Simple Flutter Audio Recorder',
      ),
      debugShowCheckedModeBanner: false,
      routes: {'/recording_page': (ctx) => RecordingPage()},
    );
  }
}

class HomePage extends StatefulWidget {
  //HomePage constructor

  final String title;
  HomePage({Key key, this.title}) : super(key: key);
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  SnackBar errorSnackBar = new SnackBar(content: Text("Tapped button"));
  TabController _tabController;
  @override
  Widget build(BuildContext context) {
    Scaffold scaffold = Scaffold(
      appBar: new AppBar(
          actions: <Widget>[],
          // Set AppBar title
          title: new Text(widget.title),
          bottom: new TabBar(
            controller: _tabController,
            isScrollable: true,
            indicator: const UnderlineTabIndicator(),
            tabs: _allPages.map((_Page page) {
              return new Tab(text: page.text, icon: new Icon(page.icon));
            }).toList(),
          )),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          // new SafeArea(top: false, bottom: false, child: AudioRecorderScreen()),

          new SafeArea(
            top: false,
            bottom: false,
            child: Listsdemo(),
          ),
          new SafeArea(top: false, bottom: false, child: FileBrowserPage()),
        ],
      ),
    );

    return scaffold;
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: _allPages.length);
    _tabController.addListener(_onTabChange);
    requestPermissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChange() {}

  requestPermissions() async {
    Map<Permission, PermissionState> permission =
        await PermissionsPlugin.requestPermissions([
      Permission.RECORD_AUDIO,
      Permission.WRITE_EXTERNAL_STORAGE,
      Permission.READ_EXTERNAL_STORAGE
    ]);
    return permission;
  }
}
