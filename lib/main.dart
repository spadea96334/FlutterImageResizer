import 'package:fluent_ui/fluent_ui.dart';
import 'package:image_resizer/utility/setting_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'page/image_options_page.dart';
import 'page/image_page.dart';
import 'page/image_settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions =
      const WindowOptions(size: Size(800, 700), center: true, backgroundColor: Colors.transparent);

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  // load setting
  await SettingManager().loadSetting();
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
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      ImagePage(toOptionsPage: () {
        _currentIndex = 1;
        setState(() {});
      }),
      const ImageOptionsPage(),
      const ImageSettingsPage()
    ];

    return NavigationView(
      pane: NavigationPane(
          selected: _currentIndex,
          onChanged: (index) => setState(() => _currentIndex = index),
          displayMode: PaneDisplayMode.open,
          size: const NavigationPaneSize(openMaxWidth: 150),
          items: [
            PaneItem(icon: const Icon(FluentIcons.picture), title: const Text('Image'), body: const SizedBox()),
            PaneItem(
                icon: const Icon(FluentIcons.column_options),
                title: const Text('Image options'),
                body: const SizedBox()),
            PaneItem(icon: const Icon(FluentIcons.settings), title: const Text('Settings'), body: const SizedBox())
          ]),
      paneBodyBuilder: (item, body) => IndexedStack(index: _currentIndex, children: pages),
    );
  }
}
