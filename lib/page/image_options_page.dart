import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image_resizer/utility/setting_manager.dart';
import 'package:image_resizer/widget/options_dropdown_widget.dart';
import 'package:image_resizer/widget/tooltip_button.dart';
import '../model/image_resize_config.dart';
import '../resizer/image_resizer.dart';
import '../widget/options_input_widget.dart';
import '../widget/profile_name_input_dialog.dart';
import '../widget/progress_dialog.dart';

class ImageOptionsPage extends StatefulWidget {
  const ImageOptionsPage({super.key});

  @override
  State<StatefulWidget> createState() => _ImageOptionsPageState();
}

class _ImageOptionsPageState extends State<ImageOptionsPage> {
  final ImageResizer _imageResizer = ImageResizer();
  final SettingManager _profileManager = SettingManager();
  int _currentProfileIndex = 0;
  final List<DropdownMenuItem<ImageFormat>> _formatItems = [];
  final List<DropdownMenuItem<ResizePolicy>> _policyItems = [];
  final List<DropdownMenuItem<Interpolation>> _filterItems = [];
  final List<DropdownMenuItem<FileTarget>> _fileTargetItems = [];

  @override
  void initState() {
    super.initState();

    for (var element in ImageFormat.values) {
      _formatItems.add(DropdownMenuItem(value: element, child: Text(element.name)));
    }

    for (var element in ResizePolicy.values) {
      _policyItems.add(DropdownMenuItem(value: element, child: Text(element.name)));
    }

    for (var element in Interpolation.values) {
      _filterItems.add(DropdownMenuItem(value: element, child: Text(element.name)));
    }

    for (var element in FileTarget.values) {
      _fileTargetItems.add(DropdownMenuItem(value: element, child: Text(element.name)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<ImageResizeConfig>> profileItems = [];
    for (var element in _profileManager.profiles) {
      profileItems.add(DropdownMenuItem<ImageResizeConfig>(value: element, child: Text(element.name)));
    }
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.only(top: 10, left: 5),
              child: const Text('Options', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
          const Padding(padding: EdgeInsets.only(left: 5, right: 5), child: Divider(height: 1, color: Colors.black)),
          Row(children: [
            OptionDropdownWidget<ImageResizeConfig>(
                title: 'Profile:',
                value: profileItems[_currentProfileIndex].value!,
                items: profileItems,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  _currentProfileIndex = _profileManager.profiles.indexOf(value);
                  _imageResizer.config = value.copy();
                  setState(() {});
                }),
            TooltipButton(icon: const Icon(Icons.add), message: 'add', onPressed: addProfile),
            TooltipButton(icon: const Icon(Icons.save_as), message: 'save', onPressed: saveProfile),
            TooltipButton(icon: const Icon(Icons.delete_forever), message: 'delete', onPressed: deleteProfile)
          ]),
          const Padding(padding: EdgeInsets.only(left: 5), child: Text('Size', style: TextStyle(fontSize: 16))),
          const Padding(padding: EdgeInsets.only(left: 5, right: 5), child: Divider(height: 1, color: Colors.black54)),
          OptionDropdownWidget<ResizePolicy>(
              title: 'Policy:',
              value: _imageResizer.config.policy,
              items: _policyItems,
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                _imageResizer.config.policy = value;
                setState(() {});
              }),
          OptionDropdownWidget<Interpolation>(
              title: 'Filter:',
              value: _imageResizer.config.filter,
              items: _filterItems,
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                _imageResizer.config.filter = value;
                setState(() {});
              }),
          Row(children: [
            const SizedBox(width: 10),
            const Text('Unit:'),
            Checkbox(
                value: (_imageResizer.config.unit == SizeUnit.pixel),
                onChanged: (value) {
                  if (value!) {
                    _imageResizer.config.unit = SizeUnit.pixel;
                  }

                  unitChanged();
                }),
            const Text('pixels'),
            const SizedBox(width: 5),
            Checkbox(
                value: (_imageResizer.config.unit == SizeUnit.scale),
                onChanged: (value) {
                  if (value!) {
                    _imageResizer.config.unit = SizeUnit.scale;
                  }
                  unitChanged();
                }),
            const Text('percentage')
          ]),
          Row(children: [
            OptionInputWidget(
                title: 'Width',
                unitLabel: _imageResizer.config.unit == SizeUnit.pixel ? 'pixels' : '%',
                allowPattern: RegExp('[0-9]+'),
                hintText: '0',
                enabled: !_imageResizer.config.widthAuto,
                listenable: _imageResizer.configNotifier,
                valueHandler: () => _imageResizer.config.width.toString(),
                onChanged: widthChanged),
            Checkbox(
                value: _imageResizer.config.widthAuto,
                onChanged: (value) {
                  if (value! && _imageResizer.config.heightAuto) {
                    return;
                  }

                  _imageResizer.config.widthAuto = value;
                  if (_imageResizer.config.unit == SizeUnit.pixel) {
                    _imageResizer.config.width = 0;
                  } else {
                    _imageResizer.config.width = _imageResizer.config.height;
                  }

                  setState(() {});
                }),
            const Text('auto')
          ]),
          Row(children: [
            OptionInputWidget(
                title: 'Height',
                unitLabel: _imageResizer.config.unit == SizeUnit.pixel ? 'pixels' : '%',
                allowPattern: RegExp('[0-9]+'),
                hintText: '0',
                enabled: !_imageResizer.config.heightAuto,
                listenable: _imageResizer.configNotifier,
                valueHandler: () => _imageResizer.config.height.toString(),
                onChanged: heightChanged),
            Checkbox(
                value: _imageResizer.config.heightAuto,
                onChanged: (value) {
                  if (value! && _imageResizer.config.widthAuto) {
                    return;
                  }

                  _imageResizer.config.heightAuto = value;

                  if (_imageResizer.config.unit == SizeUnit.pixel) {
                    _imageResizer.config.height = 0;
                  } else {
                    _imageResizer.config.height = _imageResizer.config.width;
                  }

                  setState(() {});
                }),
            const Text('auto')
          ]),
          const Padding(padding: EdgeInsets.only(left: 5), child: Text('File', style: TextStyle(fontSize: 16))),
          const Padding(padding: EdgeInsets.only(left: 5, right: 5), child: Divider(height: 1, color: Colors.black54)),
          Row(children: [
            OptionDropdownWidget<ImageFormat>(
                title: 'Format:',
                value: _imageResizer.config.imageFormat,
                items: _formatItems,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  _imageResizer.config.imageFormat = value;
                  setState(() {});
                }),
            Checkbox(
                value: _imageResizer.config.convertWebpToPng,
                onChanged: (value) {
                  _imageResizer.config.convertWebpToPng = value!;
                  setState(() {});
                }),
            const Text('Convert webp to png')
          ]),
          OptionInputWidget(
              title: 'Jpg quality',
              unitLabel: '%',
              allowPattern: RegExp('[0-9]'),
              hintText: '95(0~100)',
              listenable: _imageResizer.configNotifier,
              valueHandler: () => _imageResizer.config.jpgQuality.toString(),
              onChanged: (value) {
                value = value.isEmpty ? '95' : value;
                if (int.parse(value) > 100) {
                  value = '100';
                  setState(() {});
                }

                _imageResizer.config.jpgQuality = int.parse(value);
              }),
          OptionInputWidget(
              title: 'Png compression',
              unitLabel: '',
              allowPattern: RegExp('[0-9]'),
              hintText: '1(0~9)',
              listenable: _imageResizer.configNotifier,
              valueHandler: () => _imageResizer.config.pngCompression.toString(),
              onChanged: (value) {
                value = value.isEmpty ? '1' : value;
                if (int.parse(value) > 9) {
                  value = '9';
                  setState(() {});
                }
                _imageResizer.config.pngCompression = int.parse(value);
              }),
          OptionDropdownWidget<FileTarget>(
              value: _imageResizer.config.target,
              items: _fileTargetItems,
              title: 'File target:',
              onChanged: (value) {
                _imageResizer.config.target = value!;
                setState(() {});
              }),
          OptionInputWidget(
              title: 'File Destination',
              unitLabel: '',
              icon: const Icon(Icons.folder_open),
              textFieldWidth: 300,
              enabled: (_imageResizer.config.target != FileTarget.origin),
              listenable: _imageResizer.configNotifier,
              valueHandler: () => _imageResizer.config.destination,
              iconButtonOnPressed: iconButtonOnPressed,
              onChanged: (value) {
                _imageResizer.config.destination = value;
              }),
          const Expanded(child: SizedBox()),
          Row(children: [
            const Expanded(child: SizedBox()),
            Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5, right: 5),
                child: TextButton(
                    onPressed: resizeButtonPressed,
                    style: const ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(Colors.black87),
                        backgroundColor: WidgetStatePropertyAll(Colors.white),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black45),
                            borderRadius: BorderRadius.all(Radius.circular(15))))),
                    child: const Text('Go')))
          ])
        ]));
  }

  void unitChanged() {
    if (_imageResizer.config.widthAuto) {
      if (_imageResizer.config.unit == SizeUnit.pixel) {
        _imageResizer.config.width = 0;
      } else {
        _imageResizer.config.width = _imageResizer.config.height;
      }
    }
    if (_imageResizer.config.heightAuto) {
      if (_imageResizer.config.unit == SizeUnit.pixel) {
        _imageResizer.config.height = 0;
      } else {
        _imageResizer.config.height = _imageResizer.config.width;
      }
    }

    setState(() {});
  }

  void widthChanged(String value) {
    value = value.isEmpty ? '0' : value;
    _imageResizer.config.width = int.parse(value);

    if (_imageResizer.config.unit == SizeUnit.scale && _imageResizer.config.heightAuto) {
      _imageResizer.config.height = _imageResizer.config.width;
      _imageResizer.configChanged();
    }
  }

  void heightChanged(String value) {
    value = value.isEmpty ? '0' : value;
    _imageResizer.config.height = int.parse(value);

    if (_imageResizer.config.unit == SizeUnit.scale && _imageResizer.config.widthAuto) {
      _imageResizer.config.width = _imageResizer.config.height;
      _imageResizer.configChanged();
    }
  }

  bool checkOptions() {
    if (_imageResizer.config.heightAuto && _imageResizer.config.widthAuto) {
      return false;
    }

    if (_imageResizer.fileList.isEmpty) {
      showAlert('No image selected');

      return false;
    }

    if ((_imageResizer.config.width == 0 && !_imageResizer.config.widthAuto) ||
        (_imageResizer.config.height == 0 && !_imageResizer.config.heightAuto)) {
      showAlert('Size settings incorrect');

      return false;
    }

    return true;
  }

  void resizeButtonPressed() {
    if (!checkOptions()) {
      return;
    }

    if (_imageResizer.processing) {
      showAlert('Alerdy processing');

      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ProgressDialog();
        });

    _imageResizer.resize();
  }

  void showAlert(String message) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              child: IntrinsicWidth(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    Padding(padding: const EdgeInsets.only(top: 15, left: 5), child: Text(message)),
                    Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
                      const Expanded(child: SizedBox()),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Close'))
                    ])
                  ])));
        });
  }

  Future<void> iconButtonOnPressed() async {
    if (_imageResizer.config.target == FileTarget.origin) {
      return;
    }

    String? result = await getDirectoryPath();
    if (result == null) {
      return;
    }

    _imageResizer.config.destination = result;
    setState(() {});
  }

  void addProfile() {
    showDialog(
        context: context,
        builder: (context) {
          return ProfileNameInputDialog(onFinished: (value) {
            ImageResizeConfig config = _imageResizer.config.copy();
            config.name = value;
            _imageResizer.config = config;
            _profileManager.profiles.add(config);
            _currentProfileIndex = _profileManager.profiles.length - 1;
            _profileManager.saveProfile().then((value) {
              if (context.mounted) Navigator.pop(context);
              setState(() {});
            });
          });
        });
  }

  void saveProfile() {
    _profileManager.profiles[_currentProfileIndex] = _imageResizer.config.copy();
    _profileManager.saveProfile();
    setState(() {});
  }

  void deleteProfile() {
    if (_profileManager.profiles.length == 1) {
      showAlert('Must exist at least one profile');

      return;
    }

    _profileManager.profiles.removeAt(_currentProfileIndex);
    _profileManager.saveProfile();

    if (_currentProfileIndex > 0) {
      _currentProfileIndex--;
    }

    setState(() {});
  }
}
