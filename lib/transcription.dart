import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class Transcription extends StatefulWidget {
  const Transcription({super.key});

  @override
  State<Transcription> createState() => _TranscriptionState();
}

class _TranscriptionState extends State<Transcription> {
  Future<void> Transcription() async {
    await dotenv.load();
    OpenAI.apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

    final ByteData data = await rootBundle.load('lib/audio/middle_sample.mp3');
    final bytes = data.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/middle_sample.mp3');
    await file.writeAsBytes(bytes);

    OpenAIAudioModel transcription =
        await OpenAI.instance.audio.createTranscription(
      file: file,
      model: "whisper-1",
      responseFormat: OpenAIAudioResponseFormat.json,
    );

    print(transcription.text);
    setState(() {
      text = transcription.text;
    });
  }

  var text = '';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("文字起こし画面"),
        ),
        body: Padding(
            padding: EdgeInsets.all(15),
            child: Center(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Transcription();
                      },
                      child: Text("文字起こしする")),
                  Text(text)
                ],
              ),
            ))),
      ),
    );
  }
}
