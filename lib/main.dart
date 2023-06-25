import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_player_application/dependency_injection.dart';
import 'package:video_player_application/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Video player demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// Used to pick the videos from the gallery
  void pickVideos() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.video);

    /// If user press the cancel button show the error snackbar
    if (result == null || result.files.isEmpty) {
      showSnackBar(title: "Please pick at least one video");
    }

    /// If user select more than 4 videos show the error snackbar
    else if (result.files.length > 4) {
      showSnackBar(title: "You can only select maximum 4 videos");
    } 
    
    /// Navigate the user the main video plyer screen
    else {
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => VideoPlayers(platformFile: result.files)));
    }
  }

  void showSnackBar({required String title}) {
    var snackBar = SnackBar(content: Text(title));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Please pick video"),
            const Text("Max limit : 4"),
            OutlinedButton(onPressed: pickVideos, child: const Text("Pick"))
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
