import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_resizer/utility/profile_manager.dart';
import '../model/image_resize_config.dart';
import 'resizer_thread.dart';

class ImageResizer with ChangeNotifier {
  final List<ResizerThread> _availableThreads = [];
  static final ImageResizer _singleton = ImageResizer._private();
  List<File> fileList = [];
  ImageResizeConfig config = ImageResizeConfig();
  Completer<void>? _availableThreadCompleter;
  int processCount = 0;
  bool _processing = false;
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
      _availableThreads.add(thread);
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
    if (_processing) {
      return;
    }

    _processing = true;
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
        _availableThreads.add(thread);
        _availableThreadCompleter?.complete();

        if (processCount == fileList.length) {
          _processing = false;
          _availableThreads.clear();
        }
      });
    }
  }

  Future<ResizerThread> getAvailableThread() async {
    if (_availableThreads.isNotEmpty) {
      return _availableThreads.removeAt(0);
    }

    assert(_availableThreadCompleter == null);
    print('wait thread');
    _availableThreadCompleter = Completer();
    await _availableThreadCompleter!.future;
    _availableThreadCompleter = null;

    return _availableThreads.removeAt(0);
  }
}
