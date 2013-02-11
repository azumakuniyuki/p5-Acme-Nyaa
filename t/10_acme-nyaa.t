use strict;
use utf8;
use Test::More 'tests' => 9;

BEGIN { use_ok 'Acme::Nyaa' }

my $kijitora = Acme::Nyaa->new;
my $language = [ 'ja' ];

can_ok( 'Acme::Nyaa', 'new' );
can_ok( 'Acme::Nyaa', 'cat' );
can_ok( 'Acme::Nyaa', 'neko' );
can_ok( 'Acme::Nyaa', 'loadmodule' );
isa_ok( $kijitora, 'Acme::Nyaa' );
is( $kijitora->{'language'}, 'ja' );

foreach my $e ( @$language )
{
	$kijitora = Acme::Nyaa->new( 'language' => $e );
	isa_ok( $kijitora, 'Acme::Nyaa' );
	is( $kijitora->{'language'}, $e );
}


