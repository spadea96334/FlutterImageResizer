import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_resizer/utility/setting_manager.dart';
import '../resizer/image_resizer.dart';

class ImageSettingsPage extends StatefulWidget {
  const ImageSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _ImageSettingsPageState();
}

class _ImageSettingsPageState extends State<ImageSettingsPage> with AutomaticKeepAliveClientMixin {
  final ImageResizer imageResizer = ImageResizer();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<DropdownMenuItem> formatItems = [];
    for (int i = 1; i <= Platform.numberOfProcessors; i++) {
      formatItems.add(DropdownMenuItem(value: i, child: Text(i.toString())));
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
            const Text('Threads:'),
            const SizedBox(width: 5),
            DropdownButton(
                value: imageResizer.threadCount,
                items: formatItems,
                dropdownColor: Colors.grey[100],
                focusColor: Colors.grey[100],
                onChanged: (value) {
                  imageResizer.threadCount = value;
                  SettingManager().setSetting(SettingKey.threads, value.toString());
                  setState(() {});
                })
          ]),
        ]));
  }

  @override
  bool get wantKeepAlive => true;
}
