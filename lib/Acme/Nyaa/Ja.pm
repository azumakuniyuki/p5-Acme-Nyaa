package Acme::Nyaa::Ja;
use strict;
use warnings;
use utf8;
use Encode;
use Encode::Guess qw(shift-jis euc-jp 7bit-jis);;

my $RxComma = qr/[、,]/;
my $RxPeriod = qr/[。.]/;
my $RxConversation = qr/[「『].+[」』]/;
my $RxEndOfSentence = qr/[!！?？(?:...)(?:。。。)(?:,,,)(?:、、、)…]+/;
my $Cats = [ '猫', 'ネコ', 'ねこ' ];
my $HiraganaNya = 'にゃ';
my $KatakanaNya = 'ニャ';
my $FightingCats = [
	'「マーオ」',
	'「マーオ!」',
	'「マーーオ」',
	'「マーーオ!」',
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
	my $text1 = undef;
	my $bless = ref $text0;

	return q() if( $bless ne '' && $bless ne 'SCALAR' );
	$text1 = $bless eq 'SCALAR' ? $$text0 : $text0;
	return q() unless length $text1;

	my $cname = __PACKAGE__->_reckon( \$text1 );
	my $uflag = $cname eq 'utf8' ? utf8::is_utf8 $text1 : undef;

	return $text1 unless $cname;
	$text1 =  __PACKAGE__->_toutf8( $text1, $cname, $uflag );
	$text1 =~ s{($RxPeriod)}{$1\x1f}g;

	my $sizeh = scalar @$HiraganaTails;
	my $sizek = scalar @$KatakanaTails;
	my $index = 0;
	my $lines = [ split( /\x1F/, $text1 ) ];

	foreach my $e ( @$lines )
	{
		next if $e =~ qr/\A$RxPeriod\z/;
		next if grep { $e eq $_ } @$DoNotBecomeCat;
		next if grep { $e =~ m/$_$RxPeriod?\z/ } @$HiraganaTails;
		next if grep { $e =~ m/$_$RxPeriod?\z/ } @$KatakanaTails;
		next if grep { $e =~ m/$_$RxEndOfSentence?\z/ } @$HiraganaTails;
		next if grep { $e =~ m/$_$RxEndOfSentence?\z/ } @$KatakanaTails;
		next if grep { $e =~ m/$_\z/ } @$FightingCats;

		next if $e =~ m{\A[\x20-\x7E]+\z};
		next unless $e =~ m{[\p{InHiragana}\p{InKatakana}]+};

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
		elsif( $e =~ m/\p{InHiragana}$RxPeriod\z/ )
		{
			$index = int rand $sizek;
			$e =~ s/($RxPeriod)\z/$KatakanaTails->[ $index ]$1/;
		}
		elsif( $e =~ m/\p{InKatakana}$RxPeriod\z/ )
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
				if( $e =~ m/\p{InKatakana}$RxEndOfSentence\z/ )
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

	return __PACKAGE__->_utf8to( join( '', @$lines ), $cname, $uflag );
}

sub neko
{
	my $class = shift;
	my $text0 = shift;
	my $text1 = undef;
	my $bless = ref $text0;

	return q() if( $bless ne '' && $bless ne 'SCALAR' );
	$text1 = $bless eq 'SCALAR' ? $$text0 : $text0;
	return q() unless length $text1;

	my $cname = __PACKAGE__->_reckon( \$text1 );
	my $uflag = $cname eq 'utf8' ? utf8::is_utf8 $text1 : undef;

	return $text1 unless $cname;
	$text1 = __PACKAGE__->_toutf8( $text1, $cname, $uflag );

	my $map = {
		'神' => 'ネコ',
	};

	foreach my $e ( keys %$map )
	{
		next unless $text1 =~ m{$e};
		my $f = $map->{ $e };

		$text1 =~ s{\A[$e]\z}{$f};
		$text1 =~ s{\A[$e](\p{InHiragana})}{$f$1};
		$text1 =~ s{\A[$e](\p{InKatakana})}{$f$1};
		$text1 =~ s{(\p{InHiragana})[$e](\p{InHiragana})}{$1$f$2}g;
		$text1 =~ s{(\p{InHiragana})[$e](\p{InKatakana})}{$1$f$2}g;
		$text1 =~ s{(\p{InKatakana})[$e](\p{InKatakana})}{$1$f$2}g;
		$text1 =~ s{(\p{InKatakana})[$e](\p{InHiragana})}{$1$f$2}g;
		$text1 =~ s{(\p{InHiragana})[$e]($RxPeriod|$RxComma)?\z}{$1$f$2}g;
		$text1 =~ s{(\p{InKatakana})[$e]($RxPeriod|$RxComma)?\z}{$1$f$2}g;
	}

	return __PACKAGE__->_utf8to( $text1, $cname, $uflag );
}

sub _reckon
{
	my $class = shift;
	my $text0 = shift;
	my $bless = ref $text0;

	my $text1 = $bless eq 'SCALAR' ? $$text0 : $text0;
	return q() unless length $text1;

	my $guess = Encode::Guess->guess( $text1 );
	return q() unless ref $guess;
	return $guess->name;
}

sub _toutf8
{
	my $class = shift;
	my $text0 = shift // return q();
	my $cname = shift || __PACKAGE__->_reckon( \$text0 );
	my $uflag = shift // 0;

	return $text0 unless $cname;
	Encode::from_to( $text0, $cname, 'utf8' ) if $cname ne 'utf8';
	$uflag = utf8::is_utf8($text0);
	utf8::decode $text0 unless $uflag;

	return $text0;
}

sub _utf8to
{
	my $class = shift;
	my $text0 = shift // return q();
	my $cname = shift || return $text0;
	my $uflag = shift // 0;

	utf8::encode $text0 if( $uflag == 0 && utf8::is_utf8 $text0 );
	Encode::from_to( $text0, 'utf8', $cname ) if $cname ne 'utf8';

	return $text0;
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
