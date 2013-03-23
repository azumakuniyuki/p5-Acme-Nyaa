use strict;
use utf8;
use Test::More 'tests' => 1301;
use Encode;

BEGIN { 
	use_ok 'Acme::Nyaa';
	use_ok 'Acme::Nyaa::Ja';
}
sub e { 
	my $text = shift; 
	my $char = shift || q();

	Encode::from_to( $text, $char, 'utf8' ) if $char;
	utf8::encode $text if utf8::is_utf8 $text;
	return $text;	
}

my $nekotext = 't/cat-related-text.ja.txt';
my $textlist = [];
my $langlist = [ qw|af ar de el en es fa fi fr he hi id is la pt ru th tr zh| ];
my $encoding = [ qw|euc-jp 7bit-jis shift-jis| ];
my $cmethods = [ 'new', 'reckon', 'toutf8', 'utf8to' ];
my $imethods = [ 
	'cat', 'neko', 'nyaa', 'straycat',
	'language', 'findobject', 'objects', 'object',
];
my $sabatora = undef;

$sabatora = Acme::Nyaa->new( 'language' => 'ja' );
isa_ok( $sabatora, 'Acme::Nyaa' );
is( $sabatora->language, 'ja', '->language() = ja' );

$sabatora = Acme::Nyaa::Ja->new;
isa_ok( $sabatora, 'Acme::Nyaa::Ja' );
isa_ok( $sabatora->new, 'Acme::Nyaa::Ja' );
isa_ok( $sabatora->object, 'Acme::Nyaa::Ja' );
isa_ok( $sabatora->objects, 'Acme::Nyaa::Ja' );
isa_ok( $sabatora->findobject, 'Acme::Nyaa::Ja' );
is( $sabatora->language, 'ja', '->language() = ja' );
is( $sabatora->reckon( '猫' ), 'utf8', '->reckon() = utf8' );

can_ok( 'Acme::Nyaa::Ja', @$cmethods );
can_ok( 'Acme::Nyaa::Ja', @$imethods );

ok( -T $nekotext, sprintf( "%s is textfile", $nekotext ) );
ok( -r $nekotext, sprintf( "%s is readable", $nekotext ) );
open( my $fh, '<', $nekotext ) || die 'cannot open '.$nekotext;
$textlist = [ <$fh> ];
ok( scalar @$textlist, sprintf( "%s have %d lines", $nekotext, scalar @$textlist ) );
close $fh;

foreach my $f ( 0, 1 )
{
	foreach my $u ( @$textlist )
	{
		my $label = $f ? '->cat(utf8-flagged)' : '->cat(utf8)';
		my ($text0, $text1, $text2, $text3, $text4);

		$text0 = $u; chomp $text0;
		utf8::decode( $text0 ) if $f;

		$text1 = $sabatora->cat( \$text0 );
		ok( length $text1 >= length $text0, 
			sprintf( "[1] %s: %s => %s", $label, e($text0), e($text1) ) );

		$text2 = $sabatora->cat( \$text1 );
		ok( length $text2 >= length $text1, sprintf( "[2] %s", $label ) );

		$label = $f ? '->neko(utf8-flagged)' : '->neko(utf8)';
		$text3 = $sabatora->neko( \$text0 );
		ok( length $text3 >= length $text0, 
			sprintf( "[1] %s: %s => %s", $label, e($text0), e($text3) ) );

		$text4 = $sabatora->neko( \$text3 );
		is( $text4, $text3, sprintf( "[2] %s", $label ) );
	}
}

foreach my $e ( @$encoding )
{
	foreach my $t ( @$textlist )
	{
		my $label = sprintf( "->cat(%s)", $e );
		my ($text0, $text1, $text2, $text3, $text4);

		$text0 = $t; chomp $text0;
		Encode::from_to( $text0, 'utf8', $e );

		$text1 = $sabatora->cat( \$text0 );
		ok( length $text1 >= length $text0, 
			sprintf( "[1] %s: %s => %s", $label, e($text0,$e), e($text1,$e) ) );

		$text2 = $sabatora->cat( \$text1 );
		ok( length $text2 >= length $text1, sprintf( "[2] %s", $label ) );

		$label = sprintf( "->neko(%s)", $e );
		$text3 = $sabatora->neko( \$text0 );
		ok( length $text3 >= length $text0, 
			sprintf( "[1] %s: %s => %s", $label, e($text0,$e), e($text3,$e) ) );

		$text4 = $sabatora->neko( \$text3 );
		is( $text4, $text3, sprintf( "[2] %s", $label ) );
	}
}

foreach my $l ( @$langlist )
{
	$nekotext = sprintf( "t/cat-related-text.%s.txt", $l );
	ok( -T $nekotext, sprintf( "%s is textfile", $nekotext ) );
	ok( -r $nekotext, sprintf( "%s is readable", $nekotext ) );

	open( my $fh, '<', $nekotext ) || die 'cannot open '.$nekotext;
	$textlist = [ <$fh> ];
	ok( scalar @$textlist, 
		sprintf( "%s have %d lines", $nekotext, scalar @$textlist ) );
	close $fh;

	foreach my $e ( @$textlist )
	{
		my $label = sprintf( "->cat(%s)", $l );
		my ($text0, $text1, $text2, $text3, $text4);

		$text0 = $e;
		$text1 = $sabatora->cat( \$text0 );
		is( $text1, $text0,  
			sprintf( "[1] %s: %s => %s", $label, e($text0), e($text1) ) );
	}
}

foreach my $e ( '', '猫', 'ねこ', 'ネコ' )
{
	$nekotext = $sabatora->nyaa($e);
	ok( length $nekotext, sprintf( "->nyaa(%s) => %s", e($e), e($nekotext) ) );
}

$nekotext = 't/a-part-of-i-am-a-cat.ja.txt';
ok( -T $nekotext, sprintf( "%s is textfile", $nekotext ) );
ok( -r $nekotext, sprintf( "%s is readable", $nekotext ) );

open( $fh, '<', $nekotext ) || die 'cannot open '.$nekotext;
$textlist = [ <$fh> ];
ok( scalar @$textlist, 
	sprintf( "%s have %d lines", $nekotext, scalar @$textlist ) );
close $fh;

my $text0 = join( '', @$textlist );
my $text1 = $sabatora->straycat( $textlist );
my $text2 = $sabatora->straycat( \$text0 );

ok( length( $text1 ) > length( $text0 ) );
ok( length( $text2 ) > length( $text0 ) );

