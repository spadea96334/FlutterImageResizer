import 'package:fluent_ui/fluent_ui.dart';
import 'package:image_resizer/opencv_bridge.dart';
import 'page/image_options_page.dart';
import 'page/image_page.dart';
import 'page/image_settings_page.dart';

void main() {
  OpenCVBridge();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Image resizer',
      theme: FluentThemeData(
          // visualDensity: VisualDensity.standard,
          ),
      home: const MyHomePage(title: 'Image resizer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int topIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
        pane: NavigationPane(
            selected: topIndex,
            onChanged: (index) => setState(() => topIndex = index),
            displayMode: PaneDisplayMode.open,
            size: const NavigationPaneSize(openMaxWidth: 150),
            items: [
          PaneItem(icon: const Icon(FluentIcons.picture), title: const Text('Image'), body: const ImagePage()),
          PaneItem(
              icon: const Icon(FluentIcons.column_options),
              title: const Text('Image options'),
              body: const ImageOptionsPage()),
          PaneItem(
              icon: const Icon(FluentIcons.settings), title: const Text('Settings'), body: const ImageSettingsPage())
        ]));
  }
}
