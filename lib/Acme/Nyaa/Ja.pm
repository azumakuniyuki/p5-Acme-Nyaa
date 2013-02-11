package Acme::Nyaa::Ja;
use strict;
use warnings;
use utf8;
use Encode;

my $RxComma = qr/[、,]/;
my $RxPeriod = qr/[。.]/;
my $RxHiragana = qr/[あ-ん]/;
my $RxKatakana = qr/[ア-ン]/;
my $RxConversation = qr/[「『].+[」』]/;
my $RxEndOfSentence = qr/[!！?？(?:...)(?:。。。)(?:,,,)(?:、、、)…]+/;

my $Cats = [ '猫', 'ネコ', 'ねこ' ];
my $HiraganaNya = 'にゃ';
my $KatakanaNya = 'ニャ';
my $FightingCats = [
	'「マーオ」',
	'「マーーオ」',
	'「マーーーオ!!」',
	'「マーーーーオ!!!」',
];
my $HiraganaTails = [ 'にゃ', 'にゃー', 'にゃ〜', 'にゃぁ', 'にゃん', 'にゃーん', 'にゃ〜ん' ];
my $KatakanaTails = [ 'ニャ', 'ニャー', 'ニャ〜', 'ニャァ', 'ニャん', 'ニャーん', 'ニャ〜ん' ];
my $DoNotBecomeCat = [
	# See http://ja.wikipedia.org/wiki/モーニング娘。
	'モーニング娘。',
	'カントリー娘。',
	'ココナッツ娘。',
	'ミニモニ。',
	'エコモニ。',
	'ハロー!モーニング。',
	'エアモニ。',
	'モーニング刑事。',
	'モー娘。',
];

sub cat
{
	my $class = shift;
	my $text0 = shift;
	my $bless = ref $text0;

	return q() if( $bless ne '' && $bless ne 'SCALAR' );
	my $text1 = $bless eq 'SCALAR' ? $$text0 : $text0;
	return q() unless length $text1;

	my $sizeh = scalar @$HiraganaTails;
	my $sizek = scalar @$KatakanaTails;
	my $index = 0;
	my $lines = [ split( $RxPeriod, $text1 ) ];

	if( $text1 =~ m/($RxPeriod)/ )
	{ 
		# Perl::Critic found these violations in "lib/Acme/Nyaa/Ja.pm":
		# Don't modify $_ in list functions at line 61, column 2.  See page 114 of PBP.  (Severity: 5)
		foreach my $e ( @$lines ){ $e .= $1; }
	}

	foreach my $e ( @$lines )
	{
		next if $e =~ qr/\A$RxPeriod\z/;
		next if grep { $e eq $_ } @$DoNotBecomeCat;
		next if grep { $e =~ m/$_$RxPeriod?\z/ } @$HiraganaTails;
		next if grep { $e =~ m/$_$RxPeriod?\z/ } @$KatakanaTails;
		next if $e =~ m{\A[\x20-\x7E]+\z};

		if( $e =~ m/な($RxPeriod?)\z/ )
		{
			# な => にゃー
			$e =~ s/な($RxPeriod?)\z/$HiraganaNya$1/;
		}
		elsif( $e =~ m/ナ($RxPeriod?)\z/ )
		{
			# ナ => ニャー
			$e =~ s/ナ($RxPeriod?)\z/$HiraganaNya$1/;
		}
		elsif( $e =~ m/$RxHiragana$RxPeriod\z/ )
		{
			$index = int rand $sizek;
			$e =~ s/($RxPeriod)\z/$KatakanaTails->[ $index ]$1/;
		}
		elsif( $e =~ m/$RxKatakana$RxPeriod\z/ )
		{
			$index = int rand $sizeh;
			$e =~ s/($RxPeriod)\z/$HiraganaTails->[ $index ]$1/;
		}
		else
		{
			if( $e =~ m/($RxEndOfSentence)\z/ )
			{
				# ... => ニャー..., ! => ニャ!
				my $eos = $1;
				if( $e =~ m/$RxKatakana$RxEndOfSentence\z/ )
				{
					$index = int rand( $sizeh / 2 );
					$e =~ s/$RxEndOfSentence/$HiraganaTails->[ $index ]$eos/g;
				}
				else
				{
					$index = int rand( $sizek / 2 );
					$e =~ s/$RxEndOfSentence/$KatakanaTails->[ $index ]$eos/g;
				}
			}
			elsif( $e =~ m/$RxConversation\z/ )
			{
				# 0.5の確率で会話の後ろで猫が喧嘩をする
				if( $e =~ m/\A(.*$RxConversation\s*)($RxConversation.*)\z/ )
				{
					$index = int rand scalar @$FightingCats;
					$e = $1.$FightingCats->[ $index ].$2 if int(rand(10)) % 2;
				}
				$index = int rand scalar @$FightingCats;
				$e .= $FightingCats->[ $index ] if int(rand(10)) % 2;
			}
			else
			{
				$index = int rand $sizek;
				$e .= $KatakanaTails->[ $index ];
			}
		}
	}

	return join( '', @$lines );
}

sub neko
{
	my $class = shift;
	my $text0 = shift;
	my $bless = ref $text0;

	return q() if( $bless ne '' && $bless ne 'SCALAR' );
	my $text1 = $bless eq 'SCALAR' ? $$text0 : $text0;
	my $sizec = scalar @$Cats;
	return q() unless length $text1;

	my $map = {
		'神' => 'ネコ',
	};

	foreach my $e ( keys %$map )
	{
		next unless $text1 =~ m{$e};
		my $f = $map->{ $e };

		$text1 =~ s{\A[$e]\z}{$f};
		$text1 =~ s{\A[$e]($RxHiragana)}{$f$1};
		$text1 =~ s{\A[$e]($RxKatakana)}{$f$1};
		$text1 =~ s{($RxHiragana)[$e]($RxHiragana)}{$1$f$2}g;
		$text1 =~ s{($RxHiragana)[$e]($RxKatakana)}{$1$f$2}g;
		$text1 =~ s{($RxKatakana)[$e]($RxKatakana)}{$1$f$2}g;
		$text1 =~ s{($RxKatakana)[$e]($RxHiragana)}{$1$f$2}g;
		$text1 =~ s{($RxHiragana)[$e]($RxPeriod|$RxComma)?\z}{$1$f$2}g;
		$text1 =~ s{($RxKatakana)[$e]($RxPeriod|$RxComma)?\z}{$1$f$2}g;
	}

	return $text1;
}

1;

__END__
=encoding utf8

=head1 NAME

Acme::Nyaa - Convert texts like which a cat is talking in Japanese

=head1 SYNOPSIS

  use Acme::Nyaa;

  my $kijitora = Acme::Nyaa->new( 'language' => 'ja' );

  print $kijitora->cat( \'猫がかわいい。' ); # => 猫がかわいいニャー。
  print $kijitora->neko( \'神と和解せよ' ); # => ネコと和解せよ


=head1 DESCRIPTION
  
  Acme::Nyaa is a converter which translate Japanese texts to texts
  like which a cat talking.

=head1 METHODS

=over

=item new
  new() is a constructor of Acme::Nyaa

=item cat
  cat() is a converter that appends string "ニャー" at the end of
  each sentence.

=item neko
  neko() is a converter that replace a noun with 'ネコ'.

=back

=head1 AUTHOR

azumakuniyuki E<lt>perl.org [at] azumakuniyuki.orgE<gt>

=head1 SEE ALSO
L<Acme::Nyaa>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
