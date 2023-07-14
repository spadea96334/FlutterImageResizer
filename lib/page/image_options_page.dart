import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image_resizer/utility/setting_manager.dart';
import 'package:image_resizer/widget/tooltip_button.dart';
import '../model/image_resize_config.dart';
import '../resizer/image_resizer.dart';
import '../widget/options_input_widget.dart';
import '../widget/profile_name_input_dialog.dart';

class ImageOptionsPage extends StatefulWidget {
  const ImageOptionsPage({super.key});

  @override
  State<StatefulWidget> createState() => _ImageOptionsPageState();
}

class _ImageOptionsPageState extends State<ImageOptionsPage> {
  final ImageResizer _imageResizer = ImageResizer();
  final SettingManager _profileManager = SettingManager();
  final GlobalKey _profileKey = GlobalKey();
  int _currentProfileIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<ImageResizeConfig>> profileItems = [];
    for (var element in _profileManager.profiles) {
      profileItems.add(DropdownMenuItem<ImageResizeConfig>(value: element, child: Text(element.name)));
    }

    List<DropdownMenuItem> formatItems = [];
    for (var element in ImageFormat.values) {
      formatItems.add(DropdownMenuItem(value: element, child: Text(element.name)));
    }

    List<DropdownMenuItem> filterItems = [];
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
            const SizedBox(width: 10),
            const Text('Profile:'),
            const SizedBox(width: 5),
            DropdownButton(
                key: _profileKey,
                value: profileItems[_currentProfileIndex].value,
                items: profileItems,
                dropdownColor: Colors.grey[100],
                focusColor: Colors.grey[100],
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
          Row(children: [
            const SizedBox(width: 10),
            const Text('Format:'),
            const SizedBox(width: 5),
            DropdownButton(
                value: _imageResizer.config.imageFormat,
                items: formatItems,
                dropdownColor: Colors.grey[100],
                focusColor: Colors.grey[100],
                onChanged: (value) {
                  _imageResizer.config.imageFormat = value as ImageFormat;
                  setState(() {});
                })
          ]),
          Row(children: [
            const SizedBox(width: 10),
            const Text('Filter:'),
            const SizedBox(width: 5),
            DropdownButton(
                value: _imageResizer.config.filter,
                items: filterItems,
                dropdownColor: Colors.grey[100],
                focusColor: Colors.grey[100],
                onChanged: (value) {
                  _imageResizer.config.filter = value as Interpolation;
                  setState(() {});
                })
          ]),
          OptionInputWidget(
              title: 'Width',
              unitLabel: 'pixels',
              initValue: _imageResizer.config.width.toString(),
              allowPattern: RegExp('[0-9]+'),
              hintText: '0',
              onChanged: (value) {
                value = value.isEmpty ? '0' : value;
                _imageResizer.config.width = int.parse(value);
              }),
          OptionInputWidget(
              title: 'Height',
              unitLabel: 'pixels',
              initValue: _imageResizer.config.height.toString(),
              allowPattern: RegExp('[0-9]+'),
              hintText: '0',
              onChanged: (value) {
                value = value.isEmpty ? '0' : value;
                _imageResizer.config.height = int.parse(value);
              }),
          Tooltip(
            message: 'If value of precentage is not 0, pixel value will be invaild',
            child: OptionInputWidget(
                title: 'Width',
                unitLabel: '%',
                initValue: _imageResizer.config.scaleX.toString(),
                allowPattern: RegExp('[0-9]+'),
                hintText: '100',
                onChanged: (value) {
                  value = value.isEmpty ? '100' : value;
                  _imageResizer.config.scaleX = int.parse(value);
                }),
          ),
          Tooltip(
              message: 'If value of precentage is not 0, the value of pixel will be invaild',
              child: OptionInputWidget(
                  title: 'Height',
                  unitLabel: '%',
                  initValue: _imageResizer.config.scaleY.toString(),
                  allowPattern: RegExp('[0-9]+'),
                  hintText: '100',
                  onChanged: (value) {
                    value = value.isEmpty ? '100' : value;
                    _imageResizer.config.scaleY = int.parse(value);
                  })),
          OptionInputWidget(
              title: 'Jpg quality',
              unitLabel: '%',
              initValue: _imageResizer.config.jpgQuality.toString(),
              allowPattern: RegExp('[0-9]'),
              hintText: '95(0~100)',
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
              initValue: _imageResizer.config.pngCompression.toString(),
              allowPattern: RegExp('[0-9]'),
              hintText: '1(0~9)',
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
              initValue: _imageResizer.config.destination,
              icon: const Icon(Icons.folder_open),
              textFieldWidth: 300,
              iconButtonOnPressed: iconButtonOnPressed,
              onChanged: (value) {
                _imageResizer.config.destination = value;
              })
        ]));
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
