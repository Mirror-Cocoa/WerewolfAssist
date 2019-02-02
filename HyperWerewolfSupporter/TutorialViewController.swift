//
//  TutorialViewController.swift
//  HyperWerewolfSupporter
//
//  Created by Ichiro Miura on 2019/01/27.
//  Copyright © 2019年 mycompany. All rights reserved.
//

import Foundation
import UIKit
import Gecco

class TutorialViewController: UIViewController, SpotlightViewControllerDelegate {
    
    private var spotlightViewController: SpotlightViewController!
    
    var stepIndex: Int = 0
    let maxIndex = 36
    let minIndex = 0
    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var currentStep: UILabel!
    
    @IBOutlet var img: UIImageView!
    @IBOutlet weak var desc: UITextView!
    
    let quotation = ["""
【タイトル画面】
この度は人狼アシスタントを
インストールしていただき、
ありがとうございます。

まずは、
下部にある[人物リスト]
ボタンを押してみましょう！▼
""","""
【人物登録 (1 / 10)】
このような画面が出てきます。
未登録なので、表に誰もいません。
物寂しいですね。

誰かを追加してみましょう。▼
""","""
【人物登録 (2 / 10)】
右上の[追加・削除]を押すと...▼
""","""
【人物登録 (3 / 10)】
このような画面が出てきます。
""","""
【人物登録 (4 / 10)】
左上の[+]を押すと...▼
""","""
【人物登録 (5 / 8)】
人物登録用の
ダイアログが出現します。

人の名前を入力して、
OKを押してください。

今回、参加者に
小坂シーナさんがいたと仮定して
「小坂シーナ」と入力します▼
""","""
【人物登録 (6 / 10)】
「小坂シーナ」さんが登録されました。
""","""
【人物登録 (7 / 10)】
これを繰り返し、
人数分入力しましょう。

人狼ゲームの参加表明をした際に、
この機能を使うと良いです。

また、参加者が固定されている場合は
あらかじめリストに登録しておくとより効果的です。▼
""","""
【人物登録 (8 / 10)】
人物の登録が終わったら、右上の[完了]を押しましょう。▼
""","""
【人物登録 (9 / 10)】
これで人物が登録されました。

間違って入力した時は、
この画面で名前をタップすると
名前の修正ができます。

自分の名前を「川瀬玲人」と仮定して
「川瀬玲人」を長押ししてみます。▼
""","""
【人物登録 (10 / 10)】
「あなた」を登録できます。
「あなた」は、強制的に参加ができ、自分の席を手前に表示できます。
「あなた」登録をしないと、このアプリが使えなくなるので注意してください。


「今、順番変わってない？」と思った方、目ざといです。
タイトル画面から戻ってきた時、自動的に名前順に順番を変更してくれます。▼
""","""
【初期配置登録画面(1 / 5)】
今度はいよいよ本番です。
タイトル画面から[Player Mode]ボタンを押してみましょう！▼
""","""
【初期配置登録画面(2 / 5)】
参加者の人数を入力してください。
参加者の人数によって、机が配置されます。

今回は、8人とします。▼
""","""
【初期配置登録画面(3 / 5)】
初期配置登録画面です。
右側の人物登録リストをタップすると、机上に反時計回りに人が追加されていきます。

登録されているメンバーはちょうど8人なので、上から全員タップします。▼
""","""
【初期配置登録画面(4 / 5)】
全員追加されました。

ちなみに、参加者に漏れがあっても、ここで新規にメンバーを追加することもできます。

(削除、変更はここではできません。)▼
""","""
【初期配置登録画面(5 / 5)】
[次へ]ボタンを押しましょう。

規定の人数に達していない場合、
[次へ]ボタンが押せないことに注意してください。▼
""","""
【議論中画面 (1 / 17)】
いよいよ議論中の画面です。
色々な機能があるので、見ていきましょう。▼
""","""
【議論中画面 (2 / 17)】
議論時間の再生/停止ボタンです。
再生ボタンを押すことで、右にある残り時間を刻々と刻みます。

再生ボタンは一時停止と切り替わり、一時停止ボタンを押すと、時間が止まります。

停止ボタンを押すと、強制的に0:00にすることができます。

尚、アラームなどは今回鳴動しません。ご了承ください。▼
""","""
【議論中画面 (3 / 17)】
議論時間の増減ボタンです。
30秒刻みでプラスマイナスをすることができます。

最大議論時間は10分です。▼
""","""
【議論中画面 (4 / 17)】
役職プレートです。

種類は全てで「占」「霊」「狩」「共」「狂」「狼」の6種類あります。

試しにタップしてみましょう。▼

(役職って何？という方や、人狼初心者な方は下の表を参照してください。)



〜村人サイド〜
占：
占い師。毎晩誰かを占い、
白か黒かを判定する。(別名：預言者 etc)

霊：
霊能者。前日に吊られた人物を判定する。
(別名：霊媒師 etc)

狩：
狩人。毎晩誰か一人を殺害する人狼から守る。
守る対象を自分にはできない。
(別名：騎士、ハンター etc)

共：
共有者。ゲーム前に2人だけで目を開ける。
お互いにその人は村人サイドであることがわかる。

〜人狼サイド〜
狂：
狂人。狼の味方。
人狼サイドが勝てば勝利。
狼が誰かは知らない。
占い結果は「白」と出る。

狼：
人狼。毎晩誰か一人を襲撃する。
占い結果は「黒」と出る。
""","""
【議論中画面 (5 / 17)】
右下に、「現在のモード」と
表示されていた部分がありましたが、
今は「CO 白　黒　溶」
に切り替わっています。

水色が現在のモード、
灰色が現在のモードではないモードです。
現在のモードは「CO」です。

試しに、占いのCO結果を見てみましょう。▼

(CO：カミングアウトの略称。「私はこの役職です」と言うことを指す)
""","""
【議論中画面 (6 / 17)】
おっと。

「和高麻里」さんと・・・▼
""","""
【議論中画面 (7 / 17)】
「天津紗枝」さんがCOしてきました。

この2人をタップしてみましょう。▼
""","""
【議論中画面 (8 / 17)】
占いに誰がCOしたかがわかりました。

右の表にも反映されていますね。

では、占い結果はどうでしょう？▼
""","""
【議論中画面 (9 / 17)】
モードを「白」に変えて、
占い師からドラッグ & ドロップしましょう。

今回、正面から占いたかった二人は、

「和高麻里」さんが
「折田心」さんを占って「白」

「天津紗枝」さんが
「川瀬玲人」を占って「白」
だったので、各々ドラッグ & ドロップします。

もちろん、
モードを「黒」にした場合は「黒」
モードを「溶」にした場合は「溶」が出てきます。

また、占い結果を修正することも可能です。▼



(「溶」って何？という方や、人狼初心者な方は下の説明を参考にしてください。)
〜溶けるという概念〜

人狼における役職には
先ほど説明したものの他に、
「狐」という役職があります。

この役職は第3陣営です。

村人サイドor人狼サイドの
勝利が決した時に生き残っていれば、
単独で勝つことができます。

人狼に噛まれても平気です。

但し、狐には弱点があります。
それは占われることです。

その場合、狐は溶けて命を落としてしまいます。

それを、人狼ゲームでは「溶ける」と呼称します。
""","""
【議論中画面 (10 / 17)】
おっと。
「飯川瑠依香」さんが
霊媒師をCOしてきたので、
先ほどの手順で
役職プレート「霊」をタップ
→「飯川瑠依香」さんをタップしました。▼
""","""
【議論中画面 (11 / 17)】
カレンダーです。
今日が何日目かを表しています。▼
""","""
【議論中画面 (12 / 17)】
日付の増減ボタンです。
翌日の朝になったら
[+]ボタンを押してみましょう。

また、[-]ボタンを押すことで、
潜伏していた人の占い結果を
遡って反映することができます。

占い結果一覧にも
日付が参照されます。▼



(潜伏って何？という方や、人狼初心者な方は下記の説明を参考にしてください。)
〜潜伏という概念〜
人狼ゲームは、
何日も続くゲームです。

例えば、
2日目までは役職のない
村人として振る舞っていた人が
3日目の朝に、
誰かが占いをCOしたとします。

これが潜伏です。
黙っていることを指します。

そうすると、
2つ以上の結果が出てくるはずです。

その結果を残したいとき、例えば
1日目→Aさん白(◯)
2日目→Bさん白(◯)
3日目→Cさん黒(●)
とする必要があるため、
日付の遡り機能を作成しました。
""","""
【議論中画面 (13 / 17)】
翌日の朝、[+]ボタンを押したら
【吊られた人を選択】が表示されます。
誰が吊られたか選択し、
[Done]を押してください。

今回は「小坂シーナ」さんが
吊りの対象となったため、
「小坂シーナ」さんを選択し、
[Done]を押します。

次は、
【噛まれた人を選択】に切り替わります。▼
""","""
【議論中画面 (14 / 17)】
【噛まれた人を選択】が表示されます。
誰が襲撃されたかを選択し、
[Done]を押してください。

1人だけの場合は、
左側のみ操作してください。
同一人物を指した場合は、
無効となります。

今回は「天津紗枝」さんが
人狼の襲撃対象となったため、
左側の「天津紗枝」さんを選択し、
[Done]を押します。

誰も襲撃されなかった場合、
GJを選択してください。▼


(GJ：Good Jobの略称。狩人が人狼からの襲撃を守った場合に、死亡者が出ないことを指す)
""","""
【議論中画面 (15 / 17)】
翌朝、
「小坂シーナ」さんが吊られ、
「天津紗枝」さんが
襲撃されたことがわかりました。

吊られた人には
幽霊のアイコンが、
襲撃された人には
スプーンとフォークのアイコンが
それぞれつきます。

右側の表をスライドすると、
吊られた人と
噛まれた人がそれぞれ出てきます。▼
""","""
【議論中画面 (16 / 17)】
2日目、占い結果として
「和高麻里」さんが「大庭加奈子」さんを
占って「白」と出しました。
やり方は、ページと同様です。

右側の表にも反映されましたね。▼
""","""
【議論中画面 (17 / 17)】
2日目、霊能者の結果として
「飯川瑠依香」さんが前日吊られた
「小坂シーナ」さんを占って「黒」と出しました。
占う時は、「飯川瑠依香」をタップしましょう。

右側の表にも反映されましたね。
この表は、スライドをすることも可能です。▼
"""]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func prevClick(_ sender: Any) {
        if (self.minIndex >= self.stepIndex) { return }
        self.stepIndex -= 1;
        displayUpdate()
    }
    
    @IBAction func nextClick(_ sender: Any) {
        if (self.maxIndex - 1 <= self.stepIndex) { return }
        self.stepIndex += 1;
        displayUpdate()
    }
    
    func displayUpdate() {
        self.currentStep.text = String(self.stepIndex + 1)
        self.img.image = UIImage(named:"img_" + String(self.stepIndex))
        self.desc.text = self.quotation[self.stepIndex]
        self.desc.contentOffset = CGPoint.zero
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.desc.contentOffset = CGPoint.zero //set
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.desc.contentOffset = CGPoint.zero //keep
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.desc.contentOffset = CGPoint.zero //init
    }
    
    
}