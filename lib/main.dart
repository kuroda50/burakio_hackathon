import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dart_openai/dart_openai.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'color.dart';
import 'prompt.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    home: MyWidget(),
  ));
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String summarizedText = "", fileName = "", alertText = "";
  File? file;
  bool? isTranscription, isLoading;
  bool isCheckedBusy = true,
      isCheckedDetailed = false,
      isCheckUnderstandability = false;

  Future<String> Transcription() async {
    setState(() {
      isTranscription = true;
    });
    await dotenv.load();
    OpenAI.apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

    OpenAIAudioModel transcription =
        await OpenAI.instance.audio.createTranscription(
      file: file!,
      model: "whisper-1",
      responseFormat: OpenAIAudioResponseFormat.text,
      language: "ja",
      temperature: 0.2,
    );
    setState(() {
      isTranscription = false;
    });
    return transcription.text;
  }

  Future<void> filePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file = File(result.files.single.path!);
      setState(() {
        fileName = basename(file!.path);
        alertText = "";
      });
    } else {
      print("ファイルが選択されていません");
    }
  }

  Future<String> summary(
    String inputText,
  ) async {
    setState(() {
      isLoading = true;
    });
    // ここにGPTとのやり取り
    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-4o",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: isCheckedBusy
              ? Prompt.promptSummaryBusy
              : isCheckedDetailed
                  ? Prompt.promptSummaryDetailed
                  : Prompt.promptSummaryUnderstandability,
          role: OpenAIChatMessageRole.system,
        ),
        OpenAIChatCompletionChoiceMessageModel(
          content: Prompt.exampleUserText,
          role: OpenAIChatMessageRole.user,
        ),
        OpenAIChatCompletionChoiceMessageModel(
          content: isCheckedBusy
              ? Prompt.exampleBusyAnswerText
              : isCheckedDetailed
                  ? Prompt.exampleDetailedAnswerText
                  : Prompt.exampleUnderstandabilityAnswerText,
          role: OpenAIChatMessageRole.assistant,
        ),
        OpenAIChatCompletionChoiceMessageModel(
          content: inputText,
          role: OpenAIChatMessageRole.user,
        ),
      ],
    );
    setState(() {
      isLoading = false;
    });
    return chatCompletion.choices[0].message.content;
  }

  Future<void> summarize() async {
    String allText = await Transcription();
    print("文字全文： $allText");
    summarizedText = await summary(allText);
    print("要約した文： $summarizedText");
    setState(() {
      summarizedText = summarizedText;
    });
    saveScore();
  }

  Future<void> saveScore() async {
    RegExp regExp = RegExp(r'評価: *(\d)/5');
    Match? match = regExp.firstMatch(summarizedText);
    if (match != null) {
      String? scoreText = match.group(0);
    } else {
      print("一致する文がみつかりません");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "シラバス要約",
            style: TextStyle(
              color: AppColor.subTextColor,
            ),
          ),
          backgroundColor: AppColor.mainColor,
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        filePick();
                      },
                      child: Text(
                        "ファイルを選択する",
                        style: TextStyle(
                          color: AppColor.subTextColor,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.buttonColor)),
                  fileName != ""
                      ? Text("ファイル名：${fileName}")
                      : const SizedBox.shrink(),
                  ElevatedButton(
                      onPressed: () {
                        if (fileName != "") {
                          alertText = "";
                          summarize();
                        } else {
                          alertText = "ファイルを選択してください";
                        }
                        setState(() {
                          alertText = alertText;
                        });
                      },
                      child: Text(
                        "要約/評価する",
                        style: TextStyle(
                          color: AppColor.subTextColor,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.buttonColor)),
                  isTranscription == true
                      ? Text("音声をテキストに変換中……")
                      : const SizedBox.shrink(),
                  isLoading == true
                      ? Text("テキストを要約中……")
                      : const SizedBox.shrink(),
                  Text(
                    alertText,
                    style: TextStyle(
                      color: AppColor.errorColor,
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: CheckboxListTile(
                      title: const Text("簡単に"),
                      subtitle: const Text("簡潔で短い要約をします"),
                      secondary: const Icon(Icons.thumb_up),
                      value: isCheckedBusy,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          isCheckedBusy = value;
                          isCheckedDetailed = !value;
                          isCheckUnderstandability = !value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: CheckboxListTile(
                      title: const Text("詳しく"),
                      subtitle: const Text("詳しい部分まで要約をします"),
                      secondary: const Icon(Icons.article),
                      value: isCheckedDetailed,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          isCheckedDetailed = value;
                          isCheckedBusy = !value;
                          isCheckUnderstandability = !value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: CheckboxListTile(
                      title: const Text("わかりやすさ"),
                      subtitle: const Text("授業のわかりやすさを評価します"),
                      secondary: const Icon(Icons.lightbulb_circle_outlined),
                      value: isCheckUnderstandability,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          isCheckedDetailed = !value;
                          isCheckedBusy = !value;
                          isCheckUnderstandability = value;
                        });
                      },
                    ),
                  ),
                  MarkdownBody(
                    data: summarizedText,
                    softLineBreak: true,
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
