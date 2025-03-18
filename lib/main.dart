import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dart_openai/dart_openai.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

void main() async {
  await dotenv.load();
  runApp(MaterialApp(
    home: MyWidget(),
  ));
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String summarizedText = "", fileName = "";
  File? file;
  bool? isTranscription;
  bool? isLoading;

  Future<String> Transcription() async {
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

    return transcription.text;
  }

  Future<void> filePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file = File(result.files.single.path!);
      setState(() {
        fileName = basename(file!.path);
      });
    } else {
      print("ファイルが選択されていません");
    }
  }

  Future<String> summary(String inputText) async {
    const prompt_summary = """
  System
    ・You will be provided with transcribed text from university lectures. 
    ・Your task is to summarize the text as follows:
      ・Extract and condense the main points into no more than three key takeaways.
      ・Always summarize assignments and grading criteria, even if briefly mentioned.
        ・For assignments, include deadlines and tasks.
        ・For grading, summarize the evaluation method.
      ・Consider the context to correct minor transcription errors.
      ・Ensure the output is appropriate before returning it.
      ・Think in English but output in Japanese.
  User
    1.命題の逆と条件
      ・ある命題「PならばQ」に対し、矢印の向きを逆にしたものを「逆」と呼ぶ。
      ・「PならばQ」が真なら、PはQであるための十分条件。
      ・「QならばP」が真なら、PはQであるための必要条件。
    2.必要十分条件
      ・命題とその逆の両方が真なら、PとQは必要十分条件の関係にある。
      ・これは「同値」とも呼ばれ、ベン図ではPとQが完全に一致する。
    3.覚え方
      ・「十分条件」は漢字の「十」と「分」で表現。
      ・「必要条件」は漢字の「必」や「要」を使って記憶。
    課題・評価方法
      ・課題や成績評価についての具体的な言及はなし。
  """;
    // ここにGPTとのやり取り
    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-4o",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: prompt_summary,
          role: OpenAIChatMessageRole.system,
        ),
        OpenAIChatCompletionChoiceMessageModel(
          content: inputText,
          role: OpenAIChatMessageRole.user,
        ),
      ],
    );
    return chatCompletion.choices[0].message.content;
  }

  Future<void> summarize() async {
    setState(() {
      isTranscription = true;
    });
    String allText = await Transcription();
    print("文字全文： $allText");
    setState(() {
      isTranscription = false;
      isLoading = true;
    });
    summarizedText = await summary(allText);
    print("要約した文： $summarizedText");
    setState(() {
      isLoading = false;
      summarizedText = summarizedText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("シラバス要約動画"),
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
                      child: Text("ファイルを選択する")),
                  fileName != ""
                      ? Text("ファイル名：${fileName}")
                      : const SizedBox.shrink(),
                  ElevatedButton(
                      onPressed: () {
                        summarize();
                      },
                      child: Text("要約する")),
                  isTranscription == true
                      ? Text("音声をテキストに変換中……")
                      : const SizedBox.shrink(),
                  isLoading == true
                      ? Text("テキストを要約中……")
                      : const SizedBox.shrink(),
                  MarkdownBody(data: summarizedText)
                ],
              ),
            ),
          ),
        ));
  }
}
