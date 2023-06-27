import 'package:fluent_ui/fluent_ui.dart';

void main() {
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
        visualDensity: VisualDensity.standard,
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return NavigationView(
        appBar: const NavigationAppBar(title: Text("Fluent Design App Bar")),
        pane: NavigationPane(
            selected: topIndex,
            onChanged: (index) => setState(() => topIndex = index),
            displayMode: PaneDisplayMode.open,
            size: const NavigationPaneSize(openMaxWidth: 150),
            items: [
              PaneItem(
                  icon: const Icon(FluentIcons.picture), title: const Text('image'), body: const Text('image page')),
              PaneItem(
                  icon: const Icon(FluentIcons.settings),
                  title: const Text('settings'),
                  body: const Text('settings page'))
            ]));
  }
}
