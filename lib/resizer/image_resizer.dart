import 'dart:async';
import 'dart:io';
import 'package:image_resizer/utility/event_notifier.dart';
import 'package:image_resizer/utility/setting_manager.dart';
import '../model/image_resize_config.dart';
import 'resizer_thread.dart';

class ImageResizer {
  static final ImageResizer _singleton = ImageResizer._private();

  List<File> fileList = [];
  ImageResizeConfig config = ImageResizeConfig();
  EventNotifier configNotifier = EventNotifier();
  EventNotifier progressNotifier = EventNotifier();
  int processCount = 0;
  bool get initFailed => _initFailed;
  bool get processing => _processing;
  int threadCount = Platform.numberOfProcessors;

  final List<ResizerThread> _idleThreads = [];
  Completer<void>? _idleThreadCompleter;
  bool _processing = false;
  bool _initFailed = false;

  ImageResizer._private();

  Future<void> loadThreadsSetting() async {
    String? value = await SettingManager().getSetting(SettingKey.threads);
    if (value == null) {
      threadCount = Platform.numberOfProcessors;
      return;
    }

    threadCount = int.tryParse(value) ?? Platform.numberOfProcessors;
  }

  Future<bool> initThread(int count) async {
    ResizerThread.config = config;
    List<Future> threadFutures = [];
    if (fileList.length < count) {
      count = fileList.length;
    }

    for (int i = 0; i < count; i++) {
      ResizerThread thread = ResizerThread();
      threadFutures.add(thread.init());
      _idleThreads.add(thread);
    }

    await Future.wait(threadFutures);

    for (ResizerThread thread in _idleThreads) {
      if (thread.initFailed) {
        return false;
      }
    }

    return true;
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

    _initFailed = false;
    _processing = true;
    processCount = 0;

    if (!await initThread(threadCount)) {
      _initFailed = true;
      progressNotifier.emit();

      return;
    }

    checkDestinationPath();

    for (int i = 0; i < fileList.length; i++) {
      File file = fileList[i];
      ResizerThread thread = await getIdleThread();
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
    _idleThreadCompleter = Completer();
    await _idleThreadCompleter!.future;
    _idleThreadCompleter = null;

    return _idleThreads.removeAt(0);
  }

  void configChanged() {
    configNotifier.emit();
  }
}
