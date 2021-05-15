import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'sec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int progress = 0;
  String taskCompletedId;
  ReceivePort _receivePort = ReceivePort();

  static downloadingCallback(id, status, progress) {
    ///Looking up for a send port
    SendPort sendPort = IsolateNameServer.lookupPortByName("downloading");

    ///ssending the data
    sendPort.send([id, status, progress]);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ///register a send port for the other isolates
    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, "downloading");

    ///Listening for the data is comming other isolataes
    _receivePort.listen((message) {
      setState(() {
        progress = message[2];
      });

      //  print(progress);
    });

    FlutterDownloader.registerCallback(downloadingCallback);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                await FlutterDownloader.open(taskId: taskCompletedId);
              }),
          IconButton(
              icon: Icon(Icons.ac_unit),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SecodScreen(),
                    ));
              }),
        ],
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "$progress",
              style: TextStyle(fontSize: 40),
            ),
            SizedBox(
              height: 60,
            ),
            FlatButton(
              child: Text("Start Downloading"),
              color: Colors.redAccent,
              textColor: Colors.white,
              onPressed: () async {
                final status = await Permission.storage.request();
                bool isDirExist;
                int checkNum = 0;
                if (status.isGranted) {
                  final externalDir = await getExternalStorageDirectory();

                  String newPath = "";
                  List<String> paths = externalDir.path.split("/");
                  print(paths);
                  for (int x = 1; x < paths.length; x++) {
                    String folder = paths[x];
                    if (folder != "Android") {
                      newPath += "/" + folder;
                    } else {
                      break;
                    }
                  }
                  newPath = newPath + "/AnasDowloads";

                  isDirExist = await Directory(newPath).exists();
                  try {
                    if (isDirExist == false) {
                      await Directory(newPath).create(recursive: true);
                    }
                  } catch (e) {
                    checkNum = 1;

                    print('some errro occured y broooo');
                  }

                  final id = await FlutterDownloader.enqueue(
                    url:
                        "https://firebasestorage.googleapis.com/v0/b/yksh-nkhls.appspot.com/o/WhatsApp_Video_2021-03-05_at_2.22.44_AM.mp4?alt=media&token=a5bf37a1-f046-4288-a57a-8956bb4158ca",
                    savedDir: checkNum == 1 ? externalDir.path : newPath,
                    fileName: "re.mp4",
                    showNotification: true,
                    openFileFromNotification: true,
                  );
                  var box = GetStorage();

                  if (box.hasData('ids')) {
                    List _list = GetStorage().read('ids');
                    _list.add(id);
                    GetStorage().write('ids', _list);
                  } else {
                    GetStorage().write('ids', [id]);
                  }

                  setState(() {
                    taskCompletedId = id;
                  });
                  print('this is the task id = $id');
                } else {
                  print("Permission deined");
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
