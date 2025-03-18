import 'dart:io';
import 'color.dart';
import 'prompt.dart';
import 'firebase_options.dart';

import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final db = FirebaseFirestore.instance;

class MyWidget2 extends StatefulWidget {
  String professorId = "";
  MyWidget2({super.key, required this.professorId});

  @override
  State<MyWidget2> createState() => _MyWidget2State();
}

class _MyWidget2State extends State<MyWidget2> {
  String summarizedText = "", fileName = "", alertText = "";
  File? file;
  bool? isTranscription, isLoading;
  bool isCheckedBusy = true,
      isCheckedDetailed = false,
      isCheckUnderstandability = false;
  Professor? professor;

  void initState() {
    super.initState();
    buildData();
  }

  Future<void> buildData() async {
    professor = await getProfessor();
    File tempFile = await getFile(professor!.id);
    setState(() {
      professor = professor;
      file = tempFile;
    });
  }

  Future<Professor> getProfessor() async {
    print("ここまで実行");
    DocumentSnapshot professorSnapshot =
        await db.collection("professors").doc(widget.professorId).get();
    print("ここまで実行");
    Professor professorTemp = Professor(
        id: professorSnapshot.id,
        name: professorSnapshot["name"],
        scores: professorSnapshot["scores"].cast<int>());
    print("ここまで実行2");
    return professorTemp;
  }

  Future<File> getFile(String fileId) async {
    final storageRef =
        FirebaseStorage.instance.ref().child("audio/$fileId.webm");

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_audio.webm');

    await storageRef.writeToFile(tempFile);

    return tempFile;
  }

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
                  professor != null ? Text(professor!.name) : Text("まだ取得してないよ"),
                  ElevatedButton(
                      onPressed: () {
                        if (file != null) {
                          alertText = "";
                          summarize();
                        } else {
                          alertText = "ファイルを取得中です";
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
                      subtitle: const Text("簡潔で短く要約します"),
                      secondary: const Icon(Icons.thumb_up),
                      value: isCheckedBusy,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          isCheckedBusy = true;
                          isCheckedDetailed = false;
                          isCheckUnderstandability = false;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: CheckboxListTile(
                      title: const Text("詳しく"),
                      subtitle: const Text("詳しい部分まで要約します"),
                      secondary: const Icon(Icons.article),
                      value: isCheckedDetailed,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          isCheckedBusy = false;
                          isCheckedDetailed = true;
                          isCheckUnderstandability = false;
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
                          isCheckedDetailed = false;
                          isCheckedBusy = false;
                          isCheckUnderstandability = true;
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

class Professor {
  String id;
  String name;
  List<int> scores;

  Professor({
    required this.id,
    required this.name,
    required this.scores,
  });
}
