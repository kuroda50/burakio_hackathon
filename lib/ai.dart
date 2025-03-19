import 'dart:io';
import 'color.dart';
import 'prompt.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // ← JSON デコードに使う
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/process_run.dart'; // 追加

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
  String summarizedText = "",
      fileName = "",
      alertText = "",
      profileUrl = "",
      avatarUrl = "";
  File? file;
  bool? isTranscription, isLoading;
  bool isCheckedBusy = true,
      isCheckedDetailed = false,
      isCheckUnderstandability = false;
  Professor? professor;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await buildData();
    });
  }

  Future<void> buildData() async {
    professor = await getProfessor();
    File tempFile = await getFile(professor!.id);
    setState(() {
      professor = professor;
      file = tempFile;
    });
    await fetchProfileAndAvatar(professor!.name);
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

  Future<String> summary(String inputText) async {
    setState(() {
      isLoading = true;
    });
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

  Future<void> analyzeAvatar(File avatarImageFile) async {
    final apiKey = dotenv.env['GOOGLE_VISION_API_KEY'] ?? '';
    final url = Uri.parse(
        'https://vision.googleapis.com/v1/images:annotate?key=$apiKey');

    // 画像ファイルをBase64に変換
    final bytes = await avatarImageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final requestBody = jsonEncode({
      "requests": [
        {
          "image": {"content": base64Image},
          "features": [
            {"type": "FACE_DETECTION", "maxResults": 1}
          ]
        }
      ]
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Vision API Response: $data');

        final faceAnnotations = data['responses'][0]['faceAnnotations'];
        if (faceAnnotations == null || faceAnnotations.isEmpty) {
          print('😶 顔が検出されませんでした');
          setState(() {
            alertText = '顔が見つかりませんでした';
          });
          return;
        }

        final face = faceAnnotations[0];

        // ここでは「joyLikelihood」「angerLikelihood」などを使って気難しさをざっくり推定！
        final angerLikelihood = face['angerLikelihood'];
        final joyLikelihood = face['joyLikelihood'];

        // 独自の気難しさスコアを作る
        String mood = '';
        int score = 3; // デフォルト普通

        if (angerLikelihood == 'VERY_LIKELY' || angerLikelihood == 'LIKELY') {
          mood = 'かなり厳しそう';
          score = 5;
        } else if (angerLikelihood == 'POSSIBLE') {
          mood = '少し厳しそう';
          score = 4;
        } else if (joyLikelihood == 'VERY_LIKELY' ||
            joyLikelihood == 'LIKELY') {
          mood = 'とても穏やかで優しそう';
          score = 1;
        } else {
          mood = '普通、ニュートラル';
          score = 3;
        }

        setState(() {
          alertText = '気難しさ分析結果:\nスコア: $score / 5\n理由: $mood';
        });
      } else {
        print('❌ Vision API エラー: ${response.statusCode}');
        print(response.body);
        setState(() {
          alertText = 'Vision API エラー: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('❌ Vision API 通信エラー: $e');
      setState(() {
        alertText = 'Vision API 通信エラー';
      });
    }
  }

  Future<void> saveScore() async {
    RegExp regExp = RegExp(r'評価: *(\d)/5');
    Match? match = regExp.firstMatch(summarizedText);
    if (match != null) {
      String? scoreText = match.group(0);
      print("スコアが見つかりました: $scoreText");
    } else {
      print("一致する文がみつかりません");
    }
  }

  Future<void> fetchProfileAndAvatar(String researcherName) async {
    const flaskServerUrl = 'http://192.168.224.133:5000';
    final endpoint = '$flaskServerUrl/get_avatar';

    try {
      print('🔗 Flaskサーバーへリクエスト開始: $endpoint');

      final uri = Uri.parse('$endpoint?researcher_name=$researcherName');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String avatarUrlFromServer = data['avatar_url'];
        String profileUrlFromServer = data['profile_url'];

        print('✅ アバターURL取得成功: $avatarUrlFromServer');
        print('🔗 プロフィールURL取得成功: $profileUrlFromServer');

        setState(() {
          profileUrl = profileUrlFromServer;
          avatarUrl = avatarUrlFromServer;
        });
      } else {
        print('❌ エラー: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('❌ 例外発生: $e');
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
                professor != null ? Text(professor!.name) : Text("教授の情報を取得中……"),
                SizedBox(height: 16),

                // 🔽 追加：アバター画像表示
                avatarUrl.isNotEmpty
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(avatarUrl),
                      )
                    : const SizedBox.shrink(),

                SizedBox(height: 16),

                // プロフィールURL表示
                profileUrl.isNotEmpty
                    ? InkWell(
                        onTap: () {
                          // Webブラウザで開くなどの処理を追加してもOK！
                          print("プロフィールURLをタップしました: $profileUrl");
                        },
                        child: Text(
                          "プロフィールを見る",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),

                SizedBox(height: 24),

                //気難しさ分析ボタン
                ElevatedButton(
                  onPressed: () async {
                    if (avatarUrl.isNotEmpty) {
                      setState(() {
                        alertText = '画像を取得しています...';
                      });

                      try {
                        // avatarUrlをFileに変換する
                        final avatarFile = await urlToFile(avatarUrl);

                        // analyzeAvatarにFileを渡す！
                        await analyzeAvatar(avatarFile);
                      } catch (e) {
                        setState(() {
                          alertText = '画像の取得に失敗しました: $e';
                        });
                      }
                    } else {
                      setState(() {
                        alertText = "まずはアバター画像を取得してください！";
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.buttonColor,
                  ),
                  child: Text(
                    "気難しさを分析する",
                    style: TextStyle(
                      color: AppColor.subTextColor,
                    ),
                  ),
                ),

                SizedBox(height: 16),

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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.buttonColor,
                  ),
                  child: Text(
                    "要約/評価する",
                    style: TextStyle(
                      color: AppColor.subTextColor,
                    ),
                  ),
                ),

                SizedBox(height: 16),

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

                SizedBox(height: 16),

                // チェックボックス
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

                SizedBox(height: 24),

                // 要約されたMarkdownテキスト
                MarkdownBody(
                  data: summarizedText,
                  softLineBreak: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Professorモデル
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

void exampleFunction({required String path, required String researcherName}) {
  // 何かの例として残ってる関数
}

Future<File> urlToFile(String imageUrl) async {
  final http.Response response = await http.get(Uri.parse(imageUrl));
  final documentDirectory = await getTemporaryDirectory();
  final file = File('${documentDirectory.path}/avatar.jpg');
  file.writeAsBytesSync(response.bodyBytes);
  return file;
}
