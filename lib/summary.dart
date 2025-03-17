import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  runApp(const Summary());
}

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  var text = '';
  Future<void> AIchat() async {
    await dotenv.load();
    OpenAI.apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    const prompt_summary = "下記の文章から「タイトル」「新機能や改善点」「タグ」を抽出し、日本語で出力してください";
    final user_message =
        """ポインタやリスト構造を利用したデータ構造およびハッシュ法を理解し，双方向リストやリングバッファ，ハッシュの計算方法を説明できる．(知識・理解)
        木構造の基本および２分探索木や平衡木の原理を理解し，その動作を説明できる．(知識・理解)
        グラフ構造の基本および基本的な探索問題の解法について理解し，その動作を説明できる．(知識・理解)
        文字列探索，字句解析など，文字，文字列，字句の解析方法について理解し，その動作を説明できる．(知識・理解)
        深さ優先／ 幅優先などによる解空間の一般的な探索法および分割統治法や動的計画法などの効率的な解法について理解し，その動作を説明できる．(知識・理解)""";
    // ここにGPTとのやり取り
    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: prompt_summary,
          role: OpenAIChatMessageRole.system,
        ),
        OpenAIChatCompletionChoiceMessageModel(
          content: user_message,
          role: OpenAIChatMessageRole.user,
        ),
      ],
    );
    print(chatCompletion.choices[0].message.content);
    setState(() {
      text = chatCompletion.choices[0].message.content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("要約画面"),
        ),
        body: Padding(
            padding: EdgeInsets.all(15),
            child: Center(
              child: Column(
                children: [
                  Text("ここにGPTのメッセージ"),
                  ElevatedButton(
                      onPressed: () {
                        AIchat();
                      },
                      child: Text("要約する")),
                      Text(text)
                ],
              ),
            )),
      ),
    );
  }
}
