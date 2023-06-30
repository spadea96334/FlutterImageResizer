import 'package:flutter/material.dart';
import '../image_resizer.dart';
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
                value: imageResizer.imageFormat,
                items: formatItems,
                dropdownColor: Colors.grey[100],
                focusColor: Colors.grey[100],
                onChanged: (value) => formatChange(value))
          ]),
          OptionInputWidget(
              title: 'Width',
              unitLabel: 'pixels',
              initValue: imageResizer.imageWidth.toString(),
              allowPattern: RegExp('[0-9]+'),
              onChanged: (value) {
                imageResizer.imageWidth = int.parse(value);
              }),
          OptionInputWidget(
              title: 'Height',
              unitLabel: 'pixels',
              initValue: imageResizer.imageHeight.toString(),
              allowPattern: RegExp('[0-9]+'),
              onChanged: (value) {
                imageResizer.imageHeight = int.parse(value);
              })
        ]));
  }

  void formatChange(Object value) {
    imageResizer.imageFormat = value as ImageFormat;
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}
