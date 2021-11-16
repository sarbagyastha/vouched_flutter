import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vouched_flutter/vouched_flutter.dart';
import 'package:vouched_example/detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
      ),
      home: const ScannerPage(),
    );
  }
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CardDetailInstruction? _instruction;
  String? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.light
                  ? Brightness.dark
                  : Brightness.light,
        ),
        title: const Text('Vouched Demo'),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "You're almost there!",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use the camera to scan any form of photo ID. '
                    "We'll use this information to validate your identity.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        ?.copyWith(height: 1.3),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 1,
                child: VouchedScanner(
                  borderRadius: BorderRadius.circular(10),
                  onCardDetailResult: (result) {
                    _instruction = result.instruction;
                    _image = result.image;
                    setState(() {});
                  },
                  onResponse: (response) async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          response: response,
                          image: _image,
                        ),
                      ),
                    );
                    Vouched.resumeCamera();
                  },
                  onError: (error) {},
                ),
              ),
            ),
            Expanded(
              child: Center(child: Text(_readableInstruction)),
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.top + kToolbarHeight,
            )
          ],
        ),
      ),
    );
  }

  String get _readableInstruction {
    switch (_instruction) {
      case CardDetailInstruction.noCard:
        return 'Place your card in the scanner area.';
      case CardDetailInstruction.onlyOne:
        return 'Card Found.';
      case CardDetailInstruction.moveCloser:
        return 'Please move your device a bit closer.';
      case CardDetailInstruction.moveAway:
        return 'Please move your device a bit farther.';
      case CardDetailInstruction.glare:
        return 'There is a glare in document.';
      case CardDetailInstruction.dark:
        return "It's too dark.";
      case CardDetailInstruction.blur:
        return 'The document is not clear.';
      case CardDetailInstruction.holdSteady:
        return 'Please do not move your device.';
      case CardDetailInstruction.noFace:
      case CardDetailInstruction.openMouth:
      case CardDetailInstruction.closeMouth:
      case CardDetailInstruction.lookForward:
      case CardDetailInstruction.lookLeft:
      case CardDetailInstruction.lookRight:
      case CardDetailInstruction.blinkEyes:
      case CardDetailInstruction.none:
      default:
        return _instruction?.toString() ?? '';
    }
  }
}
