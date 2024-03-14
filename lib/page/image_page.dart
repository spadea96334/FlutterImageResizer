import 'dart:io';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import '../resizer/image_resizer.dart';
import 'package:path/path.dart' as p;

class ImagePage extends StatefulWidget {
  const ImagePage({super.key, required this.toOptionsPage});

  final Function() toOptionsPage;

  @override
  State<StatefulWidget> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  final ImageResizer _imageResizer = ImageResizer();

  @override
  Widget build(BuildContext context) {
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
                          itemCount: _imageResizer.fileList.length)))),
          Row(children: [
            Text('Total : ${_imageResizer.fileList.length}'),
            const Expanded(child: SizedBox()),
            Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5, right: 5),
                child: TextButton(
                    onPressed: nextButtonPressed,
                    style: const ButtonStyle(
                        foregroundColor: MaterialStatePropertyAll(Colors.black87),
                        backgroundColor: MaterialStatePropertyAll(Colors.white),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black45),
                            borderRadius: BorderRadius.all(Radius.circular(15))))),
                    child: const Text('Next')))
          ])
        ]));
  }

  void nextButtonPressed() {
    widget.toOptionsPage();
  }

  void clearButtonPressed() {
    _imageResizer.fileList.clear();
    setState(() {});
  }

  Widget buildList(BuildContext context, int index) {
    return Container(
        height: 20,
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
        child: Text(_imageResizer.fileList[index].path,
            maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)));
  }

  Widget buildSeparator(BuildContext context, int index) {
    return const Divider(height: 0);
  }

  void onDropDone(DropDoneDetails details) {
    for (XFile xfile in details.files) {
      FileSystemEntityType type = FileSystemEntity.typeSync(xfile.path);
      if (type == FileSystemEntityType.file) {
        addFileIfAccept(xfile.path);
      } else if (type == FileSystemEntityType.directory) {
        getDictionaryFile(xfile.path);
      }
    }

    setState(() {});
  }

  void addFileIfAccept(String path) {
    const List<String> extList = ['jpg', 'jpeg', 'png', 'webp', 'bmp', 'tif', 'tiff'];
    String ext = p.extension(path);

    if (extList.contains(ext)) {
      _imageResizer.fileList.add(File(path));
    }
  }

  void getDictionaryFile(String path) {
    Directory directory = Directory(path);
    List<FileSystemEntity> entities = directory.listSync(recursive: true);
    for (FileSystemEntity entity in entities) {
      FileSystemEntityType type = FileSystemEntity.typeSync(entity.path);
      if (type == FileSystemEntityType.file) {
        addFileIfAccept(entity.path);
      } else if (type == FileSystemEntityType.directory) {
        getDictionaryFile(entity.path);
      }
    }
  }
}
