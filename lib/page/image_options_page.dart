import 'package:flutter/material.dart';
import '../model/image_resize_config.dart';
import '../resizer/image_resizer.dart';
import '../widget/options_input_widget.dart';

class ImageOptionsPage extends StatefulWidget {
  const ImageOptionsPage({super.key});

  @override
  State<StatefulWidget> createState() => _ImageOptionsPageState();
}

class _ImageOptionsPageState extends State<ImageOptionsPage> with AutomaticKeepAliveClientMixin {
  final ImageResizer imageResizer = ImageResizer();

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
            const Text('format:'),
            const SizedBox(width: 5),
            DropdownButton(
                value: imageResizer.config.imageFormat,
                items: formatItems,
                dropdownColor: Colors.grey[100],
                focusColor: Colors.grey[100],
                onChanged: (value) {
                  imageResizer.config.imageFormat = value as ImageFormat;
                  setState(() {});
                })
          ]),
          Row(children: [
            const SizedBox(width: 10),
            const Text('Filter:'),
            const SizedBox(width: 5),
            DropdownButton(
                value: imageResizer.config.filter,
                items: filterItems,
                dropdownColor: Colors.grey[100],
                focusColor: Colors.grey[100],
                onChanged: (value) {
                  imageResizer.config.filter = value as Interpolation;
                  setState(() {});
                })
          ]),
          OptionInputWidget(
              title: 'Width',
              unitLabel: 'pixels',
              initValue: imageResizer.config.width.toString(),
              allowPattern: RegExp('[0-9]+'),
              onChanged: (value) {
                value = value.isEmpty ? '0' : value;
                imageResizer.config.width = int.parse(value);
              }),
          OptionInputWidget(
              title: 'Height',
              unitLabel: 'pixels',
              initValue: imageResizer.config.height.toString(),
              allowPattern: RegExp('[0-9]+'),
              onChanged: (value) {
                value = value.isEmpty ? '0' : value;
                imageResizer.config.height = int.parse(value);
              }),
          OptionInputWidget(
              title: 'jpg quality:',
              unitLabel: '%',
              initValue: imageResizer.config.jpgQuality.toString(),
              allowPattern: RegExp('[0-9]'),
              onChanged: (value) {
                value = value.isEmpty ? '0' : value;
                if (int.parse(value) > 100) {
                  value = '100';
                  setState(() {});
                }

                imageResizer.config.jpgQuality = int.parse(value);
              }),
          OptionInputWidget(
              title: 'Png compression',
              unitLabel: '',
              initValue: imageResizer.config.pngCompression.toString(),
              allowPattern: RegExp('[0-9]'),
              onChanged: (value) {
                value = value.isEmpty ? '0' : value;
                if (int.parse(value) > 9) {
                  value = '9';
                  setState(() {});
                }
                imageResizer.config.pngCompression = int.parse(value);
              })
        ]));
  }

  @override
  bool get wantKeepAlive => true;
}
