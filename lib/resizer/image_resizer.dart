import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_resizer/utility/profile_manager.dart';
import '../model/image_resize_config.dart';
import 'resizer_thread.dart';

class ImageResizer with ChangeNotifier {
  List<ResizerThread> availableThreads = [];
  static final ImageResizer _singleton = ImageResizer._private();
  List<File> fileList = [];
  ImageResizeConfig config = ImageResizeConfig();
  Completer<void>? availableThreadCompleter;
  int processCount = 0;
  bool processing = false;
  int threadCount = Platform.numberOfProcessors;

  ImageResizer._private() {
    ProfileManager().getSetting(SettingKey.threads).then((value) {
      if (value == null) {
        return;
      }

      try {
        threadCount = int.parse(value);
      } catch (e) {
        return;
      }
    });
  }

  Future<void> initThread(int count) async {
    ResizerThread.config = config;
    print('initing');
    List<Future> threadFutures = [];
    for (int i = 0; i < count; i++) {
      print('create $i');
      ResizerThread thread = ResizerThread();
      threadFutures.add(thread.initIsolate());
      availableThreads.add(thread);
    }

    await Future.wait(threadFutures);
    print('init successed');
  }

  void checkDestinationPath() {
    // TODO: show error when dst is empty
    Directory dst = Directory(config.destination);
    if (!dst.existsSync()) {
      dst.createSync(recursive: true);
    }
  }

  factory ImageResizer() {
    return _singleton;
  }

  Future<void> resize() async {
    if (processing) {
      return;
    }

    processing = true;
    processCount = 0;
    await initThread(threadCount);
    checkDestinationPath();

    for (int i = 0; i < fileList.length; i++) {
      File file = fileList[i];
      print('get thread $i');
      ResizerThread thread = await getAvailableThread();
      print('get thread succ');
      thread.resize(file).then((value) {
        processCount++;
        notifyListeners();
        availableThreads.add(thread);
        availableThreadCompleter?.complete();

        if (processCount == fileList.length) {
          processing = false;
          availableThreads.clear();
        }
      });
    }
  }

  Future<ResizerThread> getAvailableThread() async {
    if (availableThreads.isNotEmpty) {
      return availableThreads.removeAt(0);
    }

    assert(availableThreadCompleter == null);
    print('wait thread');
    availableThreadCompleter = Completer();
    await availableThreadCompleter!.future;
    availableThreadCompleter = null;

    return availableThreads.removeAt(0);
  }
}
