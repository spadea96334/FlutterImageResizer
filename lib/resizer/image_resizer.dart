import 'dart:async';
import 'dart:io';
import 'package:image_resizer/utility/event_notifier.dart';
import 'package:image_resizer/utility/setting_manager.dart';
import '../model/image_resize_config.dart';
import 'resizer_thread.dart';

class ImageResizer {
  final List<ResizerThread> _idleThreads = [];
  static final ImageResizer _singleton = ImageResizer._private();
  List<File> fileList = [];
  ImageResizeConfig config = ImageResizeConfig();
  EventNotifier configNotifier = EventNotifier();
  EventNotifier progressNotifier = EventNotifier();
  Completer<void>? _idleThreadCompleter;
  int processCount = 0;
  bool _processing = false;
  int threadCount = Platform.numberOfProcessors;

  ImageResizer._private();

  Future<void> loadThreadsSetting() async {
    String? value = await SettingManager().getSetting(SettingKey.threads);
    if (value == null) {
      threadCount = Platform.numberOfProcessors;
      return;
    }

    threadCount = int.tryParse(value) ?? Platform.numberOfProcessors;
  }

  Future<void> initThread(int count) async {
    ResizerThread.config = config;
    print('initing');
    List<Future> threadFutures = [];
    if (fileList.length < count) {
      count = fileList.length;
    }

    for (int i = 0; i < count; i++) {
      print('create $i');
      ResizerThread thread = ResizerThread();
      threadFutures.add(thread.initIsolate());
      _idleThreads.add(thread);
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
      ResizerThread thread = await getIdleThread();
      print('get thread succ');
      thread.resize(file).then((value) {
        processCount++;
        progressNotifier.emit();
        _idleThreads.add(thread);
        _idleThreadCompleter?.complete();

        if (processCount == fileList.length) {
          _processing = false;
          _idleThreads.clear();
        }
      });
    }
  }

  Future<ResizerThread> getIdleThread() async {
    if (_idleThreads.isNotEmpty) {
      return _idleThreads.removeAt(0);
    }

    assert(_idleThreadCompleter == null);
    print('wait thread');
    _idleThreadCompleter = Completer();
    await _idleThreadCompleter!.future;
    _idleThreadCompleter = null;

    return _idleThreads.removeAt(0);
  }

  void configChanged() {
    configNotifier.emit();
  }
}
