import 'dart:io';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import '../image_resizer.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<StatefulWidget> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> with AutomaticKeepAliveClientMixin {
  final ImageResizer imageResizer = ImageResizer();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Expanded(child: Container(padding: const EdgeInsets.fromLTRB(4, 4, 4, 4), child: const Text('Image'))),
              Container(
                padding: const EdgeInsets.only(top: 14, bottom: 10, right: 10),
                child: TextButton(
                    style: const ButtonStyle(
                        foregroundColor: MaterialStatePropertyAll(Colors.black87),
                        backgroundColor: MaterialStatePropertyAll(Colors.white),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black45),
                            borderRadius: BorderRadius.all(Radius.circular(15))))),
                    onPressed: clearButtonPressed,
                    child: const Text('clear')),
              )
            ],
          ),
          Expanded(
              child: DropTarget(
                  onDragDone: (details) => onDropDone(details),
                  child: Container(
                      color: Colors.white,
                      child: ListView.separated(
                          itemBuilder: (context, index) => buildList(context, index),
                          separatorBuilder: (context, index) => buildSeparator(context, index),
                          itemCount: imageResizer.fileList.length))))
        ]));
  }

  void clearButtonPressed() {
    imageResizer.fileList.clear();
    setState(() {});
  }

  Widget buildList(BuildContext context, int index) {
    return Container(
        height: 20,
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
        child: Text(imageResizer.fileList[index],
            maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)));
  }

  Widget buildSeparator(BuildContext context, int index) {
    return const Divider(height: 0);
  }

  void onDropDone(DropDoneDetails details) {
    for (XFile xfile in details.files) {
      print(xfile.path);
      FileSystemEntityType type = FileSystemEntity.typeSync(xfile.path);
      if (type == FileSystemEntityType.file) {
        imageResizer.fileList.add(xfile.path);
      } else if (type == FileSystemEntityType.directory) {}
      setState(() {});
      print(type.toString());
    }
  }

  @override
  bool get wantKeepAlive => true;
}
