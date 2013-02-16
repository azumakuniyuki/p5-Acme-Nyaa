use strict;
use utf8;
use Test::More 'tests' => 1290;
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
my $sabatora = Acme::Nyaa->new( 'language' => 'ja' );

isa_ok( $sabatora, 'Acme::Nyaa' );
is( $sabatora->{'language'}, 'ja', '->language() = ja' );

can_ok( 'Acme::Nyaa::Ja', 'cat' );
can_ok( 'Acme::Nyaa::Ja', 'neko' );
can_ok( 'Acme::Nyaa::Ja', 'nyaa' );

can_ok( 'Acme::Nyaa::Ja', '_reckon' );
can_ok( 'Acme::Nyaa::Ja', '_toutf8' );
can_ok( 'Acme::Nyaa::Ja', '_utf8to' );

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

$nekotext = q();
$nekotext = $sabatora->nyaa();
ok( length $nekotext, sprintf( "->nyaa() => %s", $nekotext ) );

