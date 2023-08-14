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
  bool _usePixelUnit = true;
  int _currentProfileIndex = 0;
  bool _widthAuto = false;
  bool _heightAuto = false;

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<ImageResizeConfig>> profileItems = [];
    for (var element in _profileManager.profiles) {
      profileItems.add(DropdownMenuItem<ImageResizeConfig>(value: element, child: Text(element.name)));
    }

    List<DropdownMenuItem<ImageFormat>> formatItems = [];
    for (var element in ImageFormat.values) {
      formatItems.add(DropdownMenuItem(value: element, child: Text(element.name)));
    }

    List<DropdownMenuItem<ResizePolicy>> policyItems = [];
    for (var element in ResizePolicy.values) {
      policyItems.add(DropdownMenuItem(value: element, child: Text(element.name)));
    }

    List<DropdownMenuItem<Interpolation>> filterItems = [];
    for (var element in Interpolation.values) {
      filterItems.add(DropdownMenuItem(value: element, child: Text(element.name)));
    }

    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Container(padding: const EdgeInsets.fromLTRB(4, 4, 4, 4), child: const Text('Image options')))
          ]),
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
                }),
            TooltipButton(icon: const Icon(Icons.add), message: 'add', onPressed: addProfile),
            TooltipButton(icon: const Icon(Icons.save_as), message: 'save', onPressed: saveProfile),
            TooltipButton(icon: const Icon(Icons.delete_forever), message: 'delete', onPressed: deleteProfile)
          ]),
          OptionDropdownWidget<ImageFormat>(
              title: 'Format:',
              value: _imageResizer.config.imageFormat,
              items: formatItems,
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                _imageResizer.config.imageFormat = value;
                setState(() {});
              }),
          OptionDropdownWidget<ResizePolicy>(
              title: 'Policy:',
              value: _imageResizer.config.policy,
              items: policyItems,
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
              items: filterItems,
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                _imageResizer.config.filter = value;
              }),
          Row(children: [
            const SizedBox(width: 10),
            const Text('Unit:'),
            Checkbox(
                value: _usePixelUnit,
                onChanged: (value) {
                  _usePixelUnit = value!;
                  unitChanged();
                }),
            const Text('pixels'),
            const SizedBox(width: 5),
            Checkbox(
                value: !_usePixelUnit,
                onChanged: (value) {
                  _usePixelUnit = !value!;
                  unitChanged();
                }),
            const Text('percentage')
          ]),
          Row(children: [
            OptionInputWidget(
                title: 'Width',
                unitLabel: _usePixelUnit ? 'pixels' : '%',
                allowPattern: RegExp('[0-9]+'),
                hintText: '0',
                enabled: !_widthAuto,
                listenable: _imageResizer.configNotifier,
                valueHandler: () =>
                    _usePixelUnit ? _imageResizer.config.width.toString() : _imageResizer.config.scaleX.toString(),
                onChanged: widthChanged),
            Checkbox(
                value: _widthAuto,
                onChanged: (value) {
                  if (value! && _heightAuto) {
                    return;
                  }

                  _widthAuto = value;
                  _imageResizer.config.width = 0;
                  _imageResizer.config.scaleX = _imageResizer.config.scaleY;
                  setState(() {});
                }),
            const Text('auto')
          ]),
          Row(children: [
            OptionInputWidget(
                title: 'Height',
                unitLabel: _usePixelUnit ? 'pixels' : '%',
                allowPattern: RegExp('[0-9]+'),
                hintText: '0',
                enabled: !_heightAuto,
                listenable: _imageResizer.configNotifier,
                valueHandler: () =>
                    _usePixelUnit ? _imageResizer.config.height.toString() : _imageResizer.config.scaleY.toString(),
                onChanged: heightChanged),
            Checkbox(
                value: _heightAuto,
                onChanged: (value) {
                  if (value! && _widthAuto) {
                    return;
                  }

                  _heightAuto = value;
                  _imageResizer.config.height = 0;
                  _imageResizer.config.scaleY = _imageResizer.config.scaleX;
                  setState(() {});
                }),
            const Text('auto')
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
          OptionInputWidget(
              title: 'File Destination',
              unitLabel: '',
              icon: const Icon(Icons.folder_open),
              textFieldWidth: 300,
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
                        foregroundColor: MaterialStatePropertyAll(Colors.black87),
                        backgroundColor: MaterialStatePropertyAll(Colors.white),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black45),
                            borderRadius: BorderRadius.all(Radius.circular(15))))),
                    child: const Text('Go')))
          ])
        ]));
  }

  void unitChanged() {
    if (_usePixelUnit) {
      _imageResizer.config.changeUnitToPixel();
      if (_widthAuto) {
        _imageResizer.config.width = 0;
      }
      if (_heightAuto) {
        _imageResizer.config.height = 0;
      }
    } else {
      _imageResizer.config.changeUnitToPercentage();
      if (_widthAuto) {
        _imageResizer.config.scaleX = _imageResizer.config.scaleY;
      }
      if (_heightAuto) {
        _imageResizer.config.scaleY = _imageResizer.config.scaleX;
      }
    }

    setState(() {});
  }

  void widthChanged(String value) {
    if (_usePixelUnit) {
      value = value.isEmpty ? '0' : value;
      _imageResizer.config.width = int.parse(value);
    } else {
      value = value.isEmpty ? '100' : value;
      _imageResizer.config.scaleX = int.parse(value);
      if (_heightAuto) {
        _imageResizer.config.scaleY = int.parse(value);
        _imageResizer.configNotifier.emit();
      }
    }
  }

  void heightChanged(String value) {
    if (_usePixelUnit) {
      value = value.isEmpty ? '0' : value;
      _imageResizer.config.height = int.parse(value);
    } else {
      value = value.isEmpty ? '100' : value;
      _imageResizer.config.scaleY = int.parse(value);
      if (_widthAuto) {
        _imageResizer.config.scaleX = int.parse(value);
        _imageResizer.configNotifier.emit();
      }
    }
  }

  bool checkOptions() {
    if (_heightAuto && _widthAuto) {
      return false;
    }

    if (_imageResizer.fileList.isEmpty) {
      print('no file');
      // TODO: show error toast
      return false;
    }

    if (_usePixelUnit) {
      if ((_imageResizer.config.width == 0 && !_widthAuto) || (_imageResizer.config.height == 0 && !_heightAuto)) {
        print('error size');
        // TODO: show error toast
        return false;
      }
    } else {
      if (_imageResizer.config.scaleX == 0 && _imageResizer.config.scaleY == 0) {
        print('error size');
        // TODO: show error toast
        return false;
      }
    }

    return true;
  }

  void resizeButtonPressed() {
    if (!checkOptions()) {
      return;
    }

    showDialog(
        context: context,
        builder: (context) {
          return ProgressDialog();
        });

    _imageResizer.resize();
  }

  Future<void> iconButtonOnPressed() async {
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
            _profileManager.profiles.add(config);
            _currentProfileIndex = _profileManager.profiles.length - 1;
            _profileManager.saveProfile().then((value) {
              Navigator.pop(context);
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
      // TODO: show tips
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
