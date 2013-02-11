use strict;
use utf8;
use Test::More 'tests' => 83;
use Encode;

BEGIN { use_ok 'Acme::Nyaa' }
sub e { return encode 'utf8', shift; }

my $sabatora = Acme::Nyaa->new( 'language' => 'ja' );
isa_ok( $sabatora, 'Acme::Nyaa' );
is( $sabatora->{'language'}, 'ja' );

my $textlist = [
	'猫がかわいい。',
	'暑さ寒さも彼岸まで',
	'後は野となれ山となれ',
	'言うは易く行なうは難し',
	'犬も歩けば棒に当たる',
	'海老で鯛を釣る',
	'猫の手も借りたい',
	'芝生に入るな。',
	'モーニング娘。',
];

my $sentence = [
	# http://www.aozora.gr.jp/cards/000148/files/789_14547.html
	'吾輩は猫である。名前はまだ無い。',
	'どこで生れたかとんと見当がつかぬ。何でも薄暗いじめじめした所でニャーニャー泣いていた事だけは記憶している',
	'吾輩はここで始めて人間というものを見た。しかもあとで聞くとそれは書生という人間中で一番獰悪な種族であったそうだ。',
	'この書生というのは時々我々を捕えて煮て食うという話である。しかしその当時は何という考もなかったから別段恐しいとも思わなかった。',
	'ふと気が付いて見ると書生はいない。たくさんおった兄弟が一疋も見えぬ。',
	'肝心の母親さえ姿を隠してしまった。その上今までの所とは違って無暗に明るい。眼を明いていられぬくらいだ。',
	'寒月と主人は「フフフフ」と笑い出す。',
	'吾輩は我慢に我慢を重ねて、ようやく一杯のビールを飲み干した時、妙な現象が起った。',
	'吾輩も日本の猫だから多少の愛国心はある。',
	'この垣根の穴は今日に至るまで吾輩が隣家の三毛を訪問する時の通路になっている。',
	'三毛子はこの近辺で有名な美貌家である。',
	'町内で吾輩を先生と呼んでくれるのはこの三毛子ばかりである。',
	'障子の内で御師匠さんが二絃琴を弾き出す。「宜い声でしょう」と三毛子は自慢する。',
	'御師匠さんの声で「三毛や三毛や御飯だよ」と呼ぶ。',
	'三毛子の様子でも見て来ようかと二絃琴の御師匠さんの庭口へ廻る',
];

my $conversation = [
	'「そうよ」「御嫁に行った」「妹の御嫁に行ったですよ」',
	'「三毛子さん三毛子さん」',
	'「寒月君はどうだい」「私にもちと分りかねますな」',
	'何か面白い種があるのだろうと思いまして……',
	'あの天璋院様の御祐筆の妹の御嫁にいった……',
	'御承知の通り、文学美術が好きなものですから……',
	'馬鹿な事を！',
	'大和魂！',
	'大抵なものなら噛み切れる訳だが、驚いた！',
	'何ですって？',
	'何、猫だ？',
	'何を食ったって？',
	'細君は主人に尻を向けて――なに失礼な細君だ？',
];

my $messages = [
	'神と和解せよ',
	'神のさばきは突然にくる',
	'不倫や姦淫を神はさばく',
	'心から神を信じなさい',
	'神は心を見る',
	'死後さばきにあう',
	'あなたの神はたヾひとり',
	'人の道も行いも神は見ている',
	'神は言っている ここで死ぬ定めではないと',
	'真の神を信じなさい',
	'神は世をさばく日を定めた',
];

my $wordlist = [
	'神',
	'八坂神社',
	'天照大神',
	'兵庫県神戸市',
	'八百万の神々',
	'神と化す',
];

my $english = [
	'Perl 5 is a highly capable, feature-rich programming language with over 24 years of development. ',
	'With free online books, over 25,000 extension modules, and a large developer community, there are many ways to learn Perl 5.'
];

foreach my $e ( @$textlist )
{
	my $text0 = $e;
	my $text1 = $sabatora->cat( \$text0 );
	my $text2 = $sabatora->cat( $text1 );
	ok( $text1, sprintf( "%s => %s", e($e), e($text1) ) );
	is( $text2, $text1, sprintf( "%s == %s", e($text2), e($text1) ) );
}

foreach my $e ( @$sentence )
{
	my $text0 = $e;
	my $text1 = $sabatora->cat( \$text0 );
	my $text2 = $sabatora->cat( $text1 );
	ok( $text1, e($text1) );
	is( $text2, $text1, '->cat() again' );
}

foreach my $e ( @$conversation )
{
	my $text0 = $e;
	my $text1 = $sabatora->cat( \$text0 );
	my $text2 = $sabatora->cat( $text1 );
	ok( $text1, e($text1) );
}

foreach my $e ( @$messages )
{
	my $text0 = $e;
	my $text1 = $sabatora->neko( \$text0 );
	my $text2 = $sabatora->neko( $text1 );
	ok( $text1, sprintf( "%s => %s", e($text0), e($text1) ) );
}

foreach my $e ( @$wordlist )
{
	my $text0 = $e;
	my $text1 = $sabatora->neko( \$text0 );
	my $text2 = $sabatora->neko( $text1 );
	ok( $text1, sprintf( "%s => %s", e($text0), e($text1) ) );
}

foreach my $e ( @$english )
{
	my $text0 = $e;
	my $text1 = $sabatora->cat( \$text0 );
	ok( $text1 );
}

