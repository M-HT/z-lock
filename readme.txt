/*==========================================================================
 *
 *  Copyright (C) 2005,2006 HELLO WORLD PROJECT. All Rights Reserved.
 *
 *  ○ゲームタイトル：Z-LOCK
 *  ○ジャンル      ：縦方向スクロールシューティング
 *  ○プレイ人数    ：一人
 *  ○バージョン    ：0.11
 *  ○公開日付      ：2005/08/29
 *  ○更新日付      ：2006/09/09
 *
 ==========================================================================*/

・はじめに

  狙われて強くなれ。さあみんな、俺にロックオン。


・ルール

  敵を倒してボスを倒して、ステージをクリアしてください。
  敵や敵弾に当たると、死にます。残機がなくなるとゲームオーバーです。

  敵は、自機にロックオンしてきます。
  ロックオンした後、一定時間経つと弾を撃ちます。

  敵にロックされると、自機のショットがパワーアップします。
  ショットのパワーによって、敵を倒した時のスコアが変わります。
  なるべくロックされて、その状態で敵を倒しましょう。


・操作説明

  自機移動  ：キーボードカーソルキーorジョイパッドの十字キー
  ショット  ：キーボードZキーorジョイパッドの一つ目のボタン
  吸着      ：キーボードXキーorジョイパッドの二つ目のボタン(NORMAL & ORIGINAL)

  ゲーム中、ESCでタイトルに戻ります。タイトルで押すと z-lock を終了します。

・メインメニュー説明

  NORMAL MODE  ：通常のモードです。
  CONCEPT MODE ：ルールの変わったモードです。
  ORIGINAL MODE：このゲームの原型となったモードです。
  HIDDEN MODE  ：敵弾がロックカーソルに近づくにつれ見えなくなるモードです。
  SCORE ATTACK ：３分間に何点稼げるかを競うモードです。
  TIME ATTACK  ：100万点を取るまでの時間を競うモードです。
  SOUND        ：サウンドに関する設定やテストができます。
  EXIT         ：Z-LOCK を終了します。


・モード説明

  このゲームには３種類のモードがあります。
  以下、それぞれについて簡単に説明します。

  「NORMAL MODE」
    普通に弾が撃てるモードです。
    ゲージは開放型で、ゲージがMAXの時にしか発動できません。
    一度ゲージを開放すると、なくなるまで消費しつづけます。
    ゲージがなくなった後は、回復するまで開放できませんが、ショットは撃つことが
    できます。

  「CONCEPT MODE」
    最低限一つ以上ロックされて無いと弾が撃てません。
    ショットを打つと、自動的にロックされます。
    ゲージは消費型で、押している間は消費します。放している間は回復します。
    ゲージがMAXになると、一定時間（ゲージが回復するまでの間）弾が撃てません。い
    わゆる「オーバーヒート状態」になります。

  「ORIGINAL MODE」
    このゲームのルールの元となったモードです。
    最低限一つ以上ロックされて無いと弾が撃てません。
    ゲージは開放型で、ゲージがMAXの時にしか発動できません。
    一度ゲージを開放すると、なくなるまで消費しつづけます。
    ゲージがなくなった後は、回復するまで開放できませんが、ロックされてさえいれば
    ショットは撃つことができます。

  「HIDDEN MODE」
    敵弾がロックカーソルに近づくにつれ見えなくなるモードです。
    敵弾は最初は見えますが、ロックカーソルに近づくのに反比例して、表示が薄くなり
    ます。
    それ以外は「NORMAL MODE」と同じです。
    このモードのみ、ステージ経過の保存がありません。

  以上の制約以外は、基本的には違いはありません。

  「SCORE ATTACK」「TIME ATTACK」は、「HIDDEN MODE」以外から選ぶことができます。
  （ハイスコアは別々に保存されます）


＜最後に＞

・謝辞

  Z-LOCK は D言語 で書かれています(ver. 0.129)。
    D Programming Language
    http://www.digitalmars.com/d/index.html
    日本語訳
    http://www.kmonos.net/alang/d/

  「ABA Games」のお世話になっております。
  弾の操作に BulletML を利用しています。
  弾定義に Bulletnote を利用しています。
  ソースの一部を PARSEC47 から流用しています。
    ABA Games
    http://www.asahi-net.or.jp/~cs8k-cyu/
    BulletML
    http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/index.html
    Bulletnote
    http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/bulletnote/index.html
    PARSEC47
    http://www.asahi-net.or.jp/~cs8k-cyu/windows/p47.html

  「Entangled Space」のお世話になっております。
  BulletML ファイルのパースにlibBulletMLを利用しています。
  D - porting の SDL_mixer ヘッダファイルを利用しています。
    Entangled Space
    http://user.ecc.u-tokyo.ac.jp/~s31552/wp/
    libBulletML
    http://user.ecc.u-tokyo.ac.jp/~s31552/wp/libbulletml/
    D - porting
    http://user.ecc.u-tokyo.ac.jp/~s31552/wp/d/porting.html

  画面の出力には Simple DirectMedia Layer を利用しています。
    Simple DirectMedia Layer
    http://www.libsdl.org/

  BGM と SE の出力に SDL_mixer と Ogg Vorbis CODEC を利用しています。
    SDL_mixer 1.2
    http://www.libsdl.org/projects/SDL_mixer/
    Vorbis.com
    http://www.vorbis.com/

  DedicateD の D言語用 OpenGL, SDLヘッダファイル を利用しています。
    DedicateD
    http://int19h.tamb.ru/files.html


＜最後に＞

  「ORIGINAL MODE」について。

  最初に断っておきます。すっかり忘れてました。このモード。
  というか「NORMAL」も「CONCEPT」も、元々はある呑み会で見せたのがきっかけで生ま
れたんですけどね。

  最初の最初は、こんなゲームではありませんでした。なんつーか「できそこないなサイ
ヴァリア」って感じで。

  2004年の9月から開発を始めて、そうですね、半年くらいはそのまま続けてたんですが、
ふと「思いきって変えてみよう」と。
  で、数ヶ月くらいあーだこーだしてるうちに、原型の一歩手前くらいになったんです。

  そんな折、「SDL-offやるよ」とのお達しがあって、まあ、集まりと呑みの好きな人間な
んで「イクイクーイッチャウゥー！」と。
  そんときに見せたんですよ。SDL-offの面子に。

  で、そこで出た意見。

  「あーあれですね。狙われないと弾撃てないてどうですか？」

  普通なら引くでしょ。でもまあ、そんとき普通じゃなかったし。
  そんでまあ、その場に開発環境があるという、いかにもなoff現場というか状況だったの
で、ジョッキ片手にポチポチっとソース編集してコンパイル＆実行してやってみてもらっ
たわけですよ。

  結果、爆笑。そして概ね好評。

  その後、お家に帰って、その結果を反映したまでは良かったんですが。
  アレコレ、考えすぎちゃったんですよね。いわゆる「CONCEPT MODE」が、一週間と経たぬ
うちに別ものに。
  その間の変更で、すっかり元の形を忘れ去っていた、と。

  で、公開したあと、友人と呑んでて（またか）話を聞いて見ると、
  「おまえ、ヒヨッタな。」
  なんて言われて「？？？」。

  詳細を聞いてみると、「CONCEPT MODE はこうじゃなかっただろ」と。
  最初は「そうだっけ？」な状態だったけど。話を聞いて、そう言われてみれば、そうでも
なかったかもしれないかもしれないなあ･･･、と。
  で、「そういえば VAIO-U にまだ残ってたかも」と思い出して起動してみれば、

  「あー！」

  ってな感じですよ。そりゃ奥さん困ったもんだ。
  かくして、大急ぎで当時の仕様を再現してみました。思えばコレがなければ今の形も無か
った訳だし。そういう意味も含めて、 Ver0.11 で公開することにしました。

  このゲームをこういう形にしていただいた「SDL-off」メンバーに感謝いたします。

  次に「HIDDEN MODE」について。

  これは、これを公開するちょっと前にまた SDL-off のメンバーで呑むことがあって、そ
の場で出たアイデアなんです。
  なんだろう。音ゲーとかでよくあるよね？「音符が見えなくなるモード」。あれをシュ
ーティングでやったらどうなるんだろ？って話になったんです。


＜連絡＞

・御意見、ご感想などはこちらまで。
    ads00721@nifty.com


＜更新履歴＞

2005/09/04  Ver0.20  「ORIGINAL MODE」追加。というか、復活。
                     「HIDDEN MODE」追加。
                     音のボリュームを調整。今更。
                     自機爆発音をすっかり忘れていたので、追加。
2005/08/29  Ver0.10  公開。


＜ライセンス＞

Z-LOCK は BSDスタイルライセンスのもと配布されます。

<ENGLISH>
License
-------

Copyright 2005 HELLO WORLD PROJECT (Jumpei Isshiki). All rights reserved. 

Redistribution and use in source and binary forms, 
with or without modification, are permitted provided that 
the following conditions are met: 

 1. Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer. 

 2. Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, 
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 


<JAPANESE>
ライセンス
-------

Copyright 2005 HELLO WORLD PROJECT (Jumpei Isshiki). All rights reserved. 

 1.ソースコード形式であれバイナリ形式であれ、変更の有無に 関わらず、以下の条件を
   満たす限りにおいて、再配布および使用を許可します。

 2.ソースコード形式で再配布する場合、上記著作権表示、 本条件書および下記責任限定
   規定を必ず含めてください。 

バイナリ形式で再配布する場合、上記著作権表示、 本条件書および下記責任限定規定を、
配布物とともに提供される文書 および/または 他の資料に必ず含めてください。 
本ソフトウェアは HELLO WORLD PROJECT によって、”現状のまま” 提供されるものとし
ます。 本ソフトウェアについては、明示黙示を問わず、 商用品として通常そなえるべき
品質をそなえているとの保証も、 特定の目的に適合するとの保証を含め、何の保証もな
されません。 事由のいかんを問わず、 損害発生の原因いかんを問わず、且つ、 責任の
根拠が契約であるか厳格責任であるか (過失その他) 不法行為であるかを問わず、
 HELLO WORLD PROJECT も寄与者も、 仮にそのような損害が発生する可能性を知らされて
いたとしても、 本ソフトウェアの使用から発生した直接損害、間接損害、偶発的な損害、
 特別損害、懲罰的損害または結果損害のいずれに対しても (代替品または サービスの提
供; 使用機会、データまたは利益の損失の補償; または、業務の中断に対する補償を含め) 
責任をいっさい負いません。
