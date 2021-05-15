import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_storage/get_storage.dart';

class SecodScreen extends StatelessWidget {
  List list = GetStorage().read('ids');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) => ListTile(
            trailing: IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () {
                FlutterDownloader.open(taskId: list[index]);
              },
            ),
            title: Text(
              list[index].toString(),
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
