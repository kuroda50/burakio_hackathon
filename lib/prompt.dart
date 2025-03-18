class Prompt {
  static const promptSummaryBusy = """
    Summarize the following university lecture transcript for a busy person.
      ・Condense lecture content into key points, including assignments and grading criteria
      ・Keep the summary within 50-75 words, prioritizing the most important information.
      ・Think in English but output in Japanese.""";

  static const promptSummaryDetailed = """
    ・You will be provided with transcribed text from university lectures. 
    ・Your task is to summarize the text as follows:
      ・Extract and condense the main points into no more than three key takeaways.
      ・Always summarize assignments and grading criteria, even if briefly mentioned.
        ・For assignments, include deadlines and tasks.
        ・For grading, summarize the evaluation method.
      ・Consider the context to correct minor transcription errors.
      ・Ensure the output is appropriate before returning it.
      ・Think in English but output in Japanese.""";

  static const promptSummaryUnderstandability = """
    Evaluate the following lecture’s clarity for students who are considering whether to take the class.
      ・Rate the clarity of the lecture on a scale of 1 to 5.
      ・If the lecture is difficult to understand or has many spelling mistakes, give a lower rating.
      ・Focus on clarity, and do not worry about inaccuracies.
      ・Think in English but output in Japanese.
      ・必ず、以下の形式で出力してください。
      **評価: (評価数)/5**
        (評価についての説明)
  """;

  static const exampleUserText = """
      前回 の 超 分かる 高校 数学 は ？ 
      次 の 問い に 答え て ください 。 
      条件 p の 否定 を 集合 で 表す と 補 集合 に 当たる 部分 に なる 。 
      全て や 任意 と 、 あるいは 否定 の 関係 に なる 。 これ を 覚えよう 。 
      今日 は まず 逆 に つい て 学ぼう 。 
      例えば 、 ミッキー マウス なら ば ネズミ と いう 命題 に 対し て 、 矢印 の 向き を 逆 に し た もの 。 ネズミ なら ば ミッキー マウス 。 
      これ を 逆 と いう ところ で 元 の 命題 。 
      ミッキー マウス なら ば ネズミ は ミッキー マウス って 確か に ネズミ だ から 真 に なる ね 。 
      これ を ミッキー マウス は ネズミ で ある ため の 十分 条件 と いう ミッキー マウス と いう 名前 を 聞い て 、 ネズミ じゃ ない 動物 を 想像 する 人 は い ない よ ね 。 
      ミッキー マウス は ネズミ で ある こと を 特定 する ため に は 十分 な 情報 だ から 、 この 状況 を 十分 条件 と いう 。 
      一般 的 に p なら ば q が 真 で ある こと p は q で ある ため の 十分 条件 と いう 。 
      これ を ベンズ で 表す と 、 p が q に すっぽり 入る 状況 に なる から 、 この 包含 関係 も 覚えよう 。 
      次 に メガネ 少年 なら ば ハリー ポッター 。 この 命題 は 偽 に なる 。 
      もし これ が 真 だっ たら 、 世界 中 の 少年 が 眼鏡 かけ た 瞬間 に 魔法 を 使える って こと に なっ ちゃう から やばい よ ね 。 
      ところ が 命題 の 逆 ハリー ポッター なら ば 、 メガネ 少年 は ハリー ポッター って 確か に 眼鏡 少年 だ から 真 に なる ね 。 
      これ を メガネ 少年 は ハリー ポッター で ある ため の 必要 条件 と いう 。 
      世界 に は 眼鏡 少年 が いっぱい いる から 、 眼鏡 少年 と いう 情報 だけ で 、 そいつ が ハリー ポッター だ と 特定 する こと は でき ない けど 、 少なく とも ハリー ポッター を 特定 する ため に 眼鏡 少年 と いう 情報 は 必要 だ から 、 この 状況 を 必要 条件 と いう 。
      一般 的 に p なら ば q の 逆 九 なら ば 、 p が 真 で ある こと p は q で ある ため の 必要 条件 と いう 。 
      これ を ベンズ で 表す と 、 q が p に すっぽり 入る 状況 に なる から 、 この 包含 関係 も 覚えよう 。 
      次 に アン パン の ヒーロー なら ば アン パン マン 。 
      これ は 元 の 命題 も 逆 も 、 どちら も 真 に なる 。 
      これ は 十分 条件 で も 必要 条件 で も ある から 、 必要 十分 条件 と いう 。 
      つまり 、 左 と 右 は 全く 同じ こと を 言っ て いる と いう こと 。 
      一般 的 に p なら ば q と 、 その 逆 q なら ば p が どちら も 真 で ある こと 、 p が q で ある ため の 必要 十 分 条件 また は 同値 と いっ て 両 方向 の 矢印 の 記号 で 表す 。 
      これ を ベンズ で 表す と 、 p と q が 完全 に 一致 する 状況 に なる から 、 この 包含 関係 も 覚えよう 。 最後 に 十 分 条件 の 必要 条件 の 覚え 方 を 紹介 しよう 。 
      p なら ば q が 真 で 、 その 逆 が 偽 の 時 は p は q で ある ため の 十 分 条件 に なる 。 
      これ は ここ に 線 を 引い て 数字 の 十 ここ に 刀 を 書い て 漢字 の 文 、 つまり 十 分 条件 に なる p なら ば q が 偽 で 、 その 逆 が 真 の 時 は p は q で ある ため の 必要 条件 に なる 。 
      これ は ここ に 点 を 打っ て 漢字 の 質 うわあ って 書け ば 漢字 の よう 。 
      つまり 必要 条件 に なる 。 この 覚え 方 は マジ で 半端 ない から 是非 これ で 覚えよう 。 
      今日 の 動画 内容 を まとめる と 、 ある 命題 に 対し て 矢印 の 向き を 逆 に し た もの を 逆 と いう p なら ば q が 真 で ある こと p は q で ある ため の 十 分 条件 、 逆 が 真 で ある こと p は q で ある ため の 必要 条件 。 
      いずれ も 真 で ある こと を 必要 十 分 条件 と 言い ベンズ で 表す と 、 包含 関係 は それぞれ こう なる 。 
      右 が 真 で 左 が 偽 の 時 は ここ に 一 を 書い て 数字 の 十 ここ に 漢字 の 刀 を 書い て 漢字 の 文 、 つまり 十 分 条件 に なる 。 
      右 が で 左 が 真 の 時 は ここ に 点 を 書い て 漢字 の 質 。 
      これ を 改造 すれ ば 漢字 の 用 、 つまり 必要 条件 に なる 。 これ を 覚えよう 。 
      ありがとう ござい まし た 。 今日 の 作品 は どう でし た か ？ 
      気 に 入っ て くれ たら 是非 チャンネル 登録 を お 願い し ます 。 
      twitter は 公式 ホーム ページ から 。 次 の 作品 は こちら から お 願い し ます 。 
      いつ も 素敵 な コメント ありがとう ござい ます ！ 
      """;
  static const exampleBusyAnswerText = """
    この講義では、命題の逆と条件について学びました。逆命題（例：ミッキーマウスならネズミ）や、十分条件（例：pがqならばpはqの十分条件）について説明し、必要条件（例：メガネ少年はハリー・ポッター）も触れました。必要十分条件は、両方向が真である場合です。課題として、命題の条件を図で示し、覚え方を練習することが求められます。
  """;
  static const exampleDetailedAnswerText = """
    **1.命題の逆と条件**
      ・ある命題「PならばQ」に対し、矢印の向きを逆にしたものを「逆」と呼ぶ。
      ・「PならばQ」が真なら、PはQであるための十分条件。
      ・「QならばP」が真なら、PはQであるための必要条件。
    **2.必要十分条件**
      ・命題とその逆の両方が真なら、PとQは必要十分条件の関係にある。
      ・これは「同値」とも呼ばれ、ベン図ではPとQが完全に一致する。
    **3.覚え方**
      ・「十分条件」は漢字の「十」と「文」で表現。
      ・「必要条件」は漢字の「質」や「用」を使って記憶。
    **課題・評価方法**
      ・課題や成績評価についての具体的な言及はありませんでした。
  """;
  static const exampleUnderstandabilityAnswerText = """
  **評価: 4/5**
  この教授は、全体的にかなり親しみやすく、日常的な例（例えばミッキーマウスや眼鏡少年）を使っているため、直感的に理解しやすいと思います。
  ただし、内容の密度が高く、完全に理解するのは難しい部分もあります。非常に分かりやすく説明されているものの、数学的な背景や論理の理解がある程度必要なため、完全に初心者には少しハードルが高いかもしれません。それでも、例え話を交えて理解を助けている点が素晴らしいです。
  """;
}
